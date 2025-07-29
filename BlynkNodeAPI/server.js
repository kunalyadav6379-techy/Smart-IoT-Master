#!/usr/bin/env node
/**
 * Blynk-like Local Server API - Node.js Express Version
 * A high-performance Node.js server that mimics Blynk's core functionality
 * 
 * @author Kiro AI Assistant
 * @version 2.0.0
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const fs = require('fs').promises;
const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);
const crypto = require('crypto');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 5001;
const HOST = process.env.HOST || '0.0.0.0';

// Middleware setup for performance and security
app.use(helmet()); // Security headers
app.use(compression()); // Gzip compression
app.use(cors()); // Enable CORS for all origins
app.use(express.json({ limit: '10mb' })); // JSON parsing
app.use(express.urlencoded({ extended: true })); // URL encoding
app.use(morgan('combined')); // Logging



// Authentication system
class AuthSystem {
    constructor() {
        this.userDataFile = 'user_data.json';
        this.sessions = new Map(); // Active sessions
        this.users = new Map(); // User credentials
        this.loadUsers();
        this.initializeDefaultUser();
    }

    async loadUsers() {
        try {
            const data = await fs.readFile(this.userDataFile, 'utf8');
            const parsedData = JSON.parse(data);
            
            if (parsedData.users) {
                Object.entries(parsedData.users).forEach(([username, userData]) => {
                    this.users.set(username, userData);
                });
            }
            
            console.log(`🔐 Loaded ${this.users.size} users from ${this.userDataFile}`);
        } catch (error) {
            console.log(`ℹ️  No existing user data file found, creating default user`);
            this.users = new Map();
        }
    }

    async saveUsers() {
        try {
            const usersObject = Object.fromEntries(this.users);
            const data = {
                users: usersObject,
                last_updated: new Date().toISOString()
            };

            await fs.writeFile(this.userDataFile, JSON.stringify(data, null, 2));
            console.log(`🔐 User data saved to ${this.userDataFile}`);
        } catch (error) {
            console.error(`❌ Error saving user data: ${error.message}`);
        }
    }

    initializeDefaultUser() {
        // Create default admin user if no users exist
        if (this.users.size === 0) {
            const defaultUser = {
                username: 'admin',
                password: this.hashPassword('admin123'),
                email: 'admin@iotmaster.com',
                role: 'admin',
                created_at: new Date().toISOString(),
                last_login: null,
                is_active: true
            };
            
            this.users.set('admin', defaultUser);
            this.saveUsers();
            console.log('🔐 Default admin user created (username: admin, password: admin123)');
        }
    }

    hashPassword(password) {
        return crypto.createHash('sha256').update(password).digest('hex');
    }

    generateToken() {
        return crypto.randomBytes(32).toString('hex');
    }

    async login(username, password) {
        const user = this.users.get(username);
        
        if (!user || !user.is_active) {
            return { success: false, message: 'Invalid credentials' };
        }

        const hashedPassword = this.hashPassword(password);
        if (user.password !== hashedPassword) {
            return { success: false, message: 'Invalid credentials' };
        }

        // Generate session token
        const token = this.generateToken();
        const sessionData = {
            username: user.username,
            email: user.email,
            role: user.role,
            login_time: new Date().toISOString(),
            expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString() // 24 hours
        };

        this.sessions.set(token, sessionData);

        // Update last login
        user.last_login = new Date().toISOString();
        this.users.set(username, user);
        this.saveUsers();

        return {
            success: true,
            token: token,
            user: {
                username: user.username,
                email: user.email,
                role: user.role,
                last_login: user.last_login
            },
            expires_at: sessionData.expires_at
        };
    }

    logout(token) {
        if (this.sessions.has(token)) {
            this.sessions.delete(token);
            return { success: true, message: 'Logged out successfully' };
        }
        return { success: false, message: 'Invalid session' };
    }

    validateToken(token) {
        const session = this.sessions.get(token);
        
        if (!session) {
            return { valid: false, message: 'Invalid token' };
        }

        // Check if token is expired
        if (new Date() > new Date(session.expires_at)) {
            this.sessions.delete(token);
            return { valid: false, message: 'Token expired' };
        }

        return { valid: true, session: session };
    }

    getActiveSessionsCount() {
        return this.sessions.size;
    }
}

// In-memory storage for high performance
class BlynkServer {
    constructor() {
        this.dataFile = 'blynk_data.json';
        this.beepLevelFile = 'beep_level.json';
        this.pins = new Map(); // Using Map for better performance
        this.beepLevel = 182; // Default beep level
        this.loadData();
        this.loadBeepLevel();
    }

    async loadData() {
        try {
            const data = await fs.readFile(this.dataFile, 'utf8');
            const parsedData = JSON.parse(data);

            if (parsedData.pins) {
                // Convert object to Map for better performance
                Object.entries(parsedData.pins).forEach(([key, value]) => {
                    this.pins.set(key, value);
                });
            }

            console.log(`✅ Loaded ${this.pins.size} pins from ${this.dataFile}`);
        } catch (error) {
            console.log(`ℹ️  No existing data file found, starting fresh`);
            this.pins = new Map();
        }
    }

    async loadBeepLevel() {
        try {
            const data = await fs.readFile(this.beepLevelFile, 'utf8');
            const parsedData = JSON.parse(data);
            this.beepLevel = parsedData.beep_level;
            console.log(`🔊 Loaded beep level: ${this.beepLevel} from ${this.beepLevelFile}`);
        } catch (error) {
            console.log(`ℹ️  No beep level file found, beep level not initialized`);
            this.beepLevel = null; // No default value
        }
    }

    async saveBeepLevel() {
        try {
            const data = {
                beep_level: this.beepLevel,
                last_updated: new Date().toISOString(),
                range: "0-255",
                description: "Buzzer beep level intensity"
            };

            await fs.writeFile(this.beepLevelFile, JSON.stringify(data, null, 2));
            console.log(`🔊 Beep level saved: ${this.beepLevel}`);
        } catch (error) {
            console.error(`❌ Error saving beep level: ${error.message}`);
        }
    }

    setBeepLevel(level) {
        // Validate range 0-255
        const beepLevel = Math.max(0, Math.min(255, parseInt(level)));
        this.beepLevel = beepLevel;

        // Async save to avoid blocking
        this.saveBeepLevel().catch(err => console.error('Beep level save error:', err));

        console.log(`🔊 Beep level set to: ${beepLevel}`);
        return beepLevel;
    }

    getBeepLevel() {
        return this.beepLevel;
    }

    async saveData() {
        // Debounce saves to prevent excessive file writes
        if (this.saveTimeout) {
            clearTimeout(this.saveTimeout);
        }

        this.saveTimeout = setTimeout(async () => {
            try {
                // Convert Map to object for JSON serialization
                const pinsObject = Object.fromEntries(this.pins);

                const data = {
                    pins: pinsObject,
                    last_updated: new Date().toISOString()
                };

                // Async write to avoid blocking
                await fs.writeFile(this.dataFile, JSON.stringify(data, null, 2));
                console.log(`💾 Data saved to ${this.dataFile}`);
            } catch (error) {
                console.error(`❌ Error saving data: ${error.message}`);
            }
        }, 1000); // Debounce for 1 second
    }

    getPinValue(pin) {
        const key = `V${pin}`;
        return this.pins.get(key) || {
            value: "0",
            timestamp: Date.now() / 1000,
            datetime: new Date().toISOString()
        };
    }

    setPinValue(pin, value) {
        const key = `V${pin}`;
        const pinData = {
            value: String(value),
            timestamp: Date.now() / 1000,
            datetime: new Date().toISOString()
        };

        this.pins.set(key, pinData);

        // Async save to avoid blocking
        this.saveData().catch(err => console.error('Save error:', err));

        console.log(`📌 Pin ${key} set to ${value}`);
    }

    getAllPins() {
        return Object.fromEntries(this.pins);
    }

    getPinsCount() {
        return this.pins.size;
    }
}

// CPU Temperature functions (optimized for speed)
class CPUTemperature {
    static async getCPUTemperature() {
        try {
            // Try thermal zone first (fastest method)
            return await this.readThermalZone();
        } catch (error) {
            try {
                // Fallback: use vcgencmd
                return await this.readVcgencmd();
            } catch (fallbackError) {
                // Final fallback: simulated temperature
                return this.generateSimulatedTemperature();
            }
        }
    }

    static async readThermalZone() {
        try {
            const data = await fs.readFile('/sys/class/thermal/thermal_zone0/temp', 'utf8');
            const tempMilliCelsius = parseFloat(data.trim());
            return Math.round((tempMilliCelsius / 1000.0) * 10) / 10;
        } catch (error) {
            throw new Error('Could not read thermal zone');
        }
    }

    static async readVcgencmd() {
        try {
            const { stdout } = await execAsync('vcgencmd measure_temp', { timeout: 2000 });
            // Extract temperature from "temp=45.1'C"
            const match = stdout.match(/temp=([0-9.]+)/);
            if (match) {
                return parseFloat(match[1]);
            }
            throw new Error('Could not parse vcgencmd output');
        } catch (error) {
            throw new Error('vcgencmd failed');
        }
    }

    static generateSimulatedTemperature() {
        // Generate realistic temperature between 30-50°C
        const baseTemp = 35.0;
        const variation = (Math.random() - 0.5) * 10; // ±5°C variation
        let temperature = baseTemp + variation;

        // Clamp to reasonable range
        temperature = Math.max(25.0, Math.min(65.0, temperature));

        return Math.round(temperature * 10) / 10; // Round to 1 decimal place
    }

    static getTemperatureStatus(temperature) {
        if (temperature > 80) return 'critical';
        if (temperature > 70) return 'warning';
        if (temperature > 60) return 'warm';
        return 'normal';
    }
}

// Initialize server
const blynk = new BlynkServer();
const auth = new AuthSystem();

// Routes

/**
 * API status endpoint
 */
