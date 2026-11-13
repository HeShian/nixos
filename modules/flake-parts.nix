{ inputs, ... }:
{
  # Den 的 flake-parts 集成入口。输入本身在 flake.nix 的 inputs 里声明。
  #
  # 用 flakeModules.default（纯模块，不依赖 flake-file）：
  # flakeModules.dendritic 会额外写 flake-file 的 input 默认值，需要引入 flake-file 输入。
  imports = [ inputs.den.flakeModules.default ];
}
