/*********************************************************************
 Adafruit invests time and resources providing this open source code,
 please support Adafruit and open-source hardware by purchasing
 products from Adafruit!

 MIT license, check LICENSE for more information
 Copyright (c) 2024 Phl Schatzmann

 This example counts the 'received' samples and prints them on
 Serial (via CDC)
 
*********************************************************************/

#include "Adafruit_TinyUSB.h"

Adafruit_USBD_Audio usb;
size_t sample_count = 0;

size_t writeCB(const uint8_t* data, size_t len, Adafruit_USBD_Audio& ref) {
  int16_t* data16 = (int16_t*)data;
  size_t samples = len / sizeof(int16_t);
  sample_count += samples;
  return len;
}

void setup() {
  // Manual begin() is required on core without built-in support e.g. mbed rp2040
  if (!TinyUSBDevice.isInitialized()) {
    TinyUSBDevice.begin(0);
  }
  
  Serial.begin(115200);
  //while(!Serial);  // wait for serial

  // Start USB device as Audio Sink
  usb.setWriteCallback(writeCB);
  usb.begin(44100, 2, 16);

  // If already enumerated, additional class driverr begin() e.g msc, hid, midi won't take effect until re-enumeration
  if (TinyUSBDevice.mounted()) {
    TinyUSBDevice.detach();
    delay(10);
    TinyUSBDevice.attach();
  }

}

void loop() {
  #ifdef TINYUSB_NEED_POLLING_TASK
  // Manual call tud_task since it isn't called by Core's background
  TinyUSBDevice.task();
  #endif

  // use LED do display status
  if (usb.updateLED()){
    Serial.print("Total samples: ");
    Serial.print(sample_count);
    Serial.print(" / Sample rate: ");
    Serial.println(usb.rate());
  }
}