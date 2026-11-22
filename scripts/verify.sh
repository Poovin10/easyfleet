#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

flutter analyze
(cd apps/driver && flutter test)
(cd apps/transporter && flutter test)

echo "Verification complete."
