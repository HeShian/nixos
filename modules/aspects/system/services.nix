{ den, ... }:
{
  # 机器级服务：电源、挂载、蓝牙，以及系统 profile 里的图标/光标/glib。
  #
  # 为什么放系统层而不是桌面层：这些是「机器需要」而不是「桌面需要」。
  # 放进桌面 aspect 时，VM 会因为 include 了 desktop 而被动拿到蓝牙与电源管理；
  # 独立成 aspect 后，哪台机器不需要就把它从 includes 里拿掉。
  #
  # 注意：这些包仍被 DMS 与 Dux Greeter 使用，当前两个 host 都必须 include 本 aspect。
  den.aspects.system-services = {
    nixos = { pkgs, ... }: {
      # DMS 的电池 / 电源模式 / 蓝牙 / 文件挂载组件
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
      services.gvfs.enable = true;
      services.udisks2.enable = true;

      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = true;

      # 放在系统 profile 而不是 HM，因为：
      #   - Dux Greeter 以 dms-greeter 用户运行，看不到普通用户的 HM 包；
      #   - DMS 的图标/光标探测会调用 gsettings（glib），并扫描 XDG_DATA_DIRS 里的图标主题；
      #   - DMS 的系统监视器/任务管理器会调用 dgop，dms.service 的 PATH 需要能找到它。
      environment.systemPackages = with pkgs; [
        glib # gsettings / gio
        adwaita-icon-theme
        hicolor-icon-theme
        papirus-icon-theme # Papirus-Dark，DMS/GTK 图标主题
        bibata-cursors # Bibata-Modern-Ice，光标主题
        dux-gop # dgop：DMS 的系统监视器数据源；终端里 `dgop top` 替代 btop
      ];
    };
  };
}
