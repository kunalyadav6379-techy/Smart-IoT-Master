package com.blynk.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

/**
 * Pin data model for storing virtual pin values
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PinData {
    
    @JsonProperty("value")
    private String value;
    
    @JsonProperty("timestamp")
    private double timestamp;
    
    @JsonProperty("datetime")
    private String datetime;
    
    public PinData(String value) {
        this.value = value;
        this.timestamp = Instant.now().toEpochMilli() / 1000.0;
        this.datetime = Instant.now().toString();
    }
}