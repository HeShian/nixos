# 后续改进候选

记录「评估过、暂时不做」和「已知债务」的清单，每条都写清楚**触发条件**——没有触发条件就不值得动。需要跟踪进度时，按 `AGENTS.md` 的规则在 `HeShian/nixos` 开 issue，本文件只做候选池。

## Den / 结构

- [ ] **用 policy 代替 provides** —— 当出现「某台机器要给它的所有用户统一下发某段 home 配置」时，按 Den 文档用 `den.policies.*` + `den.schema.user.includes`，而不是 `provides.to-users`（理由见 ADR-0004）。触发：真的出现这种需求。
- [ ] **`modules/vm.nix`（`nix run .#vm`）** —— `templates/default` 提供：把 `system.build.vm` 包成一个 app，改完配置起测试 VM，不必切真机。代价：一个 perSystem 包，可能还要 `den.batteries.tty-autologin`。触发：需要在真机之外反复试验桌面改动时。
- [ ] **flake-file 集成** —— `templates/default` 用 `vic/flake-file` 自动生成 `flake.nix`，inputs 与模块声明集中；`den.flakeModules.dendritic` 依赖它（我们目前用 `flakeModules.default`）。代价：多一个输入 + 一个生成文件。触发：inputs 增长到难以维护，或想用 `nix run .#write-flake`。
- [ ] **`roles/` 扩展** —— 目前只有 `roles/desktop.nix`（两台机器共用）。触发：VM 需要更小的集合时，加 `roles/minimal.nix` 并让 `nixos-vm` 改 include 它。
- [ ] **dotfiles 链接方式的选择规则** —— 现在由 host aspect 手动 include `dotfiles-live` 或 `dotfiles-store`。触发：新增第三台机器容易忘时，可写成 policy（有仓库克隆 → live，否则 store）。
- [ ] **不采用嵌套 aspect**（`den.aspects.desktop.packages`）—— 已评估：官方模板用扁平名，嵌套只增加引用层级。除非 aspect 数量再翻倍，否则不动。

## 清理与一致性（来自这次审计，未做）

- [ ] **dotfiles 链接粒度不一致** —— 19 条里 17 条是文件级，`niri/scripts` 与 `matugen` 是目录级。统一成目录级可让新增文件自动生效，但也会让"忘了加链接"不再报错。触发：`dotfiles/` 下某类文件经常新增时。
- [ ] **kitty 的 xray 规则重复** —— `dotfiles/.config/niri/blur.kdl` 已有全局规则，`windowrules.kdl` 又给 kitty 写了一份。触发：模糊效果表现异常时顺手合并。
- [ ] **`gtk-{3,4}.0/settings.ini` 双写** —— `desktop-appearance-settings` 的激活脚本与 `matugen/folder-icons.sh` 都写它；当前靠"仅在检测到 breeze/失效主题时才修"兼容，属**值重复 + 条件修复**，不是冲突（见关键记忆）。触发：图标主题表现反直觉时再动。
- [ ] **proxy 的作用域不对称** —— `proxy` aspect 只被 `acer` include，但 `clash-verge` 的 tun/serviceMode 经 `desktop` 也进了 VM。触发：VM 里出现需要/不需要代理的明确需求。
- [ ] **`openssh` 在 acer 与 VM 都开 `PasswordAuthentication = true`** —— 触发：对外的机器要收紧时。
- [ ] **`niri-pick` 的 rofi / hyprpicker fallback 分支** —— 工具未安装，但属于有意的降级链，**不删**；仅记录以免下次被当死代码清掉。
- [ ] **`programs.nh.flake` 在 VM 为 `null`** —— VM 里没有仓库克隆，`nh os switch` 无法工作。触发：需要在 VM 内自建时（克隆仓库或改 remote build）。
- [ ] **`AGENTS.md` 缺常用命令** —— 构建/切换命令只写在 README，agent 入口没有。触发：下一个 agent 又问"怎么构建"时补一行。
- [ ] **`defaults.nix` 与 `system-defaults.nix` 名字相近** —— 前者是 `den.default`（全局），后者是 `system-defaults` aspect。触发：混淆真的发生时再重命名。

## 运维

- [ ] **代理改动需 switch + 新会话** —— `environment.variables` 是系统级设置；`all_proxy` 改 HTTP 那次就属于这一类。
- [ ] **`switch` 需要 sudo 密码** —— 无法由 agent 自动完成，每次结构改动后仍需人工执行。
