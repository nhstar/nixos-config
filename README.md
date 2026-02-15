# Star’s NixOS Flake (multi-host + Home Manager)

This repo is a **multi-host NixOS flake** with a shared “common” baseline, per-host configuration folders, and **Home Manager** integrated for user-space apps and settings.  It targets **x86_64-linux** and follows `nixos-unstable`, with an extra `nixos-25.11` input available as a “stable” package set.

---

## What’s in here

### Repo layout

```
.
├── flake.nix
├── flake.lock
├── common/
│   ├── base.nix
│   ├── users.nix
│   ├── bluetooth.nix
│   ├── sound.nix
│   ├── services.nix
│   ├── firewall.nix
│   ├── fonts.nix
│   └── desktop/
│       ├── plasma.nix
│       └── hyprland.nix
├── home/
│   └── star.nix
└── hosts/
    ├── mercury/
    │   ├── configuration.nix
    │   └── hardware-configuration.nix
    ├── pulsar/
    │   ├── configuration.nix
    │   └── hardware-configuration.nix
    ├── venus/
    │   ├── configuration.nix
    │   ├── hardware-configuration.nix
    │   └── services.nix
    └── terra/
        ├── configuration.nix
        ├── hardware-configuration.nix
        ├── services.nix
        └── storage.nix
```

### How the flake builds hosts

`flake.nix` defines two things:

* **`nixosConfigurations.<host>`**
  Used by `nixos-rebuild --flake .#terra` style commands.

* **`homeConfigurations."star@<host>"`**
  Used by `home-manager switch --flake .#star@terra` to update just Home Manager, without touching NixOS generations.

There’s a small helper, `mkHost`, that composes modules in this order:

1. (Optional) overlay placeholder module (currently empty)
2. `common/*` baseline modules
3. the host’s `hosts/<name>/configuration.nix`
4. **auto-import** `hosts/<name>/services.nix` *if it exists*
5. Home Manager module + `home/star.nix`
6. sets `networking.hostName = <name>`

---

## Common modules (shared across hosts)

### `common/base.nix`

Baseline “this is a NixOS box” stuff:

* enables flakes and `nix-command`
* weekly GC, keeps 14 days
* `systemd-boot`, Plymouth theme, latest kernel
* timezone/locale
* NetworkManager
* a small set of baseline packages (vim, curl, git, flatpak, etc.)
* `programs.zsh.enable = true`
* `system.stateVersion = "25.05"`

### `common/users.nix`

Creates the `star` user, sets Zsh as the shell, and adds groups including `wheel`, `libvirtd`, and `docker`.

### `common/bluetooth.nix`

Turns on Bluetooth, powers it on at boot, and enables experimental features.

### `common/sound.nix`

PipeWire setup (PulseAudio disabled, PipeWire + WirePlumber enabled, ALSA 32-bit enabled).

### `common/services.nix`

“Normal workstation services,” including:

* dbus, fwupd, fstrim
* printing (gutenprint + hplip)
* flatpak service enabled
* OpenSSH enabled on port **2702**

### `common/firewall.nix`

Firewall enabled, allows TCP **24800** (Deskflow server).

### `common/fonts.nix`

Noto + Nerd Fonts + a few monospace favorites (Hack, JetBrains Mono, Fira Code, etc.), with fontconfig tuning.

### `common/desktop/*`

Desktop is **opt-in per host** via imports:

* `common/desktop/plasma.nix`
  Plasma 6 + SDDM (Wayland), KDE portal, KWallet PAM wiring, plus a few KDE utilities.

* `common/desktop/hyprland.nix`
  Hyprland + Wayland tools (waybar, wlogout, wl-clipboard, hyprpaper, hypridle, etc.) and a user service for `hyprnotify`.  Also enables the Hyprland portal (and keeps KDE portal available if Plasma is also present).

---

## Host breakdown

### `mercury` and `pulsar`

Minimal, “hardware + identity” hosts:

* imports only `hardware-configuration.nix`
* sets a placeholder `networking.hostId`
* enables `services.tlp`

### `venus`

Desktop “everything” host:

* imports both `plasma.nix` and `hyprland.nix`
* sets `networking.hostId = "00000003"`
* overrides portal defaults to prefer KDE generally, but routes screencast/remote-desktop to Hyprland

