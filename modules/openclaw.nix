{ config, pkgs, lib, inputs, ... }:

{
  programs.openclaw = {
    # documents path should be set to your local documents directory
    documents = "${config.home.homeDirectory}/code/openclaw-local/documents";

    config = {
      gateway = {
        mode = "local";
        auth = {
          # You should change this to a unique random token
          token = "LnKPL4bm2quluvUexgtLxTCOt6tcnujLryc/nvs5q7c=";
        };
      };

      channels.telegram = {
        tokenFile = "${config.home.homeDirectory}/.secrets/telegram-bot-token";
        allowFrom = [ 8763430768 ];
        groups = {
          "*" = {
            requireMention = true;
          };
        };
      };
    };

    instances.default = {
      enable = true;
      plugins = [
        # Add plugins here
        # Example: { source = "github:openclaw/plugin-name"; }
      ];
    };
  };
}
