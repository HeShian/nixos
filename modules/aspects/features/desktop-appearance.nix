{
  den.aspects.desktop-appearance = {
    nixos = { pkgs, ... }: {
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      # 等宽备用字体
      nerd-fonts.jetbrains-mono
      maple-mono.NF

      # Dux Shell / Dux Greeter 的界面与图标字体
      inter
      material-symbols
    ];
  };

    homeManager.imports = [
  # 用户字体
  ({ pkgs, ... }:
      let
        version = "1.2304.79";
        jetbrainsMapleMono = pkgs.runCommand "jetbrains-maple-mono-${version}" {
          nativeBuildInputs = [ pkgs.unzip ];
          src = pkgs.fetchurl {
            url = "https://github.com/SpaceTimee/Fusion-JetBrainsMapleMono/releases/download/${version}/JetBrainsMapleMono-NF-XX-XX-XX.zip";
            hash = "sha256-Wu9Qva7hbUrfNiB7Tw5O77h6T5Y2rrdZWa4yyBM7LHU=";
          };
        } ''
          mkdir -p "$out"
          unzip -j "$src" '*.ttf' -d "$out"
        '';
      in {
        xdg.dataFile."fonts/jetbrains-maple-mono" = {
          source = jetbrainsMapleMono;
          recursive = true;
        };
      })

  # 声明设置与 Qt / GTK 主题依赖，并生成 niri 的外观分片
  ({ appearance, pkgs, ... }:
      {
        home.packages = [
          pkgs.qt6Packages.qt6ct # DMS 检测到 qt6ct 后启用 Qt 配色。
          pkgs.adw-gtk3
        ];

        # DMS / GTK / Qt 的图标和光标来源（DMS 通过 gsettings 读取）
        dconf.settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "adw-gtk3-dark";
          cursor-theme = appearance.cursor.theme;
          cursor-size = appearance.cursor.size;
        };

        # Dotfile 的 cursor{} 块已由这里取代（ADR-0006）：config.kdl 原位 include 这个
        # 分片，与 DMS 运行期片段的相对顺序保持不变。
        xdg.configFile."niri/appearance.kdl".text = ''
          // 由 modules/aspects/features/desktop-appearance.nix 生成；值在 modules/_lib/appearance.nix。
          cursor {
              xcursor-theme "${appearance.cursor.theme}"
              xcursor-size ${toString appearance.cursor.size}
              hide-after-inactive-ms ${toString appearance.cursor.hideAfterInactiveMs}
          }
        '';
      })

  ../../_lib/appearance-activation.nix
];
  };
}
