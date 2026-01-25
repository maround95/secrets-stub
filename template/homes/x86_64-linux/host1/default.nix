{ config, lib, ... }:
{
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.defaultSopsFile = ./secrets.yaml;

  # example secret
  # sops.secrets."github-token" = {
  #   path = "${config.home.homeDirectory}/.config/github/token";
  #   mode = "0600";
  # };

  ####################
  # Per user config
  ####################

  # programs.zsh =
  #   lib.mkIf (config.snowfallorg.user.name == "user1") {
  #     shellAliases.test = "test1";
  #   }
  #   // lib.mkIf (config.snowfallorg.user.name == "user2") {
  #     shellAliases.test = "test2";
  #   };
}
