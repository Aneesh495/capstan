# Capstan Operations and Emergency Runbook

## 1. Node Initialization and Provisioning

### First Boot Sequence:
1. Clone the repository into `/opt/capstan/repo`.
2. Execute `./scripts/verify.sh` to confirm syntax and environment integrity.
3. Apply the bootstrap catalog:
   ```bash
   puppet apply --environmentpath=. --environment=production manifests/site.pp
   ```
4. Verify daemon supervisor:
   ```bash
   capstan status
   ```

---

## 2. Emergency Recovery and Rollbacks

### 2.1 Reverting a Bad Catalog State:
If a configuration change causes cluster instability:
1. Inspect the last committed transaction journal:
   ```bash
   ls -lat /var/lib/capstan/journal/
   ```
2. Trigger an immediate rollback to previous Merkle root:
   ```bash
   capstan apply --rollback
   ```
3. Verify system status:
   ```bash
   capstan status
   ```

### 2.2 Split-Brain and Quorum Healing:
If a network partition isolates edge nodes:
1. Query active Raft quorum state:
   ```bash
   capstan cluster
   ```
2. If isolated nodes cannot reach quorum, verify WireGuard endpoint connectivity:
   ```bash
   wg show wg0
   ```
3. Once WAN routes recover, the Raft consensus leader will automatically reconcile log entries and restore uniform cluster state.
