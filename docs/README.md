# Documentation - nixos-dotfiles

This directory contains research and documentation for the nixos-dotfiles repository.

## Immich External Library Research

Complete research on Immich's external library configuration, storage methods, and recommendations for nixos-dotfiles.

### Documents

1. **IMMICH-EXTERNAL-LIBRARY-QUICK-FINDINGS.txt** (Quick Reference)
   - Length: ~2 pages
   - Contains: Direct answers to all 5 research questions
   - Best for: Quick lookup and decision-making
   - Read time: 5 minutes

2. **immich-external-library-research.md** (Comprehensive Report)
   - Length: ~7 pages
   - Contains: Executive summary, detailed findings, best practices, recommendations
   - Best for: Understanding the full picture
   - Read time: 15-20 minutes

3. **immich-storage-methods-detailed-comparison.md** (Technical Deep Dive)
   - Length: ~8 pages
   - Contains: Four storage methods, comparison matrix, upgrade paths, technical details
   - Best for: Implementation decisions, troubleshooting
   - Read time: 20-25 minutes

### Quick Summary

**Current Status**: The bind-mount approach in `modules/systems/server/immich.nix` is sound and correct for NixOS.

**Key Finding**: Immich has native "External Libraries" feature that is fully documented and supported.

**Recommendation**: Keep current approach. Optional: Add read-only flag or separate UI-visible mount for future flexibility.

---

## How to Use These Documents

### For Quick Decisions
1. Read: IMMICH-EXTERNAL-LIBRARY-QUICK-FINDINGS.txt
2. Check: Current implementation assessment
3. Done: No changes needed or apply optional enhancements

### For Understanding the Architecture
1. Start: immich-external-library-research.md (Executive Summary section)
2. Then: skim relevant sections based on questions
3. Reference: Comparison table for method selection

### For Implementation Changes
1. Read: immich-storage-methods-detailed-comparison.md
2. Find: Your use case in the comparison matrix
3. Follow: Recommended approach for your situation
4. Check: Upgrade paths section for implementation details

---

## Context: What This Research Answers

### Question 1: Native External Library Feature?
**Answer**: YES - Immich has "External Libraries" as a first-class feature

### Question 2: Official Supported Methods?
**Answer**: Three methods:
- Docker Volume Mounts
- Filesystem-Level Mounts (NixOS)
- Network Mounts (NAS/SMB/NFS)

### Question 3: Is Bind Mounting Recommended?
**Answer**: YES for NixOS; NO for Docker (use volumes instead)

### Question 4: Multiple Storage Locations?
**Answer**: Supported via:
- Multiple import paths per library
- Storage template engine
- Multiple libraries

### Question 5: Required Permissions?
**Answer**: Standard Linux permissions; immich user needs read access (optionally write for metadata)

---

## Current Implementation

File: `/Users/mic/nixos-dotfiles/modules/systems/server/immich.nix`

Status: **SOUND AND CORRECT**

```nix
# Mount source drive
fileSystems."/mnt/old-laptop" = { ... }

# Bind mount to Immich location
fileSystems."/var/lib/immich" = {
  device = "/mnt/old-laptop/var/lib/immich";
  fsType = "none";
  options = [ "bind" "nofail" ];
  depends = [ "/mnt/old-laptop" ];
};
```

Strengths:
- Correct NixOS abstraction
- Proper dependency ordering
- Matches Immich documentation
- Well-structured and maintainable

---

## Optional Enhancements

### Enhancement 1: Add Read-Only Protection
If the old laptop SSD is archive-only:

```nix
options = [ "bind" "nofail" "ro" ];  # Add "ro"
```

Benefits: Prevents accidental deletion through web UI

### Enhancement 2: Separate External Library Mount
For better UI visibility and future flexibility:

```nix
fileSystems."/mnt/immich-archive" = {
  device = "/mnt/old-laptop/var/lib/immich";
  fsType = "none";
  options = [ "bind" "nofail" "ro" ];
  depends = [ "/mnt/old-laptop" ];
};

# Then create External Library in Immich UI
# pointing to /mnt/immich-archive
```

Benefits: Explicit in UI, easier to manage multiple libraries

---

## References

- Immich External Libraries: https://immich.app/docs/features/libraries
- Immich Docker Setup: https://immich.app/docs/install/docker-compose
- Immich Storage Template: https://immich.app/docs/administration/storage-template
- Immich Backup & Restore: https://immich.app/docs/administration/backup-and-restore
- NixOS File Systems: https://nixos.org/manual/nixos/stable/#sec-configuration-file

---

## Document History

Created: 2026-06-06  
Research: Comprehensive analysis of Immich external library configuration  
Scope: 5 specific research questions about storage, permissions, and best practices  
Status: Complete

---

For more information, see the individual documents in this directory.
