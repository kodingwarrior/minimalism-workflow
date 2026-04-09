---
name: cleanup-plans
description: Clean up saved plans from the planvault. This skill should be used when the user wants to delete old plans, remove stale specs, prune the planvault, or says "cleanup-plans".
---

# Cleanup Plans

Remove saved plans from `~/.planvault/`, either selectively or in bulk.

**Arguments**: `$ARGUMENTS` (optional: mnemonic name, `--all`, or `--stale`)

## Instructions

1. **Determine action from arguments**:

   **If `$ARGUMENTS` is a specific mnemonic**:
   - First list to confirm it exists, then ask for confirmation before deleting

   **If `$ARGUMENTS` is `--all`**:
   - List plans for current project, ask for confirmation, then delete all

   **If `$ARGUMENTS` is `--stale`**:
   - Run stale check and ask for confirmation before cleaning

   **If `$ARGUMENTS` is empty**:
   - List plans for current project and ask which to delete

2. **Available script commands**:

   ```bash
   # List plans for current project (for interactive selection)
   bash <skill-dir>/scripts/cleanup-plans.sh list

   # Delete a specific plan
   bash <skill-dir>/scripts/cleanup-plans.sh delete <mnemonic>

   # Find orphaned entries
   bash <skill-dir>/scripts/cleanup-plans.sh stale

   # Delete all plans for current project
   bash <skill-dir>/scripts/cleanup-plans.sh project-all <pwd-root>
   ```

3. **Parse the output**:

   - `NO_PLANS` — Nothing to clean up.
   - `NO_MATCH` — No plans for current project.
   - `PLAN\t<num>\t<mnemonic>\t<description>\t<updated_at>` — Plan entry for selection.
   - `DELETED\t<mnemonic>` — Confirms deletion.
   - `NOT_FOUND` — Mnemonic doesn't exist.
   - `REMAINING\t<count>` — Plans remaining after deletion.
   - `ORPHAN_INDEX\t<mnemonic>\t<pwd>` — Index entry with missing file.
   - `ORPHAN_DIR\t<name>` — Directory with no index entry.
   - `CLEAN` — No stale entries found.

## Important

- **Never delete without explicit user confirmation.**
- Always show what will be deleted before running the delete command.
