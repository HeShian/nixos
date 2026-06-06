# Neovim

本配置使用 [NixVim](https://github.com/nix-community/nixvim) 通过 Nix 模块声明式管理 Neovim，无需 lazy.nvim 或 Mason。

**[English](../en/neovim.md)**

---

## 打开方式

- 终端中输入 `nvim`
- 桌面环境中使用 Niri 快捷键（参见 `home/programs/desktop/niri/`）

---

## 基本操作

| 按键 | 功能 |
|------|------|
| `S` | 保存文件 |
| `Q` | 关闭当前缓冲区 |
| `<Space>1` ~ `<Space>5` | 切换到第 1~5 个缓冲区 |
| `<Space>o` | 打开文件浏览器 (mini.files) |
| `<Esc><Esc>` | 退出终端模式 |

Leader 键为 `Space`（空格键）。

---

## 文件查找 (Telescope)

| 按键 | 功能 |
|------|------|
| `<Space>ff` | 查找文件 |
| `<Space>fb` | 查找缓冲区 |
| `<Space>fd` | 查看诊断信息 |
| `<Space>fr` | 查看寄存器 |

---

## LSP 操作

本配置通过 Nix 管理所有 LSP 服务器，无需 Mason。

### 代码导航

| 按键 | 功能 |
|------|------|
| `gd` | 跳转到定义 |
| `gD` | 跳转到声明 |
| `gr` | 查找引用 |
| `gI` | 跳转到实现 |
| `gy` | 跳转到类型定义 |
| `K` | 显示悬停文档 |

### 代码编辑

| 按键 | 功能 |
|------|------|
| `<Space>lr` | 重命名符号 |
| `<Space>la` | 代码操作 |
| `<Space>lf` | 查找符号 |
| `<Space>lo` | 显示符号大纲 |

### 诊断导航

| 按键 | 功能 |
|------|------|
| `[` | 上一个诊断 |
| `]` | 下一个诊断 |
| `<Space>lE` | 显示诊断浮窗 |

---

## 文本跳转 (Hop)

| 按键 | 功能 |
|------|------|
| `<Space>hw` | 跳转到单词 |
| `<Space>hl` | 跳转到行 |

---

## 移动代码 (mini.move)

| 按键 | 功能 |
|------|------|
| `Ctrl+h` | 向左移动 |
| `Ctrl+l` | 向右移动 |
| `Ctrl+k` | 向上移动 |
| `Ctrl+j` | 向下移动 |

可视模式下同样生效，可移动选中的代码块。

---

## AI 补全 (Copilot)

| 按键 | 功能 |
|------|------|
| `Ctrl+l` | 接受建议 |
| `Ctrl+Tab` | 下一条建议 |
| `Ctrl+Shift+Tab` | 上一条建议 |
| `Ctrl+h` | 关闭建议 |

---

## 其他快捷键

| 按键 | 功能 |
|------|------|
| `<Space>ff` | Telescope 查找文件 |
| `<Space>fd` | Telescope 诊断 |
| `<Space>fb` | Telescope 缓冲区 |
| `<Space>m` | 最小地图 (minimap) |

按 `<Space>` 后等待片刻，which-key 会弹出所有可用快捷键提示。

---

## 已安装的 LSP 服务器

| 语言 | LSP 服务器 | 说明 |
|------|-----------|------|
| Python | pyright | 类型检查 |
| Python | ruff | 代码检查和格式化 |
| Lua | lua_ls | Lua 语言服务 |
| Nix | nixd | Nix 语言服务，支持 NixOS/HM 选项补全 |
| Nix | nil_ls | 备选 Nix 语言服务 |
| LaTeX | texlab | LaTeX 语言服务 |
| QML | qmlls | Qt QML 语言服务 |
| Markdown | harper_ls | 语法和风格检查 |
| R | r_language_server | R 语言服务 |

---

## 已安装的格式化工具

| 文件类型 | 格式化工具 |
|---------|-----------|
| Bash / Shell | shfmt, shellcheck, shellharden |
| CSS / SCSS / HTML / JSON | prettier |
| Lua | stylua |
| Markdown | prettier + injected |
| Nix | nixfmt + injected |
| YAML | yamlfmt |
| Python | ruff |
| LaTeX | latexindent |

格式化在保存时自动执行（500ms 超时），回退到 LSP 格式化。

---

## 已安装的 Tree-sitter 语法

以下语言的语法解析器已预装，支持语法高亮和缩进：

bash, fish, python, yaml, lua, json, nix, regex, toml, vim, markdown, rust, jsonc, glsl, css, hyprlang, r, diff

---

## 插件列表

### 编辑增强
- **sleuth** — 自动检测缩进设置
- **nvim-surround** — 包围文本对象
- **repeat** — 用 `.` 重复插件操作
- **lastplace** — 恢复光标到上次编辑位置
- **nvim-autopairs** — 自动关闭括号/引号
- **endwise** — 自动添加 `end`（Ruby/Lua 等）
- **markdown-preview** — 浏览器中预览 Markdown

### 补全 (nvim-cmp)
- **cmp-buffer** — 缓冲区单词补全
- **cmp-path** — 文件路径补全
- **cmp-spell** — 拼写建议
- **cmp-emoji** — 表情补全
- **cmp-nvim-lsp** — LSP 补全

### LSP / 诊断
- **conform-nvim** — 格式化运行器
- **lsp-format** — LSP 格式化集成
- **lspsaga** — 增强 LSP 界面
- **trouble** — 诊断列表
- **lsp-signature** — 函数签名提示
- **otter** — 嵌入式语言支持

### 界面
- **telescope** — 模糊查找器
- **bufferline** — 标签栏
- **lualine** — 状态栏
- **which-key** — 快捷键提示
- **gitsigns** — Git 变更标记
- **indent-blankline** — 缩进参考线
- **scrollview** — 滚动条
- **web-devicons** — 文件图标
- **render-markdown** — 编辑器内 Markdown 渲染
- **codewindow-nvim** — 代码缩略图 (minimap)
- **navbuddy** — LSP 符号导航树
- **colorizer** — 颜色代码高亮
- **smartcolumn** — 文本宽度参考线
- **fidget** — LSP 进度通知
- **fastaction** — 代码操作提示

### 语法
- **treesitter** — 语法高亮、缩进、自动安装
- **hmts** — 用户定义函数参数高亮
- **rainbow-delimiters** — 彩色括号

### 工具
- **mini.files** — 文件浏览器
- **mini.align** — 文本对齐
- **mini.hipatterns** — 高亮模式
- **mini.indentscope** — 缩进范围指示
- **mini.move** — 代码移动
- **hop** — 快速跳转
- **copilot-lua** — GitHub Copilot
- **fcitx-vim** — fcitx 输入法支持（中文/日文/韩文）

---

## 自定义

配置文件位于 `home/programs/coding/nixvim/`：

| 文件 | 内容 |
|------|------|
| `default.nix` | 主入口：全局设置、基础快捷键、编辑增强插件 |
| `lsp.nix` | LSP 服务器、格式化工具、LSP UI |
| `cmp.nix` | 补全引擎和补全源 |
| `treesitter.nix` | Tree-sitter 语法解析器 |
| `ui.nix` | 界面插件（Telescope、bufferline、which-key 等） |
| `hop.nix` | Hop 快速跳转 |
| `lualine.nix` | 状态栏配置 |
| `mini.nix` | mini.nvim 模块 |
| `ai.nix` | Copilot AI 补全 |

修改后执行 `nh home switch` 重建。
