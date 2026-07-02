{ pkgs, lib, ... }:

{
  programs.helix = {
    enable = true;
    
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
    ];
  };
}
