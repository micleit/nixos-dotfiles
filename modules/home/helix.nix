{ pkgs, lib, ... }:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    # This maps to config.toml (Editor configuration)
    settings = {
      theme = "gruvbox";
      editor = {
        line-number = "relative";
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
    };

    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = lib.getExe pkgs.nixfmt;
      }

      {
        name = "python";
        auto-format = true;
        formatter.command = lib.getExe pkgs.ruff;
      }

      {
        name = "html";
        auto-format = true;
        formatter.command = lib.getExe pkgs.superhtml;
      }

      {
        name = "markdown";
        auto-format = true;
        formatter.command = lib.getExe pkgs.marksman;
      }

      {
        name = "latex";
        auto-format = true;
        formatter.command = lib.getExe pkgs.texlab;
      }
      {
        name = "java";
        auto-format = true;
        formatter.command = lib.getExe pkgs.jdt-language-server;
      }
    ];
  };
}
