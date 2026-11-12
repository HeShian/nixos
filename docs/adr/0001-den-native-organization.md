# 用 Den 的机制组织配置，而不是自建等价物

Status: accepted；其中「目录布局」部分已由 [ADR-0002](0002-flat-modules-layout.md) 取代。

Den 已经为三类需求提供了机制，本项目一律使用它们：对所有实体成立的设置走 `den.default`（`stateVersion`、home-manager 三个开关、`nh.flake` 的仓库路径约定），用户 class 走 `den.schema.user.classes`，跨 class 的通用能力走 `den.batteries.*`（`primary-user`、`user-shell`、`unfree`）。此前自建的 `host-base` aspect 与手写的组/shell/unfree 白名单都已删除——它们等价但要求每次新增 host 时记得 include。

布局原定为「分组目录 + 扁平 aspect 名」（`modules/aspects/<域>/<关注点>.nix`），后按 `templates/default` 改为扁平 `modules/`，见 ADR-0002。

不采用嵌套 aspect（`den.aspects.desktop.packages`）：Den 支持它，但官方模板一律用扁平名，嵌套只是给引用和搜索多加一层，没有换来实现能力。

非 aspect 的辅助代码放 `modules/_lib/`——import-tree 的默认过滤会跳过含 `/_` 的路径，因此不会被当成模块加载。

一处例外：`user-shell` battery 会在 home 层启用 fish，而 home-manager 的 fish 模块会生成 `~/.config/fish/config.fish`，与活链接的 dotfile 撞车。dotfiles 里那份是唯一来源，所以 `modules/_lib/dotfiles.nix` 对 `fish/config.fish` 用 `lib.mkForce` 让它胜出；home-manager 仍负责补全文件与 `hm-session-vars.fish`。
