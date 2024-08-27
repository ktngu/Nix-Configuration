{
  description = "ktngu's nix config";

  inputs = {
    # change to github:nixos/nixpkgs/nixos-unstable for unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      # change to github:nix-community/home-manager for unstable
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    {
      nixosConfigurations =
        let
          user = "ktngu";
          mkHost =
            host:
            nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";

              specialArgs = {
                inherit (nixpkgs) lib;
                inherit inputs user;
              };

              modules = [
                inputs.home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    users.${user} = {
                      imports = [
                        # common home-manager configuration
                        ./home.nix
                        # host specific home-manager configuration
                        ./hosts/${host}/home.nix
                      ];

                      home = {
                        username = user;
                        homeDirectory = "/home/${user}";
                        # do not change this value
                        stateVersion = "24.05";
                      };

                      # Let Home Manager install and manage itself.
                      programs.home-manager.enable = true;
                    };
                  };
                }
                # common configuration
                ./configuration.nix
                # host specific configuration
                ./hosts/${host}/configuration.nix
                # host specific hardware configuration
                ./hosts/${host}/hardware-configuration.nix
              ];
            };
        in
        {
          # update with `nix flake update`
          # rebuild with `nixos-rebuild switch --flake .#dev`
          nixos = mkHost "nixos";
        };
    };
}
