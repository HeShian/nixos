{ den, ... }:
{
  den.aspects.acer = {
    includes = [
      den.batteries.hostname
      den.aspects.system
      den.aspects.tools
      den.aspects.gpu
      den.aspects.networking
      den.aspects.proxy
      den.aspects.desktop
      # 仓库内的 dotfiles 以“活链接”方式挂到 ~/.config，改完即生效
      den.aspects.dotfiles-live
    ];

    nixos = { modulesPath, ... }: {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

      boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "uas" "sd_mod" ];
      boot.kernelModules = [ "kvm-intel" ];

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/858f6bfd-73d5-4e4b-9c3e-e14e492f14ae";
        fsType = "btrfs";
      };
      fileSystems."/home" = {
        device = "/dev/disk/by-uuid/858f6bfd-73d5-4e4b-9c3e-e14e492f14ae";
        fsType = "btrfs";
        options = [ "subvol=home" ];
      };
      fileSystems."/nix" = {
        device = "/dev/disk/by-uuid/858f6bfd-73d5-4e4b-9c3e-e14e492f14ae";
        fsType = "btrfs";
        options = [ "subvol=nix" ];
      };
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/22D3-B58B";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
        priority = 100;
      };

      swapDevices = [
        {
          device = "/var/lib/swapfile";
          size = 16 * 1024;
        }
      ];

    };
  };
}
