---
name: store-release-note
description: Generate concise App Store / Play Store release notes from the latest GitHub release. This skill should be used when the user wants to write app store release notes, play store changelog, or compress release notes for mobile store submission.
---

# Store Release Note Generator

Compress the latest GitHub release notes into a short changelog suitable for App Store or Play Store submission.

**Arguments**: `<store>` (optional — `appstore` or `playstore`, defaults to both)

## Character Limits

| Store | Limit |
|-------|-------|
| App Store (iOS) | 4,000 characters |
| Play Store (Android) | 500 characters |

## Instructions

### Phase 1: Fetch Latest Release Notes

1. Get the latest GitHub release body:
   ```bash
   gh release view --json body -q .body
   ```
2. If no GitHub release exists, fall back to git log from the previous tag:
   ```bash
   git log $(git tag --list 'v*' --sort=-version:refname | head -1)..HEAD --oneline --no-merges
   ```

### Phase 2: Compress

Rewrite the release notes into a compact bullet list optimized for end users browsing an app store.

Rules:
- **No markdown links** — strip all `[#123](url)` references. Plain text only.
- **No headings** — use a flat bullet list.
- **User-facing language only** — omit infrastructure, refactoring, CI, or developer-only changes.
- **Short bullets** — each bullet is one line, starting with a past-tense verb (Added, Fixed, Improved, etc.).
- **Merge related items** — combine closely related changes into a single bullet.
- **Most impactful changes first** — lead with features, then improvements, then bug fixes.
- **No trailing period** on bullets.

### Phase 3: Format per Store

#### Play Store (500 chars)

Produce a terse version. If the compressed list exceeds 500 characters, aggressively merge or drop lower-priority items until it fits.

```
What's new in v{version}:

- Added foo for bar
- Improved baz performance
- Fixed qux crash on startup
```

#### App Store (4,000 chars)

Produce a slightly more detailed version. Each bullet can include a brief explanatory clause.

```
What's new in v{version}:

- Added foo, allowing users to do bar more easily
- Improved baz performance for large datasets
- Fixed a crash that occurred when opening qux on older devices
```

### Phase 4: Present

Display both versions (or the requested one) to the user. Clearly label each with the store name and character count so the user can verify it fits.

Format:

```
## Play Store ({N}/500 chars)

<content>

## App Store ({N}/4000 chars)

<content>
```
