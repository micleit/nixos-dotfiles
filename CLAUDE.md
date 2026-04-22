# 🤖 CLAUDE.md: Agent Instructions for nixos-dotfiles

This document provides instructions for Claude and other AI agents assisting with creation and maintenance of the nixos-dotfiles repository. It extends [GEMINI.md](./GEMINI.md) with operational patterns, tool preferences, and verification workflows learned through development.

---

## 1. Primary Objectives

- **Maintain modularity**: Keep system, user, and shared configs separated.
- **Preserve reproducibility**: Every change must be testable before merging.
- **Enable cross-platform consistency**: NixOS and Darwin configs share logic where possible.
- **Prioritize Home Manager**: User-level packages and configs go in Home Manager, not systemPackages.
- **Ensure safety**: Always build/dry-run before switching configurations.

---

## 2. Tool Preferences & Workflows

### 2.1 Nix Code Quality

**Formatting is mandatory:**
- Use `nixpkgs-fmt` (preferred) or `alejandra` before committing.
- Command: `nixpkgs-fmt .` (formats entire repo)
- Always validate formatting: `git diff` should show only logical changes, not formatting.

**Before any configuration switch:**
1. Perform a dry-run build: `nixos-rebuild build --flake .#<hostname>`
2. Review any errors or warnings.
3. Only after successful build, switch: `sudo nixos-rebuild switch --flake .#<hostname>`

### 2.2 Search & Navigation

When exploring the codebase:
- **Use grep for code searches** (ripgrep): Fast, precise pattern matching.
- **Use glob for file discovery**: `**/*.nix`, `config/**/*`, etc.
- **Use view for reading files**: Batch multiple reads in parallel for efficiency.
- **Avoid bash commands** like `find`, `cat`, `grep` when the above tools are available.

Example efficient workflow:
```bash
# GOOD: Parallel reads
view: modules/shell.nix
view: modules/terminal.nix
view: modules/shared.nix

# BAD: Sequential bash calls
bash: cat modules/shell.nix
bash: cat modules/terminal.nix
```

### 2.3 Git Workflow

- **Always include Co-authored-by trailer**:
  ```
  Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
  ```

- **Commit message style**:
  - Imperative: "Add Hyprland keybindings" (not "Added" or "Adds")
  - Include context: Reference which host(s) or modules changed
  - Example: `feat(desktop-linux): add Hyprland workspace bindings`

- **Always test before committing**:
  - For NixOS changes: `nixos-rebuild build --flake .#nixos-btw`
  - For Darwin changes: `nix run nix-darwin -- build --flake .#mbp-m4`
  - For Home Manager only: `home-manager build --flake .#mic@<hostname>`

---

## 3. Architecture Patterns

### 3.1 Directory Navigation

Know these paths by heart:

```
flake.nix                           # Entry point, defines all configs
├── hosts/
│   ├── nixos-btw/                 # Desktop NixOS
│   ├── optiplex-server/           # Headless NixOS server
│   ├── mbp-m4/                    # MacBook Pro M4 (Darwin)
│   └── headless-m1/               # Headless M1 Mac (Darwin)
├── home/
│   └── mic/
│       └── default.nix            # User profile (Home Manager)
├── modules/
│   ├── shell.nix                  # Fish, Git, Yazi, CLI utils
│   ├── terminal.nix               # Ghostty, Btop
│   ├── shared.nix                 # Fonts, cross-platform packages
│   ├── nixvim.nix                 # Neovim via Nixvim
│   ├── yazi.nix                   # File manager config
│   ├── linux/
│   │   └── desktop-linux.nix      # Hyprland, desktop-specific
│   ├── darwin/                    # macOS-specific modules
│   │   ├── darwin-system.nix      # System settings (Yabai, Skhd)
│   │   └── ...
│   └── server/                    # Self-hosted services
│       ├── immich.nix
│       ├── nextcloud.nix
│       ├── samba.nix
│       └── navidrome.nix
├── config/                        # Non-Nix source configs (symlinked)
│   ├── noctalia/                  # Hyprland/Waybar themes
│   ├── btop/
│   ├── yazi/
│   └── ...
└── scripts/                       # Custom helper scripts
```

### 3.2 Platform-Specific Conditionals

**Always use these patterns for OS-specific logic:**

