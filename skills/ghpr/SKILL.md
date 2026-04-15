---
name: ghpr
description: Create a GitHub pull request with auto-generated title and body from commits. Use when the user wants to create a PR, open a pull request, or says "ghpr".
---

# Create Pull Request

Create a pull request with auto-generated title and body from commits.

**Arguments**: `$ARGUMENTS` (optional base branch, defaults to `main`)

## Instructions

1. Parse the base branch:
   - If `$ARGUMENTS` is provided, use it as the base branch
   - Otherwise, default to `main`

2. Gather information about the current branch:
   - Run `git branch --show-current` to get the current branch name
   - Run `git log <base>..HEAD --oneline` to see commits not in base
   - Run `git diff <base>...HEAD --stat` to see changed files summary

3. Analyze the commits to generate:
   - **Title**: A clear, descriptive summary of what the PR does
   - **Body**: A 2-3 sentence summary explaining the key changes and why they were made

4. Check if branch needs to be pushed:
   - Run `git status` to check if ahead of remote
   - Push with `git push -u origin <branch>` if needed

5. Create the PR using:
```bash
gh pr create --base <base-branch> --title "the pr title" --body "$(cat <<'EOF'
## Summary
<2-3 sentence summary explaining what changed and why>

---
Assisted-By: <agenting tool name>(<model name>)
EOF
)"
```

The `Assisted-By` footer credits the AI agent that assisted in creating the PR. Use the actual tool name and model you are running as (e.g., `Assisted-By: Claude Code(claude-opus-4-6)`).

6. Return the PR URL to the user.

## Examples
- `/ghpr` - Create PR against main
- `/ghpr develop` - Create PR against develop branch

## Important
- Compare against the specified base branch (default: main)
- If there are no commits ahead of base, inform the user
- Don't push to the base branch directly - warn if on base branch
