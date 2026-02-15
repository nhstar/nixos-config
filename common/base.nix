{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nixpkgs.config = {
    allowUnfree = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.plymouth = {
    enable = true;
    theme = "metal_ball";
    themePackages = with pkgs; [
      (adi1090x-plymouth-themes.override {
        selected_themes = [ "metal_ball" ];
      })
    ];
  };

  security.pam.loginLimits = [
    { domain = "star"; type = "soft"; item = "nofile"; value = "65536"; }
    { domain = "star"; type = "hard"; item = "nofile"; value = "65536"; }

    # Optional: for ALL users
    { domain = "@users"; type = "soft"; item = "nofile"; value = "65536"; }
    { domain = "@users"; type = "hard"; item = "nofile"; value = "65536"; }
  ];

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    htop
    git
    flatpak
  ];

  programs.zsh.enable = true;
  
  system.stateVersion = "25.05";
}
