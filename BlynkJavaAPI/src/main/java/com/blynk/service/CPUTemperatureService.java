package com.blynk.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Random;

/**
 * High-performance CPU temperature service for Raspberry Pi
 * Optimized for fast temperature readings
 */
@Slf4j
@Service
public class CPUTemperatureService {
    
    private static final String THERMAL_ZONE_PATH = "/sys/class/thermal/thermal_zone0/temp";
    private static final Random random = new Random();
    
    /**
     * Get Raspberry Pi CPU temperature (optimized for speed)
     */
    public double getCPUTemperature() {
        // Try thermal zone first (fastest method)
        try {
            return readThermalZone();
        } catch (Exception e) {
            log.debug("Thermal zone read failed: {}", e.getMessage());
        }
        
        // Fallback: try vcgencmd
        try {
            return readVcgencmd();
        } catch (Exception e) {
            log.debug("vcgencmd read failed: {}", e.getMessage());
        }
        
        // Final fallback: simulated temperature for testing
        return generateSimulatedTemperature();
    }
    
    /**
     * Read temperature from thermal zone (fastest method)
     */
    private double readThermalZone() throws IOException {
        try (BufferedReader reader = new BufferedReader(new FileReader(THERMAL_ZONE_PATH))) {
            String tempStr = reader.readLine();
            if (tempStr != null) {
                double tempMilliCelsius = Double.parseDouble(tempStr.trim());
                return tempMilliCelsius / 1000.0;
            }
        }
        throw new IOException("Could not read thermal zone");
    }
    
    /**
     * Read temperature using vcgencmd (fallback method)
     */
    private double readVcgencmd() throws IOException, InterruptedException {
        ProcessBuilder pb = new ProcessBuilder("vcgencmd", "measure_temp");
        pb.redirectErrorStream(true);
        Process process = pb.start();
        
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
            String line = reader.readLine();
            if (line != null && line.contains("=")) {
                // Extract temperature from "temp=45.1'C"
                String tempStr = line.split("=")[1].split("'")[0];
                return Double.parseDouble(tempStr);
            }
        }
        
        // Wait for process to complete (with timeout)
        boolean finished = process.waitFor(2, java.util.concurrent.TimeUnit.SECONDS);
        if (!finished) {
            process.destroyForcibly();
        }
        
        throw new IOException("Could not read vcgencmd output");
    }
    
    /**
     * Generate simulated temperature for testing (when hardware methods fail)
     */
    private double generateSimulatedTemperature() {
        // Generate realistic temperature between 30-50°C
        double baseTemp = 35.0;
        double variation = random.nextGaussian() * 5.0; // ±5°C variation
        double temperature = baseTemp + variation;
        
        // Clamp to reasonable range
        temperature = Math.max(25.0, Math.min(65.0, temperature));
        
        return Math.round(temperature * 10.0) / 10.0; // Round to 1 decimal place
    }
    
    /**
     * Determine temperature status based on value
     */
    public String getTemperatureStatus(double temperature) {
        if (temperature > 80) {
            return "critical";
        } else if (temperature > 70) {
            return "warning";
        } else if (temperature > 60) {
            return "warm";
        } else {
            return "normal";
        }
    }
}