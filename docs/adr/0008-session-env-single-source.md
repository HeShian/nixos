# 会话环境表单一来源：_lib/session-env.nix 写 environment.sessionVariables

Status: accepted

登录会话的环境变量原先有三个写入者：`niri.nix` 的 `environment.sessionVariables`（`EDITOR`、`TERMINAL`、`XCURSOR_*`、Wayland 提示）、`desktop-localization.nix` 的 `environment.variables`（三个输入法变量）、以及 Dotfile 的 `config.kdl` 里 `environment {}` 块（再写一遍 `LANG`、`LANGUAGE`、`XMODIFIERS`、`QT_IM_MODULE(S)`、`SDL_IM_MODULE`、`GTK_IM_MODULE`、`EDITOR`、`TERMINAL`）。

实测（2026-11-13）：niri 的 `/proc/<pid>/environ` 里已经带着系统环境的 `LANG`、`XMODIFIERS`、`QT_IM_MODULE(S)`、`SDL_IM_MODULE`、`EDITOR`、`TERMINAL`、`XCURSOR_*`；Dotfile 的块只影响 niri 的子进程（采样一个 niri 拉起的 `wl-paste`，它的 `GTK_IM_MODULE` 只可能来自那里）。而 `GTK_IM_MODULE` 与 `LANGUAGE` 不在 `systemctl --user show-environment` 里 —— 由 systemd 启动的应用（DMS 拉起的应用、用户服务）拿不到，fcitx 的 GTK 路径在这些程序里进不来。

## 决定

1. 表在 `modules/_lib/session-env.nix`，interface 是 `{ appearance }` → attrset；`XCURSOR_*` 仍取自 `modules/_lib/appearance.nix`（ADR-0006）。
2. 唯一写入点是 `environment.sessionVariables`：它进 PAM 会话，niri 与 systemd 用户管理器都能拿到。不用 `environment.variables`（会把 GUI 变量暴露给系统服务），也不用 HM 的 `home.sessionVariables`（只进 shell，GUI 应用拿不到）。
3. 删除 Dotfile 的 `environment {}` 块：系统环境本来就随 niri 进程继承，那个块是同一批值的第二份。`LANG` 不放进表 —— 它由 `i18n.defaultLocale` 产生。
4. `GTK_IM_MODULE` 与 `LANGUAGE` 因此被补进系统侧，补上上面那个缺口。
5. `modules/checks.nix` 增加 `session-env-single-source`：断言两台 Host 的 `environment.sessionVariables` 每个键都与表一致，且 `config.kdl` 里不再出现行首的 `environment {` 块。

## 边界

- 系统级 locale 仍归 `i18n`；`LANGUAGE` 放会话表是因为它只影响会话内的界面语言偏好。
- Dotfile 的 `config.kdl` 仍可写 niri 独有的配置（`input`、`layout`、`cursor` 由 `appearance.kdl` 提供），只是不再承载环境变量。
- 这条不变量是「Dotfile 不写 environment 块」，不是「所有 `environment` 字样都禁止」—— `dms/*.kdl` 这类运行时片段不受影响。

## 后果

- 新增一个会话变量只改 `_lib/session-env.nix`；Dotfile 少 22 行、`desktop-localization` 少 6 行。
- 已登录的会话在重新登录前仍是旧环境：`GTK_IM_MODULE`/`LANGUAGE` 要等下一次登录才由系统会话提供（fcitx5 的 Wayland 前端此前已在工作，退化有限）。
- 谁把变量挪回 Dotfile，`nix flake check` 会失败。
