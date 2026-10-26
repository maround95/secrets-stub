# Private secrets flake template

This template exports a native flake-parts extension. All example configuration
modules are no-ops; replace their contents with your private configuration.

## Export contract

The public flake imports the module value, not evaluated private configurations:

```nix
imports = [ (inputs.secrets.flakeModules.default or { }) ];
```

`flakeModules.default` executes inside the **public** flake-parts evaluation. The
private flake does not need an input dependency on the public flake. Its separate
flake-parts evaluation only exports this module value and the development shells.
The root stub exports an empty module through the same interface.

The extension contributes to the public native module registry, for example:

```nix
flakeModules.default = {
  flake.modules = {
    nixos.profile-common = ./nixos/common.nix;
    nixos.nixos1 = ./nixos/nixos1.nix;
    homeManager.profile-base = ./home/common.nix;
    homeManager.nixos1-user1 = {
      imports = [ ./home/nixos1.nix ./home/nixos1-user1.nix ];
    };
    darwin.darwin1 = {
      imports = [ ./darwin/common.nix ./darwin/darwin1.nix ];
    };
  };
};
```

Inside this template's flake-parts configuration, this export is assigned at
`flake.flakeModules.default`.

Registry entries have native `deferredModule` type: public and private
contributions to the same entry combine as module imports. Do not import a node
into itself to extend it. There is no custom secrets hierarchy or automatic
family/system-wide routing.

## Explicit nodes and sharing

`nixos1`, `user1`, and `darwin1` are placeholders. Rename the entries to the public
nodes you actually deploy: for example NixOS `ares`, `nova`, `vega`, or `zeus`,
Darwin `lyra`, and Home Manager `nova-maroun`, `nova-root`, or `lyra-mdeeb`.
Shared private behavior extends meaningful shared profile nodes such as
`nixos.profile-common` or `homeManager.profile-base`; it applies only to graphs
that import those nodes.

The example `home/nixos1.nix` is shared deployment configuration imported alongside
the user-specific file in `homeManager.nixos1-user1`. Import it explicitly in any
other user nodes that should share it. Likewise, `darwin/common.nix` is explicitly
imported by the example Darwin deployment.

A variant importing a node inherits **both** its public and private contributions.
For variant isolation, intentionally share a base node and compose separate
deployment nodes rather than importing the deployment you want to avoid.

Definitions use ordinary native Nix module merging. Later imports do not
automatically override equal-priority scalar definitions; use `lib.mkDefault` or
`lib.mkForce` as needed.

## Available context

Private configuration modules participate in the same downstream graph as public
modules and can use:

- `pkgs` and `pkgs.stdenv.hostPlatform` for native platform facts
- `channels.stable`, `channels.unstable`, and `channels.unstable-small`
- `inputs`
- native `config.networking.hostName` / `config.users.users` in system graphs
- `config.home.username` and `config.home.homeDirectory` in Home Manager graphs

There are no `flakeModules`, `flakeLib`, or `outputName` special arguments. Select
root imports statically, not from downstream `config`. Use `lib.mkIf` for
conditional behavior inside already-imported modules. When another deferred
module is needed, the outer flake-parts module can capture its
`config.flake.modules` entry; simple literal contributions like these examples
need no such capture.

## Secret data

Nix configuration lives in `nixos/`, `home/`, and `darwin/`. Secret data lives
separately in `secrets/hosts/<host>.yaml` and `secrets/users/<user@host>.yaml`;
there is no architecture-based routing. Modules explicitly reference the data
files they need. The example YAML files are plaintext placeholders: configure
recipients in `.sops.yaml` and encrypt them before adding real secrets.

## Development shell

The template retains default shells for `x86_64-linux`, `aarch64-linux`,
`x86_64-darwin`, and `aarch64-darwin`, containing `sops`, `age`, `ssh-to-age`, and
`yq`. Repository layout is otherwise up to you.
