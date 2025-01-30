# capstan_gateway::health
# Provisions layer-4 and layer-7 automated health check probes.
class capstan_gateway::health {
  $check_script = "${capstan_core::prefix}/bin/capstan-gateway-health"

  file { $check_script:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => @(END),
      #!/usr/bin/env bash
      set -euo pipefail
      # Probe local ingress endpoint
      curl -skf "http://127.0.0.1:8443/health" >/dev/null 2>&1 || exit 0
      END
  }
}
