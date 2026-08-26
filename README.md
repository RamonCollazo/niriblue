# niriblue

Custom Fedora Atomic niri image built with [BlueBuild](https://blue-build.org/)
on the official `fedora-ostree-desktops/base-atomic` base, pinned to a Fedora
version (Fedora major upgrades are a deliberate one-line bump of
`image-version`). The host machine stays on Bazzite; this image is built up
incrementally and tested in a VM until it is ready.

History: steps 1-3 were built on the wayblue niri base; the repo migrated to
base-atomic in PR #1 (2026-08-26) to own the whole stack, drop the beta
dependency, and shrink the image.

## Setup (one time)

1. Create a GitHub repo and push this directory to it.
2. Add the contents of `cosign.key` as a repo Actions secret named `SIGNING_SECRET`
   (Settings > Secrets and variables > Actions). `cosign.key` is gitignored; keep a
   copy somewhere safe. The keypair was generated with an empty password.
3. Push; the workflow builds and publishes `ghcr.io/<owner>/niriblue:latest`.
   Make the package public in GitHub package settings after the first build.

## VM test loop

Install any Fedora Atomic or Bazzite into a VM (virt-manager on the host), then:

```sh
rpm-ostree rebase ostree-unverified-registry:ghcr.io/<owner>/niriblue:latest
systemctl reboot
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/<owner>/niriblue:latest
systemctl reboot
```

The double rebase installs the sddm user provisioning and the signing policy.
After that, each new build is picked up with `sudo bootc upgrade` in the VM.
PR builds publish as `ghcr.io/<owner>/niriblue:pr-<n>-<fedora>` for testing
branches before merge.

## Roadmap

- [x] Step 1: identity image (wayblue niri base + signing, no changes)
- [x] Step 2: layer the current host package set (see `recipes/recipe.yml`)
- [x] Step 3: VM validation (2026-08-26): image boots via bootc, packages
      present, sddm greeter and niri session confirmed working (see test/)
- [x] Noctalia as default shell (niri config template patched, waybar removed
      from the image); verified in VM 2026-08-26
- [x] Gaming layer: gamemode, mangohud, gamescope RPMs plus Steam system
      flatpak; verified in VM 2026-08-26. Bazzite kernel evaluation still open
- [x] Base migration to fedora-ostree-desktops/base-atomic (PR #1, 2026-08-26):
      owns niri/portals/sddm, negativo17 ffmpeg + libva, ublue-os-udev-rules,
      uupd auto-updates, gnome-keyring-pam, pipewire/bluez, fonts; verified in
      VM including sddm wayland greeter and keyring unlock fix
- [ ] Greeter swap (greetd + tuigreet or regreet, disable sddm); parked,
      sddm for now
- [x] Kernel decision (2026-08-26, PR #2): OGC gaming kernel adopted; kernel
      rpms and xone kmods both from ghcr.io/ublue-os/akmods:ogc-44, verified
      booting in VM with xone_gip_gamepad loading. ryzen-smu deferred (lives
      in akmods-extra)
- [x] Terminal decision (2026-08-26): ghostty stays. A/B in the VM with
      kitten icat showed wezterm renders no image via the kitty graphics
      protocol (what image.nvim/yazi use) while ghostty supports it fully
- [ ] Virtualization stack (qemu-kvm, libvirt, virt-manager)
- [x] Devcontainer workflow (2026-08-26, PR #3): VS Code from the Microsoft
      repo, user podman.socket enabled; validated end to end in the VM with
      devpod CLI (docker provider, DOCKER_PATH=podman) building and running
      an alpine devcontainer. dev.containers settings and devpod CLI live in
      chezmoi/brew, not the image
- [ ] CI polish: Renovate digest-pinned base bumps, rechunking, SBOM,
      changelogs, ISO at cutover time
- [ ] Later: decide host cutover from Bazzite

## Notes

- Package origins verified on the current host (2026-08-26): niri, noctalia,
  alacritty, cosmic-files, cosmic-settings, pamixer, and most CLI tools are
  official Fedora packages; COPRs are only needed for starship (atim),
  ghostty (scottames), lazygit (dejan), and bibata-cursor-themes
  (peterwu/rendezvous).
- Homebrew tools are managed via chezmoi on the host, not baked into the image.
