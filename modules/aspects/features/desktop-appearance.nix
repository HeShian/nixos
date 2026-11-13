{ ... }:
let
  # 路径以 Nix 求值结果为唯一权威：HM 激活是 systemd 服务（home-manager-<user>.service），
  # Environment 里没有 XDG_*，所以「环境优先」在激活里恒等于默认值，只会绕过
  # config.xdg.*（ADR-0007）。会话侧的 matugen 脚本用同一套默认值，由 checks 对照。
  mkPaths =
    config:
    {
      config = config.xdg.configHome;
      data = config.xdg.dataHome;
      cache = config.xdg.cacheHome;
      state = config.xdg.stateHome;
      pictures = config.xdg.userDirs.pictures;
      templates = config.xdg.userDirs.templates;
    };

  scriptsFor = import ../../_lib/appearance-scripts.nix;

  # activation 接线：脚本自己实现 --dry-run，这里只把 HM 的 DRY_RUN 传下去。
  mkActivation =
    script: args: ''
      dry_run=()
      if [[ -v DRY_RUN ]]; then dry_run+=(--dry-run); fi
      ${script} ${args} "''${dry_run[@]}"
    '';
in
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

  # 首启种子与 DMS 缺键补齐：实现在 modules/_lib/scripts/（ADR-0007）
  ({ appearance, config, lib, pkgs, ... }:
      let
        paths = mkPaths config;
        scripts = scriptsFor pkgs;

        defaultWallpaper = pkgs.nixos-artwork.wallpapers.catppuccin-mocha.gnomeFilePath;
        cavaFallback = pkgs.writeText "cava-theme-fallback" ''
          [color]
          foreground = 'cyan'
        '';
        gtkBookmarks = pkgs.writeText "gtk-bookmarks" (
          lib.concatStringsSep "\n" (map (path: "file://${lib.replaceStrings [ "%" " " "#" "?" ] [ "%25" "%20" "%23" "%3F" ] path}") (
            (with config.xdg.userDirs; [ documents pictures videos music download ])
            ++ [ config.xdg.configHome config.xdg.dataHome ]
          )) + "\n"
        );
        shellTemplate = pkgs.writeText "new.sh" "#!/usr/bin/env bash\n";

        # DMS 持有运行时设置。只创建首启种子或补齐缺失的默认值。
        dmsDefaults = pkgs.writeText "dms-defaults.json" (builtins.toJSON {
          iconThemeDark = "System Default";
          iconThemeLight = "System Default";
          iconThemePerMode = false;
          cursorSettings = { theme = appearance.cursor.theme; size = appearance.cursor.size; };
          blurredWallpaperLayer = true;
          blurWallpaperOnOverview = true;
        });

        seedArgs = lib.concatStringsSep " " [
          "--config" (lib.escapeShellArg paths.config)
          "--state" (lib.escapeShellArg paths.state)
          "--pictures" (lib.escapeShellArg paths.pictures)
          "--templates" (lib.escapeShellArg paths.templates)
          "--wallpaper" (lib.escapeShellArg defaultWallpaper)
          "--bookmarks" (lib.escapeShellArg gtkBookmarks)
          "--shell-template" (lib.escapeShellArg shellTemplate)
          "--cava-fallback" (lib.escapeShellArg cavaFallback)
        ];
        defaultsArgs = lib.concatStringsSep " " [
          "--settings" (lib.escapeShellArg "${paths.config}/dms/settings.json")
          "--defaults" (lib.escapeShellArg dmsDefaults)
        ];
      in
      {
        home.activation.dms-appearance-seed = lib.hm.dag.entryAfter [ "writeBoundary" ]
          (mkActivation "${scripts.seed}/bin/seed-appearance" seedArgs);
        home.activation.dms-theme-defaults = lib.hm.dag.entryAfter [ "writeBoundary" ]
          (mkActivation "${scripts.dmsDefaults}/bin/dms-defaults" defaultsArgs);
      })

  # 上代遗留迁移：备份与用户设置保护
  ({ appearance, config, lib, pkgs, ... }:
      let
        paths = mkPaths config;
        scripts = scriptsFor pkgs;
        args = lib.concatStringsSep " " [
          "--config" (lib.escapeShellArg paths.config)
          "--data" (lib.escapeShellArg paths.data)
          "--cache" (lib.escapeShellArg paths.cache)
          "--icon-theme" (lib.escapeShellArg appearance.icons.fallback)
          "--cursor-theme" (lib.escapeShellArg appearance.cursor.theme)
        ];
      in
      {
        home.activation.gtk-legacy-cleanup = lib.hm.dag.entryAfter [ "writeBoundary" ]
          (mkActivation "${scripts.gtkLegacyCleanup}/bin/gtk-legacy-cleanup" args);
      })
];
  };
}
