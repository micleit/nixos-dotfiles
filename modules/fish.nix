{ pkgs, ... }:

{
  # 1. SYSTEM LEVEL: Make the shell available and set as default
  programs.fish.enable = true;
  users.users.mic.shell = pkgs.fish;

  # 2. USER LEVEL: Using Home Manager inside the system module
  home-manager.users.mic = { pkgs, ... }: {
    programs.fish = {
      enable = true;
      
      # Using the functions attribute is cleaner than interactiveShellInit
      functions = {
        civic-burn = {
          body = 
          ''
            set files (command ls -1 *.{flac,mp3} 2>/dev/null)
            if test -z "$files"
                echo (set_color red)"No FLAC or MP3 files found in this directory."(set_color normal)
                return 1
            end

            echo (set_color cyan)"--- Preparing & Normalizing tracks for the Civic ---"(set_color normal)
            
            for f in $files
                # Use quoted variables to handle spaces in filenames
                set title (ffprobe -v error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "$f")
                set artist (ffprobe -v error -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$f")
                
                # If no metadata, use the filename minus extension
                if test -z "$title"
                    set title (string replace -r '\.(flac|mp3)$' "" "$f")
                end
                
                echo (set_color blue)"Processing: "(set_color normal)"$title - $artist"

                # Conversion + Normalization
                set output (string replace -r '\.(flac|mp3)$' '.wav' "$f")
                ffmpeg -i "$f" -af "loudnorm=I=-16:TP=-1.5:LRA=11" -ar 44100 -ac 2 -y "$output" >/dev/null 2>&1
            end

            echo "---"
            echo (set_color yellow)"Normalization complete."(set_color normal)
            read -l -P "Ready to burn to /dev/sr0? [y/N] " confirm
            
            if test "$confirm" = "y" -o "$confirm" = "Y"
                echo (set_color green)"Starting burn... Keep the laptop still!"(set_color normal)
                sudo cdrecord -v dev=/dev/sr0 -dao -pad -text *.wav
                echo (set_color green)"Success! Ejecting disc and cleaning up..."(set_color normal)
                rm *.wav
            else
                echo (set_color red)"Burn cancelled. Temporary WAV files preserved."(set_color normal)
            end
          '';
        };

        y = {
          body = ''
            set tmp (mktemp -t "yazi-cwd.XXXXXX")
            command yazi $argv --cwd-file="$tmp"
            if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
                builtin cd -- "$cwd"
            end
            rm -f -- "$tmp"
          '';
        };
      };

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

    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  # 3. System-wide packages needed for the shell AND burning to function
  environment.systemPackages = with pkgs; [
    eza
    fzf
    zoxide
    yazi
    pokeget-rs
    ffmpeg      # Added for audio conversion
    cdrtools    # Added for cdrecord
  ];
}
