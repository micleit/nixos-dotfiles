# Seafile on NixOS: Complete Research Summary

## Executive Summary

Seafile is an open-source cloud storage system with advanced privacy and collaboration features. Unlike Nextcloud (folder-based sharing), Seafile uses a **library-based model** where collections of files are independently synced and can be individually encrypted. NixOS currently lacks a native Seafile service module, but one could be created following the pattern of the existing Nextcloud module.

---

## 1. Available NixOS Modules/Packages

### Current Status
- **NO native NixOS service module** for Seafile server
- **Client packages available** (but limited use for server setup):
  - `seafile-client`: Desktop sync client (v9.0.15)
  - `seadrive-gui`: Virtual drive GUI (v3.0.19)
  - `seafile-shared`: Core libraries and daemon components

### What Exists Upstream
- Seafile repositories: `haiwen/seafile` (sync daemon), `haiwen/seafile-server` (server core), `haiwen/seahub` (web UI)
- Documentation: https://manual.seafile.com and https://forum.seafile.com
- Community: Active development, latest v9.0+ releases available

### For optiplex-server
- Would need to create custom `modules/systems/server/seafile.nix` module
- Similar structure to existing Nextcloud module but simpler (C-based daemon vs PHP)

---

## 2. External Storage & Data Directories

### Directory Structure
```
/var/lib/seafile/                  # Main data directory
├── conf/                          # Configuration files
│   ├── seafile.conf               # Main server config
│   ├── seahub_settings.py         # Seahub (web UI) settings
│   └── ccnet.conf                 # (Legacy) Network config
├── logs/                          # Service logs
├── pids/                          # Process ID files
├── seahub-data/                   # Web UI data/cache
│   └── media/                     # User avatars, temp uploads
└── storage/                       # File content storage
    ├── blocks/                    # Raw file blocks (compressed/encrypted)
    └── fs/                        # Filesystem metadata (library structure)
```

### Key Characteristics
- **Library Storage**: Each library stored with UUID-based naming
  - Libraries are independent collections with separate sync control
  - Can be individually encrypted with user-chosen passwords
  - Stored in `storage/blocks/` (content) and `storage/fs/` (metadata)
- **External Storage Support**: Can mount to dedicated partition or network storage
- **Data Integrity**: Content-addressable storage (SHA1 hashing for deduplication)

### For optiplex-server
- **Recommendation**: Bind-mount to `/mnt/seafile-data` (similar to Immich setup)
- **Expected Size**: Varies by library size; can be terabytes
- **Permissions**: Must be owned by `seafile:seafile` user (750)

---

## 3. Database Requirements

### Supported Databases
1. **PostgreSQL** (RECOMMENDED)
   - Production standard for Seafile
   - Supports full-text search with extensions
   - Already running on optiplex-server for Nextcloud

2. **MySQL** (Supported)
   - Also production-ready
   - Slightly less common for Seafile deployments

3. **SQLite** (Not recommended for production)
   - Only suitable for testing/small deployments
   - Limited concurrent user support

### Database Schema

**Main Database Structure:**
- `ccnet_db`: User accounts, groups, permissions (DEPRECATED in v7+, merged to main)
- `seafile-db`: 
  - Libraries, repositories, file metadata
  - User information, sharing permissions
  - Organization/group data
- `notification-db`: Optional, for activity notifications
- `seahub-db`: Web UI specific data (sessions, comments, etc.)

**Key Tables (examples):**
- `repo` (Repository/Library metadata)
- `repo_file` (File entries in libraries)
- `share` (File sharing relationships)
- `user` (User accounts)
- `group` (Groups)

### Initialization
- Seafile auto-generates schema on first start if database is empty
- Database migrations run automatically between versions
- No manual schema setup required

### For optiplex-server
```nix
services.postgresql = {
  enable = true;
  ensureDatabases = [ "seafile-db" ];
  ensureUsers = [{
    name = "seafile";
    ensureDBOwnership = true;
  }];
};
```

