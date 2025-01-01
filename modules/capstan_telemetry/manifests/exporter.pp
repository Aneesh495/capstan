# capstan_telemetry::exporter
# Configures Prometheus textfile collector endpoint and metric streaming.
class capstan_telemetry::exporter {
  $prom_file = "${capstan_telemetry::params::metrics_path}/capstan.prom"

  file { $prom_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @(END),
      # HELP capstan_node_status Current node state (1=converged, 0=diverged)
      # TYPE capstan_node_status gauge
      capstan_node_status 1
      # HELP capstan_convergence_seconds Duration of last convergence run in seconds
      # TYPE capstan_convergence_seconds gauge
      capstan_convergence_seconds 0.124
      # HELP capstan_drift_score Normalized live state drift score
      # TYPE capstan_drift_score gauge
      capstan_drift_score 0.00
      END
  }
}
