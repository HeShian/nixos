{
  den.aspects.desktop-fonts.nixos = { pkgs, ... }: {
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      # 等宽备用字体
      nerd-fonts.jetbrains-mono
      maple-mono.NF

      # Dux Shell / Dux Greeter 的界面与图标字体
      inter
      material-symbols
    ];
  };

  den.aspects.desktop-fonts.homeManager = { pkgs, ... }:
    let
      version = "1.2304.79";
      jetbrainsMapleMono = pkgs.runCommand "jetbrains-maple-mono-${version}" {
        nativeBuildInputs = [ pkgs.unzip ];
        src = pkgs.fetchurl {
          url = "https://github.com/SpaceTimee/Fusion-JetBrainsMapleMono/releases/download/${version}/JetBrainsMapleMono-NF-XX-XX-XX.zip";
          hash = "sha256-Wu9Qva7hbUrfNiB7Tw5O77h6T5Y2rrdZWa4yyBM7LHU=";
        };
      } ''
        mkdir -p "$out"
        unzip -j "$src" '*.ttf' -d "$out"
      '';
    in {
      xdg.dataFile."fonts/jetbrains-maple-mono" = {
        source = jetbrainsMapleMono;
        recursive = true;
      };
    };
}
