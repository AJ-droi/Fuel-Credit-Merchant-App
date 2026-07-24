#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
flutter pub get
flutter run -d chrome --web-port=5002 \
  --dart-define=API_BASE_URL=http://localhost:4000/api/v1
