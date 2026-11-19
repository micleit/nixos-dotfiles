#!/usr/bin/env bash
set -euo pipefail

# Single-source push-deployment script for multi-host NixOS / nix-darwin configurations

HOST="${1:-}"
ACTION="${2:-switch}"
shift 2 2>/dev/null || shift $#

if [ -z "$HOST" ]; then
  echo "Usage: $0 <host> [action] [additional-flags]"
  echo "Hosts:   desktop-nixos (or desktop), optiplex-server, new-optiplex, mbp-m4"
  echo "Actions: dry-activate, build, test, switch, boot (default: switch)"
  exit 1
fi

case "$HOST" in
  desktop|desktop-nixos)
    FLAKE_ATTR="desktop-nixos"
    TARGET_IP="100.69.4.32"
    TARGET_USER="mic"
    IS_DARWIN=false
    ;;
  optiplex-server)
    FLAKE_ATTR="optiplex-server"
    TARGET_IP="100.91.229.67"
    TARGET_USER="mic"
    IS_DARWIN=false
    ;;
  new-optiplex)
    FLAKE_ATTR="new-optiplex"
    TARGET_IP="100.126.42.11"
    TARGET_USER="mic"
    IS_DARWIN=false
    ;;
  mbp-m4|mbp)
    FLAKE_ATTR="mbp-m4"
    TARGET_IP="127.0.0.1"
    TARGET_USER="mic"
    IS_DARWIN=true
    ;;
  *)
    echo "Unknown host: $HOST"
    exit 1
    ;;
esac

echo "=========================================="
echo "Deploying: $FLAKE_ATTR (action: $ACTION)"
echo "Target:    $TARGET_USER@$TARGET_IP"
echo "=========================================="

if [ "$IS_DARWIN" = true ]; then
  if command -v darwin-rebuild >/dev/null 2>&1; then
    darwin-rebuild "$ACTION" --flake ".#$FLAKE_ATTR" "$@"
  else
    nix run nix-darwin -- "$ACTION" --flake ".#$FLAKE_ATTR" "$@"
  fi
  exit 0
fi

# Locate nixos-rebuild
if command -v nixos-rebuild >/dev/null 2>&1; then
  REBUILD_CMD="nixos-rebuild"
else
  REBUILD_CMD="nix run .#darwinConfigurations.mbp-m4.pkgs.nixos-rebuild --"
fi

# Determine sudo elevation flags based on whether target requires password
ELEVATE_ARGS=()
if ssh -o BatchMode=yes -o ConnectTimeout=5 "$TARGET_USER@$TARGET_IP" "sudo -n true" 2>/dev/null; then
  ELEVATE_ARGS=("--elevate=sudo")
else
  ELEVATE_ARGS=("--ask-sudo-password")
fi

# Execute remote rebuild; building on remote target avoids aarch64-darwin cross-compile
exec $REBUILD_CMD "$ACTION" \
  --flake ".#$FLAKE_ATTR" \
  --target-host "$TARGET_USER@$TARGET_IP" \
  --build-host "$TARGET_USER@$TARGET_IP" \
  "${ELEVATE_ARGS[@]}" \
  "$@"
