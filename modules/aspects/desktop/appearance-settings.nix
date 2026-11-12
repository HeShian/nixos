{
  # 外观的系统侧设置：dconf 主题键，以及把 Dux 的 VS Code 主题扩展装到可写目录。
  # 与「首启种子」的区别：这里描述的是「应该是什么」，不依赖文件是否已存在。
  den.aspects.desktop-appearance-settings.homeManager =
    { lib, pkgs, ... }:
    let
      dmsVsix = pkgs.fetchurl {
        name = "dms-theme-0.0.3.vsix";
        url = "https://raw.githubusercontent.com/duxlabs-dev/dux-shell/9b413296b16721f7679fb62e624cb1ed2433fa58/quickshell/matugen/dms-theme.vsix";
        hash = "sha256-MI1x1wiqvwg/N89oMuNVp0qlRT84ubvuMjtpkX0WKQY=";
      };
      codeThemeSettings = pkgs.writeText "dms-vscode-settings.json" (builtins.toJSON {
        "workbench.colorTheme" = "Dynamic Base16 DankShell";
      });
    in
    {
      # Dux 每次换壁纸时更新扩展内的主题文件，扩展需安装到可写的用户目录。
      home.activation.dms-vscode-theme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if ! compgen -G "$HOME/.vscode/extensions/danklinux.dms-theme-*" >/dev/null; then
          run ${lib.getExe pkgs.vscode} --install-extension ${dmsVsix}
        fi
        settings="''${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/settings.json"
        if [ ! -e "$settings" ]; then
          run install -Dm644 ${codeThemeSettings} "$settings"
        fi
      '';

      # DMS / GTK / Qt 的图标和光标来源（DMS 通过 gsettings 读取）
      dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "adw-gtk3-dark";
        cursor-theme = "Bibata-Modern-Ice";
        cursor-size = 24;
      };
    };
}
