# 用 Den 的机制组织配置，而不是自建等价物

Den 已经为三类需求提供了机制，本项目一律使用它们：对所有实体成立的设置走 `den.default`（`stateVersion`、home-manager 三个开关、`nh.flake` 的仓库路径约定），用户 class 走 `den.schema.user.classes`，跨 class 的通用能力走 `den.batteries.*`（`primary-user`、`user-shell`、`unfree`）。此前自建的 `host-base` aspect 与手写的组/shell/unfree 白名单都已删除——它们等价但要求每次新增 host 时记得 include。

布局保留 Den 模板验证过的**分组目录 + 扁平 aspect 名**：`modules/aspects/<域>/<关注点>.nix` 里定义 `den.aspects.<域>-<关注点>`。`templates/default` 那种 7 文件扁平布局面向起步项目，本项目 aspect 数量已经远多于它；`templates/example`、`fleet-demo` 是与我们同规模的先例。

不采用嵌套 aspect（`den.aspects.desktop.packages`）：Den 支持它，但官方模板一律用扁平名，嵌套只是给引用和搜索多加一层，没有换来实现能力。

非 aspect 的辅助代码放 `modules/_lib/`——import-tree 的默认过滤会跳过含 `/_` 的路径，因此不会被当成模块加载。
