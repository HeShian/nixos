{ inputs, ... }:
{
  # 默认应用关联：双击文件、浏览器链接、“打开方式”走哪个桌面项。
  den.aspects.desktop-mimeapps = {
    homeManager = { pkgs, ... }:
    let
      zen = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta;
      zenDesktop = "${zen.meta.mainProgram}.desktop";
    in {
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = [ zenDesktop ];
          "application/xhtml+xml" = [ zenDesktop ];
          "x-scheme-handler/http" = [ zenDesktop ];
          "x-scheme-handler/https" = [ zenDesktop ];

          "image/png" = [ "imv.desktop" ];
          "image/jpeg" = [ "imv.desktop" ];
          "image/gif" = [ "imv.desktop" ];
          "image/webp" = [ "imv.desktop" ];
          "image/bmp" = [ "imv.desktop" ];
          "image/tiff" = [ "imv.desktop" ];
          "image/svg+xml" = [ "imv.desktop" ];

          "video/mp4" = [ "mpv.desktop" ];
          "video/webm" = [ "mpv.desktop" ];
          "video/x-matroska" = [ "mpv.desktop" ];
          "video/avi" = [ "mpv.desktop" ];
          "video/quicktime" = [ "mpv.desktop" ];

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

          # ── 日历：Dux Calendar（webcal 订阅与 .ics 文件） ──
          "text/calendar" = [ "dev.duxlabs.calendar.desktop" ];
          "text/x-vcalendar" = [ "dev.duxlabs.calendar.desktop" ];
          "application/ics" = [ "dev.duxlabs.calendar.desktop" ];
          "x-scheme-handler/webcal" = [ "dev.duxlabs.calendar.desktop" ];
          "x-scheme-handler/webcals" = [ "dev.duxlabs.calendar.desktop" ];

          # ── 文本：Dux 便签（dev.duxlabs.shell.notepad.desktop 由 dux-shell 提供） ──
          # 该桌面项就是 `dms ipc call notepad openFile %f`，NoDisplay 但仍然可作默认程序。
          "text/plain" = [ "dev.duxlabs.shell.notepad.desktop" ];
          "text/markdown" = [ "dev.duxlabs.shell.notepad.desktop" ];

          "application/json" = [ "code.desktop" ];
          "application/x-shellscript" = [ "code.desktop" ];
          "text/x-csrc" = [ "code.desktop" ];
        };
      };
    };
  };
}