---

## 4. Configuration File Locations & Structure

### Primary Configuration Files

#### `conf/seafile.conf`
Main server configuration in INI format:
```ini
[database]
type=pgsql
host=localhost
port=5432
user=seafile
password=<password>
db_name=seafile-db

[seaf-server]
port=12001                         # RPC port for client/web communication
bind_addr=127.0.0.1                # Should be localhost for Cloudflare Tunnel
# loglevel=info
# workers=4                        # Number of worker threads

[fileserver]
port=8082                          # File upload/download port
upload_tmp_dir=/tmp
max_upload_size=2147483648         # 2GB default
max_download_dir_size=2147483648

[seahub]
port=8000                          # Seahub web UI port
workers=4
daemon=true
pidfile=/var/run/seahub.pid

[history]
keep_days=7                        # Library version history retention

[gc]
# Garbage collection for storage optimization
enable=true
scan_days=7

[notification]
enabled=true
```

#### `conf/seahub_settings.py`
Django-based web UI configuration:
```python
# seahub_settings.py
SECRET_KEY = 'xxx-random-key-xxx'
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'seahub-db',
        'USER': 'seafile',
        'PASSWORD': '<password>',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}

ALLOWED_HOSTS = ['localhost', '127.0.0.1']
TIME_ZONE = 'UTC'

# Seahub features
ENABLE_LIBRARY_ENCRYPTION = True
MAX_FILE_SIZE = 2147483648  # 2GB
UPLOAD_TMP_DIR = '/tmp'
FILE_PREVIEW_MAX_SIZE = 30 * 1024 * 1024  # 30MB

# Two-factor auth
ENABLE_TWO_FACTOR_AUTH = False

# Office document editing
ENABLE_ONLYOFFICE = False
```

#### `conf/ccnet.conf` (Legacy)
Network and identity configuration (mostly deprecated in v7+):
```ini
[General]
SERVICE_URL=http://localhost:8000

[Network]
Port=13419
```

### Configuration Generation
- Seafile provides `seaf-server-init` script to generate initial config
- Config files are **NOT** auto-regenerated on each start
- Manual edits required for updates (e.g., add new SMTP settings)
- **NixOS Consideration**: Could use template mechanism + systemd oneshot to generate from module options

---

## 5. Data Migration: Nextcloud → Seafile

### Fundamental Differences

| Aspect | Nextcloud | Seafile |
|--------|-----------|---------|
| **Model** | Folder-based hierarchical | Library-based collection |
| **Sharing** | Share folders with users/groups | Create libraries, share independently |
| **Encryption** | End-to-end optional | Per-library, client-side |
| **Sync** | Selective folder sync | Selective library sync |
| **Metadata** | File permissions, full sync history | Library encryption, version control |

### Migration Strategies

#### Strategy 1: Manual Export/Import (Simplest)
1. Export files from Nextcloud via web UI or sync client
2. Create Seafile libraries for each user/department
3. Upload files via Seafile web UI or sync client
4. Recreate sharing permissions manually
5. **Time**: Hours to days depending on volume
6. **Data Loss Risk**: Low (no automation issues)
7. **Best For**: <100GB, simple structures

#### Strategy 2: Programmatic Migration (Most Complete)
1. Write Python script using Seafile API:
   ```python
   import seafile_admin  # Seafile Python SDK
   
   # Create library for each Nextcloud folder
   library = seafile_admin.create_library('My Folder', password=None)
   
   # Bulk-copy files via filesystem
   # Recreate sharing relationships via API
   ```
2. Use Nextcloud OCS API to export user/group structure
3. Map permissions to Seafile library sharing model
4. Run incremental syncs to catch changes
5. **Time**: Days to weeks (script development + testing)
6. **Data Loss Risk**: Medium (need thorough testing)
7. **Best For**: >1TB, complex hierarchies

