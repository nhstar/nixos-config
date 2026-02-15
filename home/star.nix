{ config, anyrun, pkgs, lib, inputs, ... }:

{
  home.username = "star";
  home.homeDirectory = "/home/star";

  imports = [ inputs.lazyvim.homeManagerModules.default ];

  ###############################################################
  ## Packages managed by Home-Manager
  ###############################################################
  home.packages = with pkgs; [
    _86Box-with-roms
    home-manager
    alpine
    bat
    bitwarden-desktop
    cliphist
    deskflow
    eza
    fd
    firefox
    fzf
    gcc
    helvum
    jq
    junction
    kitty
    lazygit
    lazyssh
    microsoft-edge
    # neovim replaced with the lazyvim flake
    nextcloud-client
    pavucontrol
    ranger
    rdesktop
    ripgrep
    stow
    starship
    tmux
    unzip
    virt-manager
    vlc
    zellij
    zip

    #Container tools
    distrobox
    distrobox-tui

    # KDE apps
    kdePackages.kontact
    kdePackages.kpat
    kdePackages.yakuake
    kdePackages.krdc
    # kdePackages.neochat
    kdePackages.tokodon

    # Dev tools
    powershell
    direnv
    
    #chatty apps
    telegram-desktop
    signal-desktop
    # nheko ###  Won't install some dep's...  Apparently a big sec issue unresolved.
    element-desktop
    discord
  ];

  ###############################################################
  ## VSCode
  ###############################################################
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      enkia.tokyo-night
      ecmel.vscode-html-css
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-containers
      ms-python.python
      ms-python.vscode-pylance
      ms-python.flake8
      ms-vscode.powershell
      bbenoist.nix
      redhat.ansible
      hashicorp.terraform
    ];
  };

  programs.lazyvim = {
      enable = true;

      extras = {
        lan.nix.enable = true;
        lang.python.enable = true;
        lang.go.enable = true;
        lang.yaml.enable = true;
        lang.json.enable = true;
        lang.docker.enable = true;
        lang.bash.enable = true;
      };

      treesitterParsers = with pkgs.vimPlugins.nvim-treesitter-parsers; [
        nix
        python
        json
        bash
        powershell
        terraform
      ];

    };

  programs.anyrun = {
    enable = true;
    config = {
      x = { fraction = 0.5; };
      y = { fraction = 0.3; };
      width = { fraction = 0.3; };
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = false;
      closeOnClick = false;
      showResultsImmediately = false;
      maxEntries = null;

      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
        "${pkgs.anyrun}/lib/libsymbols.so"
      ];
    };

    # Inline comments are supported for language injection into
    # multi-line strings with Treesitter! (Depends on your editor)
    extraCss = /*css */ ''
      .some_class {
        background: red;
      }
    '';

    extraConfigFiles."some-plugin.ron".text = ''
      Config(
        // for any other plugin
        // this file will be put in ~/.config/anyrun/some-plugin.ron
        // refer to docs of xdg.configFile for available options
      )
    '';
  };
  ###############################################################
  ## Environment variables for Hyprland
  ## (Wayland session variables belong HERE, not systemd)
  ###############################################################
  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "kitty";
  };

  ###############################################################
  ## Remove ALL systemd user services from HM
  ## Hyprland launches everything via exec-once, clean & simple
  ###############################################################

  systemd.user = {
    # DO NOT start services automatically
    # startServices = false;

    services = {
      nextcloud = {
        Unit = {
          Description = "Nextcloud Desktop";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = "${pkgs.nextcloud-client}/bin/nextcloud --background";
          Restart = "on-failure";
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };

  ###############################################################
  ## Required HM boilerplate
  ###############################################################
  home.stateVersion = "25.05";
}

