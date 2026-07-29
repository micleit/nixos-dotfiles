{ inputs, pkgs, ... }:

{
  imports = [ ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users.mic = {
      imports = [
        ../../home/mic/default.nix
        ../../modules/systems/linux/desktop-linux.nix
        ../../modules/home/shell.nix
        ../../modules/home/terminal.nix
        ../../modules/home/aerc.nix
        ../../modules/home/linux.nix
        ../../modules/home/yazi.nix
        ../../modules/home/helix.nix
        ../../modules/home/caveman.nix
        inputs.nixvim.homeModules.nixvim
      ];
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
      ];
    };
  };

  # Host-specific packages can be declared here or in default.nix
  environment.systemPackages = with pkgs; [ ];
}
