# ❄️ NixOS & Dotfiles

A modular, cross-platform Nix configuration built with Flakes and Home Manager, designed for both NixOS (Desktop) and macOS (Darwin).

## 🚀 Architecture

This configuration follows a modular, flake-parts-based approach as mandated by [GEMINI.md](./GEMINI.md):

- **Flake Parts**: Uses `hercules-ci/flake-parts` for modular flake composition (`parts/nixos-systems.nix`, `parts/darwin-systems.nix`)
- **Clear Hierarchy**:
  - `hosts/` → Machine-specific system configurations (hardware, networking, SSH keys)
  - `home/` → User profile (imports shared home-manager modules across all hosts)
  - `modules/home/` → Cross-platform Home Manager configs (shell, terminal, packages, editors)
  - `modules/systems/` → System-level configs (Darwin, Linux, Server with clear separation)
- **Home Manager First**: User-facing applications (Fish, Ghostty, Neovim, Yazi) managed at user level for portability
- **Minimal Host Config**: Hosts only contain hardware/platform-specific settings; features come from modules

## 📂 Directory Structure

```text
.
├── flake.nix               # Entry point (uses Flake Parts)
├── parts/                  # Flake-parts modules
│   ├── nixos-systems.nix   # NixOS configurations
│   └── darwin-systems.nix  # Darwin configurations
├── hosts/
│   ├── desktop-nixos/          # NixOS Desktop
│   │   ├── default.nix     # System-level hardware, networking, SSH
│   │   └── hardware-configuration.nix
│   ├── acer-nixos/
│   ├── optiplex-server/    # Self-hosted services (Immich, Nextcloud, etc)
│   ├── mbp-m4/             # MacBook Pro M4
│   └── headlessm1/         # Headless M1 Mac
├── home/
│   └── mic/                # Main user profile
│       └── default.nix     # Home Manager imports (shared across all hosts)
├── modules/
│   ├── home/               # Home Manager modules (cross-platform)
│   │   ├── shell.nix       # Fish, Git, Yazi, CLI utilities
│   │   ├── terminal.nix    # Ghostty, Btop
│   │   ├── shared.nix      # Fonts, cross-platform packages (obsidian, sioyek, etc)
│   │   ├── nixvim.nix      # Neovim via Nixvim
│   │   ├── yazi.nix        # File manager config
│   │   └── caveman.nix     # Caveman mode for CLI tools
│   └── systems/            # System-level configurations
│       ├── darwin/         # macOS-specific
│       │   ├── homebrew.nix       # Homebrew management (parameterized per-host)
│       │   ├── darwin.nix         # macOS user-level packages
│       │   ├── yabai.nix          # Tiling window manager
│       │   ├── skhd.nix           # Hotkey daemon
│       │   ├── aerospace.nix      # AeroSpace config (headless-m1 only)
│       │   └── aerospace-skhd.nix # AeroSpace skhd overrides (headless-m1 only)
│       ├── linux/          # Linux-specific
│       │   └── desktop-linux.nix  # Hyprland, desktop apps
│       └── server/         # Self-hosted services
│           ├── cloudflare-tunnel.nix  # Tunnel setup for optiplex-server
│           ├── immich.nix
│           ├── nextcloud.nix
│           ├── navidrome.nix
│           ├── vaultwarden.nix
│           └── ... (see modules/systems/server/)
├── config/                 # Non-Nix source configs (symlinked)
│   ├── noctalia/           # Hyprland/Waybar themes
│   ├── btop/
│   ├── yazi/
│   └── ...
└── scripts/                # Custom helper scripts
```

## 🛠️ Usage

### NixOS (Build & Switch)
To apply changes to your NixOS system:
```bash
sudo nixos-rebuild switch --flake .#desktop-nixos
```

### Dry Run (Verification)
To verify changes without applying them:
```bash
nixos-rebuild build --flake .#desktop-nixos
```

## ✨ Key Components

- **Window Manager**: [Hyprland](https://hyprland.org/) with a custom [Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell) setup.
- **Shell**: [Fish](https://fishshell.com/) with Zoxide, Eza, and Yazi integration.
- **Editor**: [Neovim](https://neovim.io/) managed via [Nixvim](https://github.com/nix-community/nixvim).
- **Terminal**: [Ghostty](https://ghostty.org/) with a Gruvbox/Noctalia-inspired theme.
- **File Manager**: [Yazi](https://yazi-rs.github.io/) (terminal) and Nautilus (GUI).
- **Gaming**: Steam and Gamemode enabled.

## 🍎 macOS Readiness
The configuration is structured to support `nix-darwin`. To add a MacBook:
1. Create a new host in `hosts/`.
2. Reference the shared modules in `modules/`.
3. Add a new output in `flake.nix` under `darwinConfigurations`.
