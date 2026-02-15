{
  imports = [ ./hardware-configuration.nix ];
  networking.hostId = "placeholder-mercury";
  services.tlp.enable = true;
}
