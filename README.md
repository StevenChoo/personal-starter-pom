# Personal Maven Starter POMs

This project provides a set of starter POMs for Java and Kotlin projects, with and without Spring Boot.
The starter POMs include configuration and dependencies that are almost always included in a project.

## Available Parent POMs

| POM Artifact ID              | Based On         | Description                 | Java Version | Key Features                                   |
|------------------------------|------------------|-----------------------------|--------------|------------------------------------------------|
| `java-starter`               | -                | Base Java projects          | 21           | Core Java setup Maven starter                  |
| `kotlin-starter`             | `java-starter`   | Base Kotlin projects        | 21           | Core Kotlin setup Maven starter                |
| `spring-boot-java-starter`   | `java-starter`   | Spring Boot Java projects   | 21           | Spring Boot for Java with Web, JPA, Actuator   |
| `spring-boot-kotlin-starter` | `kotlin-starter` | Spring Boot Kotlin projects | 21           | Spring Boot for Kotlin with Web, JPA, Actuator |

## Features

### Default Plugins

All parent POMs include the following plugins with sensible defaults:

- Maven Compiler Plugin
- Maven Surefire Plugin
- Maven Source Plugin
- Maven Javadoc Plugin
- Maven Release Plugin
- Flatten Maven Plugin

### Quality Assurance

All parent POMs include the following quality assurance tools:

- PMD for static code analysis
- SpotBugs for bug detection
- Maven Enforcer Plugin with extra rules for dependency control
- JaCoCo Maven Plugin for code coverage

### Code Formatting

- Java projects use Spotless with Palantir Java formatter
- Kotlin projects use Spotless with KtLint

## Usage

Add one of the starter as parent POMs to your project:

### Java Project

```xml
<parent>
    <groupId>io.github.stevenchoo</groupId>
    <artifactId>java-starter</artifactId>
    <version>1.0-SNAPSHOT</version>
</parent>
```

### Kotlin Project

```xml
<parent>
    <groupId>io.github.stevenchoo</groupId>
    <artifactId>kotlin-starter</artifactId>
    <version>1.0-SNAPSHOT</version>
</parent>
```

### Spring Boot Java Project

```xml
<parent>
    <groupId>io.github.stevenchoo</groupId>
    <artifactId>spring-boot-java-starter</artifactId>
    <version>1.0-SNAPSHOT</version>
</parent>
```

### Spring Boot Kotlin Project

```xml
<parent>
    <groupId>io.github.stevenchoo</groupId>
    <artifactId>spring-boot-kotlin-starter</artifactId>
    <version>1.0-SNAPSHOT</version>
</parent>
```

### Snapshot Repository

```xml
<repositories>
  <repository>
    <name>Central Portal Snapshots</name>
    <id>central-portal-snapshots</id>
    <url>https://central.sonatype.com/repository/maven-snapshots/</url>
    <releases>
      <enabled>false</enabled>
    </releases>
    <snapshots>
      <enabled>true</enabled>
    </snapshots>
  </repository>
</repositories>
```

## Development Tools

This project includes several tools in the `tools/` directory to help with development, building, and publishing.

### Building and Testing

- `build.sh`: Build all modules locally
- `build-and-test.sh`: Build and run tests for all modules
- `format-examples.sh`: Format all example projects

```shell
# Build all modules
./tools/build.sh

# Build and test
./tools/build-and-test.sh

# Format examples
./tools/format-examples.sh
```

### Publishing Modules

The project includes scripts for publishing modules to Maven Central:

- `publish-module.sh`: Publish a specific module
- `publish-module-manual.sh`: Manually publish a specific module

```shell
# Set required environment variables
export MAVEN_GPG_KEY="your-gpg-key-id"
export MAVEN_GPG_PASSPHRASE="your-gpg-passphrase"
export MAVEN_SERVER_ID="the-id-of-the-configured-server"

# Publish a module (e.g., java-starter)
./tools/publish-module.sh java-starter

# Optional: Manual publishing with Nexus staging
./tools/publish-module-manual.sh java-starter
```

## Manual Tasks

### POM Sorting

Before releasing, it's recommended to sort the POM files for consistency. From the project root:

```shell
# Sort individual POMs
mvn com.github.ekryd.sortpom:sortpom-maven-plugin:3.3.0:sort -f ./java-starter/pom.xml
mvn com.github.ekryd.sortpom:sortpom-maven-plugin:3.3.0:sort -f ./kotlin-starter/pom.xml
mvn com.github.ekryd.sortpom:sortpom-maven-plugin:3.3.0:sort -f ./spring-boot-java-starter/pom.xml
mvn com.github.ekryd.sortpom:sortpom-maven-plugin:3.3.0:sort -f ./spring-boot-kotlin-starter/pom.xml

# Alternatively, use this bash one-liner to sort all POMs:
find . -name "pom.xml" -not -path "*/target/*" -not -path "*/examples/*" | xargs -I{} mvn com.github.ekryd.sortpom:sortpom-maven-plugin:3.3.0:sort -f {}
```
