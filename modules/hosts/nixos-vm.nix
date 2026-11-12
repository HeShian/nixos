{ den, ... }:
{
  den.hosts.x86_64-linux.nixos-vm = {
    defaultUser = "user-vm";
    users.user-vm = { };
  };

  den.aspects.nixos-vm = {
    includes = [
      den.batteries.hostname
      den.aspects.system-defaults
      den.aspects.system-tools
      den.aspects.system-services
      den.aspects.development-tools
      den.aspects.qemu-guest
      den.aspects.networkmanager
      den.aspects.openssh
      den.aspects.desktop
      # VM 内没有仓库克隆，直接链接 flake 源里的 dotfiles（构建时只读）
      den.aspects.dotfiles-store
    ];

    nixos = { modulesPath, lib, ... }: {
      imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

      boot.loader.grub = {
        enable = true;
        device = "/dev/vda";
      };
      boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" ];
      boot.kernelParams = [ "console=tty0" "console=ttyS0,115200n8" ];
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos-vm";
        fsType = "ext4";
      };

      # VM 里没有仓库克隆，nh 没有可用的默认 flake（置空而非指向不存在的路径）
      programs.nh.flake = lib.mkForce null;
    };
  };
}
