# capstan_telemetry
#
# Primary class orchestrating high-frequency kernel telemetry, eBPF tracepoints,
# Prometheus metrics export, and real-time state divergence detection.
#
# @param enable_ebpf_probes Load and attach kernel tracepoint probes.
# @param enable_exporter Deploy Prometheus metrics endpoint exporter.
# @param exporter_port Listening TCP port for Prometheus scraping.
# @param enable_otel Stream telemetry metrics to OpenTelemetry collector.
# @param sample_interval_ms Kernel sampling interval in milliseconds.
# @param drift_threshold_percent Threshold for triggering autonomous convergence pass.
class capstan_telemetry (
  Boolean $enable_ebpf_probes      = $capstan_telemetry::params::enable_ebpf_probes,
  Boolean $enable_exporter         = $capstan_telemetry::params::enable_exporter,
  Stdlib::Port $exporter_port      = $capstan_telemetry::params::exporter_port,
  Boolean $enable_otel             = $capstan_telemetry::params::enable_otel,
  Integer[10, 10000] $sample_interval_ms = $capstan_telemetry::params::sample_interval_ms,
  Float[0.1, 100.0] $drift_threshold_percent = $capstan_telemetry::params::drift_threshold_percent,
) inherits capstan_telemetry::params {

  if $enable_ebpf_probes {
    contain capstan_telemetry::probes
  }

  if $enable_exporter {
    contain capstan_telemetry::exporter
  }

  contain capstan_telemetry::drift_detector
}
