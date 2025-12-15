#!/bin/bash
set -euo pipefail

CMAKE_OSX_ARCHITECTURES="arm64;x86_64"
CMAKE_OSX_DEPLOYMENT_TARGET="12.0"

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEPS_DIR="${ROOT_DIR}/.deps"

if [[ ! -f "${DEPS_DIR}/.deps_versions" ]]; then
    echo "Dependencies not found. Please run setup-deps.sh first."
    exit 1
fi

. "${DEPS_DIR}/.deps_versions"

PREBUILT_DIR="${DEPS_DIR}/obs-deps-${PREBUILT_VERSION}-universal"
QT6_DIR="${DEPS_DIR}/obs-deps-qt6-${QT6_VERSION}-universal"

SOURCE_DIR="${DEPS_DIR}/obs-studio-${OBS_VERSION}"
BUILD_DIR="${SOURCE_DIR}/build_universal"

if [[ ! -d $SOURCE_DIR ]]; then
    echo "Error: OBS source directory not found at $SOURCE_DIR"
    exit 1
fi

rm -rf "$BUILD_DIR"

cmake -S "$SOURCE_DIR" \
      -B "$BUILD_DIR" \
      -G "Xcode" \
      -DCMAKE_OSX_ARCHITECTURES="${CMAKE_OSX_ARCHITECTURES}" \
      -DCMAKE_OSX_DEPLOYMENT_TARGET="${CMAKE_OSX_DEPLOYMENT_TARGET}" \
      -DOBS_CMAKE_VERSION=3.0.0 \
      -DENABLE_PLUGINS=OFF \
      -DENABLE_FRONTEND=OFF \
      -DOBS_VERSION_OVERRIDE="$OBS_VERSION" \
      "-DCMAKE_PREFIX_PATH=${PREBUILT_DIR};${QT6_DIR}" \
      "-DCMAKE_INSTALL_PREFIX=$DEPS_DIR"

cmake --build "$BUILD_DIR" \
      --target obs-frontend-api \
      --config Debug \
      --parallel

cmake --build "$BUILD_DIR" \
      --target obs-frontend-api \
      --config Release \
      --parallel

cmake --install "$BUILD_DIR" \
      --component Development \
      --config Debug \
      --prefix "$DEPS_DIR"

cmake --install "$BUILD_DIR" \
      --component Development \
      --config Release \
      --prefix "$DEPS_DIR"

echo "Install done. Artifacts are in $DEPS_DIR"
