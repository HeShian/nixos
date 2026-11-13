# 采用 diagram-demo 的分组形态：aspects/{den,defaults,features,hosts,users}

参考上游：`github:denful/den` 的 `templates/diagram-demo`（本仓库 `flake.lock` pin 在 `bf2504f9f2e8621fee091335132ab3ae698cf808`）。

`templates/default` 的扁平布局是 7 文件起步形态；规模放大到 36 个 aspect 后，全铺在 `modules/` 会让入口层失去信息。`templates/diagram-demo` 提供了按类别分组的形态，本项目采用它：`modules/flake-parts.nix` 负责 Den 的 flake 接入，`modules/aspects/` 下按类别分目录——`den.nix` 只放 `den.hosts` 声明与 `den.schema`，`defaults.nix` 只放 `den.default`，Aspect 定义按类别放在 `features/`、`hosts/`、`users/` 中。

取代 ADR-0002 的扁平布局。`features/` 下不再按域细分（不做 `features/desktop/`、`features/system/`）：aspect 名已经带域前缀，多一层目录只增加路径长度。`roles/` 后来在 ADR-0004 中补上：`desktop` 这种「把一组 feature 组合成一种机器形态」的 aspect 放在那里，与纯 feature 分开。

## 2026-11-13 修订：按关注点组织文件

取消本记录原先沿用 ADR-0002 的「一个文件一个 Aspect、文件名必须等于 Aspect 名」约定。`features/` 已有 30 个文件，维护者明确指出导航负担；按安装、默认关联、应用接线拆文件，也让同一个应用的知识散落多处。

文件按共同维护的关注点命名，可以定义多个相关 Aspect。Aspect 是否独立取决于实际组合与复用需求；放在同一文件不会使它们必须一起启用。一个关注点需要多个实现文件时，也无需为每个文件创建独立 Aspect。

这与锁定版本的 [diagram-demo/greeters.nix](https://github.com/denful/den/blob/bf2504f9f2e8621fee091335132ab3ae698cf808/templates/diagram-demo/modules/aspects/features/greeters.nix) 一致：同一文件定义 `regreet`、`gdm`、`sddm` 三个 Aspect。因此一文件一 Aspect 是本项目过去的约定，并非模板要求。

取舍是无法再仅凭 Aspect 名推导唯一文件名，需要搜索其定义；换来相关声明就近维护，并避免仅为满足文件约定而拆出新的 Aspect。此次修订保留现有类别目录和 Role 的组合职责；应用职责的收拢见 [ADR-0005](0005-application-ownership.md)。

应用收拢后仍有 28 个 feature 文件，导航负担未消除，因此进一步按应用、外观、本地化、niri 会话、Dux、Dotfile、网络、硬件、系统设置和工具归为 10 个文件。共同启用的能力合并为一个 Aspect：应用、外观、本地化、niri、Dux、系统与工具。Dotfile live/store、GPU/QEMU、通用网络/代理保留独立 Aspect，因为 Host 有实际选择差异。文件内按职责分段，Host / Role 通过这些公开关注点组合。具体文件索引见 README。

命名沿用上游的小写、连字符风格，文件名表达关注点；单 Aspect 文件与名称对应，相关且独立选择的多个 Aspect 可共处一个文件。`den.nix`、`defaults.nix` 是实体与默认声明入口，不套用 Aspect 文件命名规则。Den 接入入口改名为 `modules/flake-parts.nix`，对应模板位置；保留本项目的 `nh.nix` 包导出与 `_lib/` 辅助实现。
