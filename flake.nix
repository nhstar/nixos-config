{
  description = "Star's multi-host NixOS configuration (Mercury, Pulsar, Venus, Home Manager integrated)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, anyrun, home-manager, lazyvim, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      pkgsStable = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };

      mkHost = name: path:
        lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs anyrun pkgsStable;
          };

          modules = [
            # 🔹 ADD OVERLAY AS A MODULE HERE
            {
              nixpkgs.overlays = [
                (final: prev: { })
              ];
            }

            ./common/base.nix
            # Desktop is intentionally host-specific (e.g., Plasma-only on Terra).
            ./common/users.nix
            ./common/bluetooth.nix
            ./common/sound.nix
            ./common/services.nix
            ./common/firewall.nix
            ./common/fonts.nix
            path
            # Auto-import host-specific services.nix if present
            (let hostServices = ./hosts/${name}/services.nix;
             in if builtins.pathExists hostServices then hostServices else {})

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Helps avoid clobber failures like ~/.config/nvim/init.lua
              home-manager.backupFileExtension = "bak";

              # Pass args into HM modules (so inputs.lazyvim works in home/star.nix)
              home-manager.extraSpecialArgs = {
                inherit inputs anyrun pkgsStable;
              };

              home-manager.users.star = import ./home/star.nix;
            }

            { networking.hostName = name; }
          ];
        };

      # A tiny helper so we don’t repeat ourselves for homeConfigurations
      mkHome = hostName:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };

          extraSpecialArgs = {
            inherit inputs anyrun pkgsStable;
          };

          modules = [
            ./home/star.nix

            # Optional: if you ever want host-specific HM tweaks later
            # ({ ... }: { home.sessionVariables.HOSTNAME = hostName; })
          ];
        };
    in
    {
      nixosConfigurations = {
        mercury = mkHost "mercury" ./hosts/mercury/configuration.nix;
        pulsar  = mkHost "pulsar"  ./hosts/pulsar/configuration.nix;
        venus   = mkHost "venus"   ./hosts/venus/configuration.nix;
        terra   = mkHost "terra"   ./hosts/terra/configuration.nix;
      };

      # ✅ This is the new bit that makes:
      # home-manager switch --flake .#star@venus
      # work without touching NixOS generations.
      homeConfigurations = {
        "star@mercury" = mkHome "mercury";
        "star@pulsar"  = mkHome "pulsar";
        "star@venus"   = mkHome "venus";
        "star@terra"   = mkHome "terra";
      };
    };
}

