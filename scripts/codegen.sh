#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

flutter pub get
(cd packages/core && flutter gen-l10n)
(cd packages/domain && dart run build_runner build)

echo "Code generation complete."
