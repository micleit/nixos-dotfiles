# ❄️ NixOS & Dotfiles

A modular, cross-platform Nix configuration built with Flakes and Home Manager, designed for both NixOS (Desktop) and macOS (Darwin).

## 🚀 Architecture

This configuration follows a modular approach as mandated by [GEMINI.md](./GEMINI.md):

- **Flakes First**: Managed via `flake.nix`.
- **Platform Separation**:
    - `hosts/`: Machine-specific system configurations (NixOS, Darwin).
    - `home/`: User-specific Home Manager profiles.
    - `modules/`: Shared logic, services, and application settings.
- **Home Manager Dominance**: Most user-facing applications (Fish, Ghostty, Hyprland) are managed at the user level for maximum portability.

## 📂 Directory Structure

```text
.
├── flake.nix               # Entry point for the entire configuration
├── hosts/
│   └── nixos-btw/          # NixOS Desktop (nixos-btw)
│       ├── default.nix     # System-level services, hardware, and users
│       └── hardware-configuration.nix # Auto-generated hardware config
├── home/
│   └── mic/                # Main user profile
│       └── default.nix     # Entry point for Home Manager, imports modules
├── modules/
│   ├── home/               # Home Manager modules (Cross-platform)
│   │   ├── shell.nix       # Fish, Git, Yazi, and core CLI utilities
│   │   ├── terminal.nix    # Ghostty and Btop configurations
│   │   └── shared.nix      # Fonts, and shared cross-platform applications
│   └── nixvim.nix          # Neovim configuration via Nixvim
├── config/                 # Source for non-Nix symlinked configurations
├── scripts/                # Custom helper scripts (e.g., drift, borders)
└── walls/                  # Curated wallpapers and media
```

## 🛠️ Usage

### NixOS (Build & Switch)
To apply changes to your NixOS system:
```bash
sudo nixos-rebuild switch --flake .#nixos-btw
```

### Dry Run (Verification)
To verify changes without applying them:
```bash
nixos-rebuild build --flake .#nixos-btw
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
