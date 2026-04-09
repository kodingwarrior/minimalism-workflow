---
name: save-plan
description: Save a plan or spec as markdown, associated with the current project directory. This skill should be used when the user wants to save a plan, persist a spec, store a design document, or says "save-plan".
---

# Save Plan

Save a plan or spec as markdown to `~/.planvault/`, associated with the current working directory.

**Arguments**: `$ARGUMENTS` (optional mnemonic name for the plan)

## Instructions

1. **Determine the mnemonic name**:
   - If `$ARGUMENTS` is provided, use it as the mnemonic name
   - Otherwise, ask the user for a short mnemonic name (e.g., `api-redesign`, `auth-migration`, `v2-rollout`)
   - Mnemonic must be lowercase alphanumeric with hyphens only (`^[a-z0-9][a-z0-9-]*$`)

2. **Gather plan content**:
   - Ask the user for the plan content, or collect it from the current conversation context if a plan was just discussed
   - Write the content to a temporary file

3. **Generate a one-line description** from the plan content automatically

4. **Run the save script**:
   ```bash
   bash <skill-dir>/scripts/save-plan.sh "<mnemonic>" "<description>" "<temp-plan-file>"
   ```
   - Exit code 1: invalid mnemonic format
   - Exit code 2: mnemonic collision with another project — inform the user and suggest a different name

5. **On success**: report the mnemonic name and how to load it later (`/load-plan <mnemonic>`)

## Important

- If the mnemonic already exists for the SAME project, ask the user whether to overwrite or pick a different name before running the script.
- Never overwrite without explicit user confirmation.