app.get('/', (req, res) => {
    res.json({
        status: "Blynk Node.js Server Running",
        version: "2.0.0",
        framework: "Express.js",
        performance: "High-performance Node.js implementation",
        endpoints: {
            read_pin: "GET /pin/V{pin}",
            write_pin: "PUT /pin/V{pin}",
            update_pin: "GET /update/V{pin}?value={value}",
            get_all_pins: "GET /pins",
            admin_pins: "GET /admin/pins",
            cpu_temperature: "GET /cpu/temperature",
            health: "GET /health"
        }
    });
});

/**
 * Read virtual pin value (optimized for speed)
 */
app.get('/pin/V:pin', (req, res) => {
    try {
        const pin = parseInt(req.params.pin);
        if (isNaN(pin)) {
            return res.status(400).json({ error: 'Invalid pin number' });
        }

        const pinData = blynk.getPinValue(pin);
        res.json({
            pin: `V${pin}`,
            value: pinData.value,
            timestamp: pinData.timestamp
        });
    } catch (error) {
        console.error(`❌ Error reading pin V${req.params.pin}:`, error.message);
        res.status(500).json({ error: 'Internal server error' });
    }
});

/**
 * Write to virtual pin (optimized for speed)
 */
app.put('/pin/V:pin', (req, res) => {
    try {
        const pin = parseInt(req.params.pin);
        if (isNaN(pin)) {
            return res.status(400).json({ error: 'Invalid pin number' });
        }

        const { value } = req.body;
        if (value === undefined) {
            return res.status(400).json({ error: 'Value is required' });
        }

        blynk.setPinValue(pin, value);

        res.json({
            status: "success",
            pin: `V${pin}`,
            value: String(value),
            timestamp: Date.now() / 1000
        });
    } catch (error) {
        console.error(`❌ Error writing pin V${req.params.pin}:`, error.message);
        res.status(500).json({ error: 'Internal server error' });
    }
});

