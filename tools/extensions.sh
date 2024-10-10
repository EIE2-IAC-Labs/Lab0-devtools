#!/usr/bin/env bash

IAC_FOLDER="$HOME/Documents/iac"
REPO_NAME="lab0-devtools"
TOOLS_FOLDER="$IAC_FOLDER/$REPO_NAME"

set -euo pipefail

printf "[iac] Installing extensions. Make sure to install the recommended instructions when prompted.\n"
cat "${TOOLS_FOLDER}/autumn/workspace/iac-autumn.code-workspace" | jq -r '.extensions.recommendations | .[]' | xargs -L1 code --install-extension
printf "[iac] Sucessfully installed all extensions.\n"
