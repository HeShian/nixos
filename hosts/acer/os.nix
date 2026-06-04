{ host, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  system.stateVersion = "26.05";
  networking.hostName = host;

  # NVIDIA 混合显卡（Intel iGPU 主渲染 + NVIDIA dGPU 按需 offload）
  hardware.nvidia = {
    modesetting.enable = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    powerManagement.enable = true;
  };
  hardware.opengl.enable = true;
}
