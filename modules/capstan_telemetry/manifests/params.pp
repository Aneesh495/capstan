# capstan_telemetry::params
# Default parameters for telemetry collection, eBPF probes, and drift thresholds.
class capstan_telemetry::params {
  $enable_ebpf_probes      = true
  $enable_exporter         = true
  $exporter_port           = 9100
  $enable_otel             = false
  $otel_endpoint           = 'http://127.0.0.1:4317'
  $sample_interval_ms      = 100
  $drift_threshold_percent = 5.0
  $metrics_path            = '/var/lib/capstan/metrics'
}
