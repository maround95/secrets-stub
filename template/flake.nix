{
  description = "Private secrets flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [ ];

      flake =
        let
          lib = nixpkgs.lib;

          # Applies to every graph of this family/system.
          # Example lookup path:
          #   modules.secrets.nixos.x86_64-linux.common
          mkCommon = family: system: modules: {
            modules.secrets.${family}.${system}.common = modules;
          };

          # Applies to one main-flake output by name.
          # Example lookup path:
          #   modules.secrets.nixos.x86_64-linux.outputs.nixos1
          mkOutput = family: system: outputName: modules: {
            modules.secrets.${family}.${system}.outputs.${outputName} = modules;
          };

          # Applies to one Home Manager user graph under a named output.
          # Example lookup path:
          #   modules.secrets.home.x86_64-linux.outputs.nixos1.users.user1
          mkHomeUser = system: outputName: user: modules: {
            modules.secrets.home.${system}.outputs.${outputName}.users.${user} = modules;
          };
        in
        lib.mkMerge [
          # Applies to all x86_64-linux NixOS outputs.
          (mkCommon "nixos" "x86_64-linux" [
            ./nixos/common.nix
          ])

          # Applies only to nixosConfigurations.nixos1.
          (mkOutput "nixos" "x86_64-linux" "nixos1" [
            ./nixos/nixos1.nix
          ])

          # Applies to all x86_64-linux Home Manager graphs.
          (mkCommon "home" "x86_64-linux" [
            ./home/common.nix
          ])

          # Applies to all HM users under the main-flake output nixos1.
          (mkOutput "home" "x86_64-linux" "nixos1" [
            ./home/nixos1.nix
          ])

          # Applies only to the HM user user1 under the main-flake output nixos1.
          (mkHomeUser "x86_64-linux" "nixos1" "user1" [
            ./home/nixos1-user1.nix
          ])

          # Applies to all aarch64-darwin Darwin outputs.
          (mkCommon "darwin" "aarch64-darwin" [
            ./darwin/common.nix
          ])

          # Applies only to darwinConfigurations.darwin1.
          (mkOutput "darwin" "aarch64-darwin" "darwin1" [
            ./darwin/darwin1.nix
          ])
        ];

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
