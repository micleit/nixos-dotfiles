{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.anki-cli;

  fsrs = pkgs.python3Packages.callPackage ../../pkgs/fsrs/package.nix {};

  anki-cli = pkgs.callPackage ../../pkgs/anki-cli/package.nix {
    inherit fsrs;
  };
in {
  options.programs.anki-cli = {
    enable = mkEnableOption "anki-cli";

    package = mkOption {
      type = types.package;
      default = anki-cli;
      description = "The anki-cli package to use.";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      example = literalExpression ''
        {
          backend = {
            prefer = "ankiconnect";
            ankiconnect_url = "http://127.0.0.1:8765";
          };
        }
      '';
      description = "Configuration settings written to <filename>~/.config/anki-cli/config.toml</filename>.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.configFile."anki-cli/config.toml" = mkIf (cfg.settings != {}) {
      source = (pkgs.formats.toml {}).generate "anki-cli-config" cfg.settings;
    };
  };
}
