# Immich Storage Methods: Detailed Comparison

A comprehensive analysis of storage approaches for Immich external media libraries, comparing methods, trade-offs, and recommendations.

---

## Overview: Immich Storage Architecture

Immich supports media in two fundamental ways:

1. **Managed Upload Storage** (`UPLOAD_LOCATION`)
   - Files uploaded through Immich UI/app
   - Immich has full control and ownership
   - Default location: `$UPLOAD_LOCATION/upload/<userID>/`

2. **External Libraries** (This Research)
   - Files stored outside `UPLOAD_LOCATION`
   - Immich reads them, creates database entries
   - User maintains original file ownership

---

## Method 1: Docker Volume Mounts (Docker Deployments)

### Description
Mount external storage directly into container via `docker-compose.yml`

### Configuration
```yaml
immich-server:
  volumes:
    - ${UPLOAD_LOCATION}:/data
    - /mnt/nas/photos:/mnt/media/photos:ro
    - /mnt/external-ssd:/mnt/media/backup:ro
    
immich-microservices:  # IMPORTANT: Also mount for workers
  volumes:
    - ${UPLOAD_LOCATION}:/data
    - /mnt/nas/photos:/mnt/media/photos:ro
    - /mnt/external-ssd:/mnt/media/backup:ro
```

### Key Points
- `:ro` suffix makes volume read-only (prevents web UI deletion)
- **MUST mount to all worker containers**, not just server
- Import paths in Immich UI must use container-internal paths (`/mnt/media/photos`), not host paths
- Dynamically specify paths in `.env` file

### Advantages
- Docker best practice
- Explicit and auditable (in docker-compose.yml)
- Easy to add/remove volumes
- Excellent documentation in Immich official guides

### Disadvantages
- Requires docker-compose recreation to add/remove mounts
- Must remember to mount to microservices too
- Container path mapping can be confusing

### Best For
- Docker-only deployments
- Multi-container setups (server + microservices)
- When using Immich docker-compose.yml directly

---

## Method 2: Filesystem Bind Mounts (NixOS/systemd)

### Description
Mount external storage at filesystem level using NixOS `fileSystems` declarative config

### Configuration
```nix
# Current nixos-dotfiles approach
fileSystems."/mnt/old-laptop" = {
  device = "/dev/disk/by-uuid/7290c982-8ba3-422f-9eda-4831b7255260";
  fsType = "ext4";
  options = [ "nofail" "defaults" ];
};

fileSystems."/var/lib/immich" = {
  device = "/mnt/old-laptop/var/lib/immich";
  fsType = "none";
  options = [ "bind" "nofail" ];
  depends = [ "/mnt/old-laptop" ];
};
```

### Key Points
- `fsType = "none"` indicates bind mount
- `depends` ensures parent mounts before child
- `nofail` prevents boot failures if drive missing
- Service sees files at `/var/lib/immich` directly
- No container path mapping needed

### Advantages
- Declarative, reproducible configuration
- Native to NixOS abstraction layer
- Works for any systemd service (not Docker-specific)
- Matches Immich's troubleshooting documentation
- No need for service-specific volume configuration
- Clean separation of concerns (filesystem vs. service config)

### Disadvantages
- Requires NixOS rebuild to modify
- Less explicit than container-aware approach
- Bind mounts can be confusing conceptually

### Best For
- NixOS systems running Immich directly (not in Docker)
- Systems that need declarative, reproducible config
- Archive/read-only external storage
- When you want filesystem-level uniformity

---

## Method 3: Network Mounts (NAS/SMB/NFS)

### Description
Mount network-attached storage (NAS) for external libraries

### Configuration (NixOS)
```nix
fileSystems."/mnt/nas-photos" = {
  device = "192.168.1.100:/exports/photos";
  fsType = "nfs";
  options = [ "nofail" "noauto" "x-systemd.automount" ];
};

# Or for SMB/Samba:
fileSystems."/mnt/samba-photos" = {
  device = "//nas.local/photos";
  fsType = "cifs";
  options = [
    "username=user"
    "password=pass"  # Or use /etc/fstab secrets
    "nofail"
  ];
};
```

### Configuration (Docker)
```yaml
immich-server:
  volumes:
    - /mnt/nas-photos:/mnt/media/nas:ro
```

### Key Points
- NFS and SMB both supported
- Automatic watching **does NOT work** on network shares
- Must use periodic rescans (not recommended for large libraries)
- Ensure mount survives network interruptions (`x-systemd.automount`)

### Advantages
- Decentralized storage (keep data on NAS, Immich on server)
- Cost-effective for multi-device setups
- Easy disaster recovery

### Disadvantages
- Network latency impacts scanning speed
- Automatic watching unavailable (must rescan manually)
- Network issues can cause availability problems
- Not ideal for tight integration

### Best For
- Large photo archives on dedicated NAS
- Multi-server setups where photos are shared
- When you want storage separate from compute
- Cost-conscious setups

### Caution
Database MUST NOT be on network share (corruption risk)

---

## Method 4: Separate External Library Mount with UI

### Description
Mount external storage to a separate location and manage via Immich web UI

### Configuration (NixOS)
```nix
# Mount external drive separately
fileSystems."/mnt/immich-external" = {
  device = "/dev/disk/by-uuid/...";
  fsType = "ext4";
  options = [ "nofail" "ro" ];  # Read-only for archives
};
```

