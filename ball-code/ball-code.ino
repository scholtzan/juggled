#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <string>
#include <cstdlib>
#include <math.h>
#include <queue>
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"

using namespace std;

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

Adafruit_MPU6050 mpu;

int red1 = 16;
int green1 = 5;
int blue1 = 19;

int red2 = 25;
int green2 = 26;
int blue2 = 27;

int batteryPin = 34;

int freq = 5000;
int resolution = 8;
int ledChannel[2][3] = {
  {0, 1, 2},
  {3, 4, 5}  
};

float prev_sm = 0.0;

class Color {
  public:
    int r;
    int g;
    int b;
    
    Color(int red, int green, int blue) {
      r = red;
      g = green;
      b = blue;
    }

    Color(string color) {
      int rgb[] = {0, 0, 0};
      int c = 0;
      int prev = 0;
      
      for (int i = 0; i < color.length(); i++) {
        if (color[i] == ',') {
          rgb[c] = atoi(color.substr(prev, i - prev).c_str());
          c += 1;
          prev = i + 1;
        }
      }

      rgb[c] = atoi(color.substr(prev, color.length() - prev).c_str());

      r = rgb[0];
      g = rgb[1];
      b = rgb[2];
    }

    int* to_array() {
      int arr[3] = {r, g, b};
      return arr;
    }
};

class Command {
  private:
    string event;
    string arg;
    Color color0;
    Color color1;

  public:
    Command(string e, string a, Color c0, Color c1): color0(0,0,0), color1(0,0,0) {
      event = e;
      arg = a;
      color0 = c0;
      color1 = c1;
    }

    string getEvent() {
      return event;  
    }

    string getArg() {
      return arg;  
    }

    Color getColor0() {
      return color0;  
    }

    Color getColor1() {
      return color1;  
    }
};

queue<Command> command_queue;

class MyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      string value = pCharacteristic->getValue();
      bool parsing_done = false;

      if (value.length() > 0) {
        Serial.println("*********");
        Serial.print("New value: ");

        string action = value.substr(0, 3);
        value = value.substr(4, value.length() - 4);
        if (action == "get") {
          string val = value.substr(0, 3);
          if (val == "bat") {
            // battery
            int voltage = (int)(((analogRead(batteryPin)  * 3.3 ) / (4095)) * 100);
            pCharacteristic->setValue(voltage);
            parsing_done = true; 
          } else if (val == "tem") {
            // temperature  
            // todo
          }
        } else if (action == "set") {
          // clear queue
          queue<Command> empty;
          swap( command_queue, empty );
          
          while (!parsing_done) {
            string event = value.substr(0, value.find(";"));
            value = value.substr(value.find(";") + 1, value.length() - value.find(";") - 1);

            string arg = value.substr(0, value.find(";"));
            value = value.substr(value.find(";") + 1, value.length() - value.find(";") - 1);

            for (int i = 0; i < arg.length(); i++){
                Serial.print(arg[i]);
            }

            Color color0(value.substr(0, value.find(";")));

            value = value.substr(value.find(";") + 1, value.length() - value.find(";") - 1);

            int end;
            if (value.find("|") != -1) {
              end = value.find("|");
            } else {
              end = value.length();
            }
  
            Color color1(value.substr(0, end));

            if (end != value.length()) {
              value = value.substr(end + 1, value.length() - end - 1);
            }
  
            Command cmd(event, arg, color0, color1);
            command_queue.push(cmd);

            if (end == value.length()) {
              value = "";
              parsing_done = true;  
            }
          }
        }
      }
    }
};

void setup() {
   WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0); //disable brownout detector   

  ledcSetup(ledChannel[0][0], freq, resolution);
  ledcAttachPin(red1, ledChannel[0][0]);

  ledcSetup(ledChannel[0][2], freq, resolution);
  ledcAttachPin(blue1, ledChannel[0][2]);

  ledcSetup(ledChannel[0][1], freq, resolution);
  ledcAttachPin(green1, ledChannel[0][1]);
  
  ledcSetup(ledChannel[1][0], freq, resolution);
  ledcAttachPin(red2, ledChannel[1][0]);

  ledcSetup(ledChannel[1][2], freq, resolution);
  ledcAttachPin(blue2, ledChannel[1][2]);

  ledcSetup(ledChannel[1][1], freq, resolution);
  ledcAttachPin(green2, ledChannel[1][1]);

  Serial.begin(115200);

  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) {
      delay(10);
    }
  }
  Serial.println("MPU6050 Found!");
