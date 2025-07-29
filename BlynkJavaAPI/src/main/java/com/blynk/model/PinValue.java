package com.blynk.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request model for pin value updates
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PinValue {
    
    @JsonProperty("value")
    private String value;
}