```nix
# NixOS only (e.g., Hyprland, systemd services)
lib.mkIf pkgs.stdenv.isLinux {
  # NixOS-specific config
}

# macOS only (e.g., Yabai, Skhd, Darwin system settings)
lib.mkIf pkgs.stdenv.isDarwin {
  # Darwin-specific config
}

# Home directory conditional
home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/mic" else "/home/mic";
```

### 3.3 Module Import Pattern

All user-facing modules must be imported in `home/mic/default.nix`:

```nix
imports = [
  ../../modules/shell.nix
  ../../modules/terminal.nix
  ../../modules/shared.nix
  ../../modules/nixvim.nix
  ../../modules/yazi.nix
  # Conditionally import platform-specific modules
] ++ lib.optionals pkgs.stdenv.isLinux [
  ../../modules/linux/desktop-linux.nix
] ++ lib.optionals pkgs.stdenv.isDarwin [
  ../../modules/darwin/darwin-system.nix
];
```

### 3.4 Symlinked Configs

Large configs (Hyprland, Yazi, Btop) live in `config/` and are symlinked:

```nix
xdg.configFile."noctalia".source = config.lib.file.mkOutOfStoreSymlink 
  "${config.home.homeDirectory}/nixos-dotfiles/config/noctalia";
```

**Benefit**: Edits take effect on next app restart without rebuild.

---

## 4. Common Tasks & Workflows

### 4.1 Adding a New System

1. **Create host config**: `hosts/<hostname>/default.nix`
2. **Add hardware config** (NixOS only): `hosts/<hostname>/hardware-configuration.nix`
3. **Update flake.nix**:
   - For NixOS: Add to `nixosConfigurations.<hostname>`
   - For Darwin: Add to `darwinConfigurations.<hostname>`
4. **Test build**: `nixos-rebuild build --flake .#<hostname>` (NixOS) or `nix run nix-darwin -- build --flake .#<hostname>` (Darwin)
5. **Commit with all three checks passed**.

### 4.2 Adding a New Module

1. **Create module**: `modules/<name>.nix` with function signature:
   ```nix
   { config, pkgs, lib, inputs, ... }:
   {
     # module content
   }
   ```
2. **Add platform conditionals** if needed: `lib.mkIf pkgs.stdenv.isLinux { ... }`
3. **Import in `home/mic/default.nix`**: Add to `imports` list.
4. **Test**:
   ```bash
   home-manager build --flake .#mic@<hostname>
   ```
5. **Format**: `nixpkgs-fmt .`
6. **Commit**.

### 4.3 Updating a Symlinked Config

Symlinked configs (`config/*`) can be edited directly without rebuilding:

1. Edit file in `config/<app>/`
2. Restart the application
3. Changes take effect immediately
4. **Commit the changes** when stable

### 4.4 Debugging Build Failures

When `nixos-rebuild build` fails:

1. **Read the error output carefully**: Nix errors usually point to exact line numbers.
2. **Search for syntax issues**: Invalid Nix syntax, missing braces, quote mismatches.
3. **Check imports**: Ensure modules are imported correctly in parent config.
4. **Test incrementally**:
   ```bash
   home-manager build --flake .#mic@nixos-btw  # Test user only
   ```
5. **Validate Nix syntax**:
   ```bash
   nix flake check
   ```
6. **Consult Nixpkgs manual**: https://nixos.org/manual/nixpkgs/stable/ and https://nixos.org/manual/nixos/stable/

---

## 5. Testing & Verification

### 5.1 Pre-Commit Checklist

Before committing any changes:

- [ ] Code formatted with `nixpkgs-fmt .`
- [ ] Dry-run build succeeds: `nixos-rebuild build --flake .#<hostname>`
- [ ] No unexpected changes in `git diff`
- [ ] Commit message is clear and includes context
- [ ] Co-authored-by trailer included
- [ ] Related files (e.g., README.md, GEMINI.md) updated if applicable

### 5.2 Testing Commands by Host

**NixOS Desktop (nixos-btw):**
```bash
nixos-rebuild build --flake .#nixos-btw
sudo nixos-rebuild switch --flake .#nixos-btw
```

**NixOS Server (optiplex-server):**
```bash
nixos-rebuild build --flake .#optiplex-server
sudo nixos-rebuild switch --flake .#optiplex-server
```

