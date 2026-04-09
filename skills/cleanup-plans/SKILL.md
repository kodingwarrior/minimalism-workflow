---
name: cleanup-plans
description: Clean up saved plans from the planvault. This skill should be used when the user wants to delete old plans, remove stale specs, prune the planvault, or says "cleanup-plans".
---

# Cleanup Plans

Remove saved plans from `~/.planvault/`, either selectively or in bulk.

**Arguments**: `$ARGUMENTS` (optional mnemonic name to delete a specific plan)

## Instructions

1. **Check planvault exists**:
   - If `~/.planvault/index.json` does not exist, inform the user that no plans exist and exit

2. **Read the index**:
   - Read `~/.planvault/index.json` to get the full mapping table

3. **Determine project root**:
   - Run `git rev-parse --show-toplevel 2>/dev/null || pwd` to get the current project root

4. **Resolve what to clean up**:

   **If `$ARGUMENTS` is a specific mnemonic**:
   - Look up the mnemonic in index.json
   - If not found, report the error and list available plans
   - If found, show the plan metadata and ask for confirmation before deleting

   **If `$ARGUMENTS` is `--all`**:
   - Filter index.json for all entries where `pwd` matches the current project root
   - List all matching plans and ask for confirmation before deleting all of them

   **If `$ARGUMENTS` is `--stale`**:
   - Find plans with index entries whose plan files are missing, or plan directories with no index entry
   - List the inconsistencies and ask for confirmation before cleaning them up

   **If `$ARGUMENTS` is empty**:
   - Filter index.json for all entries where `pwd` matches the current project root
   - List them in a table with metadata:
     ```
     Plans for /path/to/project:
       1. api-redesign    "REST API v2 redesign plan"          (updated: 2026-04-10)
       2. auth-migration  "Migrate to OAuth2 token rotation"   (updated: 2026-04-08)
     ```
   - Ask the user which plan(s) to delete (by number or mnemonic), or offer `all` to remove everything for this project

5. **Delete the plan**:
   - Remove the plan directory: `rm -rf ~/.planvault/plans/<mnemonic>`
   - Remove the entry from index.json
   - Write the updated index.json back

6. **Confirm to user**:
   - Report which plans were deleted
   - Show remaining plan count for the project

## Examples

- `/cleanup-plans` — List plans for current project, select which to delete
- `/cleanup-plans api-redesign` — Delete the `api-redesign` plan directly
- `/cleanup-plans --all` — Delete all plans for the current project
- `/cleanup-plans --stale` — Find and remove orphaned/inconsistent entries

## Important

- Never delete without explicit user confirmation.
- When deleting multiple plans, list all of them before confirming.
- If the index becomes empty after cleanup, keep the file as `{}` rather than deleting it.
