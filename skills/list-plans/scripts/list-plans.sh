#!/bin/bash
set -euo pipefail

# Usage: list-plans.sh [--all] [pwd-root]

ARG="${1:-}"
PWD_ROOT=""

if [ "$ARG" = "--all" ]; then
  PWD_ROOT="${2:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
else
  PWD_ROOT="${ARG:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  ARG=""
fi

VAULT="$HOME/.planvault"
INDEX="$VAULT/index.json"

if [ ! -f "$INDEX" ]; then
  echo "NO_PLANS"
  exit 0
fi

python3 -c "
import json

idx = json.load(open('$INDEX'))
if not idx:
    print('NO_PLANS')
    exit()

show_all = '$ARG' == '--all'
pwd_root = '$PWD_ROOT'

if show_all:
    by_project = {}
    for k, v in idx.items():
        by_project.setdefault(v['pwd'], []).append((k, v))
    for proj in sorted(by_project.keys()):
        print(f'PROJECT\t{proj}')
        for k, v in sorted(by_project[proj], key=lambda x: x[1].get('updated_at',''), reverse=True):
            print(f\"PLAN\t{k}\t{v.get('description','')}\t{v.get('updated_at','')}\")
    print(f'TOTAL\t{len(idx)}')
else:
    matches = {k: v for k, v in idx.items() if v['pwd'] == pwd_root}
    if matches:
        print(f'PROJECT\t{pwd_root}')
        for k, v in sorted(matches.items(), key=lambda x: x[1].get('updated_at',''), reverse=True):
            print(f\"PLAN\t{k}\t{v.get('description','')}\t{v.get('updated_at','')}\")
        print(f'TOTAL\t{len(matches)}')
    else:
        print('NO_MATCH')
        # Show all as fallback
        by_project = {}
        for k, v in idx.items():
            by_project.setdefault(v['pwd'], []).append((k, v))
        for proj in sorted(by_project.keys()):
            print(f'PROJECT\t{proj}')
            for k, v in sorted(by_project[proj], key=lambda x: x[1].get('updated_at',''), reverse=True):
                print(f\"PLAN\t{k}\t{v.get('description','')}\t{v.get('updated_at','')}\")
        print(f'TOTAL\t{len(idx)}')
"
