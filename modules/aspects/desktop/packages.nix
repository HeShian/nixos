{ inputs, den, ... }:
{
  # 用户级软件集合：装什么、允许哪些 unfree、Steam 开关。
  # 应用与桌面的「接线」（默认程序、扩展、主题联动）分别在 mimeapps / app-integrations。
  den.aspects.desktop-packages = {
    # 不自由软件白名单。Den 的 unfree battery 生成等价的
    # `nixpkgs.config.allowUnfreePredicate`，并同时覆盖 host 与 home 两个 class。
    includes = [
      (den.batteries.unfree [
        "chatgpt"
        "vscode"
        "obsidian"
        "feishu"
        "wemeet"
        "libwemeetwrap" # 腾讯会议的运行依赖
        "qq"
        "wechat"
        "steam"
        "steam-unwrapped"
        # NVIDIA 驱动组件（hardware.nvidia）
        "nvidia-x11"
        "nvidia-settings"
        "nvidia-modprobe"
        "nvidia-persistenced"
      ])
    ];

    nixos.programs.steam.enable = true;

    homeManager = { pkgs, ... }:
    let
      zen = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta;
    in {
      home.packages = with pkgs; [
        # ── 浏览器 / 办公 / 通讯 ────────────────────────────────
        zen
        bitwarden-desktop
        chatgpt
        onlyoffice-desktopeditors
        obsidian
        vscode
        feishu
        wemeet
        qq
        wechat
        ayugram-desktop
        vesktop
        thunderbird

        # ── 游戏 ────────────────────────────────────────────────
        heroic
        lutris

        # ── 文件管理（Dux Files 由 programs.dux-files 安装，这里只留缩略图依赖） ──
        # dfiles 通过 freedesktop 缩略图器生成预览（bwrap 沙箱内执行）
        ffmpegthumbnailer
        poppler
        webp-pixbuf-loader
        libgsf
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-libav
        gnome-keyring

        # ── 媒体 / 截图 / 剪贴板 ────────────────────────────────
        mpv
        celluloid
        go-musicfox
        kazumi
        imv
        satty
        pavucontrol
        wl-clipboard
        libnotify
        imagemagick
        jq
        fuzzel
        fzf
        slurp
        grim
        wl-screenrec

        # ── 系统 / 终端小工具 ───────────────────────────────────
        xprop
        procps
        fastfetch
        gdu
        timg
        pywalfox-native
        qt6Packages.qt6ct # DMS 的 Qt 主题后端（检测到 qt6ct 才会启用 Qt 配色）
        adw-gtk3
        bazaar # Flatpak 图形化软件商店（参考配置）
      ];
    };
  };
}
