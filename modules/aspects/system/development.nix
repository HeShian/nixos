{
  den.aspects.development-tools.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [ python3 uv nodejs codex deepseek-harness ];
  };
}
