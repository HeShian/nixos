{
  den.aspects.system.nixos = {
    time.timeZone = "Asia/Shanghai";
        nix.settings.experimental-features = [ "nix-command" "flakes" ];

    services.upower.enable = true;
        services.power-profiles-daemon.enable = true;
        services.gvfs.enable = true;
        services.udisks2.enable = true;
  };
}
