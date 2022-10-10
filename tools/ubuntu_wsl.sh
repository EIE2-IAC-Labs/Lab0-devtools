#!/usr/bin/env bash

# Author : James Nock
# Year   : 2022

set -euo pipefail

echo () {
    printf "\n%b\n" "[iac] $1"
}

gzip_code=0

echo "Testing gzip"
gzip 2>/dev/null || gzip_code=$?
if [ "${gzip_code}" -eq 126 ]; then
    echo "Broken gzip detected; applying patch... you may need to enter your password..."
    printf '\x10' | sudo dd of=/usr/bin/gzip count=1 bs=1 conv=notrunc seek=$((0x189))
else
    echo "gzip working correctly"
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "Running additional script from ${SCRIPT_DIR}"

"${SCRIPT_DIR}/ubuntu.sh"