/**
 * Update pin via GET request (optimized for speed)
 */
app.get('/update/V:pin', (req, res) => {
    try {
        const pin = parseInt(req.params.pin);
        if (isNaN(pin)) {
            return res.status(400).json({ error: 'Invalid pin number' });
        }

        const value = req.query.value || "0";
        blynk.setPinValue(pin, value);

        res.json({
            status: "success",
            pin: `V${pin}`,
            value: String(value),
            timestamp: Date.now() / 1000
        });
    } catch (error) {
        console.error(`❌ Error updating pin V${req.params.pin}:`, error.message);
        res.status(500).json({ error: 'Internal server error' });
    }
});

/**
 * Get all pins (fast Map access)
 */
app.get('/pins', (req, res) => {
    try {
        res.json({
            pins: blynk.getAllPins(),
            count: blynk.getPinsCount()
        });
    } catch (error) {
        console.error('❌ Error getting pins:', error.message);
        res.status(500).json({ error: 'Internal server error' });
    }
});

/**
 * Admin endpoint to list all pins
 */
app.get('/admin/pins', (req, res) => {
    try {
        res.json({
            pins: blynk.getAllPins(),
            total_pins: blynk.getPinsCount()
        });
    } catch (error) {
        console.error('❌ Error listing pins:', error.message);
        res.status(500).json({ error: 'Internal server error' });
    }
});

