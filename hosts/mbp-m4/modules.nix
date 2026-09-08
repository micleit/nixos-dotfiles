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
        R
        rstudio
        obsidian
        (sioyek.overrideAttrs (oldAttrs: {
          postInstall = ''
            mkdir -p sioyek.app/Contents/Resources
            cp -r pdf_viewer/shaders sioyek.app/Contents/Resources/shaders
            cp pdf_viewer/{prefs,prefs_user,keys,keys_user}.config tutorial.pdf sioyek.app/Contents/Resources/

            mkdir -p $out/Applications $out/bin
            cp -r sioyek.app $out/Applications
            ln -s $out/Applications/sioyek.app/Contents/MacOS/sioyek $out/bin/sioyek
          '';
        }))
        moonlight-qt
        sunshine
        prismlauncher

      ];
    };
  };

  # Host-specific packages can be declared here or in default.nix
  environment.systemPackages = with pkgs; [];
}
