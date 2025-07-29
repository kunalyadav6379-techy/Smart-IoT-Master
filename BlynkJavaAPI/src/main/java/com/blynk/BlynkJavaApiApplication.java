package com.blynk;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Blynk Java API Application
 * High-performance Blynk-like API server
 * 
 * @author Kiro AI Assistant
 * @version 2.0.0
 */
@SpringBootApplication
public class BlynkJavaApiApplication {

    public static void main(String[] args) {
        System.out.println("Starting Blynk Java API Server...");
        System.out.println("High-performance Java server that mimics Blynk's core functionality");
        System.out.println("Version: 2.0.0");
        System.out.println("Framework: Spring Boot");
        System.out.println();
        System.out.println("API Endpoints:");
        System.out.println("- Read pin: GET /pin/V{pin}");
        System.out.println("- Write pin: PUT /pin/V{pin}");
        System.out.println("- Update pin: GET /update/V{pin}?value={value}");
        System.out.println("- Get all pins: GET /pins");
        System.out.println("- Admin pins: GET /admin/pins");
        System.out.println("- CPU temperature: GET /cpu/temperature");
        System.out.println("- Health check: GET /actuator/health");
        System.out.println();
        System.out.println("Server starting on http://0.0.0.0:5001");
        
        SpringApplication.run(BlynkJavaApiApplication.class, args);
    }

    /**
     * Configure CORS to allow all origins
     */
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**")
                        .allowedOrigins("*")
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                        .allowedHeaders("*")
                        .allowCredentials(false);
            }
        };
    }
}