@echo off
REM Blynk Java API Startup Script for Windows
REM High-performance Java server optimized for IoT applications

echo Starting Blynk Java API Server...
echo ==================================

REM Check if Java is installed
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Java is not installed or not in PATH
    echo Please install Java 17 or higher
    pause
    exit /b 1
)

REM Build the application if jar doesn't exist
if not exist "target\blynk-java-api-2.0.0.jar" (
    echo Building application...
    mvn clean package -DskipTests
    if %errorlevel% neq 0 (
        echo Error: Build failed
        pause
        exit /b 1
    )
)

REM Set JVM options for optimal performance
set JAVA_OPTS=-Xms256m -Xmx512m -XX:+UseG1GC -XX:+UseStringDeduplication -Djava.awt.headless=true

REM Start the application
echo Starting server on port 5001...
java %JAVA_OPTS% -jar target\blynk-java-api-2.0.0.jar

echo Server stopped.
pause