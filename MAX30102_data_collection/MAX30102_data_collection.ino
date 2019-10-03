/*
  Hardware Connections (Breakoutboard to Arduino):
  -5V = 5V (3.3V is allowed)
  -GND = GND
  -SDA = A4 (or SDA)
  -SCL = A5 (or SCL)
  -INT = Not connected
*/

#include <Wire.h>
#include "MAX30105.h"

MAX30105 particleSensor;

void setup()
{
  Serial.begin(115200);
  Serial.println("Initializing...");

  // Initialize sensor
  if (!particleSensor.begin(Wire, I2C_SPEED_FAST, MAX30105_ADDRESS)) //Use default I2C port, 400kHz speed
  {
    Serial.println("MAX30105 was not found. Please check wiring/power. ");
    while (1);
  }

  //Setup to sense a nice looking saw tooth on the plotter
  byte ledBrightness = 0x1F; //Options: 0=Off to 255=50mA
  byte sampleAverage = 2; //Options: 1, 2, 4, 8, 16, 32
  byte ledMode = 2; //Options: 1 = Red only, 2 = Red + IR, 3 = Red + IR + Green
  byte sampleRate = 100; //Options: 50, 100, 200, 400, 800, 1000, 1600, 3200
  int pulseWidth = 411; //Options: 69, 118, 215, 411
  int adcRange = 4096; //Options: 2048, 4096, 8192, 16384

  particleSensor.setup(ledBrightness, sampleAverage, ledMode, sampleRate, pulseWidth, adcRange); //Configure sensor with these settings
  
  particleSensor.enablePROXINT();
  particleSensor.enableFIFORollover();
  particleSensor.setPROXINTTHRESH(0x3C);      //set proximity threshold
  particleSensor.clearFIFO();                 //clear all old samples from FIFO
  
}

void loop()
{
  // The proximity interrupt is triggered when the measured IR value is above the set threshold
  // When the sensor is close enough to the user's skin, the IR value will be high enough to trigger the proximity interrupt
  // To determine if the proximity interrupt is triggered, the interrupt status must be read (register 0x00000000)
  // But reading the interrupt status clears all interrupts and sets it to 0

  Serial.println(particleSensor.getIR());
  
}
