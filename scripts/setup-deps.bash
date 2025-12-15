#/bin/bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if ! command -v cmake &> /dev/null; then
    echo "cmake could not be found, aborting..."
    exit 1
fi

