{ pkgs, ... }:

{
  # 1. SYSTEM LEVEL: Make the shell available and set as default
  programs.fish.enable = true;
  users.users.mic.shell = pkgs.fish;

  # 2. USER LEVEL: Using Home Manager inside the system module
  home-manager.users.mic = { pkgs, ... }: {
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

        if status is-interactive
            if type -q pokeget
                pokeget random 2>/dev/null
            end
        end

        # Yazi function
        function y
            set tmp (mktemp -t "yazi-cwd.XXXXXX")
            command yazi $argv --cwd-file="$tmp"
            if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
                builtin cd -- "$cwd"
            end
            rm -f -- "$tmp"
        end
      '';

      shellAliases = {
        ls = "eza -lh --group-directories-first --icons=auto";
        lsa = "ls -a";
        lt = "eza --tree --level=2 --long --icons --git";
        gc = "git clone";
        cd = "z";
        ssh = "test \"$TERM\" = \"xterm-kitty\"; and kitty +kitten ssh; or command ssh";
      };

      plugins = [
        { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
        { name = "tide"; src = pkgs.fishPlugins.tide.src; }
        { name = "done"; src = pkgs.fishPlugins.done.src; }
      ];
    };

    # Enable zoxide for the user
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  # 3. System-wide packages needed for the shell to function
  environment.systemPackages = with pkgs; [
    eza
    fzf
    zoxide
    yazi
    pokeget-rs
  ];
}
