---
name: list-plans
description: List all saved plans from the planvault, optionally filtered by the current project. This skill should be used when the user wants to see available plans, browse saved specs, or says "list-plans".
---

# List Plans

List saved plans from `~/.planvault/`, optionally filtered by the current project directory.

**Arguments**: `$ARGUMENTS` (optional: `--all` to show plans across all projects)

## Instructions

1. **Run the list script**:
   ```bash
   bash <skill-dir>/scripts/list-plans.sh $ARGUMENTS
   ```

2. **Parse the output**:

   - `NO_PLANS` — No plans saved yet. Suggest `/save-plan`.
   - `NO_MATCH` — No plans for current project, followed by all plans as fallback.
   - `PROJECT\t<path>` — Group header for a project path.
   - `PLAN\t<mnemonic>\t<description>\t<updated_at>` — A plan entry.
   - `TOTAL\t<count>` — Total plan count.

3. **Display**: Format as a readable table grouped by project, sorted by updated date descending.
