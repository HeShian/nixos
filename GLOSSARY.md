# NixOS 配置（acer / nixos-vm）

本仓库是一套 niri + Dux 桌面的 NixOS 配置，用 Den 与 home-manager 组织。术语表只收本仓库特有的组织概念：东西放在哪一层、由谁产生、改动后何时生效。

## Language

### 结构

**Host**：
一台机器的完整系统配置，对应一个独立的 flake 属性（`acer`、`nixos-vm`）。
_Avoid_: 机器、profile、配置

**User**：
一个登录用户的 home-manager 配置，按 host 绑定（`claudia`、`user-vm`）。
_Avoid_: 账号、账户

**Aspect**：
按关注点切分的配置单元，可被其它 aspect 通过 includes 组合，并能同时给出系统层与用户层的内容。
_Avoid_: 模块、组件、feature

**Entity**：
Den 的强类型数据记录（host / user / home），声明在 `den.hosts` 之类的位置；aspect 的 context 参数就是实体。
_Avoid_: 对象、记录

**Battery**：
Den 自带的可复用 aspect 提供者（`den.batteries.*`），要显式 include 才生效，用来替代手写的同类配置。
_Avoid_: 插件、工具

**全局默认（den.default）**：
写在 `den.default` 里的设置，Den 会自动注入每一种实体，因此对所有 host / user / home 成立，不需要任何文件 include。
_Avoid_: 公共模块、base

**Role**：
把多个 feature aspect 组合成一种机器形态的 aspect（如 `desktop`），只写 includes、不放具体配置。
_Avoid_: 预设、模式、profile

### 配置归属

**Dotfile**：
纳入版本管理、由 home-manager 链接到 `~/.config` 的纯文本配置，是「保存即生效」的那一层。
_Avoid_: 配置文件（泛指，会与运行时生成文件混淆）

**dotfiles-live**：
把 `~/.config` 里的路径链回仓库工作树的链接方式；改文件立即生效，用于日常使用的机器。
_Avoid_: 软链模式

**dotfiles-store**：
把 `~/.config` 链到 flake store 的链接方式；内容是只读快照，构建后生效，用于 VM。
_Avoid_: Nix 模式

**外观值（appearance）**：
由 Nix 产生、被多个作用域各取一份的外观常量（光标主题与尺寸、图标 fallback），集中在 `modules/_lib/appearance.nix`，通过模块参数 `appearance` 分发。不是 Aspect：它没有自己的配置。
_Avoid_: 主题、样式值（会与 DMS 运行时生成的主题混淆）

**会话环境**：
登录会话导出的环境变量（输入法、默认程序、Wayland 提示、光标），唯一来源是 `modules/_lib/session-env.nix`，由 niri Aspect 写到 `environment.sessionVariables`。Dotfile 的 niri `environment {}` 块不再承载这些值。
_Avoid_: 环境变量（泛指，会与 `environment.variables` 这类系统级设置混淆）

### 状态与遗留

**运行时生成文件**：
由 DMS / matugen 在运行期写入的文件（配色、窗口规则片段等），不入库、不手改；符号链接会被原子写替换。
_Avoid_: 状态（指代不清）

**首启种子**：
模块在激活时「只在文件不存在时」写入的初始值，用来给运行时组件一个可用的起点。
_Avoid_: 默认值（易与 option 默认值混淆）

**上代遗留**：
从旧桌面（noctalia、KDE、Arch）继承下来的路径、配置或 fallback 分支，在本系统上不生效、不匹配，或只能静默失败。
_Avoid_: 死代码（未必该删）

### 重复

**值重复**：
同一个值在多个作用域各写一份（如输入法环境变量同时出现在 niri 的 `config.kdl` 与 `desktop-localization.nix`，`Papirus-Dark` 同时出现在登录界面、GTK 迁移 fallback 与 matugen 脚本里）。各写点互不冲突，但改值必须同步所有位置；能收成单一来源的应收进「外观值」这类位置。
_Avoid_: 重复（未区分性质）

**写点冲突**：
同一个文件、同一个键有两个写入者，最终值取决于执行时序，必须消除其中一个写入者。
_Avoid_: 重复
