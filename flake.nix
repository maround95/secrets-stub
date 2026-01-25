{
  description = "stub secrets flake";

  outputs =
    { ... }:
    {
      nixosModules = { };
      darwinModules = { };
      homeModules = { };

      templates.default = {
        path = ./template;
        description = "Initialize a private secrets repo.";
      };
    };
}
