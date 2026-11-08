{
  den.aspects.system-defaults.nixos = {
    time.timeZone = "Asia/Shanghai";
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
