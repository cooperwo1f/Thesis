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


# Trying whatever I can think of
Currently trying to change all the configurations to see if any combinations work better.
If this doesn't work I can look at the actual altium schematics I got from Kenneth.
Thinking first I'll just try and get the actual ID from the chip since it is easy to verify.
Going to play around with the driver, add delays between reads and writes and try different
SPI configs to see if anything makes it respond.
Also will try same thing after physically pressing reset switch because maybe it needs 
hardware reset.

My scope probe wasn't working because of the x10 setting on the probe was x1 for some reason.

I actually have managed to get _somethings_ out of the ID register.

It should be    11010000
It actually is  01100000

This was gotten by setting SPI bits SMP = 0, CKE = 1, CKP = 0, and pressing
the reset button for the chip while using the scope to send a signal at the moment it
would have to be reset in software.
Managed to repeat this at least one more time... Attempting without pressing hardware reset.
Still works without hardware switch being pressed. Not correct but better than nothing.
Only thing that I changed was using the scope to correctly set the delay constant.

Used scope to measure space between pulses then set a specific pulse delay.
I think previously the delay number was overflowing potentially because it was so large.
Potentially the delay was way too short and the timing wasn't correct...?

Can get 11000000 if I set SMP = 1
Still missing bit 4 which should be 1 no matter what...
Trying without hardware reset... Still works.

Setting CKP causes ID to be 0, so that should 100% be reset.

Resetting it and running again causes ID to be 0
Pressing reset while it's running fixes the issue.
Still not what it 100% should be but it's close.

Increasing the delay amount did not change anything.
Seems like hardware reset can be pressed midrun and it recovers nicely

Without delays it often does not read correctly.
Going to add a single delay in the SPI_write function to set max speed.

Going to reduce the delays in the init function.. Everything seems to work fine.
Going to try and remove them completely. Seems to work correctly still.
Appears that the singular delay in the `SPI_write` function was enough and nothing else
needs it now. Probably good to do this with the ESP `SPI_write` so that the delays are
only in a single place and can be easily optimised.

Added a substantial amount of extra delay to both to guarantee consistency, can easily 
be optimised later.

Changing SPI3BRG as well to see if that makes any kind of difference.
Seems like it can be about any value and it still works the same.
Calculations say it should be greater than 2 so I'll set it to 4 for safety.
However, still works without propogating errors with a value of 1 which
_should_ be too fast.

Wondering if the GPIO init I am doing has an effect. Turning it off causes ID to be 0.
Which is good because it means that I am actually doing something.

Going to go through init function and see what turning various things on/off or skiping them
causes the system to do.
`CLK_SEL = 0` causes the chip to stop responding.
Not writing SDATAC doesn't appear to change anything but that could be because I'm not
doing anything that needs registers set.
`START_PIN = 0` causes chip to stop responding.

Ok now that I have a baseline that I can consistenly get to I'm going to try and do more.


# Attempting to read actual data
When reading data it doesn't seem like the DRDY pin ever actually goes low.
Even when not sending read data continuous it is always high...
Not really sure if I can trust this though because the pin isn't exposed
So I'm setting a test point high if it is read high by the microcontroller and it may
just be staying high because by the time it can poll again it has already read all the data
and thus the chip is ready to put more data out.

Going to see what happens when I try and read without setting RDATAC.
Ok so issue now is that I am always reading 11000000 even when not reading the ID.

This is really strange to me because it should be shorted so reading 0.
Wonder if that also means that the ID I was reading is not actually correct since it wasn't
exactly what it should have been anyway and it matches what the chip sends continuously.

From my calculations I am reading 15 bytes which is 120 bits which I belive is correct.
If I don't short the input it is still 11000000

Ok so something definitly not right because even once read a few bytes the `data_ready`
pin is still high when it should be low.

It's strange because the DRDY pin is active low, in software I am checking `DRDY_PIN == 0`
which made me think that maybe the chip just isn't on at all hence why I'm always seeing
`data_ready()` as true.
But this isn't the case since it becomes false if I hold down the reset pin.
Which means the physical pin is being pulled high when the chip is put into reset which
seems super strange to me because I would assume everything would just go to 0...
At least in this case I can confirm that it is actually working.

It seems wrong that sending the stop data read continuous command doesn't stop the chip
from setting it's data ready pin. Not super logical to me because shouldn't that only be 
true when the data is continuously being streamed...

