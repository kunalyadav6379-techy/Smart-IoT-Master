#ifndef WIFI_SETUP_H
#define WIFI_SETUP_H

#include "config.h"

void wifiSetup() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(SSID, PASS);
  while (WiFi.status() != WL_CONNECTED) {
    beepBuzzer();
  }
}

#endif