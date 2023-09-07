# Programming Development
## Preexisitng hardware
The hardware I was given was in the process of being programmed. It consists of two microcontrollers, a PIC32 and a ESP32. 
The ESP32 had been programmed intermittently and the PIC32 had been successfully programmed once in order to enable the PIC32.
I sucessfully programmed the ESP32 and enabled Over The Air (OTA) programming. I also implemented TCP/IP communication between the ESP32 and MATLAB.
Craig Dawson shared code that allowed the PIC32 to be programmed. 
I had previously had issues programming it because the device used on the schematics is different to what has actually been put on the board.
The code Craig has given me allows for simple programming, 
but some of the settings for the hardware have not been set correctly and the board cannot be put into debug mode.

## Board bringup approach
The process that has been followed to get the hardware working is to first program the ESP to allow it to be programmed consistently and conveniently.
Then, communication with MATLAB was established using TCP/IP.
This allows for data to be visuallised which can help with debugging the rest of the hardware.
The PIC was then programmed to allow debugging, 
in order to do this the ICE/ICD Comm Channel Select needed to be changed to PGC1/PGD1,
and DEBUG needed to be enabled.
Finally, the PIC was programmed to communicate with the ESP and the whole chain was tested to verify communication between the PIC and MATLAB.

Difficulty in that Arduino only provides code for SPI master mode.
While ESP (programmed using Arduino) in this configuration makes more sense as the slave.
Somewhat gotten around it using external libraries.
Also difficulty in that anything that halts the ESP loop causes the OTA handle to stop.
This means that any bugs that cause an infinite loop also make the ESP unprogrammable.

Also working to keep all code general.
So for instance can keep MATLAB code running for entire sequence of testing without needing to change anything.
