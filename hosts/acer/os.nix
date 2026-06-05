{ host, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  system.stateVersion = "26.05";
  networking.hostName = host;

  # 启用 NVIDIA 专有驱动
  services.xserver.videoDrivers = [ "nvidia" ];

  # NVIDIA 专有驱动（混合显卡模式）
  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    modesetting.enable = true;

    # 电源管理
    powerManagement.enable = true;
    powerManagement.finegrained = true;

    # Optimus 混合显卡：Intel iGPU 主渲染 + NVIDIA dGPU 按需 offload
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # 禁用 nouveau，使用 NVIDIA 专有驱动
  boot.blacklistedKernelModules = [ "nouveau" ];

  # OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    # 硬件解码包
    extraPackages = with pkgs; [
      # Intel VAAPI（iGPU 硬件解码）
      intel-media-driver   # iHD — 第 8 代+ Intel GPU
      intel-vaapi-driver   # i965 — 旧 Intel GPU（后备）
      libvdpau-va-gl       # VDPAU → VAAPI 桥接

      # NVIDIA VDPAU / NVDEC（dGPU 硬件解码）
      nvidia-vaapi-driver  # NVIDIA VA-API（通过 NVDEC）
      vdpauinfo            # VDPAU 调试工具
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  # 环境变量：指定 VA-API 驱动
  environment.sessionVariables = {
    # Intel iGPU 使用 iHD 驱动
    LIBVA_DRIVER_NAME = "iHD";
    # NVIDIA offload 时使用 nvidia 驱动
    # 运行时可通过 __NV_PRIME_RENDER_OFFLOAD=1 切换
    MOZ_DISABLE_RDD_SANDBOX = "1";  # Firefox 硬件解码需要
  };

  # Firefox 硬件解码
  programs.firefox = {
    enable = true;
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
      "media.hardware-video-decoding.enabled" = true;
      "gfx.webrender.all" = true;
    };
  };
}
