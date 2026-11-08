{ den, ... }:
{
  den.hosts.x86_64-linux.nixos-vm.users.user-vm.classes = [ "user" "homeManager" ];

  den.aspects.nixos-vm = {
    includes = [
      den.batteries.hostname
      den.aspects.system-defaults
      den.aspects.system-tools
      den.aspects.development-tools
      den.aspects.qemu-guest
      den.aspects.networkmanager
      den.aspects.openssh
      den.aspects.desktop
    ];

    nixos = { modulesPath, ... }: {
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

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      system.stateVersion = "26.05";
    };
  };
}
