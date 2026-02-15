{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/desktop/plasma.nix
    ./storage.nix
  ];


  xdg.portal.config.common = {
    default = [ "kde" ];

    # Force InputCapture to KDE’s portal backend
    "org.freedesktop.impl.portal.InputCapture" = [ "kde" ];

    # Helpful alongside InputCapture
    "org.freedesktop.impl.portal.RemoteDesktop" = [ "kde" ];
    "org.freedesktop.impl.portal.Inhibit" = [ "kde" ];
  };


  # Dealing with Laptop power management without impacting desktop power-profiles-daemon
  services.power-profiles-daemon.enable = lib.mkForce false;
  services.auto-cpufreq.enable = false;
  services.tlp.enable = true;

  # Set this after the first install (or copy from your Debian hostid if you use ZFS/Btrfs send/receive etc.).
  # networking.hostId = "00000002";
  
  # Intel CPU
  hardware.cpu.intel.updateMicrocode = true;

# Graphics
  services.xserver.videoDrivers = [ "nvidia" ];
  boot.blacklistedKernelModules = [ "nouveau" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false; # proprietary driver
  };

  # Power / suspend sanity
  boot.kernelParams = [
    "mem_sleep_default=s2idle"
    "quiet"
    "udev.log_level=3"
    "systemd.show_status=auto"
  ];

  # Sleep policy:
  # - On AC: suspend only
  # - On battery: suspend-then-hibernate after 1 hour
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend";
  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=1h
  '';


  # Thunderbolt
  services.hardware.bolt.enable = true;

  # Fingerprint reader disabled because I don't need it, and I think it's causing a sleep hang
  services.fprintd.enable = false;

  # Thermals
  services.thermald.enable = true;

  # Some Boot Options
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.initrd.secrets = {
    "/etc/keys/keyfile" = "/etc/keys/keyfile";
  };
}
