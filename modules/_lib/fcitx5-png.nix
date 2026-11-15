pkgs:
pkgs.writeShellApplication {
  name = "fcitx5-png";
  runtimeInputs = with pkgs; [
    coreutils
    diffutils
    gawk
    imagemagick
    systemd
    util-linux
  ];
  text = builtins.readFile ./scripts/fcitx5-png.sh;
}
