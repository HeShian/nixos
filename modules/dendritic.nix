{ inputs, ... }:
{
  # Den 的 flake 集成入口。输入本身在 flake.nix 的 inputs 里声明，
  # 这里只负责把这个 flakeModule 接进 evalModules（与 templates/default 的 dendritic.nix 同职）。
  imports = [ inputs.den.flakeModule ];
}
