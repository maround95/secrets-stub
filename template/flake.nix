{
  description = "Private secrets flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [ ];

      # This module is evaluated inside the consuming public flake.
      flake.flakeModules.default = {
        flake.modules = {
          nixos.profile-common = ./nixos/common.nix;
          nixos.nixos1 = ./nixos/nixos1.nix;
          homeManager.profile-base = ./home/common.nix;
          homeManager.nixos1-user1 = {
            imports = [
              ./home/nixos1.nix
              ./home/nixos1-user1.nix
            ];
          };
          darwin.darwin1 = {
            imports = [
              ./darwin/common.nix
              ./darwin/darwin1.nix
            ];
          };
        };
      };

      perSystem = { pkgs, ... }: {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            sops
            age
            ssh-to-age
            yq
          ];
        };
      };
    };
}
