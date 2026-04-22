{
  config,
  pkgs,
  lib,
  ...
}:

{
  # DEPRECATED: nginx reverse proxy is now handled by modules/server/nginx-reverse-proxy.nix
  # This module is kept for reference but all functionality has been migrated
  
  # Vaultwarden will be proxied at vaultwarden.53729123.xyz
  # with SSL certificates managed by ACME in the nginx-reverse-proxy module
}
