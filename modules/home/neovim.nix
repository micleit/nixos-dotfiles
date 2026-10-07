{ pkgs, lib, ... }:

let
  jupynium = pkgs.callPackage ../../pkgs/jupynium/package.nix { };
in
{
  home.packages =
    with pkgs;
    [
      (neovim.override {
        withPython3 = true;
        extraPython3Packages = p: with p; [
          pynvim
          jupynium
        ];
      })

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
      nodejs
      python3
      python3Packages.debugpy
      python3Packages.pynvim
      python3Packages.notebook
      python3Packages.nbclassic
      python3Packages.ipykernel
      jupynium
      geckodriver
    ]
    ++ (lib.optionals pkgs.stdenv.isLinux [
      zathura
      xdotool
      firefox
    ]);

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
