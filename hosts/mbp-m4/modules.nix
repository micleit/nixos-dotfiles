{
  inputs,
  pkgs,
  ...
}: {
  imports = [];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {inherit inputs;};
    users.mic = {
      imports = [
        ../../home/mic/default.nix
        ../../modules/systems/darwin/darwin.nix
        ../../modules/home/shell.nix
        ../../modules/home/terminal.nix
        # ../../modules/home/aerc.nix  # disabled due to arm64 mailutils issue
        ../../modules/home/yazi.nix
        ../../modules/home/neovim.nix
        ../../modules/home/caveman.nix
        ../../modules/home/anki-cli.nix
      ];
      programs.anki-cli.enable = true;
      home.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        curl
        ffmpeg
        gifski
        imagemagick
        texliveFull
        neovim-remote
        inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli
        sesh
        python3
        python3Packages.pip
        python3Packages.virtualenv
        python3Packages.debugpy
        black
        isort
        ruff
        go
        obsidian
        sioyek
        lan-mouse
        input-leap
      ];
    };
  };

  # Host-specific packages can be declared here or in default.nix
  environment.systemPackages = with pkgs; [];
}
