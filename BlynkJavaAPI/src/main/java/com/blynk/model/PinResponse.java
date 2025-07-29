package com.blynk.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response model for pin read operations
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PinResponse {
    
    @JsonProperty("pin")
    private String pin;
    
    @JsonProperty("value")
    private String value;
    
    @JsonProperty("timestamp")
    private double timestamp;
}