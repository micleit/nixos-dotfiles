{ pkgs, lib, ... }:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Path & Env
      fish_add_path $HOME/.spicetify
      fish_add_path $HOME/go/bin
      fish_add_path $HOME/.cargo/bin
      
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
      btw = "echo I use nixos, btw";
      lg = "lazygit";
    };

    functions = {
      s = builtins.readFile (pkgs.writeText "sesh-function.fish" ''
        sesh connect "$(sesh list --icons | fzf-tmux -p 80%,70% --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' --bind 'tab:down,btab:up' --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' --preview-window 'right:55%' --preview 'sesh preview {})')"
      '');
    };

    plugins = [
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "tide"; src = pkgs.fishPlugins.tide.src; }
      { name = "done"; src = pkgs.fishPlugins.done.src; }
    ];
  };

  xdg.configFile."fish/completions/sesh.fish".text = builtins.readFile (
    pkgs.runCommand "sesh-completion" { } ''
      ${pkgs.sesh}/bin/sesh completion fish > $out
    ''
  );

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
    pokeget-rs
    fastfetch
    tree
  ] ++ (lib.optionals stdenv.isLinux [
    wl-clipboard
    wmenu
    mpvpaper
  ]);
}
