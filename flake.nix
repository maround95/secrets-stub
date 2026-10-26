{
  description = "stub secrets flake";

  outputs = { ... }: {
    flakeModules.default = { };

    templates.default = {
      path = ./template;
      description = "Initialize a private secrets repo that extends the main flake through native flake-parts modules.";
    };
  };
}
