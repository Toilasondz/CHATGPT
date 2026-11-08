#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$ROOT/Prebuilt/VideoStarTool.dylib"
[[ -f "$BIN" ]] || { echo "Missing $BIN" >&2; exit 1; }
python3 "$ROOT/scripts/verify_prebuilt.py" "$BIN"
