{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "default_config"
      "met"
      "esphome"
      "tuya"
      "homekit"
      "zha"
    ];
    config = {
      default_config = { };
      homeassistant = {
        external_url = "https://ha.53729123.xyz";
        internal_url = "http://127.0.0.1:8123";
      };
      http = {
        server_host = [
          "0.0.0.0"
          "::"
        ];
        server_port = 8123;
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
          "10.0.0.0/8"
          "172.16.0.0/12"
          "192.168.0.0/16"
          "100.64.0.0/10"
          "0.0.0.0/0"
          "::/0"
        ];
      };
      automation = "!include automations.yaml";
      script = "!include scripts.yaml";
      scene = "!include scenes.yaml";
    };
  };

  # Ensure automations.yaml, scripts.yaml, and scenes.yaml exist in /var/lib/hass
  # so Home Assistant can read and write UI automations/scripts/scenes.
  systemd.tmpfiles.rules = [
    "f /var/lib/hass/automations.yaml 0644 hass hass - []"
    "f /var/lib/hass/scripts.yaml 0644 hass hass - {}"
    "f /var/lib/hass/scenes.yaml 0644 hass hass - []"
  ];

  networking.firewall.allowedTCPPorts = [ 8123 ];
}
