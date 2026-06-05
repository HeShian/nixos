{ pkgs, ... }:
{
  monitors = {
    "eDP-1" = {
      isMain = true;
      scale = 1.25;
      mode = {
        width = 1920;
        height = 1080;
        refresh = 60.0;
      };
      position = {
        x = 0;
        y = 0;
      };
      rotation = 0;
      focus-at-startup = true;
    };
  };
  stylix.cursor = {
    package = pkgs.graphite-cursors;
    name = "graphite-dark";
    size = 24;
  };
  home.stateVersion = "26.05";
}
