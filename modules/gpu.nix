{
  den.aspects.gpu.nixos = { pkgs, ... }: {
    # Intel 核显（i915）驱动 eDP-1，补上 VA-API 视频硬解
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # iHD 驱动，Gen9+ 核显硬解
        libva-utils # 提供 vainfo 排查工具
      ];
    };

    # NVIDIA 独显：Optimus / PRIME render offload
    services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

    hardware.nvidia = {
      # GTX 16xx（Turing）及以上使用开源内核模块
      open = true;
      modesetting.enable = true;
      nvidiaSettings = true;
      powerManagement.enable = true;
      videoAcceleration = true;

      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
        offload = {
          enable = true;
          enableOffloadCmd = true; # 提供 nvidia-offload 命令
        };
      };
    };
  };
}
