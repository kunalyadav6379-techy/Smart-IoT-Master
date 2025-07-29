package com.blynk.service;

import com.blynk.model.PinData;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * High-performance Blynk service for managing virtual pins
 * Uses in-memory storage with periodic file persistence for speed
 */
@Slf4j
@Service
public class BlynkService {
    
    private static final String DATA_FILE = "blynk_data.json";
    private final Map<String, PinData> pins = new ConcurrentHashMap<>();
    private final ObjectMapper objectMapper = new ObjectMapper();
    
    public BlynkService() {
        loadData();
        log.info("BlynkService initialized with {} pins", pins.size());
    }
    
    /**
     * Load pin data from file (non-blocking)
     */
    private void loadData() {
        try {
            File file = new File(DATA_FILE);
            if (file.exists()) {
                Map<String, Object> data = objectMapper.readValue(file, Map.class);
                Map<String, Object> pinsData = (Map<String, Object>) data.get("pins");
                if (pinsData != null) {
                    pinsData.forEach((key, value) -> {
                        Map<String, Object> pinMap = (Map<String, Object>) value;
                        PinData pinData = new PinData(
                            (String) pinMap.get("value"),
                            ((Number) pinMap.get("timestamp")).doubleValue(),
                            (String) pinMap.get("datetime")
                        );
                        pins.put(key, pinData);
                    });
                }
                log.info("Loaded {} pins from {}", pins.size(), DATA_FILE);
            }
        } catch (Exception e) {
            log.error("Error loading data: {}", e.getMessage());
        }
    }
    
    /**
     * Save pin data to file (async, non-blocking)
     */
    public void saveData() {
        // Run in separate thread to avoid blocking API calls
        new Thread(() -> {
            try {
                Map<String, Object> data = new HashMap<>();
                data.put("pins", pins);
                data.put("last_updated", Instant.now().toString());
                
                objectMapper.writeValue(new File(DATA_FILE), data);
                log.debug("Data saved to {}", DATA_FILE);
            } catch (IOException e) {
                log.error("Error saving data: {}", e.getMessage());
            }
        }).start();
    }
    
    /**
     * Get virtual pin value (O(1) lookup)
     */
    public PinData getPinValue(int pin) {
        String key = "V" + pin;
        return pins.getOrDefault(key, new PinData("0"));
    }
    
    /**
     * Set virtual pin value (O(1) operation)
     */
    public void setPinValue(int pin, String value) {
        String key = "V" + pin;
        PinData pinData = new PinData(value);
        pins.put(key, pinData);
        
        // Async save to avoid blocking
        saveData();
        
        log.info("Pin {} set to {}", key, value);
    }
    
    /**
     * Get all pins (returns reference to concurrent map)
     */
    public Map<String, PinData> getAllPins() {
        return pins;
    }
    
    /**
     * Get pins count
     */
    public int getPinsCount() {
        return pins.size();
    }
}