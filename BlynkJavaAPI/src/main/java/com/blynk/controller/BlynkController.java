package com.blynk.controller;

import com.blynk.model.*;
import com.blynk.service.BlynkService;
import com.blynk.service.CPUTemperatureService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

/**
 * High-performance Blynk API Controller
 * Optimized for minimal latency and maximum throughput
 */
@Slf4j
@RestController
@RequiredArgsConstructor
public class BlynkController {
    
    private final BlynkService blynkService;
    private final CPUTemperatureService cpuTemperatureService;
    
    /**
     * API status endpoint
     */
    @GetMapping("/")
    public ResponseEntity<Map<String, Object>> home() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "Blynk Java API Server Running");
        response.put("version", "2.0.0");
        response.put("framework", "Spring Boot");
        
        Map<String, String> endpoints = new HashMap<>();
        endpoints.put("read_pin", "GET /pin/V{pin}");
        endpoints.put("write_pin", "PUT /pin/V{pin}");
        endpoints.put("update_pin", "GET /update/V{pin}?value={value}");
        endpoints.put("get_all_pins", "GET /pins");
        endpoints.put("admin_pins", "GET /admin/pins");
        endpoints.put("cpu_temperature", "GET /cpu/temperature");
        endpoints.put("health", "GET /actuator/health");
        
        response.put("endpoints", endpoints);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Read virtual pin value (optimized for speed)
     */
    @GetMapping("/pin/V{pin}")
    public ResponseEntity<PinResponse> readPin(@PathVariable int pin) {
        try {
            PinData pinData = blynkService.getPinValue(pin);
            PinResponse response = new PinResponse(
                "V" + pin,
                pinData.getValue(),
                pinData.getTimestamp()
            );
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error reading pin V{}: {}", pin, e.getMessage());
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Write to virtual pin (optimized for speed)
     */
    @PutMapping("/pin/V{pin}")
    public ResponseEntity<UpdateResponse> writePin(
            @PathVariable int pin, 
            @RequestBody PinValue pinValue) {
        try {
            blynkService.setPinValue(pin, pinValue.getValue());
            
            UpdateResponse response = new UpdateResponse(
                "success",
                "V" + pin,
                pinValue.getValue(),
                Instant.now().toEpochMilli() / 1000.0
            );
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error writing pin V{}: {}", pin, e.getMessage());
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Update pin via GET request (optimized for speed)
     */
    @GetMapping("/update/V{pin}")
    public ResponseEntity<UpdateResponse> updatePinGet(
            @PathVariable int pin,
            @RequestParam(defaultValue = "0") String value) {
        try {
            blynkService.setPinValue(pin, value);
            
            UpdateResponse response = new UpdateResponse(
                "success",
                "V" + pin,
                value,
                Instant.now().toEpochMilli() / 1000.0
            );
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error updating pin V{}: {}", pin, e.getMessage());
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get all pins (fast concurrent access)
     */
    @GetMapping("/pins")
    public ResponseEntity<Map<String, Object>> getAllPins() {
        try {
            Map<String, Object> response = new HashMap<>();
            response.put("pins", blynkService.getAllPins());
            response.put("count", blynkService.getPinsCount());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting pins: {}", e.getMessage());
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Admin endpoint to list all pins
     */
    @GetMapping("/admin/pins")
    public ResponseEntity<Map<String, Object>> listAllPins() {
        try {
            Map<String, Object> response = new HashMap<>();
            response.put("pins", blynkService.getAllPins());
            response.put("total_pins", blynkService.getPinsCount());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error listing pins: {}", e.getMessage());
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get Raspberry Pi CPU temperature (optimized for speed)
     */
    @GetMapping("/cpu/temperature")
    public ResponseEntity<CPUTempResponse> getCpuTemperature() {
        try {
            double temperature = cpuTemperatureService.getCPUTemperature();
            String status = cpuTemperatureService.getTemperatureStatus(temperature);
            
            CPUTempResponse response = new CPUTempResponse(
                temperature,
                "°C",
                status,
                Instant.now().toEpochMilli() / 1000.0
            );
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting CPU temperature: {}", e.getMessage());
            return ResponseEntity.internalServerError().build();
        }
    }
}