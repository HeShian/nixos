{
  den.aspects.umbriel-window-rules.homeManager.programs.umbriel.settings.window_rule = [
    {
      match.is_dialog = true;
      default_floating = true;
    }
    {
      match.app_id = [
        "^(imv|galculator|blueman-manager|nm-connection-editor|pavucontrol|waypaper)$"
        "^(org[.]gnome[.](Calculator|FileRoller)|org[.]pulseaudio[.]pavucontrol|com[.]gabm[.]satty)$"
        "^dev[.]noctalia[.](Noctalia|UmbrielSharePicker)$"
      ];
      default_floating = true;
    }
    {
      match.app_id = "^quickterminal$";
      default_floating = true;
      default_floating_size = { width = 0.62; height = 0.68; };
      default_position = { x = 20; y = 20; anchor = "top_left"; };
    }
    {
      match = {
        app_id = "^(firefox|org[.]mozilla[.]firefox|brave-browser|com[.]brave[.]Browser)$";
        title = "^(Picture-in-Picture|Picture-in-picture|Picture in picture|画中画)$";
      };
      default_floating = true;
      default_position = { x = 20; y = 20; anchor = "bottom_right"; };
      opacity = 1.0;
      blur = false;
    }
    {
      match = {
        app_id = "^(thunar|Thunar|org[.]xfce[.]Thunar)$";
        title = "^(File Operation Progress|文件操作进度|Rename|重命名)";
      };
      default_floating = true;
    }
    {
      match = {
        app_id = "^steam$";
        title = "^(Friends List|好友列表)$";
      };
      default_floating = true;
      default_floating_size = { width = 0.25; height = 0.65; };
    }
    {
      match = {
        app_id = "^steam$";
        title = "^notificationtoasts_[0-9]+_desktop$";
      };
      default_floating = true;
      default_focused = false;
      default_position = { x = 10; y = 10; anchor = "bottom_right"; };
    }
    {
      match.app_id = "^(mpv|celluloid|io[.]github[.]celluloid_player[.]Celluloid|imv)$";
      opacity = 1.0;
      blur = false;
    }
    {
      match.app_id = "^org[.]gnome[.]";
      corner_radius = 12;
    }
    {
      match.app_id = "^(kitty|quickterminal)$";
      blur = true;
      blur_optimized = true;
    }
  ];
}
