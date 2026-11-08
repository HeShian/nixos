{
  den.aspects.desktop-audio.nixos = {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    security.rtkit.enable = true;
    xdg.sounds.enable = true;
  };
}
