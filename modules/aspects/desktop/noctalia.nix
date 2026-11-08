{ inputs, ... }:
{
  den.aspects.noctalia = {
    nixos.services.upower.enable = true;

    homeManager = {
      imports = [ inputs.noctalia.homeModules.default ];
      programs.noctalia.enable = true;
    };
  };
}
