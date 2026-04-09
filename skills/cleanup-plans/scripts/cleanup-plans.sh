#!/bin/bash
set -euo pipefail

# Usage: cleanup-plans.sh <action> [pwd-root]
# Actions:
#   list                    - list plans for current project (for selection)
#   delete <mnemonic>       - delete a specific plan
#   stale                   - find orphaned entries
#   project-all <pwd-root>  - delete all plans for a project

ACTION="${1:?Usage: cleanup-plans.sh <action> [args...]}"
shift

VAULT="$HOME/.planvault"
INDEX="$VAULT/index.json"

if [ ! -f "$INDEX" ]; then
  echo "NO_PLANS"
  exit 0
fi

case "$ACTION" in
  list)
    PWD_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
    python3 -c "
import json
idx = json.load(open('$INDEX'))
matches = {k: v for k, v in idx.items() if v['pwd'] == '$PWD_ROOT'}
if not matches:
    print('NO_MATCH')
else:
    for i, (k, v) in enumerate(sorted(matches.items(), key=lambda x: x[1].get('updated_at',''), reverse=True), 1):
        print(f\"PLAN\t{i}\t{k}\t{v.get('description','')}\t{v.get('updated_at','')}\")
"
    ;;

  delete)
    MNEMONIC="${1:?Usage: cleanup-plans.sh delete <mnemonic>}"
    python3 -c "
import json, sys
idx = json.load(open('$INDEX'))
if '$MNEMONIC' not in idx:
    print('NOT_FOUND')
    sys.exit(0)
entry = idx.pop('$MNEMONIC')
json.dump(idx, open('$INDEX', 'w'), indent=2)
print(f\"DELETED\t$MNEMONIC\t{entry['pwd']}\")
print(f'REMAINING\t{len(idx)}')
"
    rm -rf "$VAULT/plans/$MNEMONIC"
    ;;

  stale)
    python3 -c "
import json, os
idx = json.load(open('$INDEX'))
vault = os.path.expanduser('~/.planvault')

# Index entries with missing files
for k, v in idx.items():
    plan_file = f'{vault}/plans/{k}/plan.md'
    if not os.path.exists(plan_file):
        print(f'ORPHAN_INDEX\t{k}\t{v[\"pwd\"]}')

# Plan dirs with no index entry
plans_dir = f'{vault}/plans'
if os.path.isdir(plans_dir):
    for d in os.listdir(plans_dir):
        if os.path.isdir(f'{plans_dir}/{d}') and d not in idx:
            print(f'ORPHAN_DIR\t{d}')

if not any(True for k in idx if not os.path.exists(f'{vault}/plans/{k}/plan.md')) and \
   not any(True for d in (os.listdir(plans_dir) if os.path.isdir(plans_dir) else []) if os.path.isdir(f'{plans_dir}/{d}') and d not in idx):
    print('CLEAN')
"
    ;;

  project-all)
    PWD_ROOT="${1:?Usage: cleanup-plans.sh project-all <pwd-root>}"
    python3 -c "
import json
idx = json.load(open('$INDEX'))
to_delete = [k for k, v in idx.items() if v['pwd'] == '$PWD_ROOT']
for k in to_delete:
    del idx[k]
json.dump(idx, open('$INDEX', 'w'), indent=2)
for k in to_delete:
    print(f'DELETED\t{k}')
print(f'REMAINING\t{len(idx)}')
"
    # Remove plan directories
    for mnemonic in $(python3 -c "
import json
idx = json.load(open('$INDEX')) if __import__('os').path.exists('$INDEX') else {}
# Already removed from index above, read from plans dir
import os
for d in os.listdir('$VAULT/plans'):
    if os.path.isdir(f'$VAULT/plans/{d}'):
        # Check if it was for this project by checking if it's NOT in the index anymore
        if d not in idx:
            print(d)
" 2>/dev/null); do
      rm -rf "$VAULT/plans/$mnemonic"
    done
    ;;

  *)
    echo "Unknown action: $ACTION" >&2
    exit 1
    ;;
esac
