/*
 * Testing program for more complex packet structure
 * program uses a union of two structs, one contains the data
 * and the other is the raw bits.
 *
 * Might not actually be better, more flexibility with a single struct
 * as the sizes of each value can be different and the struct with grow like an array.
 * This is different as the values are embedded into a single unsigned variable.
 *
 * This could be better depending on the size of the data and if the SPI hardware
 * can transfer larger than 8-bit values.
 *
 * For instance, if we manage to fit all of the data into 64 bits it could be easier
 * to transfer it all as a single value as then the chip select pin
 * can be used to align the data rather than needing to realign for each packet
 * using additional data bits.
*/

#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"
#define BYTE_TO_BINARY(byte)  \
  ((byte) & 0x80 ? '1' : '0'), \
  ((byte) & 0x40 ? '1' : '0'), \
  ((byte) & 0x20 ? '1' : '0'), \
  ((byte) & 0x10 ? '1' : '0'), \
  ((byte) & 0x08 ? '1' : '0'), \
  ((byte) & 0x04 ? '1' : '0'), \
  ((byte) & 0x02 ? '1' : '0'), \
  ((byte) & 0x01 ? '1' : '0')

typedef union {
  struct {
    uint64_t START:1;
    uint64_t ECG:16;
    uint64_t RSP:8;
    uint64_t EMG:8;
    uint64_t BPM:8;
    uint64_t CRC:1;
  };
  struct {
    uint64_t w:32;
  };
} Packet;

Packet packet;

int main(void) {
  packet.START = 1;
  packet.ECG = 0b00000011;
  packet.RSP = 0b00001100;
  packet.EMG = 0b00110000;
  packet.BPM = 0b11000000;
  packet.CRC = 1;

  printf("ECG: "BYTE_TO_BINARY_PATTERN"\n", BYTE_TO_BINARY(packet.ECG));
  printf("RSP: "BYTE_TO_BINARY_PATTERN"\n", BYTE_TO_BINARY(packet.RSP));
  printf("EMG: "BYTE_TO_BINARY_PATTERN"\n", BYTE_TO_BINARY(packet.EMG));
  printf("BPM: "BYTE_TO_BINARY_PATTERN"\n", BYTE_TO_BINARY(packet.BPM));

  printf("\n");

  printf("Byte_Size: %lu \n", sizeof(packet));
  printf("Bit_Size: %lu \n", sizeof(packet)*8);

  printf("\n");

  printf("Packet_Sent: \t\t");
  for (uint16_t i = sizeof(packet)*8; i > 0; i -= 8) {
    uint8_t value = (packet.w >> i - 8);
    printf(BYTE_TO_BINARY_PATTERN" ", BYTE_TO_BINARY(value));
  }
  printf("\n");

  uint8_t transfer[sizeof(Packet)];
  memcpy(transfer, (uint8_t*)&packet, sizeof(Packet));

  Packet new_packet;
  memcpy((uint8_t*)&new_packet, transfer, sizeof(new_packet));

  printf("Packet_Received: \t");
  for (uint16_t i = sizeof(new_packet)*8; i > 0; i -= 8) {
    uint8_t value = (new_packet.w >> i - 8);
    printf(BYTE_TO_BINARY_PATTERN" ", BYTE_TO_BINARY(value));
  }
  printf("\n");
  printf("\n");

  printf("ECG: "BYTE_TO_BINARY_PATTERN"\n", BYTE_TO_BINARY(new_packet.ECG));
  printf("RSP: "BYTE_TO_BINARY_PATTERN"\n", BYTE_TO_BINARY(new_packet.RSP));
  printf("EMG: "BYTE_TO_BINARY_PATTERN"\n", BYTE_TO_BINARY(new_packet.EMG));
  printf("BPM: "BYTE_TO_BINARY_PATTERN"\n", BYTE_TO_BINARY(new_packet.BPM));

  printf("\n");

  printf("Byte_Size: %lu \n", sizeof(new_packet));
  printf("Bit_Size: %lu \n", sizeof(new_packet)*8);

  return 0;
}