**Darwin (mbp-m4):**
```bash
nix run nix-darwin -- build --flake .#mbp-m4
nix run nix-darwin -- switch --flake .#mbp-m4
```

**Darwin (headless-m1):**
```bash
nix run nix-darwin -- build --flake .#headless-m1
nix run nix-darwin -- switch --flake .#headless-m1
```

**Home Manager (user-only changes):**
```bash
home-manager build --flake .#mic@nixos-btw
home-manager switch --flake .#mic@nixos-btw
```

---

## 6. Code Quality Standards

### 6.1 Nix Style

- **Use 2-space indentation** (standard for Nix).
- **Use descriptive variable names**: `enableDesktopEnvironment` (not `enableDE`).
- **Prefer `lib.mkIf` over imperative conditionals** for boolean options.
- **Use late binding**: Reference config values via `config.<path>` rather than let-binding early.

### 6.2 Comments

Comment sparingly; code should be self-documenting. Only comment:
- **Non-obvious logic**: Why a workaround exists, not what it does.
- **Cross-platform quirks**: Explain platform-specific conditional logic.
- **External references**: Link to relevant issues, PRs, or documentation.

Example:
```nix
# GOOD: Explains the why
# Work around Hyprland crash on dual-monitor setup with NVIDIA
# See: https://github.com/hyprwm/Hyprland/issues/XXXX
wayland.windowManager.hyprland.settings.monitor = [ "HDMI-1,1920x1080@60,-1920x0,1" ];

# BAD: States the obvious
# Set monitor resolution
wayland.windowManager.hyprland.settings.monitor = ...
```

### 6.3 Module Naming

- **Use kebab-case for files**: `desktop-linux.nix`, `darwin-system.nix`
- **Use camelCase for Nix attributes**: `enableHyprland`, `windowManager`
- **Use descriptive names**: `modules/desktop-linux.nix` (not `modules/linux.nix`)

---

## 7. Agent Decision Tree

When assisting with nixos-dotfiles tasks:

### Is it a code search/exploration task?
- ✅ Use **grep**, **glob**, **view** (prefer these over bash)
- ✅ Use **parallel tool calling** for multiple independent reads/searches

### Is it a configuration change?
- ✅ Always **build first** before switching
- ✅ **Format with nixpkgs-fmt** before committing
- ✅ **Include Co-authored-by trailer** in commits

### Is it a cross-platform change (NixOS + Darwin)?
- ✅ Use **lib.mkIf pkgs.stdenv.isLinux** and **pkgs.stdenv.isDarwin** conditionals
- ✅ Test both platforms' dry-run builds before switching

### Is it a new module or host?
- ✅ Follow the **module import pattern** from 3.3
- ✅ Ensure **symlinks** use correct home directory paths
- ✅ Add **platform conditionals** if OS-specific

### Is it unclear or ambiguous?
- ✅ Use **ask_user** tool to clarify scope, design decisions, and constraints
- ✅ Don't assume; gather requirements first

### Is it a larger task requiring coordination?
- ✅ Create a **plan.md** in session workspace
- ✅ Use **SQL todos** to track multi-step work
- ✅ Update todo status as work progresses

---

## 8. Special Contexts & Domains

### 8.1 Hyprland (NixOS Desktop)

- **Config source**: `config/noctalia/` (symlinked)
- **Module**: `modules/linux/desktop-linux.nix`
- **Theme**: Custom Noctalia configuration with Waybar
- **Safe edits**: Modify `config/noctalia/` directly; restart Hyprland to apply

### 8.2 Self-Hosted Services (optiplex-server)

- **Services**: Immich (photos), Nextcloud (files/calendar), Samba (SMB), Navidrome (music), Vaultwarden (passwords)
- **Module directory**: `modules/server/`
- **Pattern**: Each service gets its own module
- **Database management**: Use Nix to manage PostgreSQL, Redis backups
- **Access**: Via Cloudflare Tunnel (see section 8.2a for details)

#### 8.2a Cloudflare Tunnel Setup (optiplex-server)

**Context**: optiplex-server is behind a college campus NAT (no public IP, no router access). Uses Cloudflare Tunnel for secure public access.

