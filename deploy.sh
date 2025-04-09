#!/usr/bin/env bash
#
# Copyright (C) 2025 Steven Choo <info@stevenchoo.nl>
#
# MIT License. See the LICENSE file in the root directory or <http://www.opensource.org/licenses/mit-license.php>
#

set -e

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECTS=(
  "java-starter"
  "kotlin-starter"
  "spring-boot-java-starter"
  "spring-boot-kotlin-starter"
)
GPG_PASSPHRASE=${GPG_PASSPHRASE:-""}
MAVEN_PUBLISH_PROFILE=${MAVEN_PUBLISH_PROFILE:-"central"}
SKIP_TESTS=${SKIP_TESTS:-"true"}
MAVEN_ARGS=${MAVEN_ARGS:-""}
GPG_PLUGIN_VERSION=${GPG_PLUGIN_VERSION:-"3.2.7"}
PUBLISHING_PLUGIN_VERSION=${PUBLISHING_PLUGIN_VERSION:-"0.7.0"}
MAX_VALIDATION_RETRIES=${MAX_VALIDATION_RETRIES:-5}

# Banner
echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}  Maven Multi-Project Deployment   ${NC}"
echo -e "${BLUE}====================================${NC}"

# Check if GPG is available
if ! command -v gpg &> /dev/null; then
    echo -e "${RED}Error: GPG is not installed or not in PATH${NC}"
    exit 1
fi

# Check Maven installation
if ! command -v mvn &> /dev/null; then
    echo -e "${RED}Error: Maven is not installed or not in PATH${NC}"
    exit 1
fi

# Check curl installation
if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is not installed or not in PATH${NC}"
    exit 1
fi

# If passphrase not provided, prompt for it
if [ -z "$GPG_PASSPHRASE" ]; then
    echo -e "${YELLOW}Please enter your GPG passphrase:${NC}"
    read -s GPG_PASSPHRASE
    echo ""
fi

# If Maven user not provided, prompt for it
if [ -z "$MAVEN_USER" ]; then
    echo -e "${YELLOW}Please enter your Maven Central user ID:${NC}"
    read -s MAVEN_USER
    echo ""
fi

# If Maven password not provided, prompt for it
if [ -z "$MAVEN_PASSWORD" ]; then
    echo -e "${YELLOW}Please enter your Maven Central password:${NC}"
    read -s MAVEN_PASSWORD
    echo ""
fi

# Generate Maven authentication token
MAVEN_TOKEN=$(printf "$MAVEN_USER:$MAVEN_PASSWORD" | base64 | tr -d '\n')

# Function to upload to Maven Central
upload_to_maven_central() {
    local bundle_filename=$1
    local project_name=$2
    local response_file="upload_response.json"

    echo -e "${GREEN}Uploading $project_name to Maven Central...${NC}"

    # Upload bundle to Maven Central
    HTTP_CODE=$(
        curl --request POST \
          --write-out "%{http_code}" \
          --silent \
          --output "${response_file}" \
          --header "Authorization: Bearer ${MAVEN_TOKEN}" \
          --form "bundle=@${bundle_filename}" \
          "https://central.sonatype.com/api/v1/publisher/upload?name=${project_name}&publishingType=AUTOMATIC"
    )

    # Check HTTP response code
    if [[ $HTTP_CODE -ge 200 && $HTTP_CODE -lt 300 ]]; then
        echo -e "${GREEN}Upload successful. HTTP Status: $HTTP_CODE${NC}"
        # Extract deployment ID from response
        local deployment_id=$(cat "${response_file}" | grep -o '"[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}"' | tr -d '"')
        echo "$deployment_id"
        return 0
    else
        echo -e "${RED}Upload failed. HTTP Status: $HTTP_CODE${NC}"
        echo -e "${RED}Response: $(cat ${response_file})${NC}"
        return 1
    fi
}

