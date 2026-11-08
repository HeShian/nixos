{
  den.aspects.desktop-fonts.nixos = { pkgs, ... }: {
    fonts.packages = with pkgs; [ noto-fonts noto-fonts-cjk-sans noto-fonts-color-emoji ];
  };
}
