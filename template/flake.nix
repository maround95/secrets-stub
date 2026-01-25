{
  description = "Private secrets flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {

      # nixosModules.${system}.${host}
      nixosModules = {
        x86_64-linux = {
          host1 = ./systems/x86_64-linux/host1/default.nix;
        };
      };

      # darwinModules.${system}.${host}
      darwinModules = {
        aarch64-darwin = { };
      };

      # homeModules.${system}.${host}
      homeModules = {
        x86_64-linux = {
          host1 = ./homes/x86_64-linux/host1/default.nix;
        };
      };

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              sops
              age
              ssh-to-age
              yq
            ];
          };
        }
      );
    };
}
