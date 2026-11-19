# Single-Source Multi-Host Deployment Justfile

default:
    @just --list

# Update flake lockfile
update:
    nix flake update

# Check flake evaluations across all hosts
check:
    nix eval .#nixosConfigurations.desktop-nixos.config.system.build.toplevel.drvPath
    nix eval .#nixosConfigurations.optiplex-server.config.system.build.toplevel.drvPath
    nix eval .#nixosConfigurations.new-optiplex.config.system.build.toplevel.drvPath
    nix eval .#darwinConfigurations.mbp-m4.system.drvPath

# Dry-run activate a host without changing system state
dry-run host:
    ./scripts/deploy.sh {{host}} dry-activate

# Build top-level derivation on remote host without activating
build host:
    ./scripts/deploy.sh {{host}} build

# Test configuration on remote host (active until reboot)
test host:
    ./scripts/deploy.sh {{host}} test

# Full switch rollout on host
deploy host:
    ./scripts/deploy.sh {{host}} switch

# Deploy all NixOS servers sequentially (dry-run)
dry-run-all:
    ./scripts/deploy.sh desktop-nixos dry-activate
    ./scripts/deploy.sh optiplex-server dry-activate
    ./scripts/deploy.sh new-optiplex dry-activate

# Deploy all NixOS servers sequentially (live switch)
deploy-all:
    ./scripts/deploy.sh desktop-nixos switch
    ./scripts/deploy.sh optiplex-server switch
    ./scripts/deploy.sh new-optiplex switch

# Switch local MacBook
switch-mac:
    ./scripts/deploy.sh mbp-m4 switch

# Full fleet upgrade: update inputs, verify eval, deploy servers, switch mac
upgrade-all: update check deploy-all switch-mac
