@echo off
REM Blynk Node.js API Startup Script for Windows
REM High-performance Node.js server optimized for IoT applications

echo 🚀 Starting Blynk Node.js API Server...
echo ========================================

REM Check if Node.js is installed
node -v >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: Node.js is not installed or not in PATH
    echo 📦 Please install Node.js 16 or higher
    echo 🔗 Visit: https://nodejs.org/
    pause
    exit /b 1
)

REM Check if npm is installed
npm -v >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: npm is not installed
    echo 📦 Please install npm
    pause
    exit /b 1
)

REM Install dependencies if node_modules doesn't exist
if not exist "node_modules" (
    echo 📦 Installing dependencies...
    npm install
    if %errorlevel% neq 0 (
        echo ❌ Error: Failed to install dependencies
        pause
        exit /b 1
    )
)

REM Set environment variables for optimal performance
set NODE_ENV=production
set UV_THREADPOOL_SIZE=128

REM Start the application
echo 🌟 Starting server on port 5001...
echo ⚡ Performance mode: High-speed Node.js
echo 🔧 Framework: Express.js
echo.

node server.js

echo 🛑 Server stopped.
pause