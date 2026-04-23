{ pkgs, ... }:

{
  imports = [
    ../../modules/darwin/yabai.nix
    ../../modules/darwin/skhd.nix
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.vim
    pkgs.git
    pkgs.iina
  ];

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true; # Managed unconditionally now

  system.primaryUser = "mic";
  nixpkgs.config.allowUnfree = true;

  # nix-darwin management of Nix is disabled for compatibility with Determinate
  nix.enable = false;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.fish.enable = true;

  # Manually source nix environment if nix.enable = false
  programs.zsh.shellInit = ''
    if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
  '';
  programs.fish.shellInit = ''
    if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    end
  '';

  # Set System Version
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.system = "aarch64-darwin"; # Adjust to "x86_64-darwin" if intel

  users.users.mic.home = "/Users/mic";

  # SSH Configuration
  services.openssh.enable = true;
  users.users.mic.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKxCjlGFtiU6rrgryYhKmp0u6cbPhXPYm6IRkh9mSGL0 <comment>" # mbp
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM2H3Qy26Y3JV0p5WhpR89pE4hi7tssLbL/BYm+RsKd2 mic@headless-m1" # headlessm1
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArDsvxPAbb7S2XhflttHFnsv5Sfyb/Z1mZIf+1PGJdn mic@nixos-btw" # desktop
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUGAfMHR2crHkfh6Wo73N0NW7w5VdBk476kEvF4QBxu mic@optiplex-server" # optiplex-server
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgcQZ2TjpwiJAeeOUAywqpZ+xSxIYjeN7FBn0w59zHP mic@acer-nixos" # acer
  ];

  # Homebrew management
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall"; # Safer than "zap"
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    taps = [
      "felixkratz/formulae"
      "asmvik/formulae"
    ];
    casks = [
      # "bitwarden" can't do browser integration without mac app store version.
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
      # Add your other Mac apps here
    ];
    brews = [
      "gemini-cli"
      "sketchybar" # Often better from brew for permissions/updates
      "borders"
      "cliclick"
      "switchaudio-osx"
      "nowplaying-cli"
      "lua"
      "mole"
    ];
  };

  # Services
  services.sketchybar.enable = true;
  # services.yabai and services.skhd are now managed in modules/*.nix

  # macOS System Settings
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
  };
}
