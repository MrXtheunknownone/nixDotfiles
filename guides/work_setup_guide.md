# Work setup guide: `worknix`

A complete, actionable guide for turning the physical work laptop into a NixOS machine called **`worknix`**, assembled from two repositories:

1. **`nixDotfiles`** (this repo, personal GitHub) — general dev tooling, desktop setup, home-manager config. Stays fully self-contained and buildable on its own, with zero knowledge of the second repo.
2. **A new `work-credentials` repo** (isys's self-hosted GitLab, **private**) — company-specific access only: VPN, internal server SSH access, Atlassian token, Mattermost. Never lives on GitHub, so a compromised personal account can't be a path into company infrastructure.

If you only read one section, read [Architecture](#architecture) — everything else is the mechanical follow-through of that one decision.

---

## Architecture

**Requirement:** be able to (a) build a system from just `nixDotfiles` alone, and (b) build `worknix` from `nixDotfiles` + the company repo combined.

**Why the company repo can't simply be an input of `nixDotfiles`:** Nix flakes fetch *every* declared input as soon as the flake is evaluated — regardless of which output you actually build. If `nixDotfiles/flake.nix` listed the private GitLab repo as an input, then even building the plain `mrnix` config would require fetching that private repo. That breaks standalone buildability, and it leaks (via `flake.lock`) that a private company repo exists at all, from inside a personal repo.

**The fix — flip the dependency direction:**

```
nixDotfiles (GitHub, public/personal)          work-credentials (GitLab, private)
┌────────────────────────────┐                 ┌───────────────────────────────────┐
│ flake.nix                  │                 │ flake.nix                         │
│  inputs: nixpkgs,          │  <── input ──   │  inputs: nixpkgs, home-manager,   │
│          home-manager      │     (public,    │          sops-nix, nixDotfiles    │
│                            │      one-way)   │                                   │
│  nixosModules.base         │                 │  nixosConfigurations.worknix =    │
│  nixosConfigurations.mrnix │                 │    modules = [                    │
│    = base + hosts/mrnix    │                 │      hosts/worknix                │
└────────────────────────────┘                 │      nixDotfiles.nixosModules.base│
                                               │      ./modules/{vpn,internal-ssh, │
                                               │        atlassian,mattermost}.nix  │
                                               │      sops-nix secrets             │
                                               └───────────────────────────────────┘
```

- `nixDotfiles` never references the company repo. It exports its shared config as a reusable NixOS module (`nixosModules.base`) and keeps building its own `mrnix` standalone, exactly as today.
- `work-credentials` is the one with the extra inputs, including `nixDotfiles` itself (a public GitHub input — safe, no secrets flow that direction).

Result:
- **"Build a system with just nixDotfiles"** → build from inside `nixDotfiles`, its own `mrnix` output. Zero company awareness, works even without any GitLab access.
- **"Build worknix with both"** → build from inside `work-credentials`, whose `nixosConfigurations.worknix` output pulls `nixDotfiles` in and layers the company modules on top.

This requires one small, one-time refactor of `nixDotfiles`, covered next.

---

## Company access inventory

What needs to end up in `work-credentials`, gathered from the current WSL Arch + Windows setup:

| Item | Detail | Currently lives |
|---|---|---|
| VPN | Securepoint SSL VPN, profile **"iSys neu"** (`AppData\Roaming\Securepoint SSL VPN\config\iSys neu\iSys neu.ovpn`) — standard OpenVPN protocol under the hood, no proprietary Linux client needed | Windows |
| Internal server SSH | Shared `id_ed25519`, root login to ~8 `*.isys-software.de` VMs (skillsDB test/qa/preprod/prod, wp_isys, pmTool test/prod, isysAi test/prod/runner, apprenticeship-program VM) | WSL `~/.ssh/` |
| GitLab SSH | Dedicated `id_ed25519_gitlab` | WSL `~/.ssh/` |
| Atlassian | Jira/Confluence API token (`~/.ssh/atlassian/timsAccessToken`) | WSL |
| Mattermost | Company chat, `mattermost.isys.de`, native client package | new |
| Company email | Thunderbird account config (server/auth only, not mail data) | Windows |
| Credential vault | `Passwörter.kdbx` (KeePassXC) — referenced only, never migrated into any repo | Windows |

**Explicitly excluded** from `work-credentials` (confirmed out of scope):
- AWS/Azure config (`~/.aws`, `~/.azure` — currently empty).
- `jiratui-git` (was a one-off test, not a real dependency).
- All dev tooling — JDKs, IDEs, Gradle/Maven, DBeaver, Postman, Docker, `glab`, printer drivers, Office. This belongs to `nixDotfiles` (or a future dedicated dev flake), even for tools that happen to be used for work.
- Berufsschule-related material (old VDI VPN profile, WebUntis, etc.) — no longer applicable.
- Windows desktop shortcuts — not being transferred as-is.

**Not committed to `work-credentials`, even encrypted:**
- The KeePassXC vault itself — keep syncing it however it's synced today.
- The `id_ed25519` *private* key — copy it onto `worknix` out-of-band, don't commit it (even encrypted) unless there's a strong reason to later.

---

## Part 1 — Refactor `nixDotfiles` (this repo)

Today, `configuration.nix` mixes host-specific bits (`networking.hostName = "mrnix"`, the `./hardware-configuration.nix` import) with generic/shared bits (package modules, home-manager wiring, locale, users). To be reusable by `work-credentials` for a *different* physical machine, those need to be split.

### Target layout

```
nixDotfiles/
  flake.nix                        # updated — see below
  hosts/
    mrnix/
      default.nix                  # networking.hostName = "mrnix"; imports = [ ./hardware-configuration.nix ];
      hardware-configuration.nix   # moved as-is from repo root
  modules/
    base.nix                       # everything else from today's configuration.nix
  packages/                        # unchanged
  home/                            # unchanged
```

### `modules/base.nix` (new — moved out of `configuration.nix`)

Everything currently in `configuration.nix` **except** `networking.hostName` and the `hardware-configuration.nix` import:

```nix
{ config, lib, pkgs, ... }:
{
  imports = [
    ./packages/browser.nix
    ./packages/creativity.nix
    ./packages/editor.nix
    ./packages/fonts.nix
    ./packages/git.nix
    ./packages/hypr.nix
    ./packages/media.nix
    ./packages/security.nix
    ./packages/shell.nix
    ./packages/social.nix
    ./packages/sound.nix
    ./packages/utils.nix
  ];

  home-manager.users.tim = import ./home/home.nix;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  services.libinput.enable = true;

  users.users.tim = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Amsterdam";
  system.stateVersion = "26.05";
}
```

Note the relative `./packages/...` and `./home/home.nix` paths only work correctly if `modules/base.nix` is consumed with the right base path — since this file lives one directory deeper than the old `configuration.nix`, either move `packages/` and `home/` to sit alongside it under `modules/`, or (simpler, less churn) keep `packages/` and `home/` at the repo root and adjust the paths in `base.nix` to `../packages/...` and `../home/home.nix`. Pick whichever and be consistent — the snippet above assumes `packages/`/`home/` stay at the repo root, so use `../packages/...` / `../home/home.nix` in the real file.

### `hosts/mrnix/default.nix` (new)

```nix
{ ... }:
{
  networking.hostName = "mrnix";
  imports = [ ./hardware-configuration.nix ];
}
```

Move the existing `hardware-configuration.nix` into `hosts/mrnix/` unchanged.

### `flake.nix` (updated)

```nix
{
  description = "Private Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let lib = nixpkgs.lib; in {
      nixosModules.base = import ./modules/base.nix;

      nixosConfigurations = {
        mrnix = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/mrnix
            self.nixosModules.base
            home-manager.nixosModules.default
          ];
        };
      };
    };
}
```

This is a pure refactor — `mrnix` still builds exactly as before, standalone, with no new inputs added to this repo.

### Verify the refactor

```sh
cd nixDotfiles
nix flake check
nix build .#nixosConfigurations.mrnix.config.system.build.toplevel
```

Both should succeed with no behavioral change from before the refactor.

---

## Part 2 — New `work-credentials` repo (isys GitLab, private)

### Target layout

```
work-credentials/
  flake.nix
  hosts/
    worknix/
      hardware-configuration.nix    # generated once on the real laptop — placeholder until then
      default.nix                   # networking.hostName = "worknix"; imports = [ ./hardware-configuration.nix ];
  modules/
    vpn.nix                         # OpenVPN connection using the "iSys neu" profile
    internal-ssh.nix                # ~/.ssh/config host aliases + public keys for the *.isys-software.de VMs + gitlab-isys
    atlassian.nix                   # wires the Jira/Confluence token in via a sops secret
    mattermost.nix                  # native Mattermost client package
  secrets/
    secrets.yaml                    # sops-nix encrypted
  .sops.yaml                        # age recipients
  README.md
```

### `flake.nix`

```nix
{
  description = "isys work credentials for worknix";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    nixDotfiles.url = "github:MrXtheunknownone/nixDotfiles";  # adjust to the actual GitHub path
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, nixDotfiles, ... }:
    let lib = nixpkgs.lib; in {
      nixosConfigurations.worknix = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/worknix
          nixDotfiles.nixosModules.base
          home-manager.nixosModules.default
          sops-nix.nixosModules.sops
          ./modules/vpn.nix
          ./modules/internal-ssh.nix
          ./modules/atlassian.nix
          ./modules/mattermost.nix
        ];
      };
    };
}
```

### `modules/vpn.nix` (sketch)

The `.ovpn` profile is standard OpenVPN, so it can be wired in directly. Exact shape depends on whether the profile embeds cert/key material inline (`<cert>…</cert>`, `<key>…</key>` blocks) — check this before writing the real file:

```nix
{ config, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.openvpn ];

  sops.secrets."vpn/isys-neu-ovpn" = {
    sopsFile = ../secrets/secrets.yaml;
  };

  services.openvpn.servers.isysNeu = {
    config = "config ${config.sops.secrets."vpn/isys-neu-ovpn".path}";
    autoStart = false; # connect on demand
  };
}
```

If the profile is simple enough (no embedded secrets) it could instead go through NetworkManager (`networkmanager-openvpn`) for a GUI toggle — decide once the actual file contents are checked.

### `modules/internal-ssh.nix` (sketch)

```nix
{ ... }:
{
  programs.ssh.extraConfig = ''
    Host gitlab-isys
      HostName gitlab.isys-software.de
      User git
      IdentityFile ~/.ssh/id_ed25519_gitlab

    Host skillsDBTest-vm
      HostName skillsdbtest01.isys-software.de
      User root
      IdentityFile ~/.ssh/id_ed25519

    # ... remaining *.isys-software.de hosts, copied from the current ~/.ssh/config
  '';
}
```

Only host aliases and paths to keys go here — the actual private key files are placed on `worknix` out-of-band, not generated or stored by this module.

### `modules/atlassian.nix` (sketch)

```nix
{ config, ... }:
{
  sops.secrets."atlassian/api-token" = {
    sopsFile = ../secrets/secrets.yaml;
  };
  # consumed as $ATLASSIAN_API_TOKEN or similar by whatever CLI/tool needs it —
  # decide the exact wiring once a consumer (e.g. a Jira CLI) is chosen.
}
```

### `modules/mattermost.nix`

```nix
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.mattermost-desktop ];
  # Server: https://mattermost.isys.de
}
```

Confirm `mattermost-desktop` (or whatever the current nixpkgs attribute is) exists in the pinned `nixpkgs` release before relying on it.

### `.sops.yaml` (sketch)

```yaml
keys:
  - &worknix age1...   # derived from worknix's SSH host key via ssh-to-age, or a dedicated age key
creation_rules:
  - path_regex: secrets/secrets\.yaml$
    key_groups:
      - age:
          - *worknix
```

---

## Part 3 — Full bootstrap sequence

1. **Refactor `nixDotfiles`** per Part 1. Confirm `nix flake check` and a successful `mrnix` build.
2. **Create the GitLab project**: a new **private** project on isys's self-hosted GitLab, under your own namespace, named e.g. `work-credentials`. Not a fork/mirror of anything on GitHub.
3. **SSH access to GitLab**: reuse `id_ed25519_gitlab` (already scoped to GitLab), or generate a fresh keypair and add the public key under GitLab → Preferences → SSH Keys. Add a `Host gitlab-isys` entry to `~/.ssh/config`.
4. **Scaffold `work-credentials`** per Part 2, `git init`, add the GitLab remote, first commit, push. *(You do the actual git operations — see note below.)*
5. **Check the "iSys neu" `.ovpn` profile's structure** — inline embedded certs/keys vs. references to separate files — before finalizing `modules/vpn.nix` and what exactly goes into `secrets.yaml`.
6. **Set up sops-nix**:
   - Once `worknix` exists and has an SSH host key, derive its age public key with `ssh-to-age` (or generate a dedicated `age-keygen` keypair and place the private key on the machine out-of-band).
   - Record the recipient(s) in `.sops.yaml`.
   - `sops secrets/secrets.yaml` to create/edit the encrypted file: VPN cert/key material, Atlassian token.
7. **Write the four company modules** (`vpn.nix`, `internal-ssh.nix`, `atlassian.nix`, `mattermost.nix`) for real, replacing the sketches above.
8. **CI**: add a minimal `.gitlab-ci.yml` running `nix flake check` on merge requests.
9. **Branch protection**: protect `main` on the GitLab project (require MR, no force-push) — this repo grants access to production infrastructure.
10. **On the real laptop**: boot a NixOS installer, partition disks, generate `hosts/worknix/hardware-configuration.nix`, commit it.
11. **First activation**: place the sops private key material on the machine out-of-band, then either `sudo nixos-install --flake .#worknix` (fresh install) or `sudo nixos-rebuild switch --flake .#worknix` (existing system).
12. **Verify end-to-end**: VPN connects via the migrated "iSys neu" profile, SSH to at least one internal VM works, Mattermost launches and points at `mattermost.isys.de`, the Atlassian token is readable by whatever consumes it.

> **Note on git operations:** every `git init`/commit/push mentioned above is something *you* run yourself — nothing in this repo or process should auto-commit on your behalf.

---

## Open items (not blocking, worth revisiting later)

- Rotating the shared root `id_ed25519` into per-host keys — right now one key is root on ~8 production systems, which is a broader blast radius than ideal.
- Whether to add a personal admin age key to `.sops.yaml` for secret recovery if `worknix`'s host key is ever lost.
- Confirm the exact nixpkgs attribute name for a Mattermost desktop client, and decide plain `services.openvpn` vs. NetworkManager-based VPN wiring, once the `.ovpn` file's contents are actually inspected.

## Verification checklist

- [ ] `nix flake check` passes in both `nixDotfiles` and `work-credentials`.
- [ ] `mrnix` still builds standalone from `nixDotfiles` alone.
- [ ] `worknix` builds from `work-credentials` (pulling in `nixDotfiles` as an input).
- [ ] On real hardware: VPN connects, SSH to one internal VM succeeds, Mattermost opens and points at `mattermost.isys.de`, Atlassian token is usable.
