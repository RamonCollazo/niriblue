# VM testing

The image is validated in a libvirt session VM (`qemu:///session`, no root
needed) before anything touches a real machine. First install goes through the
Fedora netinstall ISO with `ks.cfg`, which deploys the published image via
anaconda's `ostreecontainer`. After that, each new build is picked up inside
the VM with `sudo bootc upgrade`.

## Credentials

User `ramon`, password `niriblue`, wheel group, root locked (set in ks.cfg).

## First install (once)

1. Download the Fedora Everything netinstall ISO for the current release.
2. Extract `images/pxeboot/vmlinuz` and `initrd.img` from the ISO
   (`osirrox -indev <iso> -extract /images/pxeboot/... ...`).
3. Append the kickstart into the initrd:
   `echo ks.cfg | cpio -c -o | gzip -c9 >> initrd.img` style concatenation.
4. Boot a VM with direct kernel boot and cmdline
   `inst.ks=file:/ks.cfg inst.stage2=hd:LABEL=<iso-volid> inst.text console=ttyS0`.
5. The kickstart ends with `poweroff`; then remove the kernel/initrd/cmdline
   lines and the cdrom from the domain XML and boot from disk.

## Gotchas (learned 2026-08-26)

- A kickstart `text` install sets the default target to multi-user. The
  `%post` in ks.cfg sets `graphical.target`; without it the VM boots to a
  text login instead of SDDM.
- niri needs a GBM-capable GPU. The VM must use
  `<video><model type="virtio"><acceleration accel3d="yes"/></model></video>`
  plus a `<graphics type="egl-headless">` alongside VNC, otherwise niri logs
  `Failed to open device /dev/dri/card0: Invalid argument` and renders black.
  Irrelevant on real hardware.
- With egl-headless enabled, `virsh screenshot` fails with "no surface"; use
  the virt-manager console to see the display.
- `virsh send-key` works for driving the console (greeter, tty logins).
- For SSH access without root: passt-backed user NIC with a port forward,
  `<backend type="passt"/>` + `<portForward proto="tcp"><range start="2222"
  to="22"/></portForward>`, then `ssh -p 2222 ramon@127.0.0.1` (enable sshd
  in the guest once: `sudo systemctl enable --now sshd`).
- The first boot after install provisions the sddm user (wayblue behavior);
  the greeter appears from the second boot onward.
- The guest may inherit the host's hostname via passt DHCP; cosmetic.
- The VM disk fills up after several image switches ("Insufficient free
  space" from bootc switch). Reclaim with `sudo rpm-ostree cleanup -bpr`
  (drops rollback deployments and prunes the ostree repo) plus
  `podman system prune -af` for test containers.
