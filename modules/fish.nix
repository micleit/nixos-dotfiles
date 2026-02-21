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
                  echo (set_color red)"No FLAC or MP3 files found."(set_color normal); return 1
              end

              # 1. Grab the Album Name from the first file
              set first_file $files[1]
              set album_name (ffprobe -v error -show_entries format_tags=album -of default=noprint_wrappers=1:nokey=1 "$first_file")
              
              # Fallback if no album tag exists
              if test -z "$album_name"
                  set album_name "Civic Mix"
              end

              # Header with the Dynamic Album Title
              echo "TITLE \"$album_name\"" > civic.cue
              echo "PERFORMER \"Various Artists\"" >> civic.cue

              set track_num 1
              for f in $files
                  set title (ffprobe -v error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "$f")
                  set artist (ffprobe -v error -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$f")
                  
                  if test -z "$title"; set title (string replace -r '\.(flac|mp3)$' "" "$f"); end
                  if test -z "$artist"; set artist "Unknown Artist"; end

                  echo (set_color blue)"Processing: "(set_color normal)"$title"

                  set wav_file (printf "track%02d.wav" $track_num)
                  ffmpeg -i "$f" -af "loudnorm=I=-16:TP=-1.5:LRA=11" -ar 44100 -ac 2 -y "$wav_file" >/dev/null 2>&1

                  echo "TRACK "$(printf "%02d" $track_num)" AUDIO" >> civic.cue
                  echo "  TITLE \"$title\"" >> civic.cue
                  echo "  PERFORMER \"$artist\"" >> civic.cue
                  echo "  FILE \"$wav_file\" WAVE" >> civic.cue
                  echo "    INDEX 01 00:00:00" >> civic.cue

                  set track_num (math $track_num + 1)
              end

              echo "---"
              echo (set_color green)"Album: $album_name"(set_color normal)
              read -l -P "CUE sheet generated. Ready to burn with CD-Text? [y/N] " confirm
              if test "$confirm" = "y" -o "$confirm" = "Y"
                  sudo cdrecord -v dev=/dev/sr0 -dao -text civic.cue
                  rm *.wav civic.cue
                  echo (set_color green)"Burn complete! Enjoy $album_name in the Civic."(set_color normal)
              else
                  rm *.wav civic.cue
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
