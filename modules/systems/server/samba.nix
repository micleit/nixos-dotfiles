{ config, pkgs, ... }:

{
  # ============================================================================
  # SAMBA (Network Drive)
  # ============================================================================
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnixos";
        "netbios name" = "smbnixos";
        "security" = "user";

        # iOS / macOS Performance Tweak
        "vfs objects" = "fruit streams_xattr";
        "fruit:metadata" = "netatalk";
        "fruit:model" = "MacSamba";
        "fruit:posix_rename" = "yes";
        "fruit:zero_conf" = "yes";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
      };
      Shared = {
        "path" = "/home/mic/Shared";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "mic";
        "force group" = "users";
      };
    };
  };

  # Help Windows/macOS/iOS discover the server on the network
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # mDNS for macOS/iOS "Files" app discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
          <service>
            <type>_device-info._tcp</type>
            <port>0</port>
            <txt-record>model=MacSamba</txt-record>
          </service>
        </service-group>
      '';
    };
  };
}
