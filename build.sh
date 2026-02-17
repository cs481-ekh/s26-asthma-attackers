#!/bin/bash
# Build all project components from scratch using a container.
# Returns 0 on success, non-zero on build failure.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

APP_DIR="${SCRIPT_DIR}/asthmaapp"
if [ ! -d "$APP_DIR" ]; then
  echo "Error: asthmaapp directory not found"
  exit 1
fi

# Use Flutter container to fetch dependencies and build (web build works headless in CI)
FLUTTER_IMAGE="${FLUTTER_IMAGE:-ghcr.io/cirruslabs/flutter:stable}"

if ! docker info >/dev/null 2>&1; then
  echo "Error: Docker is not running or not available. Start Docker or run this in an environment with Docker."
  exit 1
fi

echo "Building Flutter app in container (image: ${FLUTTER_IMAGE})..."
docker run --rm \
  -v "${APP_DIR}:/app" \
  -w /app \
  "$FLUTTER_IMAGE" \
  sh -c "flutter pub get && flutter build web"

echo "Build completed successfully."
exit 0
