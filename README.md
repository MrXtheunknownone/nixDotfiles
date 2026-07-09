# nixDotfiles

My personal NixOS + home-manager flake for `mrnix`, my desktop — migrating it off a hand-maintained Arch Linux + Hyprland setup (previously tracked in [`myDotfiles`](https://github.com/MrXtheunknownone/myDotfiles)) onto something declarative.

The machine is an AMD CPU + NVIDIA GPU desktop running Hyprland on Wayland, with a single ultrawide monitor. This repo is a work in progress — it hasn't been switched to on real hardware yet.

Scope note: this is currently a single-host personal flake for `mrnix` only. I've also got a work machine; combining the two into one flake is a future step, not something this repo tries to do yet.
At the moment this setup runs on a machine without a nvidia gpu which proves that it works for now, but there will be the need for some flag like NVIDIA_ENABLED maybe

## Status

### Core system
- [x] Flake with pinned `nixpkgs` + `home-manager`, single `mrnix` host
- [x] Hardware config generated from the real disk layout (btrfs `/`, vfat `/boot`, swap)
- [x] Host/module split (`hosts/<name>/` + `modules/base.nix`, exported as `nixosModules.base`) so this flake can be reused as an input by other flakes without pulling in host-specific hardware config
- [x] Display manager (`greetd`) to actually start a Hyprland session
- [?] NVIDIA driver config (`hardware.nvidia.*`, `hardware.graphics.enable`)
- [x] Audio (`services.pipewire.*` is never enabled)
- [x] Docker (`virtualisation.docker.enable`)
- [?] Printing (`cups`) and firewall
- [ ] Declarative disk partitioning via [disko](https://github.com/nix-community/disko), instead of the manually generated `hardware-configuration.nix`
- [x] Multi-host structure to combine this with a separate work-machine flake — done via the `nixosModules.base` export; a private `work-credentials` flake (isys GitLab) consumes it for a second host, `worknix`. See [`guides/work_setup_guide.md`](guides/work_setup_guide.md).

### Desktop (Hyprland)
- [x] Hyprland + waybar + wofi + hyprlock/hypridle/hyprpaper + kitty wired in as real dotfiles, not defaults
- [ ] Desktop portals + tray tooling (`xdg-desktop-portal-hyprland`/`-gtk`, `nwg-look`, `network-manager-applet`)
- [ ] Cursor theme (`nordic_cursors_scalable`) config
- [ ] GTK theme settings aren't captured (set at runtime via `nwg-look` on the real machine, no `settings.ini` tracked)
- [ ] `home.nix` hardcodes the hyprpaper monitor to `eDP-1` hyprland does its own monitor config
- [ ] swaync notification config

### Shell & packages
- [x] Core app package lists: browser, creativity, editor, security, social (minus a few stragglers), utils baseline
- [ ] Missing packages: unzip/zip, swayimg, (steam)
- [ ] Gitconfig port to nix
- [ ] User shell/password and locale/keymap (`de` keyboard layout) not set

### Roadmap: bootable USB install
Long-run goal: plug in a USB stick, let it boot, have it partition the disk and install NixOS from this flake, reboot — done (maybe setting the account password by hand).

1. [ ] Finish the base `mrnix` config into a real, working desktop (greetd, NVIDIA, audio, docker, printing/firewall)
2. [ ] Adopt disko for declarative disk partitioning, replacing the manually generated `hardware-configuration.nix` filesystem block
3. [ ] Prove the flake installs cleanly from scratch (e.g. in a VM) with `nixos-install --flake` against the disko layout
4. [ ] Build a custom installer ISO (e.g. via `nixos-generators`) bundling this flake + disko config
5. [ ] Add an on-boot install script/service to the ISO that runs disko partitioning + `nixos-install` automatically, with password setup as the only manual step
6. [ ] Test the full plug-in-USB → auto-install → reboot flow end-to-end in a VM before trying it on real hardware

### Deferred by choice
- Waydroid and winboat-bin
- Porting oh-my-zsh/Powerlevel10k as-is — moving to Starship instead
- AUR-only packages without a nixpkgs equivalent — dropped rather than custom-packaged
