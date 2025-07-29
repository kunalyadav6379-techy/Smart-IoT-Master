#!/bin/bash

# Blynk Node.js API Startup Script
# High-performance Node.js server optimized for IoT applications

echo "🚀 Starting Blynk Node.js API Server..."
echo "========================================"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is not installed or not in PATH"
    echo "📦 Please install Node.js 16 or higher"
    echo "🔗 Visit: https://nodejs.org/"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    echo "❌ Error: Node.js 16 or higher is required"
    echo "📊 Current version: $(node -v)"
    echo "🔗 Please update Node.js"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ Error: npm is not installed"
    echo "📦 Please install npm"
    exit 1
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Error: Failed to install dependencies"
        exit 1
    fi
fi

# Set environment variables for optimal performance
export NODE_ENV=production
export UV_THREADPOOL_SIZE=128

# Start the application
echo "🌟 Starting server on port 5001..."
echo "⚡ Performance mode: High-speed Node.js"
echo "🔧 Framework: Express.js"
echo ""

node server.js

echo "🛑 Server stopped."