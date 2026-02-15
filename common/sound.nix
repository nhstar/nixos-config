{ config, pkgs, ... }:

{
  #############################
  ### Sound / Audio
  #############################

  # Real-time kit for PipeWire / audio scheduling
  security.rtkit.enable = true;

  # We’re using PipeWire instead of PulseAudio directly
  services.pulseaudio = {
    enable = false;
    # package = pkgs.pulseaudioFull;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # jack.enable = true; # might want it in the future
  };  
}
