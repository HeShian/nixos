# activation 逻辑放 _lib/scripts，路径由 Nix 求值后显式传入

Status: accepted

首启种子、DMS 缺键补齐与 GTK 上代遗留迁移原先都内联在 `desktop-appearance.nix` 的 Nix 字符串里（约 150 行 bash），唯一的入口是「跑一次整机 activation」：不能传参、不能喂 fixture、不能断言，shellcheck 也覆盖不到。三处已知缺陷就是这样漏过去的 —— 同一段里 `run install -d` 与裸 `install -d` 混用（干跑仍写盘）、`$HOME/Pictures` 与同脚本别处的 `config.xdg.userDirs` 不一致、jq 失败被 `2>/dev/null` 吞掉导致缺键补齐静默不发生。

## 决定

1. 三段 shell 移入 `modules/_lib/scripts/*.sh`，由 `modules/_lib/appearance-scripts.nix` 用 `pkgs.writeShellApplication` 打包（构建期 shellcheck，`runtimeInputs` 声明命令依赖）；activation 只负责接线。
2. 脚本的 interface 是显式参数：`--config/--data/--cache/--state/--pictures/--templates` 与具体输入文件；脚本里不再出现 `$HOME` 或 `${XDG_*:-…}`。
3. 路径以 Nix 求值结果为唯一权威。HM 激活是 systemd 服务 `home-manager-<user>.service`（`User=<user>`），其 `Environment=` 里没有 `XDG_*`，会话侧当前也没有 ——「环境优先」在激活里恒等于默认值，只会绕过 `config.xdg.*`。
4. `--dry-run` 由脚本自己处理：activation 只在 HM 的 `DRY_RUN` 存在时传下去。种子逐动作回显；GTK 迁移在干跑时只做分析并打印结论，不建目录、不加锁、不写文件。
5. 失败策略分两类：缺参数或输入不可读按用法错误 `exit 2`，让激活失败；用户态数据（`settings.json` 不是合法 JSON）只警告并保留原文件，`exit 0`。
6. `modules/checks.nix` 增加三条脚本检查与一条锁路径检查：临时目录里跑真实脚本，断言种子就位、幂等、干跑不写盘、已有文件不被覆盖、坏 JSON 保留原文件、用户自选主题保留，以及 GTK 迁移与 matugen 算出同一个锁路径。

## 边界

- `fcitx5-classicui-link`（一行链接）与 `dms-vscode-theme`（应用接线）没有生命周期问题，仍留在各自 Aspect 里。
- `folder-icons.sh` 是 Dotfile 脚本，不由 Nix 打包；它与迁移脚本的路径一致性由锁路径检查对照，而不是共用代码。
- 脚本检查不经过 `home-manager-generation/activate`：DAG 顺序与 `DRY_RUN` 传递由接线方式保证，实际行为以一次 `switch` 验收。

## 后果

- 改种子或迁移行为只需读一个 `.sh`，可在临时目录直接复现；shellcheck 在构建期拦下引用错误（这次就拦下了 `$key[[:space:]]` 被当成数组下标）。
- 路径只有一个算法（`mkPaths`）。若将来有人把 `xdg.dataHome` 改成非默认值，锁路径检查会失败，逼一次显式决定。
- 干跑不再写盘，`nixos-rebuild dry-activate` 的语义恢复。
