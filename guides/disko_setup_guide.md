# Disko setup guide

A design guide for replacing this repo's hand-generated disk layout (`hosts/<host>/hardware-configuration.nix`'s `fileSystems`/`swapDevices`) with a declarative [disko](https://github.com/nix-community/disko) configuration — the roadmap item in `README.md`: *"Declarative disk partitioning via disko, instead of the manually generated hardware-configuration.nix"*.

This document is a **design guide, not yet an implementation** — it describes exactly what the `.nix` files should look like, but applying them has to wait until there's real hardware to target (`mrnix` isn't deployed yet; `worknix` doesn't exist yet either — see `work_setup_guide.md`).

---

## Why disko, and why this layout

Today's `hosts/mrnix/hardware-configuration.nix` (produced by `nixos-generate-config`) hand-encodes the disk layout as static UUIDs:

```nix
fileSystems."/"     = { device = "/dev/disk/by-uuid/..."; fsType = "btrfs"; };
fileSystems."/boot" = { device = "/dev/disk/by-uuid/..."; fsType = "vfat"; options = [ "fmask=0077" "dmask=0077" ]; };
swapDevices = [ { device = "/dev/disk/by-uuid/..."; } ];
```

This only records the *result* of partitioning, not the *intent* — there's no record of why the swap partition is the size it is, and the layout can't be replayed onto different/future hardware. disko flips this around: you declare the partition scheme once, and disko both formats the disk to match it *and* generates the equivalent `fileSystems`/`swapDevices` NixOS options automatically, so they never need to be hand-written again.

**Requested layout:**
1. `boot` — fixed size, EFI system partition.
2. `swap` — sized **RAM + 1GiB** (headroom for safe hibernation/suspend-to-disk).
3. `root` — everything left over, btrfs.

**Partition order matters**: `root` is declared as `100%` of whatever space remains, so it must be the *last* partition disko allocates. Order is therefore boot → swap → root.

---

## The one-time RAM → swap-size calculation

The RAM-based sizing only needs to happen **once, at the moment the disk is actually partitioned** — not on every subsequent `nixos-rebuild switch`. Once the swap partition physically exists at some size, the running system just references it (by disko-managed device path), the same way `swapDevices` references a UUID today; nothing about day-to-day rebuilds needs to re-read `/proc/meminfo`.

This also avoids a real cost: if the swap size were instead computed *inside* the flake via `builtins.readFile /proc/meminfo` (to be "always dynamic"), every `nix flake check` / `nixos-rebuild switch` / disko invocation would need `--impure` forever, and would only be correct if evaluation happens to run on the real target machine (not true for e.g. a remote builder). Computing once and writing the literal result into `disko.nix` sidesteps all of that — and it's exactly the pattern this repo already uses for `hardware-configuration.nix` (generate once from real hardware, commit the result).

On the target machine (e.g. from a NixOS live ISO), before formatting:

```sh
awk '/MemTotal/ { printf "%.0fG\n", $2/1024/1024 + 1 }' /proc/meminfo
# e.g. 16 GiB RAM -> 17G
```

Paste the result into `disko.nix`'s `swap.size` as a plain string literal.

This is a manual step today. It's designed to become a single line inside the future on-boot auto-install script (README roadmap items 4–5, "plug in a USB stick... boot... install... reboot — done") without changing anything else about the design — the auto-installer would just run this same `awk` line and template it into `disko.nix` (or pass it directly to disko) before invoking `nixos-install`, instead of a human doing it by hand.

---

## File changes (design — not yet applied)

### 1. `flake.nix` — add the `disko` input

```nix
inputs = {
  nixpkgs.url = "nixpkgs/nixos-26.05";
  home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

And add it to the `mrnix` module list:

```nix
outputs = { self, nixpkgs, home-manager, disko, ... }:
  let lib = nixpkgs.lib; in {
    nixosModules.base = import ./modules/base.nix;

    nixosConfigurations = {
      mrnix = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/mrnix
          self.nixosModules.base
          home-manager.nixosModules.default
          disko.nixosModules.disko
        ];
      };
    };
  };
```

### 2. New file `hosts/mrnix/disko.nix`

```nix
{ ... }:
{
  disko.devices = {
    disk.main = {
      device = "/dev/PLACEHOLDER"; # TODO: set to the real device once mrnix is on real hardware, e.g. /dev/nvme0n1
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "fmask=0077" "dmask=0077" ];
            };
          };
          swap = {
            size = "PLACEHOLDER"; # TODO: RAM + 1GiB, computed once at install time (see above) — e.g. "17G"
            content = {
              type = "swap";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "btrfs";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
```

Import it in `hosts/mrnix/default.nix` alongside `hardware-configuration.nix`:

```nix
{ ... }:
{
  networking.hostName = "mrnix";

  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];
}
```

### 3. Trim `hosts/mrnix/hardware-configuration.nix`

Remove the parts disko now generates automatically (`fileSystems."/"`, `fileSystems."/boot"`, `swapDevices`). Keep everything else — disko doesn't detect kernel modules or CPU vendor, so this file still legitimately owns those:

```nix
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "ehci_pci" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
```

(The kernel-module list above is only valid for the exact hardware it was scanned from — re-run `nixos-generate-config` on the real target machine and keep just its `boot.initrd.*`/`boot.kernelModules`/`hardware.*` lines, discarding the `fileSystems`/`swapDevices` part it also produces, since disko owns that now.)

---

## Install-time sequence

Once there's real hardware to target and the `PLACEHOLDER`s above are filled in:

1. Boot a NixOS live ISO on the target machine.
2. Run the RAM calculation, edit `disko.nix`'s `swap.size` accordingly. Set `disk.main.device` to the real device (check with `lsblk`).
3. Partition and format: `nix run github:nix-community/disko -- --mode destroy,format,mount --flake .#mrnix`
4. Generate a fresh `hardware-configuration.nix` for the kernel-module/CPU bits: `nixos-generate-config --no-filesystems --root /mnt` (or hand-copy the relevant lines as above).
5. Install: `nixos-install --flake .#mrnix`
6. Reboot into the new system.

---

## Explicit non-goals of this guide

- No btrfs subvolumes (`@`, `@home`, `@snapshots`, etc.) — kept as a single filesystem matching the current layout. Worth considering later if snapshotting becomes a goal, but not part of this change.
- No actual `.nix` files were created by this guide — this is the design to implement once real hardware exists.
- The fully-automated on-boot USB installer (README roadmap items 4–6) is a separate, later step; this guide only fixes the disko *design* it will eventually call into.

## Verification (once implemented)

- `nix flake check` should pass with the new `disko` input and `hosts/mrnix/disko.nix` wired in.
- Sanity-check `disko.nix` against disko's documented schema (`disko.devices.disk.<name>.content.partitions.<name>`, `type = "gpt"`, ESP `type = "EF00"`, `content.type = "filesystem" | "swap"`) before trusting it to run against a real disk.
- On real hardware: confirm `lsblk`/`blkid` after formatting shows the expected three partitions, boot succeeds, `free -h` shows swap active at the expected size, and hibernation (if used) works with the RAM+1GiB margin.
