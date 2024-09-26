# Capstan: System Architecture and Protocol Specification

## Abstract

Capstan is a decentralized, autonomic edge infrastructure orchestrator that couples the declarative expressiveness of the Puppet Resource Abstraction Layer (RAL) with high-frequency telemetry, local-first catalog compilation, and an asynchronous consensus mesh. Designed for sovereign edge clusters, financial colocation facilities, and air-gapped secure enclaves, Capstan eliminates the brittle centralized master architecture of legacy configuration management systems while providing microsecond-level telemetry reactivity, hardware-enforced isolation, and cryptographically verified state convergence.

---

## 1. Motivation and Core Challenges

Traditional configuration management systems were architected for static datacenter environments with centralized topologies:
1. **Centralized Master Bottleneck**: Nodes periodically poll a centralized master every 30 minutes over high-latency WAN links, creating a single point of failure and vulnerability to network partitions.
2. **Coarse-Grained Execution**: Standard agent runs are slow, non-reactive to real-time kernel drift, and lack microsecond-level telemetry integration.
3. **Absence of Cryptographic Verification**: Executed runs produce unstructured text logs rather than cryptographically verifiable state proofs and Merkle audit receipts.
4. **Lack of Hardware-Enforced Isolation**: Edge workloads require fine-grained CPU core isolation, NUMA memory pinning, hugepage reservation, SR-IOV network device allocation, and TPM 2.0 measured boot PCR validation, areas poorly addressed by generic container schedulers.

Capstan resolves these bottlenecks by embedding an autonomous convergence daemon (`capstand`) directly on each edge node. The daemon operates a continuous autonomic control loop, executing local catalog compilation, verifying cryptographic Merkle state trees, coordinating distributed state through an embedded Raft consensus engine, and enforcing zero-trust communications over an encrypted WireGuard mesh.

---

## 2. Architectural Principles

### 2.1 Declarative State DSL and RAL
Capstan leverages Puppet as its primary declarative Domain-Specific Language (DSL). The Puppet Resource Abstraction Layer provides:
- **Strict Idempotency**: Target states are evaluated against live system reality before any mutation is dispatched.
- **Topological Acyclic Dependency Graphs**: Resource relationships (`before`, `require`, `notify`, `subscribe`) are compiled into a Directed Acyclic Graph (DAG) with cycle detection and topological sorting.
- **Native OS Provider Decoupling**: High-level resource declarations (`wireguard_tunnel`, `ebpf_filter`, `cpu_isolation`, `zfs_dataset`, `tpm_pcr_policy`) abstract underlying kernel interfaces, netlink sockets, and sysfs virtual files.

### 2.2 Local-First Catalog Compilation
Rather than shipping raw catalogs across the network, Capstan nodes maintain an encrypted local repository of modules, profiles, and hierarchical data (Hiera 5). When a convergence pass triggers, the local compiler synthesizes an environment-specific catalog directly in memory, validating inputs against hardware facts gathered by Facter.

### 2.3 Closed-Loop Autonomic Convergence
Capstan executes a six-stage continuous reconciliation cycle:
1. **Sense**: High-frequency eBPF tracepoints and kernel ring buffers stream socket metrics, memory allocations, and sysctl updates into shared memory.
2. **Plan**: The engine compares live system state digests against the compiled desired-state graph.
3. **Compile**: If drift is detected or a cluster consensus event occurs, Hiera hierarchies and node profiles compile into an active catalog DAG.
4. **Apply**: State mutators execute in topological order with staging journals for transactional rollback safety.
5. **Verify**: Post-convergence sanity assertions inspect target sysfs endpoints, process namespaces, and network interfaces.
6. **Audit**: The node calculates a SHA-256 Merkle tree of converged resource hashes, signs the root digest with an Ed25519 host key, and appends the receipt to the immutable state ledger.

---

## 3. Distributed Coordination and WireGuard Mesh

Edge nodes in a Capstan cluster establish an encrypted zero-trust overlay network using WireGuard:
- **Cryptographic Routing**: Each node generates an Ed25519 identity key and Curve25519 WireGuard keypair during initial provisioning.
- **Raft Consensus**: Nodes participate in an embedded asynchronous Raft consensus cluster to coordinate global cluster configurations, distribute rolling updates, and maintain quorum health.
- **Partition Tolerance**: During WAN disconnects, edge nodes continue autonomous local convergence, rejecting non-local mutations until quorum is safely re-established.

---

## 4. Hardware and Kernel Orchestration

Capstan provides deep kernel-level tuning for predictable, deterministic execution:
- **CPU Isolation**: Pins critical threads to isolated cores via `isolcpus`, disables scheduler ticks via `nohz_full`, and offloads RCU callbacks via `rcu_nocbs`.
- **NUMA Memory Policy**: Interleaves and binds memory allocations to local socket memory banks to eliminate remote interconnect bus contention.
- **Hugepages Allocation**: Configures 2MB and 1GB hugepages at boot time for low-latency zero-copy memory buffers.
- **eBPF XDP Filtering**: Attaches high-performance eBPF programs at the network driver layer for line-rate packet validation and DDoS mitigation.
- **TPM 2.0 PCR Attestation**: Validates platform configuration registers (PCR 0 through 7) before unlocking sensitive disk keyslots or applying cluster credentials.
