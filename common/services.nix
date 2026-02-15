{ config, pkgs, ... }:

{
  #############################
  ### Core services
  #############################

  services.dbus.enable = true;

  # Firmware updates
  services.fwupd.enable = true;

  # Power management
  # services.auto-cpufreq.enable = true;

  # Trim all the things
  services.fstrim.enable = true;

  # Printing
  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint pkgs.hplip ];
    browsing = true;
  };

  # Flatpak support
  services.flatpak = {
    enable = true;
    #remotes = [
    #  {
    #    name = "flathub";
    #    url = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    #  }
    #];
  };
  
  # Secrets and other secure storage
  #

  #############################
  ### SSH
  #############################

  services.openssh = {
    enable = true;
    ports = [ 2702 ];
  };
}
