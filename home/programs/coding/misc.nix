{ pkgs, ... }:
{
  home.packages = with pkgs; [
    alejandra
    nixfmt
    texlab
    prettier
    # julia-bin  # temporarily disabled - slow download
  ];
}
