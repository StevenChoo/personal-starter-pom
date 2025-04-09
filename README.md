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

### Quality Assurance

All parent POMs include the following quality assurance tools:

- PMD for static code analysis
- SpotBugs for bug detection
- Maven Enforcer Plugin with extra rules for dependency control
- JaCoCo Maven Plugin

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

## Releasing

To avoid including the plugins defined in the release profile in the flattened POMs
- clean install first to flatten
- deploy with release profile to release POMs

```shell
mvn clean install && mvn clean deploy -Prelease
```