### Configuration (Immich Web UI)
1. Navigate to: Administration > External Libraries
2. Click "Create Library"
3. Select user who owns this library
4. Click "Add" in "Folders" section
5. Enter import path: `/mnt/immich-external`
6. Optionally add exclusion patterns (e.g., `**/Raw/**`)
7. Click "Scan"

### Key Points
- Separate from `/var/lib/immich` (managed uploads)
- Fully visible and manageable in web UI
- Can have multiple import paths in single library
- Support for exclusion patterns (glob syntax)
- Automatic nightly rescans + manual trigger
- Optional: Experimental filesystem watching

### Advantages
- Most flexible for multi-library setups
- Explicit in UI (visible what's external)
- Add/remove libraries without remounting
- Immich-native feature (official support)
- Can use multiple import paths
- Better for future scalability

### Disadvantages
- Requires web UI setup (not 100% declarative)
- Manual rescans needed after external file changes
- Experimental watching feature
- Slightly more complex per-library configuration

### Best For
- Multi-library setups (different sources)
- When you want UI visibility
- Frequent library additions
- When you want maximum flexibility
- Future-proof implementations

---

## Comparison Matrix

| Aspect | Docker Volumes | Bind Mount | Network Mount | Ext. Lib UI |
|--------|---|---|---|---|
| **NixOS Native** | No | YES | YES | Partial |
| **Declarative** | YAML | YES | YES | No (UI) |
| **Setup Complexity** | Low | Low | Medium | Medium |
| **Flexibility** | Medium | Low | Medium | HIGH |
| **Add/Remove** | Rebuild | Rebuild | Modify config | UI click |
| **Official Docs** | YES | YES (troubleshooting) | Limited | YES |
| **Automatic Watching** | YES (exp.) | N/A | NO | YES (exp.) |
| **Read-Only Support** | YES (:ro) | YES (ro) | YES | YES |
| **Multiple Locations** | Unlimited | One per mount | Unlimited | Per-library paths |
| **Web UI Visibility** | Hidden | Hidden | Hidden | Explicit |
| **Performance** | Fast | Fast | Depends on network | Fast (local) |
| **Best For** | Docker | NixOS | NAS/Remote | Flexible setups |

---

## Current Implementation: nixos-dotfiles

### Analysis
The current configuration uses **Method 2 (Bind Mount)**:

```nix
fileSystems."/mnt/old-laptop" = {
  device = "/dev/disk/by-uuid/7290c982-8ba3-422f-9eda-4831b7255260";
  fsType = "ext4";
  options = [ "nofail" "defaults" ];
};

fileSystems."/var/lib/immich" = {
  device = "/mnt/old-laptop/var/lib/immich";
  fsType = "none";
  options = [ "bind" "nofail" ];
  depends = [ "/mnt/old-laptop" ];
};
```

### Strengths
- Correct NixOS abstraction
- Proper dependency ordering
- Clean and reproducible
- Matches Immich troubleshooting steps
- Service sees files directly (no path translation)

### Considerations
- Not web-UI visible as "external library"
- Rebuilds needed to modify
- Mixed with managed `/var/lib/immich` data

### Upgrade Path (Optional)

#### Option A: Add Read-Only Flag (Archive Protection)
```nix
fileSystems."/var/lib/immich" = {
  device = "/mnt/old-laptop/var/lib/immich";
  fsType = "none";
  options = [ "bind" "nofail" "ro" ];  # Add read-only
  depends = [ "/mnt/old-laptop" ];
};
```

#### Option B: Separate External Library Mount (UI Clarity)
```nix
fileSystems."/mnt/immich-archive" = {
  device = "/mnt/old-laptop/var/lib/immich";
  fsType = "none";
  options = [ "bind" "nofail" "ro" ];
  depends = [ "/mnt/old-laptop" ];
};

# Then in Immich UI:
# - Create External Library
# - Import path: /mnt/immich-archive
```

---

## Recommendations

### For Current optiplex-server (NixOS)

**Verdict**: KEEP CURRENT APPROACH

Your bind-mount configuration is:
- Correct for NixOS
- Matches upstream documentation
- Well-structured with proper dependencies
- No urgent changes needed

**Optional Enhancement**: Consider Option B (separate mount) if you plan to add more external libraries in future.

### For Multi-Library Future

If expanding to multiple external sources:
1. Keep current approach for migrated old laptop data
2. Add additional mounts as needed
3. Use Immich UI to create libraries for each mount
4. Benefits: Explicit in UI, easier to manage long-term

### For Docker Deployments

Always use docker-compose volume mounts with `:ro` suffix.

### For NAS/Remote Storage

Use network mounts only if necessary; prefer local storage for performance.

---

## Key Takeaways

1. **Immich External Libraries is native and official** - not a workaround
2. **Bind mounting is correct for NixOS** - aligns with system philosophy
3. **Current implementation is sound** - no breaking changes needed
4. **Multiple methods have valid use cases** - choose based on deployment model
5. **Read-only mounts protect archives** - use `:ro` or `ro` for external sources
6. **Web UI approach is most flexible** - consider for future expansion
7. **All methods are officially supported** - pick what fits your workflow

---

## References

- Immich External Libraries: https://immich.app/docs/features/libraries
- Immich Docker Setup: https://immich.app/docs/install/docker-compose
- Immich Troubleshooting: https://immich.app/docs/features/libraries#troubleshooting
- NixOS File Systems: https://nixos.org/manual/nixos/stable/#sec-configuration-file
