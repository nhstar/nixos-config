{ config, pkgs, anyrun, lib, ... }:

{
  programs.hyprland.enable = true;

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

  # services.logind.killUserProcesses = false;

  ##########################################
  ## Disable greetd (was used for tuigreet)
  ##########################################
  services.greetd.enable = lib.mkForce false;

  #####################################################
  ## System-level packages needed at desktop startup
  ## (User apps belong in Home-Manager)
  #####################################################
  environment.systemPackages = with pkgs; [
    # anyrun.packages.${pkgs.stdenv.hostPlatform.system}.default
    hyprlock
    hyprnotify
    libnotify
    sddm-astronaut
    kdePackages.qtmultimedia #needed by sddm-astronaut
  ];

  #####################################################
  ## XDG Desktop Portal
  ## - Plasma will use its own portal in Plasma sessions
  ## - Hyprland needs the Hyprland portal available
  #####################################################
  xdg.portal = {
    enable = true;
    # Make the Hyprland portal available for Hyprland sessions
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      #xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
    ];

    config.common = {
      default = [ "hyprland" "kde" ];

      # Force InputCapture to KDE’s portal backend
      "org.freedesktop.impl.portal.InputCapture" = [ "kde" ];

      # (Optional, but often helpful alongside InputCapture)
      "org.freedesktop.impl.portal.RemoteDesktop" = [ "kde" ];

      "org.freedesktop.impl.portal.Inhibit" = [ "kde" ];
    };
  };

  #####################################################
  ## Nice-to-have: Wayland friendliness for Electron apps
  #####################################################
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  security.pam.services = {
    login.kwallet.enable = true;
    sddm.kwallet.enable = true;
  };
}

