{
  imports = [ ./hardware-configuration.nix ];
  networking.hostId = "placeholder-pulsar";
  services.tlp.enable = true;
}
