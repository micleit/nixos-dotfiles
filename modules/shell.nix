{ pkgs, lib, ... }:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Path & Env
      fish_add_path $HOME/.spicetify
      fish_add_path $HOME/go/bin
      fish_add_path $HOME/.cargo/bin
      
      set -gx DRIFT_TIMEOUT 120
      set -gx fish_greeting ""

      function _drift_cancel
        if set -q _drift_timer_pid
          kill $_drift_timer_pid 2>/dev/null
          set -e _drift_timer_pid
        end
      end

      function _drift_schedule
        set -l timeout (set -q DRIFT_TIMEOUT; and echo $DRIFT_TIMEOUT; or echo 120)
        fish -c "sleep $timeout; and command -v drift >/dev/null 2>&1; and drift" &
        set -g _drift_timer_pid $last_pid
      end

      function _drift_on_prompt --on-event fish_prompt
        _drift_cancel
        _drift_schedule
      end

      function _drift_on_preexec --on-event fish_preexec
        _drift_cancel
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

  programs.gh = {
    enable = true;
  };

  home.packages = with pkgs; [
    # Core CLI
    eza
    fzf
    zoxide
    ripgrep
    fd
    jq
    unzip
    curl
    gnumake

    # Dev
    nil
    nixd
    nixpkgs-fmt
    nixfmt
    nodejs
    gcc
    tree-sitter

    # Fun & Misc
    pokeget-rs
    fastfetch
    tree
  ] ++ (lib.optionals stdenv.isLinux [
    wl-clipboard
    wmenu
    mpvpaper
  ]);
}
