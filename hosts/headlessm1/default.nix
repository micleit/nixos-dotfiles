{ pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/darwin/skhd.nix
  ];

  nixpkgs.overlays = [
  ];

  nixpkgs.config.permittedInsecurePackages = [
  ];

  # List packages installed in system profile.
  environment.systemPackages = [
    pkgs.vim
    pkgs.git
    pkgs.nodejs_22
  ];

  system.primaryUser = "mic";

  # nix-darwin management of Nix is disabled for compatibility with Determinate
  nix.enable = false;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  
  programs.fish.enable = true;

  # Manually source nix environment if nix.enable = false
  programs.zsh.shellInit = ''
    if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
    if [ -f /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  '';
  programs.fish.shellInit = ''
    if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    end
    if test -f /opt/homebrew/bin/brew
      eval (/opt/homebrew/bin/brew shellenv)
    end
  '';

  # Set System Version
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.system = "aarch64-darwin"; 

  users.users.mic.home = "/Users/mic";

  # SSH Configuration
  services.openssh.enable = true;
  users.users.mic.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKxCjlGFtiU6rrgryYhKmp0u6cbPhXPYm6IRkh9mSGL0 <comment>" #mbp
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM2H3Qy26Y3JV0p5WhpR89pE4hi7tssLbL/BYm+RsKd2 mic@headless-m1" #headlessm1
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArDsvxPAbb7S2XhflttHFnsv5Sfyb/Z1mZIf+1PGJdn mic@nixos-btw" #desktop
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUGAfMHR2crHkfh6Wo73N0NW7w5VdBk476kEvF4QBxu mic@optiplex-server" #optiplex-server
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgcQZ2TjpwiJAeeOUAywqpZ+xSxIYjeN7FBn0w59zHP mic@acer-nixos" #acer
  ];

  # Homebrew management
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall"; 
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    taps = [
      "felixkratz/formulae"
      "nikitabobko/tap"
    ];
    casks = [
      "visual-studio-code"
      "discord"
      "spotify"
      "raycast"
      "karabiner-elements"
      "brave-browser"
      "skim"
      "font-sf-pro"
      "font-sf-mono"
      "sf-symbols"
      "font-hack-nerd-font"
      "font-sketchybar-app-font"
      "colemak-dh"
      "nikitabobko/tap/aerospace"
      ];
    brews = [
      "gemini-cli"
      "sketchybar" 
      "borders"
      "cliclick"
      "switchaudio-osx"
      "nowplaying-cli"
      "lua"
    ];
  };

  # Home Manager for configuration files
  home-manager.users.mic = {
    # Override the default sketchybar config with the aerospace-specific one
    xdg.configFile."sketchybar".source = lib.mkForce ../../config/sketchybar-aerospace;

    # AeroSpace configuration file
    home.file.".config/aerospace/aerospace.toml".text = ''
      # AeroSpace Configuration
      # Reference: https://nikitabobko.github.io/AeroSpace/guide#configuration

      # Layout and gaps
      # sketchybar is already managed as a nix-darwin service, so we don't need a startup command here.
      
      [gaps]
      inner.horizontal = 5
      inner.vertical = 5
      outer.left = 4
      outer.bottom = 4
      outer.top = 10
      outer.right = 4

      # Sketchybar Integration
      # Trigger when workspace changes
      on-focused-workspace-changed = ['exec-and-forget sketchybar --trigger aerospace_workspace_change']
      
      [mode.main.binding]
      # Navigation (alt + h/j/k/l or a/r/w/s to match your skhd)
      alt-a = 'focus left'
      alt-r = 'focus down'
      alt-w = 'focus up'
      alt-s = 'focus right'
      
      alt-h = 'focus left'
      alt-j = 'focus down'
      alt-k = 'focus up'
      alt-l = 'focus right'

      # Move Windows
      alt-shift-a = 'move left'
      alt-shift-r = 'move down'
      alt-shift-w = 'move up'
      alt-shift-s = 'move right'

      alt-shift-h = 'move left'
      alt-shift-j = 'move down'
      alt-shift-k = 'move up'
      alt-shift-l = 'move right'

      # Layouts
      alt-e = 'layout tiles horizontal vertical' # Equalize
      alt-shift-space = 'layout floating tiling' # Toggle float

      # Workspace switching (Match your ralt 1-9)
      alt-1 = 'workspace 1'
      alt-2 = 'workspace 2'
      alt-3 = 'workspace 3'
      alt-4 = 'workspace 4'
      alt-5 = 'workspace 5'
      alt-6 = 'workspace 6'
      alt-7 = 'workspace 7'
      alt-8 = 'workspace 8'
      alt-9 = 'workspace 9'

      # Move window to workspace
      alt-shift-1 = 'move-node-to-workspace 1'
      alt-shift-2 = 'move-node-to-workspace 2'
      alt-shift-3 = 'move-node-to-workspace 3'
      alt-shift-4 = 'move-node-to-workspace 4'
      alt-shift-5 = 'move-node-to-workspace 5'
      alt-shift-6 = 'move-node-to-workspace 6'
      alt-shift-7 = 'move-node-to-workspace 7'
      alt-shift-8 = 'move-node-to-workspace 8'
      alt-shift-9 = 'move-node-to-workspace 9'

      # Fullscreen
      alt-ctrl-enter = 'fullscreen'

      # Launch apps (Matching your ghostty config)
      alt-enter = 'exec-and-forget open -na Ghostty'

      # Rules
      [[on-window-detected]]
      if.app-id = 'com.apple.systempreferences'
      run = 'layout floating'
    '';
  };

  # Override skhd config to coexist with AeroSpace
  services.skhd.skhdConfig = lib.mkForce ''
    # === Session defaults ===
    ralt + shift - y : skhd --restart-service
    hyper - escape : /usr/bin/osascript -e 'tell application "System Events" to sleep'

    # === launch commands ===
    hyper - v : /usr/bin/open -na /Applications/Visual\ Studio\ Code.app
    hyper - b : /usr/bin/open -na "Brave Browser"
    hyper - f : /usr/bin/open $HOME
    hyper - y : ghostty -e yazi
    hyper - s : /usr/bin/open -na '/System/Applications/System Settings.app'
    hyper - t : /usr/bin/touch /tmp/skhd_test
    hyper - z : /usr/bin/touch /tmp/skhd_z_test

    # mouse emulation
    hyper - k : /opt/homebrew/bin/cliclick "m:+0,-20" #up
    hyper - j : /opt/homebrew/bin/cliclick "m:+0,+20" #down
    hyper - l : /opt/homebrew/bin/cliclick "m:+20,+0" #right
    hyper - h : /opt/homebrew/bin/cliclick "m:-20,+0" #left
    hyper - m : /opt/homebrew/bin/cliclick ku:cmd,ctrl,alt,shift c:. #release all modifiers and click
    hyper - n : /opt/homebrew/bin/cliclick ku:ctrl rc:.  #right click
  '';

  # Services
  services.sketchybar.enable = true;

  # macOS System Settings
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
  };
}
