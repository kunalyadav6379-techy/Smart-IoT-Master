#ifndef LEVEL_CHECKER_H
#define LEVEL_CHECKER_H

#include "config.h"
#include "EEPROM_Function.h"
#include "API.h"
bool timer_begin = false;

void levelPins() {
  Level_100 = digitalRead(level_100);
  Level_66 = digitalRead(level_66);
  Level_33 = digitalRead(level_33);
}

void assign_Val() {
  if (currentLevel == 0) {
    Send(buzzer, 1);
    timer_begin = true;
  }

  if (currentLevel == 33) {
    if (triggVal() == 33) {
      Send(buzzer, 1);
      timer_begin = true;
    }
    timer_begin = true;
  }

  if (currentLevel == 66) {
    if (triggVal() == 66) {
      Send(buzzer, 1);
      timer_begin = true;
    }
    timer_begin = true;
  }

  if (currentLevel == 100) {
    Send(Pin_D5,digitalRead(D5));
    if (timer_begin) {
      startTime = millis();
      while (millis() - startTime <= triggerTime) {
        // Blynk.run();
        // timer.run();
      }
      timer_begin = false;
      startTime = 0;
    }
    Send(buzzer, 0);
    timer_begin = false;
  }
}

void checkLevel() {
back:
  levelPins();
  if (Level_100 == true && Level_66 == true && Level_33 == true) {
    bool success = false;
    for (int i = 1; i <= 20; i++) {
      if (digitalRead(level_100) == true && digitalRead(level_66) == true && digitalRead(level_33) == true) {
        delay(100);
        success = true;
      }

      else {
        success = false;
        break;
      }
    }

    if (success) {
      currentLevel = 100;
    }

    if (!success) {
      goto back;
    }
  }

  if (Level_100 == false && Level_66 == true && Level_33 == true) {
    bool success = false;
    for (int i = 1; i <= 20; i++) {
      if (digitalRead(level_100) == false && digitalRead(level_66) == true && digitalRead(level_33) == true) {
        delay(100);
        success = true;
      }

      else {
        success = false;
        break;
      }
    }

    if (success) {
      currentLevel = 66;
    }

    if (!success) {
      goto back;
    }
  }

  if (Level_100 == false && Level_66 == false && Level_33 == true) {
    bool success = false;
    for (int i = 1; i <= 20; i++) {
      if (digitalRead(level_100) == false && digitalRead(level_66) == false && digitalRead(level_33) == true) {
        delay(100);
        success = true;
      }

      else {
        success = false;
        break;
      }
    }

    if (success) {
      currentLevel = 33;
    }

    if (!success) {
      goto back;
    }
  }

  if (Level_100 == false && Level_66 == false && Level_33 == false) {
    bool success = false;
    for (int i = 1; i <= 20; i++) {
      if (digitalRead(level_100) == false && digitalRead(level_66) == false && digitalRead(level_33) == false) {
        delay(100);
        success = true;
      }

      else {
        success = false;
        break;
      }
    }

    if (success) {
      currentLevel = 0;
    }

    if (!success) {
      goto back;
    }
  }
}

#endif