#!/bin/bash
# ローカルで DMG を作る前に Xcode ライセンスが必要です:
#   sudo xcodebuild -license accept
set -euo pipefail
if ! xcrun --show-sdk-path &>/dev/null; then
  echo "Xcode / Command Line Tools が使えません。" >&2
  echo "ターミナルで: sudo xcodebuild -license accept" >&2
  exit 1
fi
"$(dirname "$0")/build-dmg.sh"
