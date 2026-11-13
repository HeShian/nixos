# 外观值单一来源：modules/_lib/appearance.nix 加模块参数

Status: accepted

光标主题（`Bibata-Modern-Ice`，24px）原先在六个作用域各写一份：niri 会话变量、dconf、DMS 首启种子、Dux Greeter 的 compositor 配置、niri 的 `cursor {}` 分片，以及 GTK 上代遗留迁移的 fallback 分支。README 与术语表把这套同步手续记成「五处」，实际已经是六处 —— 手抄清单开始漂移，而且漏改只表现为某个界面不对，没有求值期信号。图标 fallback 同理有三处。

## 决定

1. 值集中在 `modules/_lib/appearance.nix`，interface 只有值：`cursor.{theme,size,hideAfterInactiveMs}` 与 `icons.fallback`。它不是 Aspect —— 没有自己的配置，只被分发。
2. 用 `den.default.nixos._module.args.appearance` 与 `den.default.homeManager._module.args.appearance` 挂成两套 module system 的模块参数。不用 `options`：options 会让消费方隐式依赖「承载 aspect 被 include」，而 aspect 组合正是 Host / Role 的接口，漏 include 时表现为 `option undefined`。两套 module system 的参数不共享，必须各挂一次。
3. niri 的 `cursor {}` 不再写在 Dotfile 里：Home Manager 生成 `~/.config/niri/appearance.kdl`，`config.kdl` 在原位置 `include optional=true` 它，与 DMS 运行期片段的相对顺序保持不变。用 optional 而不是强制 include：Dotfile 是活链接、改完即生效，生成文件却要等 activation，`nh os rollback` 时旧代际也不会生成它 —— 强制 include 会让合成器配置在那些窗口里不可解析。缺分片时光标退回会话变量 `XCURSOR_THEME/SIZE`（同一个值），而分片内容由 `nix flake check` 断言，静默失败被覆盖。`hide-after-inactive-ms` 进值表，因为整块被替换后不能指望「两个 cursor 块按 key 合并」—— 那是 issue #3 里待确认的语义。
4. 作用域特有的行为留在作用域：Dux Greeter 的 `hide-after-inactive-ms 0` 是登录界面行为，不取 `appearance` 的值。
5. `modules/checks.nix` 增加 eval 级检查：`nix flake check` 断言四个渲染面与生成分片都等于值模块里的值。检查不写死具体值，所以改光标只需改一个文件。

## 边界

- matugen 的 `folder-icons.sh` 里 `Inherits=Papirus-Dark` 仍是 Dotfile 字面量：它由 Dotfile 自己的 `config.toml` 的 `post_hook` 调用，Nix 注入不到那条命令；它也是缺图时的继承链，不是活动主题。
- DMS 运行期写的 `~/.config/niri/dms/cursor.kdl` 与手写片段的优先级见文末修订与 issue #3。
- 登录界面的 `output "eDP-1" { scale 1.25 }` 与 `outputs.kdl` 的缩放仍是两份：那是「输出事实」，不是外观值，已记入 `docs/backlog.md`。

## 后果

- 改光标或图标 fallback 只需改 `modules/_lib/appearance.nix`；四个渲染面与 niri 分片随之改变，任一渲染面被改回字面量时 `nix flake check` 失败。
- Dotfile 层少了「光标」这一个可手改点。它本来就是固定值，符合 README 的归属表（固定不变 → NixOS / home-manager 模块）。
- 新增 Host 只要 include `desktop` Role 就自动拿到 `appearance` 参数；未启用 Greeter 的 Host 会被 checks 过滤掉，不会误报。

## 2026-11-13 修订：分片移到 DMS 片段之前

原决定把 `appearance.kdl` include 在 Dotfile 里 `cursor {}` 的原位置，也就是 `dms/*.kdl` 之后 —— 那等于让初值反过来覆盖 DMS 光标设置页的改动。issue #3 查清了这类片段的摆放规则（按位置插入，同名设置后者覆盖前者）之后，改为把**手写块与 `appearance.kdl` 一起放在 `dms/*.kdl` 之前**：

- 手写块 = 默认值；DMS 运行期片段 = 用户在界面里改动的权威。`dms/cursor.kdl` 因此能覆盖 `appearance.kdl` 的初值，与本文「interface 是初值」的定位一致。
- 同时确认 `dms/input.kdl` 与 `dms/layout.kdl` **有意不 include**：它们是 DMS 启动时按自身默认值写出的（鼠标 accel 0.0、gaps 4、border 宽度 2、窗口圆角），include 会把手写的显式选择换成 DMS 的默认值。DMS 的「输入」「布局」两页因此不生效，改这两类设置要改 Dotfile。
- 片段 → 位置 → 理由的完整表格在 `dotfiles/.config/niri/config.kdl` 头部。
