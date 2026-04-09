---
name: load-plan
description: Load a previously saved plan or spec for the current project directory. This skill should be used when the user wants to load a plan, recall a spec, review a saved design document, or says "load-plan".
---

# Load Plan

Load a previously saved plan from `~/.planvault/` for the current project or by mnemonic name.

**Arguments**: `$ARGUMENTS` (optional mnemonic name of the plan to load)

## Storage Layout

```
~/.planvault/
├── index.json              # Mapping table: mnemonic → project pwd + metadata
└── plans/
    └── <mnemonic>/
        └── plan.md         # The plan content in markdown
```

## Instructions

1. **Check planvault exists**:
   - If `~/.planvault/index.json` does not exist, inform the user that no plans have been saved yet and suggest using `/save-plan`

2. **Read the index**:
   - Read `~/.planvault/index.json` to get the full mapping table

3. **Determine project root**:
   - Run `git rev-parse --show-toplevel 2>/dev/null || pwd` to get the current project root

4. **Resolve which plan to load**:

   **If `$ARGUMENTS` is provided** (mnemonic name given):
   - Look up the mnemonic in index.json
   - If not found, report the error and list available plans for the current project (if any)

   **If `$ARGUMENTS` is empty** (no mnemonic given):
   - Filter index.json for all entries where `pwd` matches the current project root
   - If exactly one plan exists, load it automatically
   - If multiple plans exist, list them in a table format and ask the user which one to load:
     ```
     Plans for /path/to/project:
       - api-redesign    "REST API v2 redesign plan"          (updated: 2026-04-10)
       - auth-migration  "Migrate to OAuth2 token rotation"   (updated: 2026-04-08)
     ```
   - If no plans exist for this project, list all available plans across all projects as a fallback reference

5. **Load and present the plan**:
   - Read `~/.planvault/plans/<mnemonic>/plan.md`
   - Present the full plan content to the user
   - Show metadata: mnemonic, associated project path, created/updated dates

## Examples

- `/load-plan` — List and load plans for the current project
- `/load-plan api-redesign` — Load the `api-redesign` plan directly

## Important

- If the plan file is missing but the index entry exists, report the inconsistency and suggest the user re-save.
- Always show the mnemonic name and project path when presenting a plan, so the user can confirm it is the right one.
- When listing plans, sort by `updated_at` descending (most recently updated first).