**Architecture**:
```
Internet → Cloudflare (DNS + SSL) → Cloudflare Tunnel (outbound connection) → optiplex-server (localhost services)
```

**Why this approach**:
- ✅ No port forwarding needed (works behind NAT)
- ✅ Outbound-only connection (very secure)
- ✅ Automatic SSL/TLS via Cloudflare (free tier)
- ✅ No ACME certificate management needed
- ✅ Works on any internet connection

**Current Setup**:
- **Domain**: 53729123.xyz (registered on Porkbun, nameservers point to Cloudflare)
- **Tunnel token**: Stored in `/etc/cloudflared/tunnel.env` on optiplex-server
- **Services**: 
  - https://immich.53729123.xyz → http://127.0.0.1:2283
  - https://nextcloud.53729123.xyz → http://127.0.0.1:80
  - https://navidrome.53729123.xyz → http://127.0.0.1:4533
  - https://vaultwarden.53729123.xyz → http://127.0.0.1:8222
  - https://53729123.xyz → http://127.0.0.1:8080 (landing page)

**Adding a New Service to the Tunnel**:

1. **Create/update NixOS module** in `modules/server/<service>.nix`:
   ```nix
   services.myservice = {
     enable = true;
     config = {
       bindAddr = "127.0.0.1";
       port = 9999;
       # ... other config
     };
   };
   ```

2. **Import module** in `hosts/optiplex-server/default.nix`:
   ```nix
   imports = [
     ...
     ../../modules/server/myservice.nix
   ];
   ```

3. **Deploy**:
   ```bash
   cd /home/mic/nixos-dotfiles
   sudo nixos-rebuild switch --flake .#optiplex-server
   ```

4. **Verify service running**:
   ```bash
   systemctl status myservice
   curl -I http://127.0.0.1:9999
   ```

5. **Add route in Cloudflare dashboard**:
   - Go to https://one.dash.cloudflare.com
   - Zero Trust → Networks → Tunnels → optiplex-server
   - Public Hostname tab → Add a public hostname
   - Fill in:
     - Subdomain: `myservice`
     - Domain: `53729123.xyz`
     - Service Type: `HTTP`
     - Service URL: `http://127.0.0.1:9999`
   - Save

6. **Verify tunnel config updated**:
   ```bash
   journalctl -u cloudflared -n 5 | grep "Updated to new configuration"
   ```

7. **Test**: Visit `https://myservice.53729123.xyz` in browser

**Troubleshooting**:
- Service returns 502 error → Check service is running: `systemctl status myservice`
- Tunnel won't connect → Check token is valid: `systemctl status cloudflared`
- Service not accessible → Verify Cloudflare route is correct (check dashboard)
- DNS not resolving → Wait 5-30 mins for Cloudflare to propagate

**Important Files**:
- NixOS tunnel module: `modules/server/cloudflare-tunnel.nix`
- Tunnel token file: `/etc/cloudflared/tunnel.env` (on server, not in git)
- Cloudflare dashboard: https://one.dash.cloudflare.com

**Regenerating Tunnel Token** (if expired):
1. Cloudflare dashboard → Zero Trust → Tunnels → optiplex-server
2. Click "Rotate token" or recreate tunnel
3. Copy new token
4. On optiplex-server:
   ```bash
   sudo systemctl stop cloudflared
   echo -n "TUNNEL_TOKEN=<new_token>" | sudo tee /etc/cloudflared/tunnel.env > /dev/null
   sudo systemctl start cloudflared
   ```

**Key Learning**: Cloudflare Tunnel is ideal for self-hosted services behind NAT. The outbound-only connection model avoids all firewall/port forwarding complexity while maintaining security.

### 8.3 Photography Workflows

- **Hardware**: Fujifilm X-T3, GoPro
- **Scripts**: Stored in `scripts/` (Nix-wrapped)
- **External storage**: Coordinated with Immich on optiplex-server
- **Tools**: Raw processing, video encoding via Nix packages

### 8.4 macOS (Darwin)

- **Use nix-darwin** for system-level settings
- **Desktop manager**: Yabai (tiling) + Skhd (hotkeys)
- **Home Manager modules** work across Darwin hosts
- **Bootstrap sequence**: See GEMINI.md section 6

---

## 9. Troubleshooting & Edge Cases

