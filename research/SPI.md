# PIC32MX775F512H to ADS1298R SPI comms
PIC32.SCK3  --> ADS1298R.SCLK
PIC32.SDI3  <-- ADS1298R.DOUT
PIC32.SDO3  --> ADS1298R.DIN
PIC32.RD7   <-- ADS1298R.nDRDY
PIC32.RD8   --> ADS1298R.CLKSEL
PIC32.nSS3  --> ADS1298R.nCS
PIC32.RD10  --> ADS1298R.START

For timing see page 17 of [datasheet](https://www.ti.com/lit/ds/symlink/ads1298r.pdf?ts=1691984863544&ref_url=https%253A%252F%252Fwww.ti.com%252Fproduct%252FADS1298R)
See page 65 for register maps

## Difference in design vs manufacture
*IMPORTANT:* The chip that was actually used in the design is the ADS1294R!! 
This is contrary to what the schematic and PCB design designators say.
The only way I figured this out was to physically inspect the board.
Mostly the same except this one only has 4 channels and so the expected data
to be read is `24 + 4 x 24 = 120 bits`
Also does not contain all the same registers as the bigger brothers.

Other differences are that the ID should be `0b11010000`
Registers `RLD_SENSP` and `RLD_SENSN` do not contain bits[4:7]
Registers `LOFF_SENSP` and `LOFF_SENSN` do not contain bits[4:7]

As far as I can tell from the datasheet, everything else should be the same.

Also appears to be additional connection from nDRDY to DGND with some capacitors.
*COMPLETELY UNDOCUMENTED*

Not 100% sure if this is actually happening though because only image of PCB design
low res screenshot of only top side of board. Very hard to follow traces.
As far as I can tell it seems reasonable that each trace routed from the PIC to the ADS
is correct. Not really possible to check as it is a ZXG package (basically a BGA package).

Also pin 43 of the PIC is connected to DOUT which according to the datasheet of the PIC
is actually the SPI chip select pin not the data input pin.

Might have to write a custom driver that just pulls whatever pin the actual chip select
is connected to low, writes whatever the equivalent SCK pin is high and write/reads
the corresponding SDO and SDI pin manually...

Not sure if any of this is actually managable anyway because the reset switch
is a push button and doesn't appear to have any way of switching it via the PIC.
*VERY ANNOYING.*

Can't even really tell where the reset pin goes because it is grounded to the sleve of
the 3.5mm jack?!? Whatever is routed to the switch is on the underside of the board
that I don't have access to...


# New research determining correct pinmaps
PIC32MX775F512H         ADS1294R
PIN55 RD7 ...           nDRDY (also goes somewhere else maybe ground) _according to schematics it goes to nDRDY_
PIN54 RD6 ...           *NOT SURE* (maybe back to PIN64 of PIC??) _according to schematics it goes to TP8_
PIN53 RD5 ...           *NOT SURE* (maybe TP7) _according to schematics it goes to TP7_
PIN52 RD4 ...           *NOT SURE* (maybe TP6) _according to schematics it goes to TP6_
PIN51 RD3 SDO3          DIN _according to schematics it goes to MOSI_
PIN50 RD2 SDI3          DOUT _according to schematics it goes to MISO_
PIN49 RD1 SCK3          SCLK _according to schematics it goes to SCLK_
PIN44 RD10 ...          nDRDY (not sure if this or RD7) _according to schematics it goes to START_
PIN43 RD9 nSS3          nCS _according to schematics it goes to nCS_
PIN42 RD8 ...           *NOT SURE* (maybe CLKSEL?) _according to schematics it goes to CLKSEL_
