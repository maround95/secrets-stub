{
  description = "stub secrets flake";

  outputs = { ... }: {
    templates.default = {
      path = ./template;
      description = "Initialize a private secrets repo that extends the main flake through layered secrets module hooks.";
    };
  };
}
