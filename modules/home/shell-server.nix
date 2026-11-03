{
  pkgs,
  lib,
  config,
  ...
}:

{
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      path+=("$HOME/.cargo/bin" "$HOME/go/bin")

      if [[ $- == *i* ]]; then
        if command -v fastfetch &> /dev/null; then
          fastfetch
        fi
      fi

      # Custom 's' function for sesh
      s() {
        local session
        session=$(sesh list --icons | fzf-tmux -p 80%,70% --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' --bind 'tab:down,btab:up' --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' --preview-window 'right:55%' --preview 'sesh preview {}')
        if [[ -n "$session" ]]; then
          sesh connect "$session"
        fi
      }

      # Custom 'y' function for che
      y() {
        local tmp
        tmp="$(mktemp -t "che-cwd.XXXXXX")"
        che "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
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
      gs = "git status";
      gl = "git log --oneline";
      cd = "z";
      btw = "echo I use nixos, btw";
      lg = "lazygit";
    };

    history = {
      size = 10000;
      save = 10000;
      share = true;
    };
  };

  # Generate completion file for sesh
  xdg.configFile."zsh/completions/_sesh".text = builtins.readFile (
    pkgs.runCommand "sesh-completion" { } ''
      ${pkgs.sesh}/bin/sesh completion zsh > $out
    ''
  );

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

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

  home.packages = with pkgs; [
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
    sesh

    # Nix formatting
    nixfmt

    # Misc
    fastfetch
    tree
  ];
}
