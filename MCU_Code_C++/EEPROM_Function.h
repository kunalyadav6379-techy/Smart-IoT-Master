#ifndef EEPROM_FUNCTION_H
#define EEPROM_FUNCTION_H

#include <ESP_EEPROM.h>
#include "API.h"
#include "config.h"

void fetchValue()
{
  String s = Read(trigger);
  if(s == "0")
  {
    triggerValue = 0;
  }

  if(s == "33")
  {
    triggerValue = 33;
  }

  if(s == "66")
  {
    triggerValue = 66;
  }
}

void EEPROM_Setup()
{
  EEPROM.begin(512);
}

void Handle_EEPROM()
{
  fetchValue();
  if(triggerValue == 33 || triggerValue == 66 || triggerValue == 0)
  {
    EEPROM.put(triggerAddr , triggerValue);
    EEPROM.commit();
  }
}

int triggVal()
{
  int x = EEPROM.read(triggerAddr);
  return x;
}

#endif