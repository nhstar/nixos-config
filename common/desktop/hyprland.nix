{ config, pkgs, lib, ... }:

{
  # Hyprland is opt-in per host.
  programs.hyprland.enable = true;

  #####################################################
  ## Hyprland-specific packages
  #####################################################
  environment.systemPackages = with pkgs; [
    hyprlock
    hyprnotify
    libnotify
    waybar
    wlogout
    wl-clipboard
    hyprpaper
    hypridle
    hyprpwcenter
  ];

  #####################################################
  ## Hyprland session services
  #####################################################
  systemd.user.services.hyprnotify = {
    description = "Hyprnotify notification daemon";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.hyprnotify}/bin/hyprnotify";
      Restart = "always";
    };
  };

  #####################################################
  ## XDG Desktop Portal
  ## - Plasma will use its own portal in Plasma sessions
  ## - Hyprland needs the Hyprland portal available
  #####################################################
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      # Keep KDE portal available if this host also runs Plasma.
      kdePackages.xdg-desktop-portal-kde
    ];
  };
}
