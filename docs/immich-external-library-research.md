# Immich External Library Configuration Research

## Executive Summary

Immich **has native support for external libraries** - a first-class feature called "External Libraries" that is fully documented and supported. The bind-mount approach in the current nixos-dotfiles configuration is a valid but indirect method; Immich's native external libraries feature is the **recommended, cleaner, and more flexible approach**.

---

## 1. Does Immich have a native "external library" or "managed library" feature?

### YES - External Libraries is a First-Class Feature

**Status**: Fully supported, documented feature  
**Documentation**: https://immich.app/docs/features/libraries  
**Last Updated**: Feb 23, 2026

Immich has **External Libraries** - a native, built-in feature for managing photo/video libraries stored outside of the standard upload directory.

### Key Characteristics:

- **Fully documented** in official Immich documentation
- **Web UI management**: Create/edit/delete libraries via Administration -> External Libraries
- **Per-user ownership**: Each library belongs to a single user (set at creation time)
- **Multiple import paths per library**: A single library can reference multiple storage locations
- **Recursive scanning**: All subdirectories within import paths are automatically scanned
- **Read-only option**: Libraries can be mounted as read-only (prevents web UI deletion)
- **Automatic scanning**: Optional automatic filesystem watching (experimental)
- **Scheduled rescans**: Nightly job + manual trigger + customizable cron schedule

---

## 2. Official Supported Methods for Storing Media on External/Separate Storage

### Method 1: Docker Volume Mounts (Recommended for Docker)

The official docs explicitly state that external libraries require volume mounts in `docker-compose.yml`:

```yaml
immich-server:
  volumes:
    - ${UPLOAD_LOCATION}:/data
    - /mnt/nas/christmas-trip:/mnt/media/christmas-trip:ro
    - /home/user/old-pics:/mnt/media/old-pics:ro
    - /mnt/media/videos:/mnt/media/videos:ro
```

**Key Points:**
- `:ro` suffix makes the mount read-only (prevents deletion via web UI)
- Without `:ro`, Immich can delete files from the web UI (use with caution)
- **Must also mount to worker containers** if using microservices architecture
- Paths in import settings must match the container-internal paths (e.g., `/mnt/media/christmas-trip`, not `/mnt/nas/christmas-trip`)

### Method 2: Filesystem-Level Mounts (NixOS)

For NixOS systems (like optiplex-server), **bind mounts or direct mounts at the filesystem level** are appropriate:

```nix
fileSystems."/var/lib/immich" = {
  device = "/mnt/old-laptop/var/lib/immich";
  fsType = "none";
  options = [ "bind" "nofail" ];
};
```

This is **exactly what your current configuration does**.

### Method 3: Network Mounts (for NAS/SMB/NFS)

Supported but with caveats:
- **Not recommended for database** (network share DBs can corrupt)
- **External libraries work fine** on network mounts
- **Automatic watching doesn't work** on network drives (must use periodic rescans)

---

## 3. Is Bind Mounting the Recommended Approach or is There a Better Way?

### For Docker (Immich-as-Docker):
**Bind mounting is NOT recommended** - use Docker volume mounts instead:
- Docker volumes are explicitly documented as the official method
- Volumes properly scope permissions within the container runtime
- Simpler to reason about (mount points are explicit in docker-compose.yml)

### For NixOS (Your Current Use Case):
**Bind mounting IS the appropriate approach** for several reasons:

1. **Filesystem-native**: NixOS's `fileSystems` is the correct abstraction for persistent storage
2. **Service-agnostic**: Works for any service (not Docker-specific)
3. **Supported by upstream**: Documented as a valid troubleshooting step in Immich docs
4. **Clean integration**: No need to simulate Docker volumes at the systemd level

**Current implementation is good:**
```nix
fileSystems."/mnt/old-laptop" = { ... };      # Mount source drive
fileSystems."/var/lib/immich" = {              # Bind mount to Immich location
  device = "/mnt/old-laptop/var/lib/immich";
  fsType = "none";
  options = [ "bind" "nofail" ];
  depends = [ "/mnt/old-laptop" ];             # Ensures parent mounts first
};
```

### The Cleaner Alternative: External Libraries Web UI

Instead of relying on system-level mounts, you could:

1. Mount external storage at a **separate location** (e.g., `/mnt/external-photos`)
2. Let Immich discover it via **External Libraries UI**
3. Set import paths to `/mnt/external-photos/` (or subdirectories)
4. Immich handles the rest (scanning, deduplication, metadata)

**Pros of this approach:**
- More flexible (add/remove libraries without remounting)
- Cleaner separation (Immich library ≠ `/var/lib/immich`)
- Better for multi-library setups
- Explicit in web UI (visible which folders are external)

**Cons:**
- Requires manual setup in Immich web UI
- Rescans needed after adding new files (vs. automatic watch)
- Experimental automatic watching feature is still new

---

## 4. How Does Immich Handle Multiple Storage Locations?

### Storage Locations are Handled Three Ways:

#### A. Multiple Import Paths in a Single External Library

A single library can have multiple import paths:

```
Library: "Photos from multiple sources"
  Import Path 1: /mnt/nas/trip-2024
  Import Path 2: /mnt/external-drive/archive
  Import Path 3: /home/user/recent-uploads
```

Immich will:
- Scan all three recursively
- Avoid duplicates (same file in multiple paths only added once)
- Apply exclusion patterns to all paths
- Apply rescans to all paths

