#include <stdio.h>
#include <stdint.h>
#include <string.h>

typedef struct {
  uint8_t a;
  uint8_t b;
  uint16_t c;
} Packet;

int main(void) {
  Packet packet;

  // Test to check if possible to assign values to packet using array interfaces
  memset((uint8_t*)&packet, 1, sizeof(packet));
  packet.c = 1027; // greater than 255 (max 8 bit value)

  printf("Packet size: %lu \n", sizeof(packet));
  printf("Packet value: ");

  for (uint8_t i = 0; i < sizeof(packet); i++) {
    printf("%u ", ((uint8_t*)&packet)[i]);
  }

  printf("\n");

  // This demostrates that a 16 bit value can be automatically transmitted in 8 bits using a struct
  // also, the two 8 bit halves can be recombined by accessing the struct member
  printf("16 bit value: %u \n", packet.c);

  // Should make sure that the packet isn't being padded unnecessarily.
  // For example, if the 16 bit value is changed to a 32 bit value,
  // the struct becomes 8 bytes long instead of 6 because the 32 bit value
  // must be padded so that it is aligned.

  return 0;
}
