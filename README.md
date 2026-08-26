# niriblue

Custom Fedora Atomic image based on [wayblue niri](https://github.com/wayblueorg/wayblue),
built with [BlueBuild](https://blue-build.org/). The host machine stays on Bazzite;
this image is built up incrementally and tested in a VM until it is ready.

Note: wayblue only publishes a `latest` tag, so this image tracks current Fedora.

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

The double rebase installs wayblue's sddm user provisioning and the signing policy.
After that, each new build is picked up with `sudo bootc upgrade` in the VM.

## Roadmap

- [x] Step 1: identity image (wayblue niri base + signing, no changes)
- [x] Step 2: layer the current host package set (see `recipes/recipe.yml`)
- [ ] Step 3: VM validation of the niri session (noctalia instead of waybar)
- [ ] Step 4: greeter swap (greetd + tuigreet or regreet, disable sddm)
- [ ] Step 5: terminal decision (ghostty vs wezterm image rendering)
- [ ] Step 6: gaming layer (steam flatpak, gamemode, mangohud, gamescope;
      evaluate pulling the Bazzite kernel)
- [ ] Step 7: virtualization stack (qemu-kvm, libvirt, virt-manager)
- [ ] Step 8: VS Code + podman devcontainer defaults baked in
      (dev.containers.dockerPath=podman, user podman.socket)
- [ ] Step 9: trim (drop anything wayblue ships that goes unused, e.g. waybar)
- [ ] Later: decide host cutover from Bazzite

## Notes

- Package origins verified on the current host (2026-08-26): niri, noctalia,
  alacritty, cosmic-files, cosmic-settings, pamixer, and most CLI tools are
  official Fedora packages; COPRs are only needed for starship (atim),
  ghostty (scottames), lazygit (dejan), and bibata-cursor-themes
  (peterwu/rendezvous).
- Homebrew tools are managed via chezmoi on the host, not baked into the image.
