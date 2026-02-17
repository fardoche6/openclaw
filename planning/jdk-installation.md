# JDK Installation and Configuration

## Problem
The project requires JDK 17, but it was not installed on the system, and `sudo` access was not available for global installation.

## Solution
We installed OpenJDK 17 locally in the user's home directory and configured VS Code to use it.

### 1. Installation
Installed **Eclipse Temurin JDK 17** to `~/.local/java/jdk-17.0.18+8`.

### 2. VS Code Configuration
Updated `.vscode/settings.json` to point `java.configuration.runtimes` to the local JDK:

```json
"java.configuration.runtimes": [
    {
        "name": "JavaSE-17",
        "path": "/home/fardoche/.local/java/jdk-17.0.18+8",
        "default": true
    }
]
```

## Verification
- Run `~/.local/java/jdk-17.0.18+8/bin/java -version` to verify the Java binary.
- VS Code should automatically pick up the JDK for the project.
