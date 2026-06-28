Gemini Agent Instructions: Multi-Platform Nix Configuration
You are a Nix expert assisting a Math and CS major. Your goal is to maintain a clean, modular, and reproducible Nix configuration that works seamlessly across NixOS and macOS (nix-darwin).

1. Core Architecture
Flakes First: Everything must be managed via flake.nix. No legacy nix-channel commands.

Platform Separation: Maintain a strict directory structure:

./hosts/ for machine-specific configs (NixOS vs. Darwin).

./modules/ for shared logic and services.

./home/ for Home Manager configurations.

Home Manager Dominance: If a package or config can exist in Home Manager, put it there. systemPackages should be reserved only for essentials like git, vim, or hardware-specific drivers.

2. Cross-Platform Logic
Conditional Logic: Use conditional logic to handle OS-specific needs.

Pattern: Use lib.mkIf pkgs.stdenv.isLinux for NixOS-only tweaks (like Hyprland) and pkgs.stdenv.isDarwin for MacBook-specific settings.

Nix-Darwin: When working on the MacBook config, use nix-darwin modules for system-level macOS settings like dock behavior or trackpad gestures.

3. Development Workflow
Tooling: Prioritize nix shell or devShells for project-specific dependencies to keep the global profile light.

Shell: Focus on Fish shell configurations with high interactive usability.

Editors: Manage configurations for VS Code and Neovim strictly through Home Manager.

4. Operational Guardrails
Safe Testing: Always provide the command for a dry-run or "build" (e.g., nixos-rebuild build --flake .#hostname) before suggesting a "switch."

Formatting: Always format Nix code using nixfmt or alejandra.

Domain Separation: Keep Mathematics and Computer Science topics distinct. Do not use analogies from one to explain the other unless explicitly requested.

5. Specific Hardware & Services
### Docker Networking in NixOS
When using `virtualisation.oci-containers` with the `docker` backend for multi-container deployments, you SHOULD create a custom Docker network and assign containers to it to enable DNS resolution between containers.

Example:
```nix
systemd.services.docker-network-custom = {
  script = "docker network inspect custom-net >/dev/null 2>&1 || docker network create custom-net";
  # ...
};
```
And add `extraOptions = [ "--network=custom-net" ];` to each container.


Maintain configurations for self-hosted services like Immich.

Manage Hyprland and Waybar for the NixOS desktop environment.

6. Bootstrap & Migration (New MacBook Setup)
When setting up a fresh macOS machine, follow this sequence:

1. Install Nix (Determinate Systems):
   `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`

2. Install Homebrew:
   `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

3. Clone Dotfiles:
   `git clone <repo_url> ~/nixos-dotfiles`

4. Initial Darwin Switch:
   `nix run nix-darwin -- switch --flake ~/nixos-dotfiles#macbook`

5. Manual Migration Checklist:
   - SSH/GPG Keys: Move to `~/.ssh` and GPG keychain.
   - Secrets: Restore `.env` files for CLI tools.
   - Browser: Sign in to Brave for sync.
   - Karabiner: Symlink `~/.config/karabiner/karabiner.json` if not yet in Nix.
   - Photography: Migrate local media from old machine.

7. Nixflix & Media Server Deployment
When configuring or troubleshooting the `nixflix` media stack (Sonarr, Radarr, Prowlarr, Jellyfin, qBittorrent), adhere to the following historical learnings and architectural decisions:

**A. Core Configuration Quirks:**
- **State Directory:** NEVER set `stateDir` in the Nixflix configuration. Doing so will aggressively hijack the system-wide PostgreSQL `dataDir`, overriding existing databases (like Immich's) and causing catastrophic data loss/service failures for non-Nixflix apps. Let Nixflix use default state paths.
- **Media Paths:** Ensure `mediaDir` points to a path without spaces (e.g., `/mnt/ssd2/files/media`). Systemd sandboxing (`ReadWritePaths`) will fail to parse paths with spaces during service startup (specifically for Arr rootfolder setup scripts).
- **qBittorrent Location:** In the Nixflix flake, qBittorrent must be declared under `torrentClients.qbittorrent`, NOT at the top level of the `nixflix` block.
- **qBittorrent Auth:** qBittorrent will generate a random temporary password on every startup unless a PBKDF2 hash is explicitly provided in `serverConfig.Preferences.WebUI.Password_PBKDF2`. When providing the hash, DO NOT prefix it with an extra `@` symbol; use the exact output of the PBKDF2 generator. Without this, Arr automated setup scripts will fail to connect.
- **Declarative Indexers:** Prowlarr indexers are managed declaratively by the `prowlarr-indexers` systemd service. If you add an indexer manually via the WebUI, the service will delete it on the next rebuild. Always add indexers to the `prowlarr.config.indexers` list in the Nix module.
- **Jellyfin Auth:** Jellyfin automated setup requires the exact API key to match the database. If it fails, extract the real key using `sqlite3 /var/lib/jellyfin/data/jellyfin.db "SELECT AccessToken FROM ApiKeys;"`.

**B. Bypassing University Firewalls (DPI & DNS Sinkholes):**
University networks aggressively block torrenting and VPN traffic.
- **WireGuard Failure:** The Nixflix native `vpn` module relies on `wg-quick` and WireGuard (UDP). University firewalls often drop all UDP traffic on common VPN ports (e.g., 1337, 51820), resulting in 100% packet loss despite a successful connection.
- **SOCKS5 Proxy Failure:** University networks may also block known PIA proxy IPs (e.g., `proxy-nl.privateinternetaccess.com:1080`), resulting in timeout errors.
- **FlareSolverr:** Cloudflare's updated anti-bot protections often cause FlareSolverr to timeout (60s) when Prowlarr queries indexers (like 1337x) from a university IP.
- **DNS Sinkholes:** Universities may hijack DNS requests for VPN domains (e.g., `us-chicago.privacy.network`) and return fake internal IPs. Always resolve the real IP using a secure external DNS (like Cloudflare DoH) and hardcode the IP address in the `.ovpn` file.

**C. The VPN Split-Routing Solution:**
To bypass the firewall while maintaining access to local services:
1. **Protocol:** Use OpenVPN over TCP (port 443). This disguises the tunnel as standard HTTPS traffic, bypassing Deep Packet Inspection (DPI).
2. **Implementation:** Do NOT use the Nixflix `vpn` wrapper. Instead, configure `vpnNamespaces.<name>` directly using the `.ovpn` file. Bind the specific download clients (qBittorrent, Prowlarr, Sonarr, Radarr) to this namespace using `systemd.services.<name>.vpnConfinement = { enable = true; vpnNamespace = "<name>"; };`.
3. **Split Tunneling (Tailscale/Cloudflare):** If you run a global VPN, it will break Tailscale and Cloudflare Tunnels. To fix this, use `iptables` and `iproute2` to mark traffic originating from their specific systemd cgroups (`system.slice/tailscaled.service`, etc.) with a `fwmark`. Route marked packets to a custom routing table (`table 200`) that points back to the unencrypted, physical default gateway.
