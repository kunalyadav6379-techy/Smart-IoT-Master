#ifndef CONFIG_H
#define CONFIG_H
// Server Configuration
const char* SSID = "some";
const char* PASS = "caughtcaught";
const char* HOSTNAME = "node";
// System Datatypes
int Level_100;
int Level_66;
int Level_33;
int currentLevel;
int triggerValue = 1;
int triggerAddr = 1;

int buzzer = 1;
int trigger = 2;
int waterTank = 3;
int Pin_D5 = 5;
int Pin_D6 = 6;
int Pin_D7 = 7;
// System Datatypes
unsigned long startTime;
unsigned long triggerTime = 25000; // Timer For 100% take 5 seconds buffer triggertime + 5000 = final result
// System Macros

#define buzzerPin D1 // Original D2 = Buzzer
#define level_100 D5
#define level_66 D6
#define level_33 D7

void beepBuzzer() {
  digitalWrite(buzzerPin, true);
  delay(100);
  digitalWrite(buzzerPin, false);
  delay(200);
  digitalWrite(buzzerPin, true);
  delay(300);
  digitalWrite(buzzerPin, false);
  delay(100);
}
void pinConfig()
{
  pinMode(buzzerPin, OUTPUT);
  pinMode(level_33, INPUT_PULLUP);
  pinMode(level_66, INPUT_PULLUP);
  pinMode(level_100, INPUT_PULLUP);
}

#endif