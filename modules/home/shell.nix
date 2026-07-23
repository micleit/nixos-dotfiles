{ pkgs, lib, config, ... }:

{
  programs.zsh = {
    enable = true;

    # Fish-like features built directly into Home Manager's Zsh module
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Path & Env setup
    initContent = ''
      path+=("$HOME/.spicetify" "$HOME/go/bin" "$HOME/.cargo/bin")

      # Only inject Homebrew on macOS hosts
      ${lib.optionalString pkgs.stdenv.isDarwin ''
        if [[ -f /opt/homebrew/bin/brew ]]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
      ''}

      if [[ $- == *i* ]]; then
        if command -v nerdfetch &> /dev/null; then
          nerdfetch
        fi
      fi

      # Your custom 's' function for sesh
      s() {
        local session
        session=$(sesh list --icons | fzf-tmux -p 80%,70% --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' --bind 'tab:down,btab:up' --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' --preview-window 'right:55%' --preview 'sesh preview {}')
        if [[ -n "$session" ]]; then
          sesh connect "$session"
        fi
      }
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
      source ${config.home.homeDirectory}/nixos-dotfiles/modules/home/.p10k.zsh
    '';

    shellAliases = {
      ls = "eza -lh --group-directories-first --icons=auto";
      lsa = "ls -a";
      lt = "eza --tree --level=2 --long --icons --git";
      gc = "git clone";
      cd = "z";
      ssh = "[ \"$TERM\" = \"xterm-kitty\" ] && kitty +kitten ssh || command ssh";
      btw = "echo I use nixos, btw";
      lg = "lazygit";
      kanata-off = "sudo launchctl bootout system /Library/LaunchDaemons/org.nixos.kanata.plist";
      kanata-on = "sudo launchctl bootstrap system /Library/LaunchDaemons/org.nixos.kanata.plist";
    };

    # History configuration (crucial for Zsh to feel good)
    history = {
      size = 10000;
      save = 10000;
      share = true;
    };
  };

  # Generate completion file specifically for Zsh
  xdg.configFile."zsh/completions/_sesh".text = builtins.readFile (
    pkgs.runCommand "sesh-completion" { } ''
      ${pkgs.sesh}/bin/sesh completion zsh > $out
    ''
  );

  # Update zoxide integration for Zsh
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Fzf integration for Zsh replaces fishPlugins.fzf-fish
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
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

  home.packages =
    with pkgs;
    [
      zsh-powerlevel10k
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
      sesh

      # Dev
      nil
      nixd
      nixpkgs-fmt
      nixfmt
      nodejs
      gcc
      tree-sitter

      # Fun & Misc
      nerdfetch
      fastfetch
      tree
    ]
    ++ (lib.optionals stdenv.isLinux [
      wl-clipboard
    ]);
}