### 9.1 "Infinite recursion" in Nix

Usually caused by circular imports or late-binding issues.
- **Check imports**: Ensure no module imports its parent.
- **Use `config.<path>` not let-bindings**: Late binding avoids recursion.

### 9.2 "Attribute not found" errors

Module or attribute missing or misspelled.
- **Verify module is imported** in `home/mic/default.nix`.
- **Check attribute names**: Nix is case-sensitive.
- **Search for definition**: Use grep to locate where attribute is defined.

### 9.3 "Home directory doesn't exist" on Darwin

Symlinks using hardcoded paths fail on new machines.
- **Always use `${config.home.homeDirectory}`** not `/Users/mic`.
- **Test on both NixOS and Darwin** before committing.

### 9.4 Build succeeds but switch fails

Usually a runtime issue, not a Nix syntax issue.
- **Check systemd service logs**: `journalctl -xe`
- **Verify file permissions**: Symlinks and generated configs must be readable.
- **Rollback if critical**: `sudo nixos-rebuild switch --rollback`

---

## 10. Documentation Maintenance

When making changes, update documentation if needed:

- **GEMINI.md**: High-level design principles (rarely changes)
- **README.md**: Usage examples, feature overview (update when adding major features)
- **CLAUDE.md**: Operational patterns, tool workflows, agent decision tree (this file)
- **Code comments**: Explain non-obvious logic (sparingly)

**Documentation update checklist:**
- [ ] Describe what changed and why
- [ ] Update examples if they're outdated
- [ ] Link to related sections or external resources
- [ ] Keep tone consistent with existing docs

---

## 11. Quick Reference

### Build Commands (Copy-Paste Ready)

```bash
# NixOS Desktop
nixos-rebuild build --flake .#nixos-btw
sudo nixos-rebuild switch --flake .#nixos-btw

# NixOS Server
nixos-rebuild build --flake .#optiplex-server
sudo nixos-rebuild switch --flake .#optiplex-server

# Darwin (mbp-m4)
nix run nix-darwin -- build --flake .#mbp-m4
nix run nix-darwin -- switch --flake .#mbp-m4

# Darwin (headless-m1)
nix run nix-darwin -- build --flake .#headless-m1
nix run nix-darwin -- switch --flake .#headless-m1

# Home Manager (user-only)
home-manager build --flake .#mic@<hostname>
home-manager switch --flake .#mic@<hostname>

# Format Nix code
nixpkgs-fmt .

# Validate Nix syntax
nix flake check
```

### File Locations (Quick Lookup)

| Component | Location | Type |
|-----------|----------|------|
| Entry point | `flake.nix` | Nix |
| Desktop (NixOS) | `hosts/nixos-btw/default.nix` | Nix |
| Server (NixOS) | `hosts/optiplex-server/default.nix` | Nix |
| MacBook (Darwin) | `hosts/mbp-m4/default.nix` | Nix |
| User config | `home/mic/default.nix` | Nix |
| Shared modules | `modules/` | Nix |
| Hyprland config | `config/noctalia/` | Symlinked |
| Shell config | `modules/shell.nix` | Nix |
| Neovim config | `modules/nixvim.nix` | Nix |
| Services config | `modules/server/` | Nix |
| Cloudflare Tunnel | `modules/server/cloudflare-tunnel.nix` | Nix |
| Landing page | `modules/server/landing-page.nix` | Nix |
| Tunnel token | `/etc/cloudflared/tunnel.env` | System (not in git) |

---

## 12. Final Guidelines for Agents

1. **Respect the user's codebase**: Never suggest architectural rewrites unless explicitly requested.
2. **Test everything before committing**: Build ≠ switch. Always build first.
3. **Document your reasoning**: Explain *why* a change is necessary, not just *what* changed.
4. **Ask for clarification**: Use `ask_user` when scope or design is ambiguous.
5. **Keep changes surgical**: Fix only what's requested; don't refactor unrelated code.
6. **Preserve modularity**: New features should follow existing patterns.
7. **Think cross-platform**: Changes affecting both NixOS and Darwin need testing on both.

---

**Last Updated**: 2026-04-22 (Cloudflare Tunnel setup for optiplex-server)  
**For latest GEMINI.md principles**: See [GEMINI.md](./GEMINI.md)
