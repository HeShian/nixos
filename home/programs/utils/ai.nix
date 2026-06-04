{
  pkgs,
  config,
  inputs,
  ...
}:
{
  programs.claude-code = {
    enable = true;
  };
  home.sessionVariables = {
    XIAOMI_API_KEY = "$(cat ${config.age.secrets.mimo_token.path})";
  };
  home.packages = with pkgs; [
    opencode
    codex
    gitingest
    claude-code
  ];
}
