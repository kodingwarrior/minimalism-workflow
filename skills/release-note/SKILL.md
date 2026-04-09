---
name: release-note
description: Generate a release changelog from git commits between the previous tag and HEAD. This skill should be used when the user wants to write release notes, generate a changelog, or summarize what changed since the last release.
---

# Release Note Generator

Generate a structured changelog from git history between the last tag and the current HEAD.

**Arguments**: `<from-ref>` (optional — defaults to the most recent `v*` tag)

## Style

Each change is a **standalone bullet** with a full descriptive sentence explaining what was added/changed/fixed and why it matters. Key characteristics:

- Reference issues and PRs inline with markdown links: `[\#123](https://github.com/{owner}/{repo}/issues/123)`
- Group bullets under **business-impact headings** (not conventional-commit categories).
- Feature bullets describe the capability from the user's perspective, not the code change.
- Bug fix bullets explain what was broken and how it's fixed.
- No nested sub-items — each bullet is self-contained.

## Instructions

### Phase 1: Determine Range

1. Find the previous tag:
   ```bash
   git tag --list 'v*' --sort=-version:refname | head -1
   ```
2. If `<from-ref>` is provided, use it instead.
3. Read the current version from `package.json` to use as the release title.
4. Detect the GitHub repo via `gh repo view --json nameWithOwner -q .nameWithOwner` for constructing issue/PR links.
5. If no tags exist, use the root commit as the start.

### Phase 2: Collect Commits

Run:
```bash
git log <from-ref>..HEAD --oneline --no-merges
```

Also collect merge commits separately for PR references:
```bash
git log <from-ref>..HEAD --oneline --merges
```

### Phase 3: Categorize

Split commits into two buckets: **Features/Improvements** and **Bug Fixes**.

| Bucket | Signals |
|--------|---------|
| Features / Improvements | `feat`, `add`, `new`, `feature`, `implement`, `improve`, `enhance`, `update`, `refactor`, `optimize`, `perf`, `support`, `redesign` |
| Bug Fixes | `fix`, `bug`, `patch`, `resolve`, `correct` |

- Skip pure version-bump commits (e.g. "Bump version to X.Y.Z", "Bump up version to X.Y.Z").
- Skip merge commits from the main list (use them only to extract PR numbers).
- If a merge commit references a PR (e.g. `Merge pull request #123`), attach the PR number to the corresponding commits.
- Infrastructure/docs/CI commits can be omitted unless they are user-facing.

### Phase 4: Group by Business Impact and Write Bullets

This is the most important step.

1. Cluster related commits by **business-level impact** — what the user or organizer actually gains. Think in terms of capabilities, not code changes.
2. Give each group a short heading (e.g. "Authentication & account management", "ICS calendar feeds").
3. For each group, write **one bullet per meaningful change**. Merge trivial follow-up commits (typo fixes, minor tweaks) into the parent bullet rather than listing them separately.
4. Each bullet should be a **complete sentence** that:
   - Starts with a past-tense verb (Added, Fixed, Redesigned, etc.)
   - Describes the change from the user's perspective
   - Ends with linked issue/PR references: `[\#123](https://github.com/{owner}/{repo}/pull/123)`
5. Bug fixes go under a single flat "Bug fixes" heading with no sub-grouping.

### Phase 5: Format

Output the changelog in this format:

```markdown
Released on {date}.

### {Business impact heading A}

- Added foo feature that allows users to do X. [\#12](https://github.com/{owner}/{repo}/pull/12)

- Redesigned the bar page with new editorial layout. [\#34](https://github.com/{owner}/{repo}/pull/34)

### {Business impact heading B}

- Added baz support for qux. [\#56](https://github.com/{owner}/{repo}/issues/56), [\#78](https://github.com/{owner}/{repo}/pull/78)

### Bug fixes

- Fixed quux not displaying correctly when corge is enabled. [\#90](https://github.com/{owner}/{repo}/pull/90)

- Fixed grault race condition on concurrent requests. [\#91](https://github.com/{owner}/{repo}/pull/91)
```

Rules:
- Use `Released on {Month Day, Year}.` as the opening line (e.g. "Released on March 24, 2026.").
- Each bullet is separated by a blank line for readability.
- Each bullet is a self-contained sentence — no nested sub-items.
- Omit empty sections entirely.
- Link PR/issue numbers as markdown links to the GitHub repo.
- Feature headings should read like product areas, not code areas.

### Phase 6: Present

Display the formatted changelog to the user. Do not write it to a file unless asked.
