# Interfacing Information for Current Hardware

## Block Diagram
The hardware provided interfaces are given in the following block diagram

![Block Diagram](Images/interface_block_diagram.png?raw=true)

According to this diagram, the provided interfaces are
  - 3.5mm ECG jack
  - 8 pin Respiratory header
  - 12 pin PPG header

## Schematics
The hardware schematics also give a descrription of what interfaces are available
(These schematics are taken from William Tran's 2022 thesis)

![Block Diagram](Images/adc.png?raw=true)
![Block Diagram](Images/pic.png?raw=true)

These schematics are quite busy but the main takeaway is that for the ADC 
there is a right-leg drive (RLD), RESP_MOD, right arm lead, and left arm lead input

For the PIC there is USB, 16 (2x8) headers exposed labeled "Respiratory Strain" 
(only 13 are connected to the PIC, headers pins 4-16 -> RB3-RB15),
and an 8 pin header for PPG (header pins 1-8 -> RE0-RE7)

The ADC being used is the ADS1298R
[datasheet](https://www.ti.com/lit/ds/symlink/ads1298r.pdf?ts=1683692522297&ref_url=https%253A%252F%252Fwww.ti.com%252Fproduct%252FADS1298R)

It isn't immediately clear how the respiratory sensor would actually connect...
It seems that the calculations are derived, so maybe the sensor is not required...

Actually, the ADC should have an input for the respiratory, it is its own discrete sensor