#### B. Storage Template (For Uploaded Files)

When `Storage Template` is enabled in Admin Settings:
- Uploaded files are organized by customizable pattern
- Default: `Year/Year-Month-Day/Filename.Extension`
- Example: `2024/2024-06-15/photo.jpg`
- Can use variables like `{{album}}`, `{{device}}`, etc.

#### C. Multiple External Libraries

Each library can be owned by one user, but:
- Multiple libraries can coexist
- Different permissions per library
- Independent scanning schedules

---

## 5. What Permissions/Ownership are Needed for External Libraries?

### Immich Service User Requirements

**The immich service runs as user `immich`** (NixOS default).

### Required Permissions for External Libraries:

```bash
# Read-only library (recommended for external archives)
immich:immich 555  /mnt/external-photos          # r-x for group/other
immich:immich 444  /mnt/external-photos/photo.jpg

# Read-write library (for Immich to write metadata/sidecars)
immich:immich 755  /mnt/external-photos
immich:immich 644  /mnt/external-photos/photo.jpg
```

### Current Configuration in nixos-dotfiles:

```nix
users.users.immich.extraGroups = [ "users" ];
```

This allows the immich user to access files owned by the `users` group.

### Best Practices:

1. **For external archives**: Mount as read-only (`:ro` in Docker, or `ro` in mount options)
   - Prevents accidental deletion
   - Forces any changes to go through web UI (tracked in DB)

2. **For library folders**: Ensure immich user can read:
   ```bash
   # Option A: Chown to immich
   sudo chown -R immich:immich /mnt/external-photos
   sudo chmod -R 755 /mnt/external-photos
   
   # Option B: Add immich to appropriate group
   sudo usermod -a -G photos immich
   ```

3. **For network mounts**: Ensure mount options include proper user mapping
   ```nix
   options = [ "bind" "nofail" "uid=immich_uid" "gid=immich_gid" ];
   ```

### Immich's Caution Note:

From official docs:
> Make sure the permissions are set correctly. If Immich can't access the files, they won't be scanned.

And important limitations:
- **XMP sidecars** (metadata files) can only be written if the library is **not** read-only
- **Deleting files from web UI** requires write permissions

---

## Summary Table: Methods Comparison

| Aspect | Current Bind Mount | External Libraries UI | Docker Volumes |
|--------|-------------------|----------------------|-----------------|
| **Recommended for NixOS** | YES | GOOD OPTION | N/A |
| **Recommended for Docker** | NO | N/A | YES |
| **Setup complexity** | Low (Nix declarative) | Medium (Web UI) | Low (docker-compose) |
| **Multiple locations** | One mount point | Unlimited import paths | Unlimited mounts |
| **Flexibility** | Static at boot | Dynamic in UI | Requires rebuild |
| **Read-only support** | YES (mount option) | YES (per-library) | YES (`:ro`) |
| **Automatic watching** | N/A | YES (experimental) | YES (experimental) |
| **Permission management** | Standard Linux | Immich-aware | Docker context |

---

## Recommendations for nixos-dotfiles

### Current Approach: KEEP IT

Your current bind-mount configuration is:
- **Correct** for a NixOS system
- **Well-structured** with proper `depends` ordering
- **Matches Immich's documented troubleshooting** steps
- **Familiar** to NixOS users (declarative, reproducible)

**However, consider these enhancements:**

### Option 1: Add Read-Only Mount Option

If the old laptop SSD is truly archive-only:

```nix
fileSystems."/var/lib/immich" = {
  device = "/mnt/old-laptop/var/lib/immich";
  fsType = "none";
  options = [ "bind" "nofail" "ro" ];  # Add read-only
  depends = [ "/mnt/old-laptop" ];
};
```

### Option 2: Separate External Library Mount

Instead of binding `/var/lib/immich`, mount external photos separately and use Immich UI:

```nix
fileSystems."/mnt/immich-external" = {
  device = "/mnt/old-laptop/var/lib/immich";
  fsType = "none";
  options = [ "bind" "nofail" "ro" ];
  depends = [ "/mnt/old-laptop" ];
};

# In Immich web UI:
# - Create new External Library
# - Import path: /mnt/immich-external
# - Choose exclusion patterns as needed
```

**Benefit**: Cleaner separation, explicit in Immich UI, easier to manage if adding more external sources later.

### Option 3: Hybrid Approach

Keep current setup for migrated data, but use External Libraries UI for future additions.

---

## Key Takeaways

1. **Immich's External Libraries feature is native and official** - not a workaround
2. **Bind mounting is appropriate for NixOS** - aligns with system philosophy
3. **For Docker deployments**, use volume mounts in `docker-compose.yml` instead
4. **Multiple storage locations are fully supported** via:
   - Multiple import paths in one library
   - Multiple libraries
   - Storage template engine
5. **Read-only mounts are recommended** for archive/external sources
6. **Current nixos-dotfiles implementation is sound** - no urgent changes needed
7. **Future consideration**: Add separate external library mount for better UI visibility

---

## References

- External Libraries Docs: https://immich.app/docs/features/libraries
- Docker Compose Guide: https://immich.app/docs/install/docker-compose
- Environment Variables: https://immich.app/docs/install/environment-variables
- Storage Template: https://immich.app/docs/administration/storage-template
- Backup & Restore: https://immich.app/docs/administration/backup-and-restore

