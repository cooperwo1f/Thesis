# IO issues
Currently having a number of IO issues with the PIC32.
Seems like no matter how I set the IO register direction, or how I set
the PORT or LATCH bits, the IO pin never changes.
I appear to be able to correctly read from the IO port although this
hasn't been fully tested I am just able to see ports that should be
inputs driven high.

It may be worth setting those to outputs and see if I still read them
as inputs because it seems like there is no pin assertion happening.

Setting the TRIS bit and then writing the PORTx bit high is all that
needs to be done.
I can verify this because the ESP32 needs its enable pin to be pulled
high and that is done sucesfully using `TRISBbits.TRISB2 = 0;` and
`PORTBbits.RB2 = 1;`
(testing this by setting `PORTBbits.RB2 = 0` resulted in the ESP
shutting down)
It just seems that no matter what I do, I cannot get signal on any of
the test points. I'm trying to determine if it's an issue with the
program or if the pinout is incorrect or if the routing was not done
properly or some other issue like maybe my scope isn't referenced to
the correct ground and the voltage that is present is actually not
being measured.

I'm thinking a reasonable way to proceed would be to continuity test
a specific pin and 100% verify the port and pin before checking it just
with the multimeter to determine if voltage is present. Then, once that
has be sorted move on to using the scope.
What do we know:

    - Pin outputs are set using TRISx and PORTx.
    - The enable pin for the ESP is using one of these pins 
        - Although all that I've really been seeing 
        is the brownout detector being triggered 
        so maybe the ESP not working is unrelated to the 
        tampering I was doing with that pin...
    - I am not able to see changes on any of the test points
        - This is really strange because I am setting the entire port
        worth of pins so I don't see how they could be getting missed.

I think it's worth investigating the ESP enable pin a little closer.
Maybe check voltage with a multimeter since it should be pretty easy.
Then, if there is voltage attempt to remove and see what the ESP does
(when properly powered using external supply as to not trip 
brownout detection).
Then continue to different pin on same port, verify that is also working.
Finally, attempt changing port and test off pin of controller.
Continuity test between pin and test point then check test point.
If all correct we know 100% that the issue is with the scope.