Also has `hosts/venus/services.nix`, which:

* enables **Docker**
* explicitly forces **Podman off**
* keeps libvirt enabled
* adds `docker-compose`

### `terra`

Laptop-ish workstation host, Plasma-first:

* imports `plasma.nix` and `storage.nix`
* portal defaults are KDE-focused
* power management tweaks:

  * forces `power-profiles-daemon` off
  * enables TLP
  * kernel param `mem_sleep_default=s2idle`
  * lid policy: suspend on AC, suspend-then-hibernate on battery after 1 hour
* NVIDIA driver config (nouveau blacklisted)
* enables bolt (Thunderbolt), thermald
* disables fprintd
* includes initrd secret mapping for `/etc/keys/keyfile`

Also has `hosts/terra/services.nix`, which:

* forces **Docker off**
* enables **Podman** (with dockerCompat wrapper)
* adds the usual container toolchain (podman-compose, buildah, skopeo, etc.)
* keeps libvirt enabled, and enables `qemu.swtpm` for TPM-backed VMs

`hosts/terra/storage.nix` is the “real” disk layout definition for Terra:

* initrd LUKS unlock for `root` and `home`
* Btrfs subvols for `/`, `/nix`, `/var`, `/var/log`, and `/home` (home uses a labeled filesystem)
* swap device labeled `SWAP`, and uses it for resume

---

## Home Manager (`home/star.nix`)

This is where user-space apps live (browser, editors, chat apps, dev tools, etc.).  Highlights:

* imports the LazyVim Home Manager module from the `lazyvim-nix` flake input
* configures VS Code extensions
* configures AnyRun
* sets user session variables like `EDITOR=nvim` and `TERMINAL=kitty`
* defines a user systemd service to run Nextcloud in the background
* `home.stateVersion = "25.05"`

Also, Home Manager is configured in `flake.nix` to use:

* global pkgs (`home-manager.useGlobalPkgs = true`)
* user packages (`home-manager.useUserPackages = true`)
* backup extension `"bak"` to avoid clobber failures

---

## How to use this repo

### Build/switch a host (on that host)

From the repo root:

```bash
sudo nixos-rebuild switch --flake .#terra
```

Swap `terra` for `venus`, `mercury`, or `pulsar`.

### Update only Home Manager (no NixOS rebuild)

```bash
home-manager switch --flake .#star@terra
```

### Update flake inputs

```bash
nix flake update
sudo nixos-rebuild switch --flake .#terra
```

### Build without switching (handy for sanity checks)

```bash
sudo nixos-rebuild build --flake .#terra
```

### Remote rebuild (common pattern)

If the target host can pull this repo:

```bash
sudo nixos-rebuild switch --flake .#terra --target-host root@terra --use-remote-sudo
```

(Adjust user/hostnames to taste.)

---

## Adding a new host

1. Create a folder: `hosts/<newhost>/`
2. Copy in a `hardware-configuration.nix` from the target machine:

   ```bash
   sudo nixos-generate-config --root /mnt
   # copy /mnt/etc/nixos/hardware-configuration.nix into hosts/<newhost>/
   ```
3. Add `hosts/<newhost>/configuration.nix`
4. Optional: add `hosts/<newhost>/services.nix` (it will be auto-imported)
5. Add it to `flake.nix` under `nixosConfigurations`

---

## Notes, gotchas, and small sharp edges

* **`networking.hostId`** matters if you use certain storage and networking features.  Mercury and Pulsar still have placeholders.
* Terra’s `storage.nix` hard-codes UUIDs and labels.  If you clone this to new hardware, you’ll want to update those.
* The `common/users.nix` user has `"docker"` in `extraGroups` even on Podman-first hosts.  Totally fine, but if you ever want to be strict, you can make groups host-specific.
* SSH listens on **a custom port**.  If you publish this repo publicly, that’s not a secret, but it *is* a fingerprint, so decide how you feel about it.

---

## Quick “what do I run?” cheat sheet

* Switch Terra system config:
  `sudo nixos-rebuild switch --flake .#terra`

* Switch only Home Manager on Terra:
  `home-manager switch --flake .#star@terra`

* Update inputs + rebuild:
  `nix flake update && sudo nixos-rebuild switch --flake .#terra`
