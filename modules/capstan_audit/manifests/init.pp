# capstan_audit
#
# Primary class managing cryptographic state convergence receipts,
# append-only Merkle ledger verification, and compliance proofs.
#
# @param ledger_retention_days Days to retain signed audit receipts.
# @param verify_receipts_on_boot Verify cryptographic signature chain during startup.
class capstan_audit (
  Integer[7, 3650] $ledger_retention_days   = 365,
  Boolean          $verify_receipts_on_boot = true,
) {
  contain capstan_audit::ledger
  contain capstan_audit::merkle
}
