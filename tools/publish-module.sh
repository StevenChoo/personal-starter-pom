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


# Go to work directory
cd "$source_dir/.." || exit 1

module=$1
echo -e "${BLUE}Processing $module...${NC}"

if [ ! -d "$module" ]; then
    echo -e "${RED}Error: Project directory $module not found${NC}"
    exit 1
fi

# Check Maven installation
if ! command -v mvn &> /dev/null; then
    echo -e "${RED}Error: Maven is not installed or not in PATH${NC}"
    exit 1
fi

# If Maven user not provided, prompt for it
if [ -z "$MAVEN_GPG_PASSPHRASE" ]; then
    echo -e "${RED}Error: MAVEN_GPG_PASSPHRASE environment variable is required${NC}"
    exit 1
fi

# If Maven user not provided, prompt for it
if [ -z "$MAVEN_GPG_KEY" ]; then
    echo -e "${RED}Error: MAVEN_GPG_KEY environment variable is required${NC}"
    exit 1
fi

mvn clean deploy --no-transfer-progress -f "./$module/pom.xml" \
  -Prelease \
  -Dmaven.deploy.skip \
  -DskipTests=true \
  -Dstrict=false \
  -Dgpg.passphrase="$MAVEN_GPG_PASSPHRASE" \
  -Dgpg.keyname="$MAVEN_GPG_KEY"
