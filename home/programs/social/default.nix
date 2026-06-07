{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    wemeet
    telegram-desktop
    vesktop
  ];
}
