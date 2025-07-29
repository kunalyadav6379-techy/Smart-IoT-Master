#ifndef OTA_SETUP_H
#define OTA_SETUP_H

#include <ESP8266WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ElegantOTA.h>
#include "config.h"

AsyncWebServer server(80);

void otaSetup() {
  ElegantOTA.begin(&server);
  server.begin();
}

void handleOTA() {
  ElegantOTA.loop();
}

#endif