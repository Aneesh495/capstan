# capstan_gateway::proxy
# Deploys edge ingress proxy configuration file and verifies gateway health.
class capstan_gateway::proxy {
  $conf_dir  = '/etc/capstan/gateway'
  $conf_file = "${conf_dir}/gateway.cfg"

  file { $conf_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $conf_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('capstan_gateway/haproxy_edge.cfg.epp', {
      'ingress_port' => $capstan_gateway::ingress_port,
      'backend_port' => $capstan_gateway::backend_port,
    }),
    require => File[$conf_dir],
  }
}