# Function to validate deployment status with adjusted wait times
validate_deployment() {
    local deployment_id=$1
    local retry_count=1
    local max_retries=$MAX_VALIDATION_RETRIES
    local response_file="status_response.json"

    # Initial wait of 30 seconds before first check
    echo -e "${BLUE}Waiting initial 30 seconds for deployment processing...${NC}"
    sleep 15

    while [ $retry_count -le $max_retries ]; do
        echo -e "${BLUE}Checking deployment status (Attempt $retry_count/$max_retries)...${NC}"

        # Call status API
        HTTP_CODE=$(
            curl --request GET \
              --write-out "%{http_code}" \
              --silent \
              --output "${response_file}" \
              --header "Authorization: Bearer ${MAVEN_TOKEN}" \
              "https://central.sonatype.com/api/v1/publisher/status?id=${deployment_id}"
        )

        # Check if request was successful
        if [[ $HTTP_CODE -ge 200 && $HTTP_CODE -lt 300 ]]; then
            # Extract deployment state
            local deployment_state=$(grep -o '"deploymentState":"[^"]*"' "${response_file}" | cut -d':' -f2 | tr -d '"')
            echo -e "${BLUE}Current status: $deployment_state${NC}"

            # Check if published
            if [ "$deployment_state" == "PUBLISHED" ]; then
                echo -e "${GREEN}Deployment successfully published!${NC}"
                local purls=$(grep -o '"purls":\[[^]]*\]' "${response_file}" | sed 's/"purls":/Published artifacts:/')
                echo -e "${GREEN}$purls${NC}"
                return 0
            elif [ "$deployment_state" == "FAILED" ]; then
                echo -e "${RED}Deployment failed!${NC}"
                echo -e "${RED}Details: $(cat ${response_file})${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}Failed to check status. HTTP Status: $HTTP_CODE${NC}"
            echo -e "${YELLOW}Response: $(cat ${response_file})${NC}"
        fi

        # Save current status to log file
        cat "${response_file}" > "status_${retry_count}.json"

        # Increment retry count
        retry_count=$((retry_count + 1))

        if [ $retry_count -le $max_retries ]; then
            # Wait 10 seconds between checks
            echo -e "${BLUE}Waiting 10 seconds before next check...${NC}"
            sleep 10
        fi
    done

    echo -e "${RED}Maximum retries reached. Deployment status could not be confirmed.${NC}"
    return 1
}

