# Capstan: Architecture and Topology Specifications

## Node Internal Architecture

The following diagram illustrates the internal subsystem decomposition of an autonomous Capstan edge node, highlighting the closed-loop convergence pipeline, the Puppet Resource Abstraction Layer, kernel telemetry probes, and the cryptographic state ledger.

```mermaid
flowchart TD
    subgraph Telemetry ["Telemetry and Kernel Event Layer"]
        BPF["eBPF Tracepoints and XDP Probes"]
        PROC["/proc and /sys Kernel Virtual Files"]
        RING["Lock-Free Shared-Memory Ring Buffer"]
        ANOMALY["Kernel Anomaly and Drift Detector"]
    end

    subgraph Daemon ["Autonomous Convergence Daemon (capstand)"]
        LOOP["Closed-Loop Autonomic Engine"]
        RAFT["Asynchronous Raft Consensus Node"]
        API["REST / Unix Socket Inspection Server"]
        STAGE["Transactional Staging and Rollback Journal"]
    end

    subgraph Compiler ["Local Catalog Synthesis and Puppet RAL"]
        FACTS["Facter System Hardware Discovery"]
        HIERA["Hiera 5 Data Hierarchy Resolution"]
        PARSER["Puppet DSL Catalog Compiler"]
        DAG["Directed Acyclic Resource Dependency Graph"]
        PROVIDERS["Custom Ruby Types and Native Providers"]
    end

    subgraph Kernel ["Hardware and OS Subsystems"]
        SYSCTL["sysctl Low-Latency Network Tunables"]
        CPU["CPU Core Isolation (isolcpus / nohz_full)"]
        NUMA["NUMA Memory Policy and Interleaving"]
        HUGE["Transparent and Static Hugepages (2M / 1G)"]
        WG["WireGuard Zero-Trust Mesh Interface"]
        ZFS["ZFS and Btrfs Local Storage Datasets"]
        TPM["TPM 2.0 Measured Boot PCR Validation"]
        CGROUPS["cgroups v2 and Namespace Slices"]
    end

    subgraph Security ["Cryptographic Audit and State Ledger"]
        SIMD["SIMD-Accelerated Merkle State Tree Hasher"]
        ED25519["Ed25519 Host Identity Signer"]
        LEDGER["Append-Only State Receipt Ledger"]
    end

    BPF --> RING
    PROC --> RING
    RING --> ANOMALY
    ANOMALY --> LOOP

    LOOP --> FACTS
    FACTS --> HIERA
    HIERA --> PARSER
    PARSER --> DAG
    DAG --> PROVIDERS

    PROVIDERS --> SYSCTL
    PROVIDERS --> CPU
    PROVIDERS --> NUMA
    PROVIDERS --> HUGE
    PROVIDERS --> WG
    PROVIDERS --> ZFS
    PROVIDERS --> TPM
    PROVIDERS --> CGROUPS

    PROVIDERS --> STAGE
    STAGE --> SIMD
    SIMD --> ED25519
    ED25519 --> LEDGER

    RAFT <--> LOOP
    LOOP <--> API
```

---

## Distributed Cluster Mesh Topology

Capstan edge clusters form an encrypted peer-to-peer overlay network orchestrated through WireGuard tunnels and synchronized via Raft consensus.

```mermaid
flowchart LR
    subgraph RegionA ["Edge Region Alpha (Financial Co-Location)"]
        NodeA1["Gateway Node (Alpha-01)\nWireGuard Hub & Proxy"]
        NodeA2["Worker Node (Alpha-02)\nCPU Isolated & NUMA Bound"]
        NodeA3["Storage Node (Alpha-03)\nNVMe-oF & ZFS Mirror"]
    end

    subgraph RegionB ["Edge Region Beta (Autonomous Telecom PoP)"]
        NodeB1["Gateway Node (Beta-01)\nWireGuard Hub & Proxy"]
        NodeB2["Worker Node (Beta-02)\nKernel Real-Time PREEMPT_RT"]
        NodeB3["Enclave Node (Beta-03)\nTPM 2.0 PCR Attested"]
    end

    subgraph Consensus ["Decentralized Raft State Consensus Mesh"]
        RaftLeader["Raft Leader\nQuorum State Coordinator"]
        RaftFollower1["Raft Follower\nAlpha Quorum Member"]
        RaftFollower2["Raft Follower\nBeta Quorum Member"]
    end

    NodeA1 <== Encrypted WireGuard Tunnel ==> NodeB1
    NodeA1 --- NodeA2
    NodeA1 --- NodeA3
    NodeB1 --- NodeB2
    NodeB1 --- NodeB3

    NodeA1 -. Raft Sync .-> RaftFollower1
    NodeB1 -. Raft Sync .-> RaftFollower2
    RaftLeader <== Dynamic State Replication ==> RaftFollower1
    RaftLeader <== Dynamic State Replication ==> RaftFollower2
```

---

## Autonomic Convergence State Machine

The state machine below delineates the transitions executed by `capstand` during continuous system reconciliation.

```mermaid
stateDiagram-v2
    [*] --> IdleSense
    IdleSense --> DriftDetected : High-Frequency Telemetry Anomaly
    IdleSense --> ScheduleTrigger : Convergence Interval Elapsed
    IdleSense --> RaftCommit : Cluster State Version Bump

    DriftDetected --> PlanCatalog
    ScheduleTrigger --> PlanCatalog
    RaftCommit --> PlanCatalog

    PlanCatalog --> CompileDAG : Resolve Hiera and Facts
    CompileDAG --> StageChanges : Construct Resource Graph

    StageChanges --> ApplyResources : Execute Atomic Providers
    ApplyResources --> Rollback : Provider Mutation Error
    Rollback --> AuditFailure : Restore Previous Known State

    ApplyResources --> VerifySanity : All Resources Converged
    VerifySanity --> ComputeMerkleTree : Post-Assertions Succeeded
    VerifySanity --> Rollback : Health Verification Failed

    ComputeMerkleTree --> SignReceipt : Generate Root SHA-256 Digest
    SignReceipt --> AppendLedger : Sign with Ed25519 Host Key
    AppendLedger --> IdleSense : Return to Telemetry Monitoring
```
