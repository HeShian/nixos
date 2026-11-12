{
  # Dux 生态：DMS + Dux Search + Dux Files + Dux Calendar（Dux Greeter 在 dux-greeter.nix）。
  # nixpkgs 的 programs.dux-shell 模块提供：
  #   - dms.service（WantedBy=graphical-session.target）
  #   - dux-shell / quickshell / matugen / cava 进系统 PATH
  #   - hardware.graphics / hardware.i2c / accounts-daemon
  den.aspects.dux-shell = {
    nixos = { config, lib, ... }: {
      programs.dux-shell.enable = true;
      programs.dux-search.enable = true; # 文件索引：dfiles 内容搜索 / DMS 启动器

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

      # nixpkgs 的 programs.niri 默认把 FileChooser 交给 gtk；
      # 这里改成 dfiles 优先、gtk 兜底（Flatpak / Firefox / Chromium 的对话框走这里）。
      xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" = lib.mkForce [
        "dfiles"
        "gtk"
      ];

      # 系统级服务（upower / power-profiles-daemon / gvfs / udisks2 / 蓝牙）
      # 与系统 profile 的图标、光标、glib 包已移到 system-services aspect。
    };
  };
}
