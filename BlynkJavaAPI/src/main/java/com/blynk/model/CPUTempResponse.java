package com.blynk.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response model for CPU temperature operations
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CPUTempResponse {
    
    @JsonProperty("temperature")
    private double temperature;
    
    @JsonProperty("unit")
    private String unit;
    
    @JsonProperty("status")
    private String status;
    
    @JsonProperty("timestamp")
    private double timestamp;
}