# Thesis Starting Doc

## DMX Dummy Fixture
- Small number of fixtures to verify correct control
  - 8 LEDs (NeoPixels) with 4 DMX channels each
    - Intensity
    - Red channel
    - Green channel
    - Blue channel
  - Total of 32 channels (4 x 8)

  - Using DMXSerial library [link](https://github.com/mathertel/DMXSerial)
    - Receives all incoming DMX packets using interrupts and stores them in an internal array
    - Individual channels are never written independently with DMX, instead all 512 channels of a "universe" are sent as a "frame"
    - Can have multiple universes
    - Every fixture in a universe receives data for every channel, then filters its specific channel
    - Because of this the channels are not required to be sent, instead the channels are 1+ the data array index
    - Library handles receiving frames, data can be accessed from internal array using `uint8_t read (int channel);`

- LEDs controlled using NeoPixel library [link](https://github.com/adafruit/Adafruit_NeoPixel)
  - LED colors stored in internal array
    - Set using `void setPixelColor(uint16_t n, uint8_t r, uint8_t g, uint8_t b);`
  - Once colors are set, need to call `void show(void);` in order to physically update LED colors
  - Incorporate intensity by multiplying intensity and color
    - Need to bitshift result in order to maintain 0-255 range
    - `(intensity * color) >> 8`
  - Need to map DMX addresses to LED
    - LED color stored as single value, index of data correlates to LED number
    - DMX data contains 4 discrete channels per LED
    - Work with base address and offsets
      - Base address gives each individual LED address
      - Offsets give color/intensity channels
    - Can either keep independant LED index or divide DMX base address by number of offset channels (4)

