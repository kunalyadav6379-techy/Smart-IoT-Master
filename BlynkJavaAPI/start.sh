#!/bin/bash

# Blynk Java API Startup Script
# High-performance Java server optimized for IoT applications

echo "Starting Blynk Java API Server..."
echo "=================================="

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "Error: Java is not installed or not in PATH"
    echo "Please install Java 17 or higher"
    exit 1
fi

# Check Java version
JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 17 ]; then
    echo "Error: Java 17 or higher is required"
    echo "Current version: $JAVA_VERSION"
    exit 1
fi

# Build the application if jar doesn't exist
if [ ! -f "target/blynk-java-api-2.0.0.jar" ]; then
    echo "Building application..."
    if command -v mvn &> /dev/null; then
        mvn clean package -DskipTests
    else
        echo "Error: Maven is not installed"
        echo "Please install Maven or build the project manually"
        exit 1
    fi
fi

# Set JVM options for optimal performance
export JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:+UseStringDeduplication -Djava.awt.headless=true"

# Start the application
echo "Starting server on port 5001..."
java $JAVA_OPTS -jar target/blynk-java-api-2.0.0.jar

echo "Server stopped."