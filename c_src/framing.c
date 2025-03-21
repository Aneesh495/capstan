/**
 * CAP1 Wire Protocol Framing with Castagnoli CRC-32C.
 */

#include "capstan.h"
#include <string.h>

uint32_t capstan_crc32c(uint32_t crc, const uint8_t* data, size_t length) {
    crc = ~crc;
    for (size_t i = 0; i < length; i++) {
        crc ^= data[i];
        for (int j = 0; j < 8; j++) {
            crc = (crc >> 1) ^ (-(crc & 1) & CRC32C_POLYNOMIAL);
        }
    }
    return ~crc;
}

bool capstan_frame_validate(const capstan_frame_header_t* header, const uint8_t* payload) {
    if (!header) return false;
    if (header->magic != CAPSTAN_MAGIC) return false;

    if (header->payload_length > 0 && payload) {
        uint32_t computed = capstan_crc32c(0, payload, header->payload_length);
        if (computed != header->crc32c) {
            return false;
        }
    }

    return true;
}
