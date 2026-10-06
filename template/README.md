# Private secrets flake stub

This template is a no-op private flake that can extend a main dendritic flake.
It intentionally defines no real secrets and no real configuration.

The goal is to make the expected export contract clear and hard to get wrong.
The main flake may import secrets modules from general to specific, using only
static output-construction facts.

## Export contract

The public export shape is:

```nix
modules.secrets.<family>.<system>.common
modules.secrets.<family>.<system>.outputs.<outputName>
modules.secrets.home.<system>.outputs.<outputName>.users.<user>
```

Where:

- `family` is one of `nixos`, `home`, or `darwin`.
- `system` is a Nix system string such as `x86_64-linux` or `aarch64-darwin`.
- `outputName` is the main flake output name, such as `nixos1` or `darwin1`.
- `user` is the Home Manager user key, only for Home Manager graphs.

The main flake should import matching modules in this order:

1. `modules.secrets.<family>.<system>.common`
2. `modules.secrets.<family>.<system>.outputs.<outputName>`
3. `modules.secrets.home.<system>.outputs.<outputName>.users.<user>` for Home Manager only

General modules are imported first. More specific modules are imported later and
may override earlier values using normal Nix module merging.

## Examples

```nix
# Applies to all x86_64-linux NixOS outputs.
modules.secrets.nixos.x86_64-linux.common = [
  ./nixos/common.nix
];

# Applies only to nixosConfigurations.nixos1.
modules.secrets.nixos.x86_64-linux.outputs.nixos1 = [
  ./nixos/nixos1.nix
];

# Applies to all x86_64-linux Home Manager graphs.
modules.secrets.home.x86_64-linux.common = [
  ./home/common.nix
];

# Applies to all HM users under the output nixos1.
modules.secrets.home.x86_64-linux.outputs.nixos1 = [
  ./home/nixos1.nix
];

# Applies only to the HM user user1 under the output nixos1.
modules.secrets.home.x86_64-linux.outputs.nixos1.users.user1 = [
  ./home/nixos1-user1.nix
];

# Applies only to darwinConfigurations.darwin1.
modules.secrets.darwin.aarch64-darwin.outputs.darwin1 = [
  ./darwin/darwin1.nix
];
```

## Internal layout

This export shape does not force your repository layout. You can keep this flake
as tiny as one `default.nix`, or split it into shared, host, user, work, and
personal modules later.

The files in this template are only examples. They intentionally do nothing.

## Available context

When these modules are imported by the main flake, they participate in the same
module graph as the public modules. They can use the main graph's context, such
as:

- `config.custom.target`
- `config.custom.lib`
- `config.custom.channels`
- `pkgs`
- in Home Manager graphs, `config.home.username` and `config.home.homeDirectory`
- optionally, `config.custom.home.identity` if the main home graph sets it

Do not use `config` to decide imports. Imports are selected by the main flake
from static output facts. Use `lib.mkIf` only for conditional behavior inside
already-imported modules.
