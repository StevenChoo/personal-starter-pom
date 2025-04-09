#!/usr/bin/env bash
#
# Copyright (C) 2025 Steven Choo <info@stevenchoo.nl>
#
# MIT License. See the LICENSE file in the root directory or <http://www.opensource.org/licenses/mit-license.php>
#

mvn clean install -f ./java-starter/pom.xml
mvn clean install -f ./kotlin-starter/pom.xml
mvn clean install -f ./spring-boot-java-starter/pom.xml
mvn clean install -f ./spring-boot-kotlin-starter/pom.xml
