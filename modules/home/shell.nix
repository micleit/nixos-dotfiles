{ pkgs, lib, ... }:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Path & Env
      fish_add_path $HOME/.spicetify
      fish_add_path $HOME/go/bin
      fish_add_path $HOME/.cargo/bin
      
      set -gx ROFI_FUZZY true
      set -gx AERC_CONFIG_DIR "$HOME/.config/aerc"
      set -gx fish_greeting ""

      set -x DRIFT_TIMEOUT 120
      if type -q drift
          drift shell-init fish | source
      end

      if status is-interactive
          if type -q pokeget
              pokeget random 2>/dev/null
          end
      end
    '';

    shellAliases = {
      ls = "eza -lh --group-directories-first --icons=auto";
      lsa = "ls -a";
      lt = "eza --tree --level=2 --long --icons --git";
      gc = "git clone";
      cd = "z";
      ssh = "test \"$TERM\" = \"xterm-kitty\"; and kitty +kitten ssh; or command ssh";
      btw = "echo I use nixos, btw";
    };

    plugins = [
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "tide"; src = pkgs.fishPlugins.tide.src; }
      { name = "done"; src = pkgs.fishPlugins.done.src; }
    ];
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "micah leiterman";
        email = "micah.leiterman@gmail.com";
      };
    };
  };

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";
  };

  home.packages = with pkgs; [
    eza
    fzf
    zoxide
    pokeget-rs
    ffmpeg
    ripgrep
    nil
    nixd
    nixpkgs-fmt
    nixfmt
    nodejs
    gcc
    fastfetch
    tree
    jq
    unzip
    curl
    gnumake
    tree-sitter
  ] ++ (lib.optionals stdenv.isLinux [
    wl-clipboard
    wmenu
    mpvpaper
  ]);
}