#### Strategy 3: Live Parallel Period (Safest for Users)
1. Set up Seafile alongside Nextcloud
2. Enable single sign-on (LDAP/AD) on both if possible
3. User-by-user migration:
   - Create Seafile library for user
   - Copy Nextcloud data to Seafile library
   - User switches to Seafile client
   - Remove from Nextcloud once complete
4. Run both for weeks/months
5. **Time**: Weeks to months (depends on user adoption)
6. **Data Loss Risk**: Very Low (no rush)
7. **Best For**: Many users, critical data

### Data Considerations

**Metadata Transfer:**
- File timestamps: Can be preserved with filesystem copy
- File permissions: Seafile doesn't support granular file-level permissions (library-level only)
- Tags/Categories: No direct equivalent in Seafile (use library names/descriptions)
- Comments: Can be recreated manually or via API
- Version history: NOT automatically transferred (archive old Nextcloud if needed)

**User & Group Structure:**
- **Users**: Need to be recreated in Seafile (LDAP/AD integration helps)
- **Groups**: Can be recreated via Seafile admin interface or API
- **Permissions**: Must map sharing relationships manually (library owner + shared with groups)

**Special Cases:**
- Shared links: Must be recreated (Seafile has different share link model)
- Calendars/Contacts: Not part of file data; use separate migration (Nextcloud Apps separate)
- Full-text search indices: Rebuild from scratch in Seafile

### Recommended Approach for optiplex-server
**Hybrid approach:**
1. Run Seafile in parallel with Nextcloud for transition period
2. Identify "high-value" libraries (frequently accessed)
3. Migrate these first using programmatic method
4. Less critical data: Manual export/import
5. Timeline: 4-8 weeks
6. Validate each migration step before decommissioning Nextcloud

---

## 6. Backup & Restore Procedures

### Backup Strategy

