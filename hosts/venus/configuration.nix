{
  imports = [
    ./hardware-configuration.nix
    ../../common/desktop/plasma.nix
    ../../common/desktop/hyprland.nix
  ];
  networking.hostId = "00000003";
  # services.tlp.enable = true;
  xdg.portal.config.common = {
    default = [ "kde" ];

    "org.freedesktop.impl.portal.Screencast" = [ "hyprland" ];
    "org.freedesktop.impl.portal.RemoteDesktop" = [ "hyprland" ];

    "org.freedesktop.impl.portal.InputCapture" = [ "kde" ];
    "org.freedesktop.impl.portal.Inhibit" = [ "kde" ];
  };

}
