# juggled - LED Juggling Ball

> This project is still work in progress.

This repository contains all the files and instructions for 3D printing and creating LED juggling balls that can be controlled via Bluetooth.

todo: insert image

## Required Materials

The following components are required to build a single juggling ball:

* ESP32  DEVKIT V1
	* This development board has an onboard Bluetooth module, will control the LEDs and collect data from the accelerometer
* Lithium  Battery  3.7V
	* The battery will power the ESP32 and all other components
* Li-lon Battery  Charger
	* This component will ensure that the Lithium battery can be recharged via micro USB
* Accelerometer
	* For collecting data on whether the juggling ball has been thrown or caught
* 2x RGB LEDs
	* To make the juggling ball glow
* Resistors
	* 1x 1kΩ
	* 1x 4.7kΩ
	* Used to read the battery charge via the ESP32
* Switch
	* To turn the juggling ball on and off
* Wire
	* For connecting all the components
* Heat Shrink Tubes
	* For insulating soldered wires
* Soldering Iron + Solder
	* All the components need to be soldered together
* Transparent TPU
	* For printing the outer shell
	* Soft and flexible material will ensure that components and inner core are protected when juggling balls are dropped
* Clear PLA+
	* For inner core that will help to keep electronics in place
* Hot Glue
	* For glueing outer shell onto inner core and for fixating electronics

![Components](https://github.com/scholtzan/juggled/raw/main/img/components.png)


## 3D Printed Shell

The juggling ball consists of an inner core and an outer shell. The models can be found in the `models/` folder.

For printing the inner core which will hold all the components in place, use a transparent material. PLA+ or PETG are more sturdy, but PLA should also work. I have used the following parameters for printing the inner core with transparent PLA+:

* Temperature: 200C
* Build Plate Temperature: 60C
* Layer Height: 0.2mm
* Infill Density: 5%
* Infill Pattern: Gyroid
* Print Speed: 80mm/s
* Generate Support: yes
	* Support density: 5%

The inner core and all components are protected by an outer shell printed with transparent TPU. The outer shell consists of two parts - a back and a front. The front will allow access to the switch and USB ports. I have used the following parameters for printing the shell:

* Temperature: 220C
* Build Plate Temperature: 75C
* Layer Height: 0.2mm
	* Adaptive Layers: yes
		* Maximum Variation: 0.1mm
		* Variation Step Size: 0.1mm
* Flow: 105%
* Infill Density: 30%
* Infill Pattern: Gyroid
* Print Speed: 20mm/s
* Retraction Distance: 3mm
* Generate Support: no

## Circuit Overview

The following diagram shows how the circuit for the LED juggling ball works:

<img src="https://github.com/scholtzan/juggled/raw/main/img/circuit.png" width="500">

1. The lithium battery outputs 3.7V when fully charged and can power the ESP32 DEVKIT
2. The lithium battery is connected to a charger module which allows the battery to be charged via micro USB
3. The two RGB LEDs are directly connected to the ESP32
4. The two resistors connect the lithium battery directly to one pin of the ESP32. This connection will be used to determine how much charge the battery has left
5. The accelerometer is connected to and powered by the ESP32

## Assembly

For assembling and soldering the electronic components together, follow the circuit overview diagram above. As space is very limited inside the juggling ball, the components need to be sandwiched together:

<img src="https://github.com/scholtzan/juggled/raw/main/img/assembled-electronics.png" width="500">

The switch, battery charging module and accelerometer are put in between the lithium battery and ESP32 DEVKIT. The LEDs will be located on the battery and the ESP32. To ensure components stay in place, I printed some additional spacers using TPU and used some hot glue. The assembled bock of electronic components should not exceed 22mm in height as it would otherwise not fit into the inner core of the juggling ball. Ensure that the switch and the USB slots a properly aligned with the opening.

Once all the electronic components have been assembled, they can be place inside the inner core of the juggling ball. Each side of the inner core has holes for the LEDs to fit through. The two pieces for the inner core need to be glue together, either by using hot glue or Gorilla glue. Next, glue the two pieces of the outer shell onto the inner core using hot glue. Make sure that the piece of shell with the opening to access the switch and USB ports is properly aligned.

## Juggling Ball Software

The code running on the ESP32 of each juggling ball is located in the `ball-code` directory. The code can be [loaded on to the ESP32](https://www.etechnophiles.com/how-to-install-program-an-esp32-with-arduino-ide-for-the-first-time/) using [Arduino IDE](https://www.arduino.cc/en/software).

The code running on the juggling balls will allow devices to connect to it via BLE and send commands to change the color or get information about the battery voltage.

### Protocol

For specifying the LED behaviour the juggling ball can process messages that follow the following format:

```
set;<action>;<arg>;<r>,<g>,<b>;<r>,<g>,<b>|<action>;<arg>;<r>,<g>,<b>;<r>,<g>,<b>|...
```

The juggling ball behaviour can be defined in multiple steps. Each step is separated by `|`. For each step an `action` is specified, some `action`s require additional `arg`uments to be specified or can change the `rgb` values of the two LEDs. Once an action has been completed, the juggling ball will move on to process the next defined step. Once the last step defined have been processed, the juggling ball will again go back to the first step.

Supported `action`s are: `wait`, `thrown`, `caught` and `color`. `arg` is required when `wait` is used, to specify in millisecons how long the ball will wait until processing the next step. The `rgb` values of the LEDs can be changed for any action.

For setting the color of one LED to red and the other to blue the message would look as follows:

```
set;color;;255,0,0;0,0,255
```  

To have the juggling ball switch between red and green every second the message would look like:

```
set;wait;1000;255,0,0;255,0,0|wait;1000;0,0,255;0,0,255
```

To change the color to blue when a ball is in the air and to red when it is caught:

```
set;caught;;255,0,0;255,0,0|thrown;;0,0,255;0,0,255
```

All messages need to be converted to HEX. So for the first example the following message would need to be sent to the juggling ball in order for it to correctly interpret it: 

```
7365743b636f6c6f723b3b3235352c302c303b302c302c323535
```

## iOS Application

The code for an iOS application is in the `app/` directory, which makes connecting juggling balls, defining behaviours and collecting statistics very easy. The application is not part of the App Store, instead it can be 
