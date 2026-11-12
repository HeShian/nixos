# 把每个 host / user 暴露成 flake 包，方便 `nix build .#acer`、`nix run .#claudia` 这类用法，
# 也正好是 nh 的 denPackages 约定。
{ den, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = den.lib.nh.denPackages { fromFlake = true; } pkgs;
    };
}
