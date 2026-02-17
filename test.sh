#!/bin/bash
# Run all tests and static analysis for the project using a container.
# Includes: unit tests, widget tests, and Flutter analyzer (linter).
# Returns 0 on success, non-zero on any failure.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

APP_DIR="${SCRIPT_DIR}/asthmaapp"
if [ ! -d "$APP_DIR" ]; then
  echo "Error: asthmaapp directory not found"
  exit 1
fi

FLUTTER_IMAGE="${FLUTTER_IMAGE:-ghcr.io/cirruslabs/flutter:stable}"

if ! docker info >/dev/null 2>&1; then
  echo "Error: Docker is not running or not available. Start Docker or run this in an environment with Docker."
  exit 1
fi

echo "Running tests and static analysis in container (image: ${FLUTTER_IMAGE})..."
docker run --rm \
  -v "${APP_DIR}:/app" \
  -w /app \
  "$FLUTTER_IMAGE" \
  sh -c "flutter pub get && flutter analyze && flutter test"

echo "All tests and checks passed."
exit 0
