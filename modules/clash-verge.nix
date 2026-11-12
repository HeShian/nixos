{ den, ... }:
{
  den.aspects.clash-verge.nixos.programs.clash-verge = {
    enable = true;
    serviceMode = true;
    tunMode = true;
    group = "users";
  };
}
