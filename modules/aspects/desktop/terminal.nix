{
  # 终端 / shell 只安装软件包，配置文件全部来自 dotfiles：
  #   ~/.config/kitty/kitty.conf、~/.config/fish/config.fish
  # 所以这里刻意不启用 programs.kitty / programs.fish / programs.starship /
  # programs.zoxide / programs.yazi，避免 home-manager 生成同名文件与软链冲突。
  den.aspects.desktop-terminal.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [
      kitty
      fish
      starship
      zoxide
      yazi
      bat
      eza
      xdg-terminal-exec
    ];
  };
}
