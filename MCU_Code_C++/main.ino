#include "OTA_Setup.h"
#include "WiFi_Setup.h"
#include "Mdns_Setup.h"
#include "EEPROM_Function.h"
#include "Level_Checker.h"

void setup()
{
  pinConfig();
  EEPROM_Setup();
  wifiSetup();
  setupMDNS();
  otaSetup();
}

void loop()
{
  handleMDNS();
  handleOTA();
  Handle_EEPROM();
  checkLevel();
  assign_Val();
  Send(waterTank, currentLevel);
  Send(Pin_D5,digitalRead(D5));
  Send(Pin_D6,digitalRead(D6));
  Send(Pin_D7,digitalRead(D7));
}