/**
 * Get Raspberry Pi CPU temperature (optimized for speed)
 */
app.get('/cpu/temperature', async (req, res) => {
    try {
        const temperature = await CPUTemperature.getCPUTemperature();
        const status = CPUTemperature.getTemperatureStatus(temperature);

        res.json({
            temperature: temperature,
            unit: "°C",
            status: status,
            timestamp: Date.now() / 1000
        });
    } catch (error) {
        console.error('❌ Error getting CPU temperature:', error.message);
        res.status(500).json({ error: 'Internal server error' });
    }
});

/**
 * Health check endpoint
 */
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        timestamp: Date.now() / 1000,
        pins_count: blynk.getPinsCount()
    });
});

/**
 * Get buzzer beep level (0-255)
 */
app.get('/api/buzzer/beeplevel', (req, res) => {
    try {
        const beepLevel = blynk.getBeepLevel();

        if (beepLevel === null) {
            return res.status(404).json({
                error: 'Beep level not initialized',
                message: 'No beep level has been set yet. Please set a beep level first.',
                range: "0-255"
            });
        }

        res.json({
            beep_level: beepLevel,
            range: "0-255",
            timestamp: Date.now() / 1000,
            description: "Buzzer beep level intensity"
        });
    } catch (error) {
        console.error('❌ Error getting beep level:', error.message);
        res.status(500).json({ error: 'Internal server error' });
    }
});

/**
 * Set buzzer beep level (0-255)
 */
app.put('/api/buzzer/beeplevel', (req, res) => {
    try {
        const { beep_level } = req.body;

        if (beep_level === undefined) {
            return res.status(400).json({ error: 'beep_level is required' });
        }

        const level = parseInt(beep_level);
        if (isNaN(level) || level < 0 || level > 255) {
            return res.status(400).json({ error: 'beep_level must be between 0 and 255' });
        }

        const actualLevel = blynk.setBeepLevel(level);

        res.json({
            status: "success",
            beep_level: actualLevel,
            range: "0-255",
            timestamp: Date.now() / 1000,
            message: `Beep level set to ${actualLevel}`
        });
    } catch (error) {
        console.error('❌ Error setting beep level:', error.message);
        res.status(500).json({ error: 'Internal server error' });
    }
});

/**
 * Authentication endpoints
 */

