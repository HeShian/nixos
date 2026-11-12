# 采用 diagram-demo 的分组形态：aspects/{den,defaults,features,hosts,users}

`templates/default` 的扁平布局是 7 文件起步形态；规模放大到 36 个 aspect 后，全铺在 `modules/` 会让入口层失去信息。`templates/diagram-demo` 提供了按类别分组的形态，本项目采用它：`modules/dendritic.nix` 负责 Den 的 flake 接入，`modules/aspects/` 下按类别分目录——`den.nix` 只放 `den.hosts` 声明与 `den.schema`，`defaults.nix` 只放 `den.default`，每个 aspect 一个文件放在 `features/`、`hosts/`、`users/` 之一。

取代 ADR-0002 的扁平布局。`features/` 下不再按域细分（不做 `features/desktop/`、`features/system/`）：aspect 名已经带域前缀，多一层目录只增加路径长度。`roles/` 不采用——只有两台机器，没有角色复用。
