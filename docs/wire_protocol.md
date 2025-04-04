# Capstan CAP1 Binary Wire Protocol Specification

## 1. Overview

The CAP1 wire protocol is a high-throughput, zero-copy binary framing protocol designed for inter-node communication across the encrypted WireGuard mesh and local Unix domain socket IPC between `capstand` and native C probes.

---

## 2. Binary Frame Layout

All multi-byte fields are encoded in Network Byte Order (Big-Endian).

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Magic: 0x43415031                       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|          Version (1)          |       Message Type Code       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                        Payload Length                         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                      Castagnoli CRC-32C                       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                        Payload Data...                        |
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

### Field Definitions:
- **Magic (32 bits)**: Fixed constant `0x43415031` (ASCII "CAP1").
- **Version (16 bits)**: Protocol revision number (currently `0x0001`).
- **Message Type (16 bits)**: Message identifier code.
- **Payload Length (32 bits)**: Length of following payload buffer in bytes (0 to 67108864).
- **CRC-32C (32 bits)**: Castagnoli polynomial (`0x1EDC6F41` reflected `0x82F63B78`) checksum calculated across the payload bytes.

---

## 3. Message Type Codes

| Code   | Identifier           | Description                                    |
|--------|----------------------|------------------------------------------------|
| 0x0001 | MSG_HEARTBEAT        | Node keepalive and latency probe               |
| 0x0002 | MSG_RAFT_VOTE_REQ    | Candidate vote solicitation                    |
| 0x0003 | MSG_RAFT_VOTE_RESP   | Vote response (granted / denied)               |
| 0x0004 | MSG_RAFT_APPEND_ENT  | Log entry replication and sync                 |
| 0x0005 | MSG_DRIFT_ALERT      | Real-time eBPF kernel drift notification       |
| 0x0006 | MSG_STATE_RECEIPT    | Cryptographically signed convergence receipt   |
| 0x0007 | MSG_CATALOG_SYNC     | Synchronous Hiera parameter update broadcast   |
