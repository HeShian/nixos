{
  den.aspects.dux = { host, ... }: {
    nixos.imports = [
  # Shell、Search、Calendar 与运行依赖
  ({ config, lib, pkgs, ... }: {
        programs.dux-shell.enable = true;
        programs.dux-search.enable = true; # 文件索引：dfiles 内容搜索 / DMS 启动器

        environment.systemPackages = with pkgs; [
          glib # DMS 使用 gsettings 探测主题
          dux-gop # DMS 系统监视与任务管理
        ];

        # Dux Calendar：后台守护进程（dcal run --session --hidden），
        # 桌面项 / `dcal show` 只负责把窗口唤出来。
        programs.dux-calendar = {
          enable = true;
          systemd.enable = true;
        };
        # 同一个坑：dcal 也会按桌面项的 Exec 名唤起程序，最小 PATH 让 exec 失败。
        systemd.user.services.dcal.enableDefaultPath = false;
        # dux-calendar 模块自己还设了 path = [ quickshell ]，同样会覆盖会话 PATH；
        # quickshell 已在系统 profile 里，清空 path 让 dcal 继承会话 PATH。
        systemd.user.services.dcal.path = lib.mkForce [ ];
      })

  # Files 守护进程与文件选择器
  ({ config, lib, ... }: {
        # Dux Files：常驻文件管理器 + portal 打开/保存对话框后端。
        # systemd 服务用 `dfiles run --session --hidden --keep-running`，
        # 关窗只是隐藏，下次呼出是热启动。
        programs.dux-files = {
          enable = true;
          systemd.enable = true;
          portal.enable = true; # 注册 org.freedesktop.impl.portal.desktop.dfiles
        };
        # 软件包和 NixOS 模块均提供 dfiles.service；覆盖前先清空软件包的 ExecStart。
        systemd.user.services.dfiles.serviceConfig.ExecStart = lib.mkForce [
          ""
          "${lib.getExe config.programs.dux-files.package} run --session --hidden --keep-running"
        ];
        # dfiles 在守护进程里按桌面项的 Exec 名启动应用（dms / imv / celluloid / mpv…），
        # 而 NixOS 默认给 systemd 单元追加最小 PATH（coreutils/findutils/systemd），
        # 会覆盖用户管理器从会话导入的 PATH，导致双击文件时 exec 找不到程序，
        # 弹出「无法处理此项目」。与 dms.service / niri 一样关掉默认 PATH，
        # 让 dfiles 继承会话 PATH（系统 profile、HM profile、flatpak 等）。
        systemd.user.services.dfiles.enableDefaultPath = false;

        # nixpkgs 的 programs.niri 默认把 FileChooser 交给 gtk；
        # 这里改成 dfiles 优先、gtk 兜底（Flatpak / Firefox / Chromium 的对话框走这里）。
        xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" = lib.mkForce [
          "dfiles"
          "gtk"
        ];
      })

  # Greeter 登录界面
  ({ appearance, ... }:
    { services.displayManager.dux-greeter = {
        enable = true;
        compositor.name = "niri";
        configHome = "/home/${host.defaultUser}";

        # 登录界面专用的最小 niri 配置：替换 niri 默认配置，
        # 避免默认配置在登录界面启动时弹出 “Important Hotkeys” 教程 / 尝试启动 waybar。
        compositor.customConfig = ''
          hotkey-overlay {
              skip-at-startup
          }

          prefer-no-csd

          layout {
              gaps 0
          }

          cursor {
              xcursor-theme "${appearance.cursor.theme}"
              xcursor-size ${toString appearance.cursor.size}
              // 登录界面不隐藏光标：这是作用域特有的行为，不取 appearance 里的值。
              hide-after-inactive-ms 0
          }

          // 与桌面一致的缩放；不存在的输出会被 niri 忽略
          output "eDP-1" {
              scale 1.25
          }

          environment {
              QS_ICON_THEME "${appearance.icons.fallback}"
          }
        '';
      };
    })

  # Shell / Greeter 共用主题，登录前从系统 profile 可见
  ({ pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        adwaita-icon-theme
        hicolor-icon-theme
        papirus-icon-theme
        bibata-cursors
      ];
    })
];

    homeManager.imports = [
  # 日历与便签关联
  ({ xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          # Dux Calendar：日历文件与 webcal 订阅。
          "text/calendar" = [ "dev.duxlabs.calendar.desktop" ];
          "text/x-vcalendar" = [ "dev.duxlabs.calendar.desktop" ];
          "application/ics" = [ "dev.duxlabs.calendar.desktop" ];
          "x-scheme-handler/webcal" = [ "dev.duxlabs.calendar.desktop" ];
          "x-scheme-handler/webcals" = [ "dev.duxlabs.calendar.desktop" ];

          # Dux 便签桌面项由 Shell 提供，调用 dms ipc call notepad openFile。
          "text/plain" = [ "dev.duxlabs.shell.notepad.desktop" ];
          "text/markdown" = [ "dev.duxlabs.shell.notepad.desktop" ];
        };
      }; })

  # 文件管理关联与缩略图依赖
  ({ pkgs, ... }: {
        # Dux Files 通过 freedesktop 缩略图器生成预览。
        home.packages = with pkgs; [
          ffmpegthumbnailer
          poppler
          webp-pixbuf-loader
          libgsf
        ];

        xdg.mimeApps.enable = true;
        xdg.mimeApps.defaultApplications = {
          # ── 文件管理：Dux Files 接管目录、回收站、远程挂载与压缩包 ──
          "inode/directory" = [ "dev.duxlabs.files.desktop" ];
          "x-scheme-handler/trash" = [ "dev.duxlabs.files.desktop" ];
          "x-scheme-handler/sftp" = [ "dev.duxlabs.files.desktop" ];
          "x-scheme-handler/smb" = [ "dev.duxlabs.files.desktop" ];
          "application/zip" = [ "dev.duxlabs.files.desktop" ];
          "application/x-tar" = [ "dev.duxlabs.files.desktop" ];
          "application/gzip" = [ "dev.duxlabs.files.desktop" ];
          "application/x-compressed-tar" = [ "dev.duxlabs.files.desktop" ];
          "application/x-bzip2" = [ "dev.duxlabs.files.desktop" ];
          "application/x-bzip2-compressed-tar" = [ "dev.duxlabs.files.desktop" ];
          "application/x-xz" = [ "dev.duxlabs.files.desktop" ];
          "application/x-xz-compressed-tar" = [ "dev.duxlabs.files.desktop" ];
          "application/zstd" = [ "dev.duxlabs.files.desktop" ];
          "application/x-zstd-compressed-tar" = [ "dev.duxlabs.files.desktop" ];
          "application/x-lzma" = [ "dev.duxlabs.files.desktop" ];
          "application/x-lzma-compressed-tar" = [ "dev.duxlabs.files.desktop" ];
          "application/x-7z-compressed" = [ "dev.duxlabs.files.desktop" ];
          "application/vnd.rar" = [ "dev.duxlabs.files.desktop" ];
          "application/x-cpio" = [ "dev.duxlabs.files.desktop" ];
        };
      })
];
  };
}
