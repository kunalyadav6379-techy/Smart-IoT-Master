package com.blynk.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response model for pin update operations
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateResponse {
    
    @JsonProperty("status")
    private String status;
    
    @JsonProperty("pin")
    private String pin;
    
    @JsonProperty("value")
    private String value;
    
    @JsonProperty("timestamp")
    private double timestamp;
}