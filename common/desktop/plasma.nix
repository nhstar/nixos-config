{ config, pkgs, lib, ... }:

{
  # Plasma daily-driver baseline (no Hyprland here).
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;

  ##########################################
  ## Display Manager: SDDM
  ##########################################
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings.General.DisplayServer = "wayland";
    theme = "sddm-astronaut-theme";
    extraPackages = [ pkgs.sddm-astronaut ];
  };

  ##########################################
  ## Disable greetd (was used for tuigreet)
  ##########################################
  services.greetd.enable = lib.mkForce false;

  ####################################################
  ## System-level packages needed at desktop startup
  ## (User apps belong in Home-Manager)
  ####################################################
  environment.systemPackages = with pkgs; [
    sddm-astronaut
    kdePackages.qtmultimedia # needed by sddm-astronaut
    kdePackages.okular
    kdePackages.dolphin
    kdePackages.kio-extras
    kdePackages.kio-fuse
    kdePackages.kio-admin
    kdePackages.kdegraphics-thumbnailers 
    kdePackages.kwallet
    kdePackages.kwallet-pam
    kdePackages.kwalletmanager
    kdePackages.qtkeychain
  ];

  ####################################################
  ## XDG Desktop Portal (KDE)
  ####################################################
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
  };

  ####################################################
  ## Wayland friendliness for Electron apps
  ####################################################
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  ##########################################
  ## KWallet integration (login + SDDM)
  ##########################################
  security.pam.services = {
    login.kwallet.enable = true;
    sddm.kwallet.enable = true;
  };
}
