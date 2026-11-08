{
  description = "Den configuration for the nixos-vm QEMU guest";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    den.url = "github:denful/den/bf2504f9f2e8621fee091335132ab3ae698cf808";
    import-tree.url = "github:denful/import-tree/eb1b52eaecc57f7c136d07ae8a93e724dfecac46";
    nix-flatpak.url = "github:gmodena/nix-flatpak/f1f045fc8b35ff59f88982c1752d3f3a42ca6a61";
    home-manager = {
      url = "github:nix-community/home-manager/2c0c1f01521469cf0271180c453c79782d53c2f6";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    umbriel.url = "github:noctalia-dev/umbriel/ad46c7d14ca1f59f2874f3df74773f781fb39c80";
    noctalia.url = "github:noctalia-dev/noctalia/76637f9d42fe55186f2251f53f2d31c924a55e38";
  };

  nixConfig = {
    extra-substituters = [
      "https://umbriel.cachix.org"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  outputs = inputs:
    (inputs.nixpkgs.lib.evalModules {
      specialArgs = { inherit inputs; };
      modules = [
        inputs.den.flakeModule
        (inputs.import-tree ./modules)
      ];
    }).config.flake;
}
