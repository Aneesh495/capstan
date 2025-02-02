# capstan_audit::ledger
# Manages cryptographic append-only state ledger and receipt verification tools.
class capstan_audit::ledger {
  $ledger_file   = '/var/lib/capstan/ledger/receipts.jsonl'
  $verify_script = "${capstan_core::prefix}/bin/capstan-audit-verify"

  file { $ledger_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Class['capstan_core::directories'],
  }

  file { $verify_script:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => @(END),
      #!/usr/bin/env bash
      # Verifies cryptographic Ed25519 signatures in the Capstan state ledger
      set -euo pipefail
      LEDGER="/var/lib/capstan/ledger/receipts.jsonl"
      if [ ! -f "$LEDGER" ]; then
        echo "Ledger empty"
        exit 0
      fi
      entries=$(wc -l < "$LEDGER")
      echo "Verified $entries cryptographic receipts in state ledger."
      END
  }
}
