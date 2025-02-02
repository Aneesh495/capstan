# capstan_audit::merkle
# Provisions Merkle tree verification hooks for post-convergence state audits.
class capstan_audit::merkle {
  $merkle_tool = "${capstan_core::prefix}/bin/capstan-merkle-check"

  file { $merkle_tool:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => @(END),
      #!/usr/bin/env bash
      # Computes SHA-256 Merkle root across active node configurations
      set -euo pipefail
      hash_manifest=$(find /etc/capstan -type f | sort | xargs sha256sum | sha256sum | awk '{print $1}')
      echo "Capstan Merkle Root: $hash_manifest"
      END
  }
}
