#!/bin/bash
set -euo pipefail

# Usage: save-plan.sh <mnemonic> <description> <plan-file> [pwd-root]
# plan-file: path to a temp file containing the plan markdown
# pwd-root: optional, defaults to git root or $PWD

MNEMONIC="${1:?Usage: save-plan.sh <mnemonic> <description> <plan-file> [pwd-root]}"
DESCRIPTION="${2:?Usage: save-plan.sh <mnemonic> <description> <plan-file> [pwd-root]}"
PLAN_FILE="${3:?Usage: save-plan.sh <mnemonic> <description> <plan-file> [pwd-root]}"
PWD_ROOT="${4:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

VAULT="$HOME/.planvault"
INDEX="$VAULT/index.json"
TODAY=$(date +%Y-%m-%d)

# Validate mnemonic
if ! echo "$MNEMONIC" | grep -qE '^[a-z0-9][a-z0-9-]*$'; then
  echo "ERROR: Invalid mnemonic '$MNEMONIC'. Must be lowercase alphanumeric with hyphens." >&2
  exit 1
fi

# Ensure vault exists
mkdir -p "$VAULT/plans"
[ -f "$INDEX" ] || echo '{}' > "$INDEX"

# Check for collision
EXISTING_PWD=$(python3 -c "
import json, sys
idx = json.load(open('$INDEX'))
entry = idx.get('$MNEMONIC')
if entry:
    print(entry['pwd'])
" 2>/dev/null || true)

if [ -n "$EXISTING_PWD" ] && [ "$EXISTING_PWD" != "$PWD_ROOT" ]; then
  echo "CONFLICT: Mnemonic '$MNEMONIC' already used by project: $EXISTING_PWD" >&2
  exit 2
fi

# Save plan file
mkdir -p "$VAULT/plans/$MNEMONIC"
cp "$PLAN_FILE" "$VAULT/plans/$MNEMONIC/plan.md"

# Update index
python3 -c "
import json
idx = json.load(open('$INDEX'))
existing = idx.get('$MNEMONIC', {})
idx['$MNEMONIC'] = {
    'pwd': '$PWD_ROOT',
    'description': '''$DESCRIPTION''',
    'created_at': existing.get('created_at', '$TODAY'),
    'updated_at': '$TODAY'
}
json.dump(idx, open('$INDEX', 'w'), indent=2)
"

echo "Saved plan '$MNEMONIC' at $VAULT/plans/$MNEMONIC/plan.md"
echo "Load with: /load-plan $MNEMONIC"