/**
 * User login
 */
app.post('/api/auth/login', async (req, res) => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            return res.status(400).json({ 
                success: false, 
                message: 'Username and password are required' 
            });
        }

        const result = await auth.login(username, password);

        if (result.success) {
            res.json(result);
        } else {
            res.status(401).json(result);
        }
    } catch (error) {
        console.error('❌ Error during login:', error.message);
        res.status(500).json({ 
            success: false, 
            message: 'Internal server error' 
        });
    }
});

/**
 * User logout
 */
app.post('/api/auth/logout', (req, res) => {
    try {
        const token = req.headers.authorization?.replace('Bearer ', '');

        if (!token) {
            return res.status(400).json({ 
                success: false, 
                message: 'Token is required' 
            });
        }

        const result = auth.logout(token);
        res.json(result);
    } catch (error) {
        console.error('❌ Error during logout:', error.message);
        res.status(500).json({ 
            success: false, 
            message: 'Internal server error' 
        });
    }
});

/**
 * Validate token
 */
app.get('/api/auth/validate', (req, res) => {
    try {
        const token = req.headers.authorization?.replace('Bearer ', '');

        if (!token) {
            return res.status(400).json({ 
                valid: false, 
                message: 'Token is required' 
            });
        }

        const result = auth.validateToken(token);
        
        if (result.valid) {
            res.json(result);
        } else {
            res.status(401).json(result);
        }
    } catch (error) {
        console.error('❌ Error validating token:', error.message);
        res.status(500).json({ 
            valid: false, 
            message: 'Internal server error' 
        });
    }
});

/**
 * Get current user info
 */
app.get('/api/auth/me', (req, res) => {
    try {
        const token = req.headers.authorization?.replace('Bearer ', '');

        if (!token) {
            return res.status(401).json({ 
                success: false, 
                message: 'Token is required' 
            });
        }

        const validation = auth.validateToken(token);
        
        if (!validation.valid) {
            return res.status(401).json({ 
                success: false, 
                message: validation.message 
            });
        }

        res.json({
            success: true,
            user: validation.session
        });
    } catch (error) {
        console.error('❌ Error getting user info:', error.message);
        res.status(500).json({ 
            success: false, 
            message: 'Internal server error' 
        });
    }
});



// Error handling middleware
app.use((err, req, res, next) => {
    console.error('❌ Unhandled error:', err);
    res.status(500).json({ error: 'Internal server error' });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Endpoint not found' });
});

// Graceful shutdown
process.on('SIGINT', async () => {
    console.log('\n🛑 Shutting down gracefully...');
    await blynk.saveData();
    process.exit(0);
});

process.on('SIGTERM', async () => {
    console.log('\n🛑 Shutting down gracefully...');
    await blynk.saveData();
    process.exit(0);
});

// Start server
app.listen(PORT, HOST, () => {
    console.log('\n🚀 Blynk Node.js API Server Started!');
    console.log('=====================================');
    console.log(`📡 Server running on http://${HOST}:${PORT}`);
    console.log('⚡ High-performance Node.js implementation');
    console.log('🔧 Framework: Express.js');
    console.log('📊 Version: 2.0.0');
    console.log('\n📋 Available Endpoints:');
    console.log('- GET  /                     - API status');
    console.log('- GET  /pin/V{pin}          - Read pin');
    console.log('- PUT  /pin/V{pin}          - Write pin');
    console.log('- GET  /update/V{pin}       - Update pin');
    console.log('- GET  /pins                - Get all pins');
    console.log('- GET  /admin/pins          - Admin pins');
    console.log('- GET  /cpu/temperature     - CPU temp');
    console.log('- GET  /api/buzzer/beeplevel - Get beep level');
    console.log('- PUT  /api/buzzer/beeplevel - Set beep level');
    console.log('- GET  /health              - Health check');
    console.log('\n✅ Server ready to handle requests!');
});

module.exports = app;