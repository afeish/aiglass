// main.cpp - Main entry point for the AI Glass ESP32 project
#include <Arduino.h>
#include "aiglass_core.h"

void setup() {
  Serial.begin(115200);
  Serial.println("AI Glass System Starting...");
  
  // Call the main setup function
  aiglass_setup();
}

void loop() {
  // Call the main loop function
  aiglass_loop();
}