Maybe it has something to do wit the START pin? Since maybe that has the ability to override
the data continuous commands somehow?

I think the fact I am getting 192 (AKA 11000000) all the time, probably means that all the
register writes I am doing are not actually correct. What I should do I think is go back
to the ID register and attempt to get that to send correctly.

I am not entirely sure where I should start because it seems like this should be working.
I'm going to go back to the SPI config and see what I can maybe do...

Also might be worth looking at software libaries for Arduino to see what they do in say
a simple ID test script.
Maybe there is something here I am missing that is really obvious.

I think it is the power-on timing. Most likely due to hte lack of /RESET pulse since
that was never connected to the PIC.

Considering that, I think it's fair to assume that the timings may still be too short.
Might be worth looking at existing Arduino library for how they setup their SPI.
Also worth looking at schematics to verify there weren't any revision changes with how
the chip RESET is connected (although I doubt there would be).

Looking at _presumably_ functional Arduino library: 
clock polarity 0, clock phase 1, output edge rising, data capture falling

What this actually means:
Idles on logic low, data transmission from clock idle to clock active, 
data shifted out on rising clock edge, data sampled on falling clock edge

*ADDITIONALLY:* Data is MSB first with a datarate of 4,000,000 (AKA 4MHz)

Also just realised it doesn't actually matter what I set the baudrate generator to because
the system clock is 5Mhz so it will literally always be able to keep up.

Interestingly enough writing START and STOP appears to work.
So the actual writing to SPI seems to be correct...


Very weird because it seems like there are two versions of the design.
The one that got made appears to be older and worse. So not really sure what's going on.
Perhaps this is the beginning of a revision 2?
But I also cannot find the altium files for it, only a single pdf remains...
Shame because the newer one has a bunch of LEDs on it that would make this way easier.


*OK* so what we know is that write must work. As writing START and STOP commands have 
an effect.
What is currently unknown is if the reading and writing register commands work correctly.
I really don't see how they wouldn't because I've hand checked the bits during debugging.
Really the only thing I can think at this stage is that maybe the PIC is sending in 32-bit 
mode. That doesn't really make sense since it's configured to 8-bit mode but maybe it
still sends extra or something (this would be very silly).

I cannot think of anything else to check short of soldering to the pins and checking
the physical signals that are being send both ways. I'm sure if I did that I would be able
to verify it almost immediately... Should definitly bring bodge wire on Tuesday and make 
use of the good soldering irons, flux, microscopes, and nice oscilloscopes at uni.

Other than that it could also be the power on cycle needs specific lines held low/high
and I just do not have digital access to those pins.

Or worst case the entire board has been designed so badly that the chip is having weird 
power issues. Looking at the altium board files it definitly does not look great.
At least there is a lot to include in ADC challenges for my results.


Interesting change, if I make the `ADS129R_read()` function write a dummy byte of
`0xFF` instead of `0x00`, the returned value is different... (it is now 0)
After I reset the device it went back to 11000000...
Pressing hardware reset causes DRDY pin to never go high again

It seems like that behaviour existed whether the dummy value is 0xFF or 0x00
Would be worth writing to the GPIO register since then I can 100% verify that the writing
is correct since I can probe one of the test points with my scope.

*ALSO IMPORTANT TO NOTE* the status word that I am expecting contains the following
`1100 LOFF_STATP[7:0] LOFF_STATN[7:0] GPIO[7:4]`
So maybe the received 11000000 could be the beginning of that status word but then I
am not reading any more or something?

GPIO register looks like `DATA[4:1] CONTROL[4:1]` with 0 being outputs and 1 being inputs
for the control section

So I am not able to write the register. I think at this stage what must be wrong is my
register writing/reading.
I think the actual write commands are working because if I write sleep, wakeup, start, stop,
or reset the chip has the response I would expect it to have.
I am not able to verify SDATAC or RDATAC because the data I am then reading is wrong.
It also doesn't seem to stop it from giving me data if I send either of them.
Maybe I should try RDATA and try to just do a simple read see if that makes any difference.

Otherwise, I think the write byte works so I don't see why writing the read/write register 
command then the address of the register is not working.

It could also be that the SDATAC, RDATAC, and RDATA commands do not work for some reason 
This would mean that all my attempts to read and write registers is futile because
the chip is not going to respond to those commands as it boots into RDATAC mode.
But even so the chip does not give any readings, just 192 (AKA 11000000) continously
so I have no idea what that is supposed to mean.
