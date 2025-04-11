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

cd "$source_dir/.." || exit 1

mvn --batch-mode --no-transfer-progress clean install -f ./java-starter/pom.xml -Dstrict=true
mvn --batch-mode --no-transfer-progress clean install -f ./kotlin-starter/pom.xml -Dstrict=true
mvn --batch-mode --no-transfer-progress clean install -f ./spring-boot-java-starter/pom.xml -Dstrict=true
mvn --batch-mode --no-transfer-progress clean install -f ./spring-boot-kotlin-starter/pom.xml -Dstrict=true
