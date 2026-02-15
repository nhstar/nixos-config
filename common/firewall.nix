{ config, lib, pkgs, ... }:

{
  networking.firewall = {
    enable = true;

    # Deskflow server (TCP)
    allowedTCPPorts = [
      24800
    ];

    # Uncomment if you ever need UDP later
    # allowedUDPPorts = [ ];
  };
}

