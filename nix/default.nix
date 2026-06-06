{ nixpkgs, ... }:
{
  imports = [
    ./substituters.nix
    ./nh.nix
    ./nixpkgs.nix
  ];

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
    nixPath = [ "nixpkgs=${nixpkgs}" ];
  };

  systemd.services.nix-daemon.environment = {
    GOPROXY = "https://goproxy.cn,direct";
  };
}
