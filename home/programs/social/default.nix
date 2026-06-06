{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    wemeet
    wechat
    telegram-desktop
    vesktop
  ];
}
