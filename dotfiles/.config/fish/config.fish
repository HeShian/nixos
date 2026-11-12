# fish 配置（由 dotfiles 软链到 ~/.config/fish/config.fish）
# NixOS 版：不再包含 pacman/apt 等 Arch 专属包装。
# 注意：niri-session 会用 fish 登录 shell 启动一次非交互实例，
# 所以 starship/zoxide 等提示符相关初始化放在 status is-interactive 里。

# home-manager 的会话变量（EDITOR/PATH 等）；文件由 nixos 的 HM 集成生成
if test -f /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.fish
    source /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.fish
end

fish_add_path ~/.local/bin

if status is-interactive
    set fish_greeting ""

    starship init fish | source
    zoxide init fish --cmd cd | source

    abbr -a nrs 'sudo nixos-rebuild switch --flake ~/nixos#acer'
    abbr -a nrb 'sudo nixos-rebuild build --flake ~/nixos#acer'
    abbr -a nfu 'nix flake update'
    abbr -a nfc 'nix flake check'
    abbr -a fa fastfetch
    abbr -a raw '~/.config/niri/scripts/wallpaper-download'
    abbr -a reboot 'systemctl reboot'
end

# yazi：退出时 cd 到最后浏览的目录
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# 常用别名（与参考配置一致）
function cat --wraps bat
    command bat --theme="base16" $argv
end

function ls --wraps eza
    command eza --icons=auto $argv
end

function lt --wraps eza
    command eza --icons=auto --tree $argv
end

function la --wraps eza
    command eza -la --icons=auto $argv
end
