# ESP issues
Remember how much it sucks having to set firewall thingys because each time the ESP tools
update or change location the firewall rules need to be reset

## Power issues
The power distribution of the board is bad and there is voltage drops across traces
Measuring 2.6V (3.3V required) when supplying the board from a single power supply
(current limit is 2x what is required)

Almost 2.7V when adding a secondary ground connection
Closer to 2.8V with additional voltage connection
2.9V with a 3rd voltage connection

Not really sure what to do because it is so much worse performing now than it was before.
