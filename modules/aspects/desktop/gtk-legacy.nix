{
  # 旧桌面（noctalia / KDE）留下的 GTK 配置迁移：
  #   - gtk.css 里 @import noctalia.css，会排在 DMS 的 dank-colors.css 之后把配色覆盖掉；
  #   - settings.ini 里的 gtk-icon-theme-name=breeze / gtk-cursor-theme-name=breeze_cursors
  #     指向未安装的主题，GTK 会回退到缺失图标/默认光标。
  # 只在检测到问题时修；用户后来在 DMS 里选了有效主题则保持不动。
  den.aspects.desktop-gtk-legacy.homeManager =
    { lib, ... }:
    {
      home.activation.gtk-legacy-cleanup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        backup="$HOME/.cache/nixos-migration-backup/gtk-$(date +%Y%m%d-%H%M%S)"

        theme_exists() {
          local name="$1" base
          [ -n "$name" ] || return 1
          local IFS=':'
          for base in ''${XDG_DATA_DIRS:-/usr/share}; do
            [ -n "$base" ] || continue
            [ -d "$base/icons/$name" ] && return 0
            [ -d "$base/themes/$name" ] && return 0
          done
          [ -d "$HOME/.icons/$name" ] && return 0
          [ -d "$HOME/.local/share/icons/$name" ] && return 0
          return 1
        }

        set_ini_key() {
          local file="$1" key="$2" value="$3"
          if grep -q "^$key=" "$file"; then
            sed -i "s|^$key=.*|$key=$value|" "$file"
          else
            sed -i "/^\[Settings\]/a $key=$value" "$file"
          fi
        }

        for v in 3.0 4.0; do
          dir="$HOME/.config/gtk-$v"
          [ -d "$dir" ] || continue

          legacy=false
          if [ -f "$dir/noctalia.css" ]; then legacy=true; fi
          if [ -f "$dir/gtk.css" ] && grep -q 'noctalia' "$dir/gtk.css"; then legacy=true; fi

          if [ "$legacy" = true ]; then
            install -d "$backup"
            cp -a "$dir" "$backup/gtk-$v" || true
            rm -f "$dir/colors.css" "$dir/noctalia.css" "$dir/noctalia-extensions.css"
            printf '@import url("dank-colors.css");\n' > "$dir/gtk.css"
          fi

          # Dux 写入配色文件，GTK 的入口样式保留用户已有的规则。
          css="$dir/gtk.css"
          if [ ! -L "$css" ] && ! grep -q 'dank-colors\.css' "$css" 2>/dev/null; then
            tmp=$(mktemp "$dir/.gtk.css.XXXXXX")
            {
              printf '@import url("dank-colors.css");\n'
              if [ -f "$css" ]; then cat "$css"; fi
            } > "$tmp"
            mv -f "$tmp" "$css"
          fi

          settings="$dir/settings.ini"
          if [ ! -f "$settings" ]; then
            printf '[Settings]\n' > "$settings"
          fi

          icon_theme="$(sed -n 's/^gtk-icon-theme-name=//p' "$settings" | head -1)"
          case "$icon_theme" in
            ""|breeze|breeze-dark|Breeze|Breeze-Dark|default)
              set_ini_key "$settings" gtk-icon-theme-name Papirus-Dark
              ;;
            *)
              if ! theme_exists "$icon_theme"; then
                set_ini_key "$settings" gtk-icon-theme-name Papirus-Dark
              fi
              ;;
          esac

          cursor_theme="$(sed -n 's/^gtk-cursor-theme-name=//p' "$settings" | head -1)"
          case "$cursor_theme" in
            ""|breeze_cursors|default|Default)
              set_ini_key "$settings" gtk-cursor-theme-name Bibata-Modern-Ice
              ;;
            *)
              if ! theme_exists "$cursor_theme"; then
                set_ini_key "$settings" gtk-cursor-theme-name Bibata-Modern-Ice
              fi
              ;;
          esac
        done
      '';
    };
}
