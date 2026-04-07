{ pkgs, lib, ... }:

{
  programs.tmux.enable = true;
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    settings = {
      # Font
      font-family = "JetBrainsMono Nerd Font Propo";
      font-size = if pkgs.stdenv.isDarwin then 14 else 10;
      
      # Visuals
      background = "#282828";
      foreground = "#ebdbb2";
      
      # Palette override to match your exact Gruvbox colors
      palette = [
        "0=#282828"
        "1=#cc241d"
        "2=#98971a"
        "3=#d79921"
        "4=#458588"
        "5=#b16286"
        "6=#689d6a"
        "7=#a89984"
        "8=#928374"
        "9=#fb4934"
        "10=#b8bb26"
        "11=#fabd2f"
        "12=#83a598"
        "13=#d3869b"
        "14=#8ec07c"
        "15=#ebdbb2"
      ];

      # Padding
      window-padding-x = 6;
      window-padding-y = 6;
      
      # Performance & Rendering
      font-thicken = true;
      
      # OS Specific
      macos-option-as-alt = "left";
      macos-titlebar-style = "hidden";
      
      # Keybinds
      keybind = "ctrl+shift+c=copy_to_clipboard";
    };
  };

  programs.btop = {
    enable = true;
  };

  home.packages = with pkgs; [
    kitty # Keep kitty as a backup
    lazygit
  ];
}
