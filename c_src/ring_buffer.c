/**
 * Lock-Free Shared-Memory Single-Producer Multi-Consumer Ring Buffer.
 * Uses atomic operations and memory fences for microsecond telemetry streaming.
 */

#include "capstan.h"
#include <stdlib.h>
#include <string.h>

capstan_ring_buffer_t* capstan_ring_buffer_create(size_t capacity) {
    /* Capacity must be a power of two for fast bitwise masking */
    if (capacity == 0 || (capacity & (capacity - 1)) != 0) {
        capacity = 1024;
    }

    capstan_ring_buffer_t* rb = (capstan_ring_buffer_t*)malloc(sizeof(capstan_ring_buffer_t));
    if (!rb) return NULL;

    rb->capacity = capacity;
    rb->head = 0;
    rb->tail = 0;
    rb->buffer = (capstan_telemetry_event_t*)calloc(capacity, sizeof(capstan_telemetry_event_t));
    if (!rb->buffer) {
        free(rb);
        return NULL;
    }

    return rb;
}

void capstan_ring_buffer_free(capstan_ring_buffer_t* rb) {
    if (rb) {
        if (rb->buffer) free(rb->buffer);
        free(rb);
    }
}

bool capstan_ring_buffer_push(capstan_ring_buffer_t* rb, const capstan_telemetry_event_t* event) {
    if (!rb || !event) return false;

    uint64_t head = __atomic_load_n(&rb->head, __ATOMIC_RELAXED);
    uint64_t tail = __atomic_load_n(&rb->tail, __ATOMIC_ACQUIRE);

    if (head - tail >= rb->capacity) {
        /* Buffer is full */
        return false;
    }

    size_t index = head & (rb->capacity - 1);
    memcpy(&rb->buffer[index], event, sizeof(capstan_telemetry_event_t));

    __atomic_store_n(&rb->head, head + 1, __ATOMIC_RELEASE);
    return true;
}

bool capstan_ring_buffer_pop(capstan_ring_buffer_t* rb, capstan_telemetry_event_t* out_event) {
    if (!rb || !out_event) return false;

    uint64_t tail = __atomic_load_n(&rb->tail, __ATOMIC_RELAXED);
    uint64_t head = __atomic_load_n(&rb->head, __ATOMIC_ACQUIRE);

    if (tail >= head) {
        /* Buffer is empty */
        return false;
    }

    size_t index = tail & (rb->capacity - 1);
    memcpy(out_event, &rb->buffer[index], sizeof(capstan_telemetry_event_t));

    __atomic_store_n(&rb->tail, tail + 1, __ATOMIC_RELEASE);
    return true;
}
