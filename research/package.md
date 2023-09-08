# Package
The package is made up of a struct containing bit length defs
for each of data types we will be sending.

This struct is then treated as an array and encoded using base64
(decision matrix pending).

The encoded data is then sent via SPI to the ESP32 which acts
as a SPI slave that simply receives any amount of data
(less than 1024 bytes long) and transmits it once it receives
the end of line character ('\n').
This character is hard coded but it also required to be present
for the MATLAB code to function so it is consistent across both.

The challenge now is that the data needs to be decoded in MATLAB.
The following code can be used in a callback function to convert
the received encoded data into an array of byte values.
`base64 = readline(src);`
`decoded = transpose(matlab.net.base64decode(char(base64)));`
The decoded data can then be converted into the correct format
using the following code
`x = uint8(decoded(9:12));`
`disp(typecast(x, 'uint32'))`
The issue here is that there is a lot of hardcoded values
in both the index of the data and the conversion format.
One solution is to remove all bit length defs and send everything
as 32-bit words. The tradeoff is that it is potentially quite wasteful.
For instance, if we only needed to send 8-bits, we are essentially
sending 24-bits of unnecessary data that will all be 0s.

We ideally want to send a header at the start of transmission that
contains all the information regarding size of data, etc.
Then send a packet identifier so the system knows what data to expect.

What would be good is to have all the identifiers be bitwise OR'd
with each other so that the MATLAB code can just look at the identifier
bit and can tell which pieces of data are present.
This is better than the alternative of having seperate identifiers for
every combination of data because then we can just define everything once.
For example our header could look like the following:
`IDENTIFIER = 0b10011000`
which might correspond to ECG data, RESP data, and EMG data.
The definitions for those data masks could be as follows:
`ECG_MASK = 0b10000000`
`RSP_MASK = 0b00010000`
`EMG_MASK = 0b00001000`
We could see from this that the identifier contains the corresponding
masks and use it to extract the data.
We could then say that the highest mask takes prescience.
So, in this example the ECG data would come first since its mask's bit
is the highest in the identifier.

Then, all we need to define is that the mask bit corresponds to x amount
of data. So that once we see a specific mask bit is set we can
automatically align the data.

I think its best to do this first manually by having all the masks
and sizes set. Then, once that is working move to having a config packet
that sets the masks and sizes dynamically.
The goal is to keep the definitions in once place and propagate it
through the system.

Wrote a debug routine to print arbritary text to MATLAB via SPI/TCP.
`
void debug(const char *fmt, ...) {
    va_list args;
    char str[1024];
   
    va_start(args, fmt);
    vsprintf(str, fmt, args);
    va_end(args);
   
    write_packet(str, strlen(str));
}
`
Then can receive in MATLAB using
`
y = char(decoded);
disp(y)
`


-----------------------------------------------------------------
## Changes in ESP code
Before I was filling a buffer from the incoming data and waiting until I received
a newline before sending the entire buffer over TCP/IP all at once.
Now I receive data and immediately send, provided client.connected()
I use slave.available() to specify the length of data to be sent.

This is better because it keeps the TCP/IP transmitter simple and also allows all
of the packet metadata to be changeable independently of the ESP.

## Issues with SPI transmission
Currently running into issues where the SPI transmission does not work consistently.
Tested it independently and got it presumably working quite well but for some reason
now that it's been implemented into the rest of the chain it only works if there is
significant delay.

`
for (size_t i = 0; i < output_length; i++) {
    char str[128];
    sprintf(str, "%c", encoded_data[i]);
    ESP_write_array(str, strlen(str));
}
`
This was originally the only way to get transmission to work.
output_length is the length of the base64 encoded string.
I essentially had to write each character seperatly as if it were a string.
This is a problem because the write function that I am using contains a significant delay.

`
void ESP_write_array(uint8_t *array, size_t len) {
    for (size_t i = 0; i < len; i += 4) {
        ESP_write_4byte(array[i], array[i+1], array[i+2], array[i+3]);
    }
    
    if (len % 4 == 1) { ESP_write_4byte(array[len-1], 0, 0, 0); }
    if (len % 4 == 2) { ESP_write_4byte(array[len-1], array[len-2], 0, 0); }
    if (len % 4 == 3) { ESP_write_4byte(array[len-1], array[len-2], array[len-3], 0); }
    
    delay(10);
}
`
There needs to be a delay between each 32-bit word otherwise the transmission fails.
This is beacuse the PIC32 will continually transmit without resetting the chip select line
and the ESP32 needs to reset after each 32-bit word, as far as I can tell this is set.

The idea of the `ESP_write_array` function is that it can pack 4 bytes into a signle word
to negate as much of this delay as possible.
