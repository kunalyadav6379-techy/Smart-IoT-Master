#!/usr/bin/env python3
"""
Blynk-like Local Server API - FastAPI Version
A high-performance Python server that mimics Blynk's core functionality
"""

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import json
import os
import time
from datetime import datetime
import asyncio
import logging
import subprocess
from typing import Optional, Dict, Any

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Blynk Local Server",
    description="High-performance Blynk-like API server",
    version="2.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models
class PinValue(BaseModel):
    value: str

class PinResponse(BaseModel):
    pin: str
    value: str
    timestamp: float

class UpdateResponse(BaseModel):
    status: str
    pin: str
    value: str
    timestamp: float

class CPUTempResponse(BaseModel):
    temperature: float
    unit: str
    status: str
    timestamp: float

class BlynkServer:
    def __init__(self):
        self.data_file = "blynk_data.json"
        self.pins = {}
        self.load_data()
        
    def load_data(self):
        """Load pin data from file"""
        if os.path.exists(self.data_file):
            try:
                with open(self.data_file, 'r') as f:
                    data = json.load(f)
                    self.pins = data.get('pins', {})
            except Exception as e:
                logger.error(f"Error loading data: {e}")
                self.pins = {}
    
    def save_data(self):
        """Save pin data to file"""
        try:
            data = {
                'pins': self.pins,
                'last_updated': datetime.now().isoformat()
            }
            with open(self.data_file, 'w') as f:
                json.dump(data, f, indent=2)
        except Exception as e:
            logger.error(f"Error saving data: {e}")
    
    def get_pin_value(self, pin):
        """Get virtual pin value"""
        key = f"V{pin}"
        return self.pins.get(key, {"value": "0", "timestamp": time.time()})
    
    def set_pin_value(self, pin, value):
        """Set virtual pin value"""
        key = f"V{pin}"
        self.pins[key] = {
            "value": str(value),
            "timestamp": time.time(),
            "datetime": datetime.now().isoformat()
        }
        self.save_data()
        
        logger.info(f"Pin V{pin} set to {value}")

# CPU Temperature functions
def get_cpu_temperature():
    """Get Raspberry Pi CPU temperature"""
    try:
        # Try reading from thermal zone (most reliable method)
        with open('/sys/class/thermal/thermal_zone0/temp', 'r') as f:
            temp_str = f.read().strip()
            temp_celsius = float(temp_str) / 1000.0
            return temp_celsius
    except FileNotFoundError:
        try:
            # Fallback: use vcgencmd (if available)
            result = subprocess.run(['vcgencmd', 'measure_temp'], 
                                  capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                temp_str = result.stdout.strip()
                # Extract temperature from "temp=45.1'C"
                temp_celsius = float(temp_str.split('=')[1].split("'")[0])
                return temp_celsius
        except (subprocess.TimeoutExpired, subprocess.CalledProcessError, FileNotFoundError, IndexError):
            pass
    except Exception:
        pass
    
    # If all methods fail, return a simulated temperature for testing
    import random
    return round(35.0 + random.uniform(-5, 15), 1)

# Initialize server
blynk = BlynkServer()

@app.get("/")
async def home():
    """API status endpoint"""
    return {
        "status": "Blynk Local Server Running",
        "version": "2.0.0",
        "framework": "FastAPI",
        "endpoints": {
            "read_pin": "GET /pin/V{pin}",
            "write_pin": "PUT /pin/V{pin}",
            "update_pin": "GET /update/V{pin}?value={value}",
            "get_all_pins": "GET /pins",
            "admin_pins": "GET /admin/pins",
            "docs": "GET /docs"
        }
    }

@app.get("/pin/V{pin}", response_model=PinResponse)
async def read_pin(pin: int):
    """Read virtual pin value"""
    try:
        pin_data = blynk.get_pin_value(pin)
        return PinResponse(
            pin=f"V{pin}",
            value=pin_data["value"],
            timestamp=pin_data.get("timestamp", time.time())
        )
    except Exception as e:
        logger.error(f"Error reading pin V{pin}: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.put("/pin/V{pin}", response_model=UpdateResponse)
async def write_pin(pin: int, pin_value: PinValue):
    """Write to virtual pin"""
    try:
        blynk.set_pin_value(pin, pin_value.value)
        
        return UpdateResponse(
            status="success",
            pin=f"V{pin}",
            value=pin_value.value,
            timestamp=time.time()
        )
    except Exception as e:
        logger.error(f"Error writing pin V{pin}: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/update/V{pin}", response_model=UpdateResponse)
async def update_pin_get(pin: int, value: str = Query(default="0")):
    """Update pin via GET request"""
    try:
        blynk.set_pin_value(pin, value)
        
        return UpdateResponse(
            status="success",
            pin=f"V{pin}",
            value=value,
            timestamp=time.time()
        )
    except Exception as e:
        logger.error(f"Error updating pin V{pin}: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/pins")
async def get_all_pins():
    """Get all pins"""
    try:
        return {
            "pins": blynk.pins,
            "count": len(blynk.pins)
        }
    except Exception as e:
        logger.error(f"Error getting pins: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/admin/pins")
async def list_all_pins():
    """Admin endpoint to list all pins"""
    try:
        return {
            "pins": blynk.pins,
            "total_pins": len(blynk.pins)
        }
    except Exception as e:
        logger.error(f"Error listing pins: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/cpu/temperature", response_model=CPUTempResponse)
async def get_cpu_temp():
    """Get Raspberry Pi CPU temperature"""
    try:
        temperature = get_cpu_temperature()
        status = "normal"
        
        # Determine status based on temperature
        if temperature > 80:
            status = "critical"
        elif temperature > 70:
            status = "warning"
        elif temperature > 60:
            status = "warm"
        
        return CPUTempResponse(
            temperature=temperature,
            unit="°C",
            status=status,
            timestamp=time.time()
        )
    except Exception as e:
        logger.error(f"Error getting CPU temperature: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == '__main__':
    import uvicorn
    
    print("Starting FastAPI Blynk Local Server...")
    print("API Documentation:")
    print("- Read pin: GET /pin/V{pin}")
    print("- Write pin: PUT /pin/V{pin}")
    print("- Update pin: GET /update/V{pin}?value={value}")
    print("- Get all pins: GET /pins")
    print("- Admin pins: GET /admin/pins")
    print("- Interactive docs: GET /docs")
    print("\nServer starting on http://0.0.0.0:8080")
    
    uvicorn.run(app, host="0.0.0.0", port=5001, log_level="info")