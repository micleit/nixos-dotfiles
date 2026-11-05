{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lan-mouse
  ];

  systemd.user.services.lan-mouse = {
    Unit = {
      Description = "Lan Mouse daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.lan-mouse}/bin/lan-mouse daemon";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
