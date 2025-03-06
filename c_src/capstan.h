/**
 * Capstan Native High-Performance C Kernels Header.
 * Declares SIMD-accelerated Merkle tree operations, lock-free ring buffer,
 * and CAP1 binary wire framing with Castagnoli CRC-32C.
 */

#ifndef CAPSTAN_H
#define CAPSTAN_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Magic bytes for CAP1 wire protocol: ASCII 'C', 'A', 'P', '1' */
#define CAPSTAN_MAGIC 0x43415031

/* Castagnoli polynomial for CRC-32C */
#define CRC32C_POLYNOMIAL 0x82F63B78

/* Wire Frame Header */
#pragma pack(push, 1)
typedef struct {
    uint32_t magic;
    uint16_t version;
    uint16_t message_type;
    uint32_t payload_length;
    uint32_t crc32c;
} capstan_frame_header_t;
#pragma pack(pop)

/* Ring Buffer Definitions */
typedef struct {
    uint64_t timestamp_ns;
    uint32_t event_type;
    uint32_t value;
    char label[32];
} capstan_telemetry_event_t;

typedef struct {
    size_t capacity;
    volatile uint64_t head;
    volatile uint64_t tail;
    capstan_telemetry_event_t* buffer;
} capstan_ring_buffer_t;

/* Merkle SIMD and Hash Functions */
void capstan_sha256(const uint8_t* data, size_t len, uint8_t out[32]);
void capstan_merkle_parent(const uint8_t left[32], const uint8_t right[32], uint8_t out[32]);

/* Ring Buffer Functions */
capstan_ring_buffer_t* capstan_ring_buffer_create(size_t capacity);
void capstan_ring_buffer_free(capstan_ring_buffer_t* rb);
bool capstan_ring_buffer_push(capstan_ring_buffer_t* rb, const capstan_telemetry_event_t* event);
bool capstan_ring_buffer_pop(capstan_ring_buffer_t* rb, capstan_telemetry_event_t* out_event);

/* Framing and CRC-32C Functions */
uint32_t capstan_crc32c(uint32_t crc, const uint8_t* data, size_t length);
bool capstan_frame_validate(const capstan_frame_header_t* header, const uint8_t* payload);

#ifdef __cplusplus
}
#endif

#endif /* CAPSTAN_H */