**Critical Components:**
1. **PostgreSQL Database** (contains all metadata)
2. **seafile-data/storage/** directory (actual file content)
3. **Configuration files** (seafile.conf, seahub_settings.py)

### Backup Procedures

#### Full Backup (Recommended weekly)
```bash
# 1. Database backup
sudo -u postgres pg_dump seafile-db > /backup/seafile-db-$(date +%Y%m%d).sql

# 2. Data directory backup
sudo tar -czf /backup/seafile-data-$(date +%Y%m%d).tar.gz \
    /var/lib/seafile/storage/ \
    /var/lib/seafile/conf/ \
    /var/lib/seafile/seahub-data/

# 3. Optional: Verify backup integrity
sudo -u seafile seaf-fsck --storage=/var/lib/seafile/storage
```

#### Incremental Backup (Daily)
- Use `rsync` for incremental data directory backup
- Use PostgreSQL WAL (Write-Ahead Logging) for database incremental backups
- Only changed files/blocks transferred

#### Retention Policy
- **Daily**: Keep 7 days
- **Weekly**: Keep 4 weeks
- **Monthly**: Keep 12 months
- **Test restore monthly** to verify backup integrity

### Restore Procedures

#### Full Restore (Disaster Recovery)
```bash
# 1. Stop Seafile services
sudo systemctl stop seafile-server seahub

# 2. Restore database
sudo -u postgres psql seafile-db < /backup/seafile-db-20260606.sql

# 3. Restore data directory
sudo rm -rf /var/lib/seafile/storage /var/lib/seafile/conf /var/lib/seafile/seahub-data
sudo tar -xzf /backup/seafile-data-20260606.tar.gz -C /

# 4. Fix permissions
sudo chown -R seafile:seafile /var/lib/seafile

# 5. Verify data integrity
sudo -u seafile seaf-fsck --storage=/var/lib/seafile/storage

# 6. Start services
sudo systemctl start seafile-server seahub

# 7. Verify health
sudo -u seafile seaf-server-monitor list
```

#### Partial Restore (Single Library)
```bash
# If single library corrupted:
# 1. Check current state
seaf-server info <repo_id>

# 2. Can use PostgreSQL backup to recover library metadata
# 3. If storage corrupted but DB OK: users see "unavailable" 
#    Library marked for recovery
```

### NixOS Specific Implementation

Would integrate with systemd timer:
```nix
systemd.timers."seafile-backup" = {
  description = "Daily Seafile backup";
  timerConfig = {
    OnCalendar = "daily";
    OnCalendar = "*-*-* 02:00:00";  # 2 AM daily
    Persistent = true;
  };
  wantedBy = [ "timers.target" ];
};

systemd.services."seafile-backup" = {
  description = "Backup Seafile database and data";
  serviceConfig = {
    Type = "oneshot";
    ExecStart = ''
      ${pkgs.bash}/bin/bash -c '''
        ${pkgs.postgresql}/bin/pg_dump -h localhost -U seafile seafile-db \
          > /backup/seafile-db-$(date +\%Y\%m\%d).sql
        ${pkgs.gnutar}/bin/tar -czf /backup/seafile-data-$(date +\%Y\%m\%d).tar.gz \
          /var/lib/seafile/storage /var/lib/seafile/conf /var/lib/seafile/seahub-data
      '''
    '';
  };
};
```

---

## Implementation Roadmap for optiplex-server

### Phase 1: Research & Testing (1-2 weeks)
- [ ] Build/run Seafile manually on NixOS (understand full setup)
- [ ] Test database migrations and recovery procedures
- [ ] Evaluate seafile-server package availability (may need custom derivation)
- [ ] Plan Nextcloud data export

### Phase 2: Module Development (2-3 weeks)
- [ ] Create `modules/systems/server/seafile.nix` module
- [ ] Implement PostgreSQL integration
- [ ] Create systemd service definitions
- [ ] Test on test deployment

### Phase 3: Deployment (1-2 weeks)
- [ ] Migrate Nextcloud data to Seafile (programmatic + manual)
- [ ] Configure Cloudflare Tunnel routes
- [ ] Set up backups and test restore
- [ ] Parallel run period for user testing

### Phase 4: Decommission (1 week)
- [ ] Verify all user data migrated
- [ ] Disable Nextcloud services
- [ ] Archive Nextcloud database for reference
- [ ] Document final configuration

---

## Key Considerations for NixOS Module

### Must-Have Features
1. PostgreSQL database setup and initialization
2. Service definitions (seaf-server, seahub, fileserver)
3. Configuration file generation
4. Data directory mount points
5. Cloudflare Tunnel integration
6. User/group management
7. Firewall configuration

### Nice-to-Have Features
1. Automated backup scheduling
2. Library encryption support
3. LDAP/AD integration options
4. Full-text search setup
5. Monitoring/health check endpoints

### Challenges
1. **seafile-server binary** may not exist in nixpkgs (likely need custom derivation)
2. **Configuration format**: Requires INI + Python file (not purely declarative)
3. **Init script**: Might need to wrap `seaf-server-init` for initial setup
4. **Multi-service coordination**: Unlike Nextcloud (single PHP app), needs 3+ services

---

## Comparison with Existing optiplex-server Modules

### Similar to Nextcloud module
- PostgreSQL database integration
- Data directory binding/mounting
- Web UI port configuration
- Admin password file handling

### Different from Nextcloud
- Simpler (C-based daemon vs PHP app)
- More granular port configuration (3 services)
- Library-based vs folder-based data model
- No built-in filesystem browser (Seafile UI is web-only)
- Better suited for sync-first workflow

### Advantages over Nextcloud for optiplex-server
- Lighter weight (C daemon vs PHP)
- Better sync performance (less server CPU)
- More flexible encryption (per-library)
- Simpler deployment (fewer components)

---

## Conclusion

Seafile is a viable Nextcloud replacement for optiplex-server with potentially simpler setup and lighter resource usage. The main challenges are:

1. **No existing NixOS module** (requires new development)
2. **Data migration** from Nextcloud (one-time effort, weeks of planning)
3. **Package availability** (may need custom derivation)

**Recommendation**: Proceed with Phase 1 research first, then decide on full migration based on findings.

