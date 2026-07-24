#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/development/flutter-ventura/bin:$PATH"
echo "Flutter: $(which flutter)"
flutter --version
cd "$HOME/Desktop/Fuel-Credit-Merchant-App"
flutter pub get
flutter run -d chrome --web-port=5002 \
  --dart-define=API_BASE_URL=http://localhost:4000/api/v1
