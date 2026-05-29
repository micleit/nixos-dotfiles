{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../../modules/systems/darwin/skhd.nix
    ../../modules/systems/darwin/aerospace-skhd.nix
  ];

  nixpkgs.overlays = [ ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ ];

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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKxCjlGFtiU6rrgryYhKmp0u6cbPhXPYm6IRkh9mSGL0 <comment>" # mbp
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM2H3Qy26Y3JV0p5WhpR89pE4hi7tssLbL/BYm+RsKd2 mic@headless-m1" # headlessm1
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArDsvxPAbb7S2XhflttHFnsv5Sfyb/Z1mZIf+1PGJdn mic@nixos-btw" # desktop
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUGAfMHR2crHkfh6Wo73N0NW7w5VdBk476kEvF4QBxu mic@optiplex-server" # optiplex-server
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgcQZ2TjpwiJAeeOUAywqpZ+xSxIYjeN7FBn0w59zHP mic@acer-nixos" # acer
  ];

  # Homebrew configuration (per-host customization)
  homebrew.taps = [
    "felixkratz/formulae"
    "nikitabobko/tap"
  ];
  homebrew.casks = [
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
  homebrew.brews = [
    "gemini-cli"
    "sketchybar"
    "borders"
    "cliclick"
    "switchaudio-osx"
    "nowplaying-cli"
    "lua"
  ];

  # Services
  services.sketchybar.enable = true;

  # macOS System Settings
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
  };
}
