#ifndef API_H
#define API_H

#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>
#include <ArduinoJson.h>

const char* server_ip = "1.1.1.1";
const int server_port = 5001;
WiFiClient wifiClient;
HTTPClient http;

void Send(int pin, int value) {
  String url = "http://" + String(server_ip) + ":" + String(server_port) + "/update/V" + String(pin) + "?value=" + String(value);

  http.begin(wifiClient, url);
  int httpCode = http.GET();

  if (httpCode > 0) {
    String response = http.getString();
  } else {
  }
  http.end();
}

String Read(int pin) {
  String url = "http://" + String(server_ip) + ":" + String(server_port) + "/pin/V" + String(pin);

  http.begin(wifiClient, url);
  int httpCode = http.GET();
  String value = "0";

  if (httpCode > 0) {
    String response = http.getString();

    // Parse JSON response
    DynamicJsonDocument doc(1024);
    deserializeJson(doc, response);
    value = doc["value"].as<String>();
  } else {
  }

  http.end();
  return value;
}

void SendPut(int pin, String value) {
  // Alternative method using PUT request
  String url = "http://" + String(server_ip) + ":" + String(server_port) + "/pin/V" + String(pin);

  http.begin(wifiClient, url);
  http.addHeader("Content-Type", "application/json");

  String jsonPayload = "{\"value\":\"" + value + "\"}";
  int httpCode = http.PUT(jsonPayload);

  if (httpCode > 0) {
    String response = http.getString();
  } else {
  }

  http.end();
}
#endif