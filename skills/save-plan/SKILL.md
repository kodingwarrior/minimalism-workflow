---
name: save-plan
description: Save a plan or spec as markdown, associated with the current project directory. This skill should be used when the user wants to save a plan, persist a spec, store a design document, or says "save-plan".
---

# Save Plan

Save a plan or spec as markdown to `~/.planvault/`, associated with the current working directory.

**Arguments**: `$ARGUMENTS` (optional mnemonic name for the plan)

## Storage Layout

```
~/.planvault/
├── index.json              # Mapping table: mnemonic → project pwd + metadata
└── plans/
    └── <mnemonic>/
        └── plan.md         # The plan content in markdown
```

### index.json Schema

```json
{
  "<mnemonic>": {
    "pwd": "/absolute/path/to/project",
    "description": "One-line summary of the plan",
    "created_at": "YYYY-MM-DD",
    "updated_at": "YYYY-MM-DD"
  }
}
```

## Instructions

1. **Determine project root**:
   - Run `git rev-parse --show-toplevel 2>/dev/null || pwd` to get the project root path
   - This becomes the `pwd` value stored in index.json

2. **Ensure storage directory exists**:
   - Run `mkdir -p ~/.planvault/plans`
   - If `~/.planvault/index.json` does not exist, initialize it with `{}`

3. **Determine the mnemonic name**:
   - If `$ARGUMENTS` is provided, use it as the mnemonic name
   - Otherwise, ask the user for a short mnemonic name (e.g., `api-redesign`, `auth-migration`, `v2-rollout`)
   - Mnemonic must be lowercase alphanumeric with hyphens only (validate with `^[a-z0-9][a-z0-9-]*$`)
   - If the mnemonic already exists in index.json, ask the user whether to overwrite or pick a different name

4. **Gather plan content**:
   - Ask the user for the plan content, or collect it from the current conversation context if a plan was just discussed
   - The content should be plain markdown

5. **Save the plan**:
   - Create the directory: `mkdir -p ~/.planvault/plans/<mnemonic>`
   - Write the plan content to `~/.planvault/plans/<mnemonic>/plan.md`

6. **Update index.json**:
   - Read the current `~/.planvault/index.json`
   - Add or update the entry for this mnemonic:
     ```json
     {
       "pwd": "<project-root>",
       "description": "<one-line summary of the plan>",
       "created_at": "<today's date>",
       "updated_at": "<today's date>"
     }
     ```
   - If updating an existing entry, preserve `created_at` and only update `updated_at`
   - Write the updated index.json back

7. **Confirm to user**:
   - Report the mnemonic name and storage path
   - Show how to load it later: `/load-plan <mnemonic>`

## Examples

- `/save-plan` — Prompt for mnemonic, then save the plan
- `/save-plan api-redesign` — Save the plan under the `api-redesign` mnemonic
- `/save-plan auth/token-rotation` — Not valid (no slashes); suggest `auth-token-rotation` instead

## Important

- Mnemonic names must be unique across all projects. If a collision occurs, inform the user which project already uses that mnemonic.
- Always validate mnemonic format before saving.
- Never overwrite an existing plan without explicit user confirmation.
- Generate the one-line description automatically from the plan content; do not ask the user for it separately.
