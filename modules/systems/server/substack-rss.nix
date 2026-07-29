{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.substack-rss;
  # Reference the packaged Python application locally
  substack-rss-pkg = pkgs.callPackage ../../../pkgs/substack-rss/package.nix {};
in {
  options.services.substack-rss = {
    enable = mkEnableOption "Substack RSS Telegram bot and static web server";

    package = mkOption {
      type = types.package;
      default = substack-rss-pkg;
      description = "The substack-rss package to use.";
    };

    telegramBotTokenFile = mkOption {
      type = types.path;
      description = "Path to environment file containing TELEGRAM_BOT_TOKEN=...";
    };

    baseUrl = mkOption {
      type = types.str;
      default = "http://127.0.0.1:${toString cfg.port}";
      description = "Base URL of the RSS feed server (used to construct external links in the feed).";
    };

    rssFilePath = mkOption {
      type = types.str;
      default = "/var/lib/substack-rss/feed.xml";
      description = "Path where the feed.xml file should be generated and updated.";
    };

    port = mkOption {
      type = types.port;
      default = 8088; # Defaulting to 8088 to avoid conflicts with other local servers (like nginx on 8080)
      description = "Port to bind the simple HTTP static web server to.";
    };
  };

  config = mkIf cfg.enable {
    # 1. Directory creation with proper permissions
    systemd.tmpfiles.rules = [
      "d /var/lib/substack-rss 0755 substack-rss substack-rss - -"
    ];

    # 2. System user and group accounts
    users.users.substack-rss = {
      isSystemUser = true;
      group = "substack-rss";
      home = "/var/lib/substack-rss";
    };
    users.groups.substack-rss = {};

    # 3. Telegram bot systemd service
    systemd.services.substack-bot = {
      description = "Substack Telegram RSS Bot Service";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      environment = {
        BASE_URL = cfg.baseUrl;
        RSS_FILE_PATH = cfg.rssFilePath;
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/substack-bot";
        EnvironmentFile = cfg.telegramBotTokenFile;
        Restart = "always";
        RestartSec = "10s";
        User = "substack-rss";
        Group = "substack-rss";

        # Basic service hardening
        ProtectSystem = "full";
        ProtectHome = true;
        NoNewPrivileges = true;
      };
    };

    # 4. Web server systemd service (lightweight python http.server serving the static directory)
    systemd.services.substack-rss-web = {
      description = "Substack RSS Static Web Server";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${pkgs.python3}/bin/python3 -m http.server --bind 127.0.0.1 ${toString cfg.port} --directory /var/lib/substack-rss";
        Restart = "always";
        RestartSec = "5s";
        User = "substack-rss";
        Group = "substack-rss";

        # Basic service hardening
        ProtectSystem = "full";
        ProtectHome = true;
        NoNewPrivileges = true;
      };
    };
  };
}
