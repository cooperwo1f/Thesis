#include <stdio.h>
#include <stdint.h>
#include <string.h>

typedef struct {
    uint32_t ECG:16;
    uint32_t RSP:16;
    uint32_t EMG:32;
    uint32_t BPM:32;
    uint32_t TST:32;
} Packet;

Packet packet;

uint8_t array[] = { 0x1E, 0x2E, 0xF1, 0xF2, 0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10, 0x00, 0x00, 0x00, 0x0A };
uint8_t desired_array[] = { 0xF2, 0xF1, 0x2E, 0x1E, 0x98, 0xBA, 0xDC, 0xFE, 0x10, 0x32, 0x54, 0x76, 0x0A, 0x00, 0x00, 0x00 };

void print_array(uint8_t* arr, uint16_t len) {
  printf("Array: \t");
  for (size_t i = 0; i < len; i++) {
    printf("0x%02X ", arr[i]);
  }
  printf("\n");
}

// Reverse array is necessary as the data over SPI comes in backwards
void reverse_array(uint8_t* arr, uint16_t len) {
  uint8_t swp;
  for (size_t i = 0; i < len-3; i += 4) {
    swp = arr[i];
    arr[i] = arr[i+3];
    arr[i+3] = swp;

    swp = arr[i+1];
    arr[i+1] = arr[i+2];
    arr[i+2] = swp;
  }
}

int main(void) {
  printf("Initial_");
  print_array(array, sizeof(array)/sizeof(array[0]));
  printf("\n");

  reverse_array(array, sizeof(array)/sizeof(array[0]));
  printf("Reversd_");
  print_array(array, sizeof(array)/sizeof(array[0]));
  printf("Desired_");
  print_array(desired_array, sizeof(desired_array)/sizeof(desired_array[0]));
  printf("\n");

  memcpy((void*)&packet, array, sizeof(Packet));
  printf("Packetd_");
  print_array((uint8_t*)&packet, sizeof(Packet));
  printf("Packet:\t\t\tECG: 0x%04X  RSP: 0x%04X EMG: 0x%08X  BPM: 0x%08X \n", packet.ECG, packet.RSP, packet.EMG, packet.BPM);

  return 0;
}
