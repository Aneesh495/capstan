# capstan_core::service
# Manages daemon configuration file and systemd service lifecycle.
class capstan_core::service {
  $config_file = "${capstan_core::config_dir}/capstand.conf"
  $systemd_unit = '/etc/systemd/system/capstand.service'

  file { $config_file:
    ensure  => file,
    owner   => $capstan_core::params::user,
    group   => $capstan_core::params::group,
    mode    => '0640',
    content => epp('capstan_core/capstand.conf.epp', {
      'node_id'             => $trusted['certname'],
      'cluster_name'        => lookup('capstan::cluster_name', String, 'first', 'edge-mesh-alpha'),
      'role'                => lookup('capstan::role', String, 'first', 'edge_gateway'),
      'convergence_seconds' => $capstan_core::convergence_seconds,
      'log_level'           => $capstan_core::log_level,
      'socket_path'         => $capstan_core::params::socket_path,
      'api_port'            => $capstan_core::api_port,
      'data_dir'            => $capstan_core::data_dir,
      'journal_dir'         => $capstan_core::capstan_core::params::journal_dir,
      'staging_dir'         => $capstan_core::capstan_core::params::staging_dir,
      'ledger_dir'          => $capstan_core::capstan_core::params::ledger_dir,
    }),
    notify  => Service[$capstan_core::params::service_name],
  }

  file { $systemd_unit:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('capstan_core/capstand.service.epp', {
      'config_file' => $config_file,
      'run_dir'     => $capstan_core::run_dir,
      'prefix'      => $capstan_core::prefix,
    }),
    notify  => [
      Exec['capstan_systemd_daemon_reload'],
      Service[$capstan_core::params::service_name],
    ],
  }

  exec { 'capstan_systemd_daemon_reload':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
    path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
  }

  # Service declaration with support for testing environments where systemd is inactive
  if $facts['kernel'] == 'Linux' and $facts.dig('systemd', 'running') {
    service { $capstan_core::params::service_name:
      ensure    => $capstan_core::service_ensure,
      enable    => $capstan_core::service_enable,
      hasstatus => true,
      hasrestart=> true,
      require   => [
        File[$config_file],
        File[$systemd_unit],
        Exec['capstan_systemd_daemon_reload'],
      ],
    }
  } else {
    # Non-systemd or test stub
    service { $capstan_core::params::service_name:
      ensure => stopped,
      enable => false,
    }
  }
}
