// main.cpp - Main entry point for the AI Glass ESP32 project
#include <Arduino.h>
#include <WiFi.h>
#include <esp_wifi.h>

// External declarations for WiFi credentials (defined in aiglass_core.cpp)
extern const char* WIFI_SSID;
extern const char* WIFI_PASS;

// Server configuration (externally defined in aiglass_core.cpp)
extern const char* SERVER_HOST;
extern const uint16_t SERVER_PORT;

void setup() {
  // Initialize serial communication
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("AI Glass System Starting...");
  
  // Connect to WiFi
  WiFi.mode(WIFI_STA);
  WiFi.setSleep(false);
  esp_wifi_set_ps(WIFI_PS_NONE);
  
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.print("[WiFi] Connecting");
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println(" OK");
  Serial.print("[WiFi] IP Address: ");
  Serial.println(WiFi.localIP());
  
  Serial.println("AI Glass System Ready!");
}

void loop() {
  // Main application loop
  delay(1000);
  Serial.println("AI Glass System Running...");
}