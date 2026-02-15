{ config, pkgs, lib, ... }:

{
  # Virtualization (same on both hosts)
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm;
  };

  # Containers: Docker
  virtualisation.podman.enable = lib.mkForce false;

  virtualisation.docker = {
    enable = true;

    # keep only if you actually want/need it on Venus
    storageDriver = "btrfs";
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
