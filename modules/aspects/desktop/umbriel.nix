{ inputs, lib, ... }:
let
  workspaceKeys = lib.listToAttrs (lib.concatMap (number:
    let index = toString number;
    in [
      (lib.nameValuePair "Mod+${index}" "workspace-switch ${index}")
      (lib.nameValuePair "Mod+Shift+${index}" "window-move-to-workspace ${index}")
    ]
  ) (lib.range 1 9));
in
{
  den.aspects.umbriel = {
    nixos = {
      imports = [ inputs.umbriel.nixosModules.default ];
      programs.umbriel.enable = true;
      environment.sessionVariables.WLR_RENDERER_ALLOW_SOFTWARE = "1";
    };

    homeManager = { config, ... }: {
      imports = [ inputs.umbriel.homeModules.default ];
      programs.umbriel = {
        enable = true;
        settings = {
          include.optional.files = [
            "${config.xdg.configHome}/umbriel/appearance.toml"
            "${config.xdg.configHome}/umbriel/noctalia.toml"
          ];
          general.autostart = [ "noctalia --daemon" "fcitx5" ];
          layout = {
            mode = "scrolling";
            gap = 10;
            extent_presets = [ 0.333 0.5 0.667 ];
            scrolling.default_extent_fraction = 0.5;
          };
          keybinds = workspaceKeys // {
            Mod = "spawn noctalia msg panel-toggle launcher";
            "Mod+Return" = "spawn kitty";
            "Mod+Q" = "window-close";
            "Mod+T" = "spawn kitty --single-instance";
            "Mod+Slash" = "spawn kitty --class quickterminal --single-instance --instance-group quickterminal";
            "Mod+E" = "spawn thunar";
            "Mod+B" = "spawn flatpak run com.brave.Browser";
            "Mod+Z" = "spawn noctalia msg panel-toggle launcher";
            "Mod+F2" = "spawn noctalia msg settings-toggle";
            "Mod+Alt+W" = "spawn noctalia msg panel-toggle wallpaper";
            "Mod+Alt+V" = "spawn noctalia msg panel-toggle clipboard";
            "Mod+Alt+L" = "spawn noctalia msg session lock";
            "Mod+Shift+P" = "spawn noctalia msg panel-toggle session";
            "Alt+Tab" = "spawn noctalia msg window-switcher hold";
            "Print" = "spawn noctalia msg screenshot-region";
            "Ctrl+Print" = "spawn noctalia msg screenshot-window";
            "Shift+Print" = "spawn noctalia msg screenshot-fullscreen";
            "Mod+Shift+Slash" = "cheatsheet-toggle";
            "Mod+P" = "spawn window-info";
            "Mod+F10" = "spawn wallpaper-random";
            "Mod+O" = "overview-toggle";
            "Mod+H" = "window-focus-left";
            "Mod+J" = "window-focus-down";
            "Mod+K" = "window-focus-up";
            "Mod+L" = "window-focus-right";
            "Mod+F" = "window-toggle-fullscreen";
            "Mod+R" = "window-cycle-primary-extent";
          };
        };
      };
    };
  };
}
