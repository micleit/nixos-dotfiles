{ inputs, pkgs, ... }:

{
  imports = [
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users.mic = {
      imports = [
        inputs.noctalia.homeModules.default
        ../../home/mic/default.nix
        ../../modules/home/shell.nix
        ../../modules/home/terminal.nix
        ../../modules/home/linux.nix
        ../../modules/home/yazi.nix
        ../../modules/home/neovim.nix
        ../../modules/home/caveman.nix
      ];
      programs.noctalia = {
        enable = true;
      };
      home.packages = with pkgs; [
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
  environment.systemPackages = with pkgs; [
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli
  ];
}