# Function to process a project
process_project() {
    local project=$1

    echo -e "${BLUE}Processing $project...${NC}"

    if [ ! -d "$project" ]; then
        echo -e "${RED}Error: Project directory $project not found${NC}"
        return 1
    fi

    if [ ! -f "$project/pom.xml" ]; then
        echo -e "${RED}Error: pom.xml not found in $project${NC}"
        return 1
    fi

    # Step 1: Clean and package the project
    echo -e "${GREEN}Building $project...${NC}"
    (
        cd "$project" && \
        mvn clean package \
            -DskipTests="$SKIP_TESTS" \
            $MAVEN_ARGS
    )

    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to build $project${NC}"
        return 1
    fi

    # Step 2: Sign the artifacts using GPG plugin
    echo -e "${GREEN}Signing $project artifacts...${NC}"
    (
        cd "$project" && \
        mvn org.apache.maven.plugins:maven-gpg-plugin:${GPG_PLUGIN_VERSION}:sign \
            -Dgpg.passphrase="$GPG_PASSPHRASE" \
            $MAVEN_ARGS
    )

    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to sign $project artifacts${NC}"
        return 1
    fi

    # Extract metadata from POM
    PROJECT_VERSION=$(cd "$project" && mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
    GROUP_ID=$(cd "$project" && mvn help:evaluate -Dexpression=project.groupId -q -DforceStdout)
    ARTIFACT_ID=$(cd "$project" && mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout)

    BUNDLE_FILENAME="${project}-${PROJECT_VERSION}-bundle.zip"

    # Create a deployment log directory within target to store all deployment-related files
    mkdir -p "$project/target/deployment-logs"

    # Step 3: Generate SHA1 and MD5 checksums for POM
    echo -e "${GREEN}Generating checksums for POM artifact...${NC}"
    (
        cd "$project/target" && \
        POM_FILE=$(find . -name "*.pom" -type f | head -1)

        if [ -n "$POM_FILE" ]; then
            echo -e "${BLUE}Creating SHA1 checksum for $POM_FILE${NC}"
            sha1sum "$POM_FILE" | awk '{print $1}' > "${POM_FILE}.sha1"

            echo -e "${BLUE}Creating MD5 checksum for $POM_FILE${NC}"
            md5sum "$POM_FILE" | awk '{print $1}' > "${POM_FILE}.md5"
        else
            echo -e "${YELLOW}Warning: No POM file found in target directory${NC}"
        fi
    )

    # Step 4: Create proper Maven repository directory structure and move files
    echo -e "${GREEN}Creating Maven repository structure...${NC}"
    (
        cd "$project/target" && \

        # Convert groupId to directory path (com.example -> com/example)
        GROUP_PATH=$(echo "$GROUP_ID" | tr '.' '/')

        # Create the full path including artifactId and version
        ARTIFACT_PATH="${GROUP_PATH}/${ARTIFACT_ID}/${PROJECT_VERSION}"
        mkdir -p "$ARTIFACT_PATH"

        echo -e "${BLUE}Moving artifacts to $ARTIFACT_PATH${NC}"

        # Move all relevant files (JAR, POM, ASC, SHA1, MD5)
        # First find all artifact files in the root of target
        find . -maxdepth 1 -name "*.jar" -o -name "*.pom" -o -name "*.asc" -o -name "*.sha1" -o -name "*.md5" | while read file; do
            # Skip if file is not a regular file
            if [ ! -f "$file" ]; then
                continue
            fi

            # Extract just the filename without path
            filename=$(basename "$file")

            # Copy to the proper path
            cp "$file" "$ARTIFACT_PATH/$filename"
            echo -e "${BLUE}Copied $filename to $ARTIFACT_PATH/${NC}"
        done
    )

    # Step 5: Bundle it
    echo -e "${GREEN}Bundling $project for upload to Maven Central...${NC}"
    (
        cd "$project/target" && \
        # Bundle only the Maven repository structure
        GROUP_PATH=$(echo "$GROUP_ID" | tr '.' '/')
        zip -r "${BUNDLE_FILENAME}" "${GROUP_PATH}"
    )

    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to create bundle for $project${NC}"
        return 1
    fi

    # Step 6: Upload to Maven Central and validate - operate from target directory
    (
        cd "$project/target" && \

        # Upload bundle and get deployment ID
        local project_name="${project}-${PROJECT_VERSION}"
        local deployment_id=$(upload_to_maven_central "${BUNDLE_FILENAME}" "$project_name")

        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to upload $project${NC}"
            exit 1
        fi

        echo -e "${GREEN}Deployment ID: $deployment_id${NC}"
        echo "$deployment_id" > "deployment_id.txt"

        # Validate deployment status
        if validate_deployment "$deployment_id"; then
            echo -e "${GREEN}Successfully published $project!${NC}"
            # Move all logs and responses to deployment-logs directory
            mkdir -p "deployment-logs"
            mv upload_response.json status_response.json status_*.json deployment_id.txt "deployment-logs/" 2>/dev/null || true
            exit 0
        else
            echo -e "${RED}Failed to publish $project${NC}"
            # Move all logs and responses to deployment-logs directory
            mkdir -p "deployment-logs"
            mv upload_response.json status_response.json status_*.json deployment_id.txt "deployment-logs/" 2>/dev/null || true
            exit 1
        fi
    )

    local result=$?
    if [ $result -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Process each project
FAILED_PROJECTS=()
for project in "${PROJECTS[@]}"; do
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}  Processing $project              ${NC}"
    echo -e "${BLUE}====================================${NC}"

    if ! process_project "$project"; then
        FAILED_PROJECTS+=("$project")
    fi

    echo ""
done

# Summary
echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}  Deployment Summary                ${NC}"
echo -e "${BLUE}====================================${NC}"

if [ ${#FAILED_PROJECTS[@]} -eq 0 ]; then
    echo -e "${GREEN}All projects were successfully processed!${NC}"
else
    echo -e "${RED}The following projects failed:${NC}"
    for failed in "${FAILED_PROJECTS[@]}"; do
        echo -e "${RED}- $failed${NC}"
    done
    exit 1
fi

echo -e "${GREEN}Deployment completed!${NC}"
exit 0
