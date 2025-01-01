# capstan_telemetry::drift_detector
# Deploys continuous divergence scoring utility and scheduled inspection runs.
class capstan_telemetry::drift_detector {
  $score_script = "${capstan_core::prefix}/bin/capstan-drift-score"

  file { $score_script:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => epp('capstan_telemetry/drift_score.sh.epp', {
      'metrics_path' => $capstan_telemetry::params::metrics_path,
    }),
  }

  # Execute initial drift score generation
  exec { 'capstan_generate_initial_drift_score':
    command     => $score_script,
    creates     => "${capstan_telemetry::params::metrics_path}/drift.json",
    path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
    subscribe   => File[$score_script],
    refreshonly => true,
  }
}
