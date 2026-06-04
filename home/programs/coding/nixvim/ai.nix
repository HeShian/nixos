{
  config,
  pkgs,
  ...
}:
{
  programs.nixvim = {
    plugins = {
      copilot-lua = {
        enable = true;
        settings = {
          panel.enabled = false;
          suggestion.enabled = true;
          suggestion.keymap = {
            hide_during_completion = false;
            accept = "<C-l>";
            accept_word = false;
            accept_line = false;
            next = "<C-Tab>";
            prev = "<C-S-Tab>";
            dismiss = "<C-h>";
          };
          filetypes.markdown = true;
        };
      };
    };
  };
}
