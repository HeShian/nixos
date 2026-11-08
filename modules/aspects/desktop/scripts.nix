{
  den.aspects.desktop-scripts.homeManager = { config, lib, pkgs, ... }: {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "window-info";
        runtimeInputs = [ pkgs.wl-clipboard pkgs.libnotify ];
        text = ''
          info="$("${lib.getExe config.programs.umbriel.package}" focused-window)"
          printf '%s\n' "$info" | wl-copy
          notify-send "窗口信息已复制" "$info"
        '';
      })
      (pkgs.writeShellApplication {
        name = "wallpaper-random";
        text = ''
          exec "${lib.getExe config.programs.noctalia.package}" msg wallpaper-random "$@"
        '';
      })
    ];
  };
}
