#!/usr/bin/env bash
#
# Copyright (C) 2025 Steven Choo <info@stevenchoo.nl>
#
# MIT License. See the LICENSE file in the root directory or <http://www.opensource.org/licenses/mit-license.php>
#

# Exit immediately if a command exits with a non-zero status
set -e

# Get dir of script so we can call the script from other places and still be able to have the correct references to directories
source=$(readlink -f -- "${BASH_SOURCE[0]}")
source_dir=$(dirname "${source}")

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Please enter your GPG key:${NC}"
read -s MAVEN_GPG_KEY
echo ""

echo -e "${YELLOW}Please enter your GPG passphrase:${NC}"
read -s MAVEN_GPG_PASSPHRASE
echo ""

echo -e "${YELLOW}Please enter your Maven server id:${NC}"
read -s MAVEN_SERVER_ID
echo ""

## Publishing requested module with given GPG key and passphrase
MAVEN_SERVER_ID=$MAVEN_SERVER_ID MAVEN_GPG_KEY=$MAVEN_GPG_KEY MAVEN_GPG_PASSPHRASE=$MAVEN_GPG_PASSPHRASE  "$source_dir/publish-module.sh" "$1"