//
  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
//  
  BLEDevice::init("Juggling ball 1");
  BLEServer *pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService(SERVICE_UUID);
  BLECharacteristic *pCharacteristic = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_WRITE
                                       );
  pCharacteristic->setValue("Hello World says Neil");
  pCharacteristic->setCallbacks(new MyCallbacks());
  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
//  Serial.println("Characteristic defined! Now you can read it in your phone!");                              
//  BLEServer *pServer = BLEDevice::createServer();
//
//  BLEService *pService = pServer->createService(SERVICE_UUID);
//
//  BLECharacteristic *pCharacteristic = pService->createCharacteristic(
//                                         CHARACTERISTIC_UUID,
//                                         BLECharacteristic::PROPERTY_READ |
//                                         BLECharacteristic::PROPERTY_WRITE
//                                       );
//
//  pCharacteristic->setValue("Hello world");
//  pCharacteristic->setCallbacks(new MyCallbacks());
//  pService->start();
//
//  BLEAdvertising *pAdvertising = pServer->getAdvertising();
//  pAdvertising->addServiceUUID(SERVICE_UUID);
//  pAdvertising->setScanResponse(true);
//  pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
//  pAdvertising->setMinPreferred(0x12);
//  pAdvertising->start();

  delay(500);
  
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 1); //enable brownout detector
}

void loop() {
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);
  float x = a.acceleration.x;
  float y = a.acceleration.y;
  float z = a.acceleration.z;

  float cur_sm = sqrt(x * x + y * y + z * z);

  if (!command_queue.empty()) {
    Command cmd = command_queue.front();
  
    if (cmd.getEvent() == "*") {
      ledcWrite(ledChannel[0][0], cmd.getColor0().r);
      ledcWrite(ledChannel[0][1], cmd.getColor0().g);
      ledcWrite(ledChannel[0][2], cmd.getColor0().b);
  
      ledcWrite(ledChannel[1][0], cmd.getColor1().r);
      ledcWrite(ledChannel[1][1], cmd.getColor1().g);
      ledcWrite(ledChannel[1][2], cmd.getColor1().b);
    } else if (cmd.getEvent() == "timed") {
      int millisec = atoi(cmd.getArg().c_str());
      ledcWrite(ledChannel[0][0], cmd.getColor0().r);
      ledcWrite(ledChannel[0][1], cmd.getColor0().g);
      ledcWrite(ledChannel[0][2], cmd.getColor0().b);
  
      ledcWrite(ledChannel[1][0], cmd.getColor1().r);
      ledcWrite(ledChannel[1][1], cmd.getColor1().g);
      ledcWrite(ledChannel[1][2], cmd.getColor1().b);
      delay(millisec);
      command_queue.pop();
      command_queue.push(cmd);
    } else if (cmd.getEvent() == "caught") {
      if (prev_sm < 2.5 && cur_sm > 2.5) {
        ledcWrite(ledChannel[0][0], cmd.getColor0().r);
        ledcWrite(ledChannel[0][1], cmd.getColor0().g);
        ledcWrite(ledChannel[0][2], cmd.getColor0().b);
    
        ledcWrite(ledChannel[1][0], cmd.getColor1().r);
        ledcWrite(ledChannel[1][1], cmd.getColor1().g);
        ledcWrite(ledChannel[1][2], cmd.getColor1().b);
        command_queue.pop();
        command_queue.push(cmd);
      }
    } else if (cmd.getEvent() == "thrown") {
      if (cur_sm < 2.5 && prev_sm > 2.5) {
        ledcWrite(ledChannel[0][0], cmd.getColor0().r);
        ledcWrite(ledChannel[0][1], cmd.getColor0().g);
        ledcWrite(ledChannel[0][2], cmd.getColor0().b);
    
        ledcWrite(ledChannel[1][0], cmd.getColor1().r);
        ledcWrite(ledChannel[1][1], cmd.getColor1().g);
        ledcWrite(ledChannel[1][2], cmd.getColor1().b);
        command_queue.pop();
        command_queue.push(cmd);
      }
    }
  }

  prev_sm = cur_sm;
  
  delay(50);
}
