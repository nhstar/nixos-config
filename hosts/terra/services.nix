{ config, pkgs, lib, ... }:

{
  virtualisation.docker.enable = lib.mkForce false;

  # Podman on Terra
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # optional: provides a `docker` wrapper -> podman
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages = with pkgs; [
    podman
    podman-desktop
    podman-compose
    buildah
    skopeo

    # OCI Runtimes
    crun
    runc

    # Rootless plumbing
    fuse-overlayfs
    slirp4netns
    shadow # <-- provides newuidmap /newgidmap
  ];

  # Virtualization via kvm
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm;
    qemu.swtpm.enable = true;
    #qemu.ovmf.enable = true;
  };
}
