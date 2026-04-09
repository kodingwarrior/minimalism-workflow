#!/bin/bash
set -euo pipefail

# Usage: load-plan.sh [mnemonic] [pwd-root]
# Without mnemonic: lists plans for current project
# With mnemonic: outputs plan content and metadata

MNEMONIC="${1:-}"
PWD_ROOT="${2:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

VAULT="$HOME/.planvault"
INDEX="$VAULT/index.json"

if [ ! -f "$INDEX" ]; then
  echo "NO_PLANS"
  exit 0
fi

if [ -z "$MNEMONIC" ]; then
  # List plans for current project
  python3 -c "
import json, sys
idx = json.load(open('$INDEX'))
matches = {k: v for k, v in idx.items() if v['pwd'] == '$PWD_ROOT'}
if not matches:
    # Show all plans as fallback
    if idx:
        print('NO_MATCH')
        for k, v in sorted(idx.items(), key=lambda x: x[1].get('updated_at',''), reverse=True):
            print(f\"{k}\t{v['pwd']}\t{v.get('description','')}\t{v.get('updated_at','')}\")
    else:
        print('NO_PLANS')
elif len(matches) == 1:
    k = list(matches.keys())[0]
    print(f'SINGLE\t{k}')
else:
    print('MULTIPLE')
    for k, v in sorted(matches.items(), key=lambda x: x[1].get('updated_at',''), reverse=True):
        print(f\"{k}\t{v['pwd']}\t{v.get('description','')}\t{v.get('updated_at','')}\")
"
else
  # Load specific plan
  PLAN_FILE="$VAULT/plans/$MNEMONIC/plan.md"

  python3 -c "
import json, sys
idx = json.load(open('$INDEX'))
entry = idx.get('$MNEMONIC')
if not entry:
    print('NOT_FOUND')
    sys.exit(0)
print(f\"FOUND\t{entry['pwd']}\t{entry.get('description','')}\t{entry.get('created_at','')}\t{entry.get('updated_at','')}\")
"

  if [ -f "$PLAN_FILE" ]; then
    echo "---CONTENT---"
    cat "$PLAN_FILE"
  else
    echo "MISSING_FILE"
  fi
fi
