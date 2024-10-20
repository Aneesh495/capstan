# capstan_kernel::sysctl
# Enforces low-latency network and memory tuning via sysctl.d configuration file.
class capstan_kernel::sysctl {
  $sysctl_conf = '/etc/sysctl.d/99-capstan-lowlatency.conf'

  file { $sysctl_conf:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('capstan_kernel/99-capstan-lowlatency.conf.epp'),
    notify  => Exec['capstan_apply_sysctl'],
  }

  exec { 'capstan_apply_sysctl':
    command     => "sysctl -p ${sysctl_conf}",
    refreshonly => true,
    path        => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
    onlyif      => 'test -f /etc/sysctl.d/99-capstan-lowlatency.conf',
  }
}
