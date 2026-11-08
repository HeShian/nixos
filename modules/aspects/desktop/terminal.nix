{
  den.aspects.desktop-terminal = {
    nixos = { pkgs, ... }: {
      fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
    };

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [ kitty bat eza ];

      programs.fish = {
        enable = true;
        functions.fish_greeting = "";
        shellAliases = {
          cat = "bat --theme=base16";
          ls = "eza --icons=auto";
          lt = "eza --icons=auto --tree";
          la = "eza -la --icons=auto";
        };
      };

      programs.starship = {
        enable = true;
        enableFishIntegration = true;
        enableBashIntegration = false;
        settings = {
          format = "$username$directory$git_branch$git_status$line_break$character";
          username = {
            show_always = true;
            format = "[$user]($style) ";
          };
          directory.truncation_length = 3;
        };
      };
      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
        enableBashIntegration = false;
        options = [ "--cmd" "cd" ];
      };
      programs.yazi = {
        enable = true;
        enableFishIntegration = true;
        enableBashIntegration = false;
        shellWrapperName = "y";
      };
    };
  };
}
