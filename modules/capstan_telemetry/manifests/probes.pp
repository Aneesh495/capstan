# capstan_telemetry::probes
# Configures eBPF kernel tracepoint parameters and shared-memory ring buffer settings.
class capstan_telemetry::probes {
  $conf_file   = '/etc/capstan/probes.conf'
  $metrics_dir = $capstan_telemetry::params::metrics_path

  file { $metrics_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $conf_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp('capstan_telemetry/probes.conf.epp', {
      'sample_interval_ms'      => $capstan_telemetry::sample_interval_ms,
      'drift_threshold_percent' => $capstan_telemetry::drift_threshold_percent,
    }),
    require => File[$metrics_dir],
  }
}
