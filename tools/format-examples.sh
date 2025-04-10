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

mvn clean install -Pformat -f ./examples/java-starter-test/pom.xml -DskipTests
mvn clean install -Pformat -f ./examples/kotlin-starter-test/pom.xml -DskipTests
mvn clean install -Pformat -f ./examples/spring-boot-java-starter-test/pom.xml -DskipTests
mvn clean install -Pformat -f ./examples/spring-boot-kotlin-starter-test/pom.xml -DskipTests
