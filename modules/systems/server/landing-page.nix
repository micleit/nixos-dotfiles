{
  config,
  pkgs,
  lib,
  ...
}:

let
  domain = "53729123.xyz";
  landingPageDir = pkgs.runCommand "landing-page" { } ''
        mkdir -p $out
        cat > $out/index.html <<'EOF'
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>53729123.xyz</title>
          <style>
            body {
              background-color: #282828; /* Gruvbox dark background */
              color: #ebdbb2; /* Gruvbox light foreground */
              font-family: monospace;
              line-height: 1.6;
              max-width: 600px;
              margin: 40px auto;
              padding: 0 20px;
            }
            h1 {
              color: #b8bb26; /* Gruvbox green */
              border-bottom: 2px dashed #504945;
              padding-bottom: 10px;
            }
            h2 {
              color: #fabd2f; /* Gruvbox yellow */
              margin-top: 30px;
            }
            a {
              color: #83a598; /* Gruvbox blue */
              text-decoration: none;
            }
            a:hover {
              color: #fe8019; /* Gruvbox orange */
              background-color: #3c3836;
              text-decoration: underline;
            }
            ul {
              list-style-type: square;
              padding-left: 20px;
            }
            li {
              margin-bottom: 10px;
            }
            .desc {
              color: #928374; /* Gruvbox gray */
            }
            hr {
              border: 0;
              border-top: 1px dashed #504945;
              margin: 40px 0;
            }
          </style>
        </head>
        <body>
          <h1>~/${domain}</h1>
          <p>Welcome to the server. All systems operational.</p>
          
          <h2>Services</h2>
          <ul>
            <li><a href="https://jellyfin.${domain}">[ Jellyfin ]</a> <span class="desc">- Media Server</span></li>
            <li><a href="https://seerr.${domain}">[ Seerr ]</a> <span class="desc">- Media Requests</span></li>
            <li><a href="https://immich.${domain}">[ Immich ]</a> <span class="desc">- Photo Backup</span></li>
            <li><a href="https://navidrome.${domain}">[ Navidrome ]</a> <span class="desc">- Music Streaming</span></li>
            <li><a href="https://lidarr.${domain}">[ Lidarr ]</a> <span class="desc">- Music Management</span></li>
            <li><a href="https://slskd.${domain}">[ Slskd ]</a> <span class="desc">- Soulseek Daemon</span></li>
            <li><a href="https://files.${domain}">[ FileBrowser ]</a> <span class="desc">- Web File Manager</span></li>
            <li><a href="https://vaultwarden.${domain}">[ Vaultwarden ]</a> <span class="desc">- Password Manager</span></li>
          </ul>

          <hr>
          <p class="desc"><i>System: NixOS 26.11<br>Location: /mnt/ssd2</i></p>
        </body>
        </html>
    EOF
  '';
in
{
  # Simple landing page server on port 8080
  services.nginx = {
    enable = true;
    virtualHosts."landing" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8080;
        }
      ];
      default = true;
      root = landingPageDir;
    };
  };

  # Open port 8080 for landing page (localhost only, no firewall needed)
}
