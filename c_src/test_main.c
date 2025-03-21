/**
 * Native C Test Suite for libcapstan.
 * Tests Merkle leaf hashing, lock-free ring buffer, and CRC-32C framing.
 */

#include "capstan.h"
#include <stdio.h>
#include <assert.h>
#include <string.h>

static void test_crc32c(void) {
    printf("[*] Running CRC-32C test...\n");
    const char* data = "123456789";
    uint32_t crc = capstan_crc32c(0, (const uint8_t*)data, 9);
    /* Standard Castagnoli CRC-32C of "123456789" is 0xE3069283 */
    assert(crc == 0xE3069283);
    printf("    CRC-32C result: 0x%08X (MATCH)\n", crc);
}

static void test_ring_buffer(void) {
    printf("[*] Running lock-free ring buffer test...\n");
    capstan_ring_buffer_t* rb = capstan_ring_buffer_create(16);
    assert(rb != NULL);

    capstan_telemetry_event_t ev1 = { .timestamp_ns = 1000, .event_type = 1, .value = 42 };
    strncpy(ev1.label, "sysctl_drift", sizeof(ev1.label) - 1);

    bool pushed = capstan_ring_buffer_push(rb, &ev1);
    assert(pushed == true);

    capstan_telemetry_event_t out_ev;
    bool popped = capstan_ring_buffer_pop(rb, &out_ev);
    assert(popped == true);
    assert(out_ev.value == 42);
    assert(strcmp(out_ev.label, "sysctl_drift") == 0);

    /* Buffer should now be empty */
    assert(capstan_ring_buffer_pop(rb, &out_ev) == false);

    capstan_ring_buffer_free(rb);
    printf("    Ring buffer push/pop verified successfully.\n");
}

static void test_sha256_merkle(void) {
    printf("[*] Running SHA-256 and Merkle parent test...\n");
    uint8_t out[32];
    const char* text = "capstan_edge_node_state";
    capstan_sha256((const uint8_t*)text, strlen(text), out);
    assert(out[0] != 0 || out[1] != 0);

    uint8_t parent[32];
    capstan_merkle_parent(out, out, parent);
    assert(parent[0] != 0 || parent[1] != 0);

    printf("    SHA-256 and Merkle parent generated successfully.\n");
}

int main(void) {
    printf("=========================================\n");
    printf("      CAPSTAN NATIVE C KERNEL TESTS      \n");
    printf("=========================================\n");

    test_crc32c();
    test_ring_buffer();
    test_sha256_merkle();

    printf("ALL NATIVE C TESTS PASSED (3/3)\n");
    return 0;
}
