# 引入 flake-parts，并把 feature 的组合单独放进 roles/

Den 的官方模板（`default`、`diagram-demo`、`fleet-demo`）都基于 flake-parts；只有采用它才能用 `perSystem` 向外暴露 flake 包。改动是：`flake.nix` 换成 `flake-parts.lib.mkFlake`，`modules/dendritic.nix` 改为导入 `inputs.den.flakeModules.default`（`flakeModules.dendritic` 会写 flake-file 的 input 默认值，需要额外引入 flake-file，本仓库不需要），新增 `modules/nh.nix` 用 `den.lib.nh.denPackages` 把每台 host 暴露成 `nix build .#acer` 这样的包。

同时按 `diagram-demo` 的分层补上 `aspects/roles/`：role 是「把多个 feature 组合成一种机器形态」的 aspect——本仓库只有 `desktop`，它只写 `includes`、几乎不写配置，被两台机器共用。与 `features/` 的分工是：feature 描述「一个关注点的配置」，role 描述「这类机器需要哪些 feature」。

`provides.to-users` / `provides.to-hosts` 没有使用。它们是 host↔user 之间的配置下发通道（host 给它的每个 user 下发 home 配置，或 user 向 host 的 OS 配置写入），我们的内容都写在各自实体自己的 aspect 上；将来若出现「某台机器要给它所有用户统一发某段配置」，Den 文档建议优先用 policy 而不是 `provides`。
