{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixy.url = "github:cuskiy/nixy";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/release-25.05";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, nixy, home-manager, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      secrets = builtins.fromTOML (builtins.readFile ./secrets.toml);

      cluster = nixy.eval {
        imports = [ ./nodes ./traits ];
        args = { inherit inputs secrets; };
      };

      isHome = name: lib.hasInfix "@" name;

      mkSystem = node:
        lib.nixosSystem {
          system = node.schema.base.system;
          modules = [ node.module ];
          specialArgs = {
            username = node.schema.base.username;
            inherit secrets;
          };
        };

      mkHome = node:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${node.schema.user.system};
          modules = [ node.module ];
          extraSpecialArgs = {
            username = node.schema.user.name;
            useremail = node.schema.user.email;
            inherit secrets;
          };
        };

      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      nixosConfigurations = lib.mapAttrs (_: mkSystem) (lib.filterAttrs (n: _: !isHome n) cluster.nodes);
      homeConfigurations = lib.mapAttrs (_: mkHome) (lib.filterAttrs (n: _: isHome n) cluster.nodes);
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.nixos.org"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.garnix.io"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
