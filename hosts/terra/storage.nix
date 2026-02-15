{ config, lib, pkgs, ... }:

{
  ############################################################
  # Unlock encrypted volumes in initrd
  ############################################################
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-bylabel/ROOT";  # nvme0n1p3 (new root)
      allowDiscards = true;
    };

    home = {
      device = "/dev/disk/by-label/terrahome";  # nvme1n1p1 (existing LUKS1)
      allowDiscards = true;
    };
  };

  ############################################################
  # Filesystems
  ############################################################

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";  # or by-uuid if you prefer
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  fileSystems."/" = {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "subvol=@" "noatime" "compress=zstd" ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "subvol=@nix" "noatime" "compress=zstd" ];
  };

  fileSystems."/var" = {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "subvol=@var" "noatime" "compress=zstd" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "subvol=@log" "noatime" "compress=zstd" ];
  };

  # /home by filesystem label (inside the unlocked LUKS container)
  # Keep subvol=@home because that is how your home volume is structured.
  fileSystems."/home" = {
    device = "/dev/disk/by-label/terrahome";
    fsType = "btrfs";
    options = [ "subvol=@home" "noatime" "compress=zstd" ];
  };

  ############################################################
  # Swap + hibernation
  ############################################################
  swapDevices = [
    { device = "/dev/disk/by-label/SWAP"; }  # or by-uuid if not labeled
  ];

  boot.resumeDevice = "/dev/disk/by-label/SWAP";
}

