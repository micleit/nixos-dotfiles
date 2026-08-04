{ inputs, pkgs, ... }:

{
  imports = [
    inputs.slippi.nixosModules.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users.mic = {
      imports = [
        ../../home/mic/default.nix
        inputs.noctalia.homeModules.default
        ../../modules/home/shell.nix
        ../../modules/home/terminal.nix
        ../../modules/home/aerc.nix
        ../../modules/home/linux.nix
        ../../modules/home/yazi.nix
        ../../modules/home/neovim.nix
        ../../modules/home/caveman.nix
      ];
      programs.noctalia = {
        enable = true;
      };
      home.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        curl
        ffmpeg
        gifski
        imagemagick
        texliveFull
        neovim-remote
        gemini-cli
        inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli
        sesh
        opencode
        python3
        python3Packages.pip
        python3Packages.virtualenv
        python3Packages.debugpy
        black
        isort
        ruff
        go
        spotify
        spicetify-cli
        obsidian
        sioyek
        apple-cursor
        pavucontrol
        wireplumber
        hyprpolkitagent
        xwayland-satellite
        grim
        slurp
        wl-clipboard
        wf-recorder
        swaybg
        gtk3
        hyprshot
        xdotool
        anki
        nautilus
        brave
        vlc
        translate-shell
        libreoffice
        bitwarden-desktop
      ];
    };
  };

  # Host-specific packages can be declared here or in default.nix
  environment.systemPackages = with pkgs; [ ];
}
