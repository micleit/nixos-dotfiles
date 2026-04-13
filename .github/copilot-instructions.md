# Copilot Instructions for nixos-dotfiles

## Overview

This is a modular, cross-platform Nix configuration using **Flakes** and **Home Manager** to manage systems across NixOS (desktop/server) and macOS (Darwin). The architecture prioritizes modularity and code reuse across platforms.

See [GEMINI.md](../GEMINI.md) for detailed design principles and [README.md](../README.md) for usage examples.

## Build & Test Commands

### NixOS Systems

Apply configuration to **nixos-btw** (desktop):
```bash
sudo nixos-rebuild switch --flake .#nixos-btw
```

Dry-run before applying (always do this first):
```bash
nixos-rebuild build --flake .#nixos-btw
```

Apply to **optiplex-server**:
```bash
sudo nixos-rebuild switch --flake .#optiplex-server
```

### macOS (Darwin)

Switch on **mbp-m4** (Apple Silicon):
```bash
nix run nix-darwin -- switch --flake .#mbp-m4
```

Dry-run:
```bash
nix run nix-darwin -- build --flake .#mbp-m4
```

Switch on **headless-m1**:
```bash
nix run nix-darwin -- switch --flake .#headless-m1
```

### Home Manager (User Config)

Test user profile without switching:
```bash
home-manager build --flake .#mic@nixos-btw
```

## Architecture

### Directory Structure

- **flake.nix**: Entry point. Defines all system configurations (nixOS and Darwin).
- **hosts/**: Machine-specific system configs
  - `nixos-btw/`: Desktop NixOS (Hyprland, gaming, photography)
  - `optiplex-server/`: Headless server with Immich, Nextcloud, Samba, Navidrome
  - `mbp-m4/`: MacBook Pro M4 (Darwin)
  - `headless-m1/`: Headless M1 Mac (Darwin)
- **home/mic/**: User profile (Home Manager). Imports all user-facing modules.
- **modules/**: Shared reusable configurations
  - `shell.nix`: Fish shell, Git, Yazi, CLI utilities
  - `terminal.nix`: Ghostty, Btop
  - `nixvim.nix`: Neovim via Nixvim
  - `shared.nix`: Fonts, cross-platform packages
  - `yazi.nix`: File manager
  - `linux/desktop-linux.nix`: Hyprland, desktop-specific (Linux only)
  - `darwin/`: macOS-specific modules (Yabai, Skhd, Darwin system settings)
  - `server/`: Self-hosted services (Immich, Nextcloud, Samba, Navidrome)
- **config/**: Non-Nix source configs (symlinked via `xdg.configFile`)
  - `noctalia/`: Hyprland/Waybar theme config
  - `btop/`, `yazi/`, `drift/`: CLI tool configs

### Platform-Specific Logic

Use conditional expressions for OS-specific code:

```nix
# For NixOS-only modules (e.g., Hyprland)
lib.mkIf pkgs.stdenv.isLinux {
  # NixOS config
}

# For macOS-only modules
lib.mkIf pkgs.stdenv.isDarwin {
  # Darwin config
}
```

Conditional paths (home directory differs):
```nix
home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/mic" else "/home/mic";
```

### Module Pattern

All user-facing packages and services go in Home Manager modules (`modules/*.nix`), not `systemPackages`. System-level packages are reserved for essentials: git, vim, hardware drivers.

Module files import in `home/mic/default.nix`:
```nix
imports = [
  ../../modules/shell.nix
  ../../modules/terminal.nix
  ../../modules/shared.nix
  # ...
];
```

## Key Conventions

### Nix Formatting

Always format Nix code before committing:
```bash
nixpkgs-fmt .
```

Alternatively, use alejandra:
```bash
alejandra .
```

Both tools are available in the shell. Default preference: **nixpkgs-fmt**.

### Import Patterns

- System configs import from `hosts/<hostname>/`.
- User configs import from `home/mic/default.nix`.
- Shared logic lives in `modules/`.
- Pass `inputs` via `specialArgs` in flake.nix to access flake inputs (e.g., nixvim, darwin).

### Symlinked Configs

Large config files (Hyprland, Yazi, Btop) are stored in `config/` and symlinked via:
```nix
xdg.configFile."noctalia".source = config.lib.file.mkOutOfStoreSymlink 
  "${config.home.homeDirectory}/nixos-dotfiles/config/noctalia";
```

This allows editing without rebuilding. Changes take effect on next app restart.

### Incremental Rebuilds

- For Home Manager–only changes: `home-manager switch --flake .`
- For system changes: `sudo nixos-rebuild switch --flake .` (NixOS) or `nix run nix-darwin -- switch --flake .` (Darwin)
- Always test with `build` before `switch`.

## System Outputs in flake.nix

The flake defines:
- **nixosConfigurations**: nixos-btw, optiplex-server
- **darwinConfigurations**: mbp-m4, headless-m1

Each uses `nixpkgs.lib.nixosSystem` or `darwin.lib.darwinSystem` with:
- System-level modules from `hosts/<hostname>/default.nix`
- Home Manager integration via `home-manager.nixosModules.home-manager` or `home-manager.darwinModules.home-manager`
- User profile: `./home/mic/default.nix`
- Platform-specific modules: `./modules/linux/desktop-linux.nix` or `./modules/darwin/darwin.nix`

## Design Priorities

1. **Flakes First**: No legacy `nix-channel` commands.
2. **Platform Separation**: Strict directory structure for Linux vs. macOS.
3. **Home Manager Dominance**: User packages and configs belong in Home Manager, not systemPackages.
4. **Modularity**: Reuse across hosts via shared modules.
5. **Safe Testing**: Always `build` before `switch`.

## Specific Contexts

- **Hyprland**: NixOS desktop only; configured via `modules/linux/desktop-linux.nix` and symlinked Noctalia configs.
- **Gaming**: Steam, Gamemode enabled on nixos-btw.
- **Photography**: Workflows for Fujifilm X-T3/GoPro via scripts in `scripts/`.
- **Self-Hosted Services**: Immich (photo storage), Nextcloud (files/calendar), Samba (SMB shares), Navidrome (music streaming) on optiplex-server.
- **macOS**: Yabai (tiling WM), Skhd (hotkey daemon), Darwin-specific settings via nix-darwin.

## When Adding a New Host

1. Create `hosts/<hostname>/default.nix` with system config.
2. Create or reference `hosts/<hostname>/hardware-configuration.nix` (auto-generated on NixOS).
3. Add output in `flake.nix`:
   - For NixOS: `nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem { ... }`
   - For Darwin: `darwinConfigurations.<hostname> = darwin.lib.darwinSystem { ... }`
4. Reference shared modules in `modules/` as needed.
5. Import `home/mic/default.nix` via Home Manager for user config.

## When Adding a New Module

1. Create `modules/<name>.nix` with program config or settings.
2. Use `{ config, pkgs, lib, inputs, ... }:` as the function signature.
3. Wrap Linux-only sections with `lib.mkIf pkgs.stdenv.isLinux { ... }`.
4. Import the module in `home/mic/default.nix` or system config as appropriate.
5. Format with `nixpkgs-fmt` before committing.

## MCP Servers

For enhanced Copilot capabilities in this repository, the **Git MCP Server** is recommended. It allows Copilot to:
- Query commit history and understand changes
- Reference past decisions in the codebase
- Analyze branches and diffs

To enable Git MCP in your Copilot CLI config, see your Copilot documentation for MCP server setup.
