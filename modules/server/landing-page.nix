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
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
              margin: 0;
              padding: 0;
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              min-height: 100vh;
              display: flex;
              align-items: center;
              justify-content: center;
            }
            .container {
              background: white;
              border-radius: 12px;
              box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
              padding: 40px;
              max-width: 600px;
              text-align: center;
            }
            h1 {
              color: #333;
              margin-top: 0;
              margin-bottom: 10px;
              font-size: 2.5em;
            }
            .subtitle {
              color: #666;
              font-size: 1.1em;
              margin-bottom: 30px;
            }
            .services {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
              gap: 15px;
              margin-top: 30px;
            }
            .service {
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              color: white;
              padding: 20px;
              border-radius: 8px;
              text-decoration: none;
              transition: transform 0.2s, box-shadow 0.2s;
              font-weight: 600;
            }
            .service:hover {
              transform: translateY(-5px);
              box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
            }
            .emoji {
              font-size: 2em;
              display: block;
              margin-bottom: 10px;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>✨ Self-Hosted Services</h1>
            <p class="subtitle">Welcome to your personal cloud</p>
        
            <div class="services">
              <a href="https://immich.${domain}" class="service">
                <span class="emoji">🖼️</span>
                Immich
              </a>
              <a href="https://nextcloud.${domain}" class="service">
                <span class="emoji">📁</span>
                Nextcloud
              </a>
              <a href="https://navidrome.${domain}" class="service">
                <span class="emoji">🎵</span>
                Navidrome
              </a>
              <a href="https://vaultwarden.${domain}" class="service">
                <span class="emoji">🔐</span>
                Vaultwarden
              </a>
            </div>
          </div>
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
