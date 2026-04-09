---
name: load-plan
description: Load a previously saved plan or spec for the current project directory. This skill should be used when the user wants to load a plan, recall a spec, review a saved design document, or says "load-plan".
---

# Load Plan

Load a previously saved plan from `~/.planvault/` for the current project or by mnemonic name.

**Arguments**: `$ARGUMENTS` (optional mnemonic name of the plan to load)

## Instructions

1. **Run the load script**:
   ```bash
   bash <skill-dir>/scripts/load-plan.sh "<mnemonic-or-empty>"
   ```

2. **Parse the output**:

   - `NO_PLANS` — No plans saved yet. Suggest `/save-plan`.
   - `SINGLE\t<mnemonic>` — One plan found for this project. Re-run with that mnemonic to load it.
   - `MULTIPLE` followed by `<mnemonic>\t<pwd>\t<description>\t<updated_at>` lines — Multiple plans found. Present as a list and ask the user which to load.
   - `NO_MATCH` followed by plan lines — No plans for this project. Show all plans as fallback.
   - `NOT_FOUND` — Mnemonic doesn't exist. List available plans.
   - `FOUND\t<pwd>\t<description>\t<created_at>\t<updated_at>` followed by `---CONTENT---` and plan markdown — Present the plan content with metadata.
   - `MISSING_FILE` — Index entry exists but plan file is missing. Suggest re-saving.

3. **Present the plan**: Show the full markdown content and metadata (mnemonic, project path, dates).
