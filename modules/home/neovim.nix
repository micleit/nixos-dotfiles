{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    neovim

    # Language Servers
    nil
    nixd
    basedpyright
    lua-language-server
    markdown-oxide
    typescript-language-server # ts_ls
    vscode-langservers-extracted # html, css, json, eslint
    superhtml
    marksman
    texlab
    jdt-language-server

    # Formatters & Linters
    nixfmt
    ruff
    isort
    black
    stylua
    google-java-format

    # Utilities & Debugging
    lazygit
    neovim-remote
    python3
    python3Packages.debugpy
  ] ++ (lib.optionals pkgs.stdenv.isLinux [
    zathura
    xdotool
  ]);

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
