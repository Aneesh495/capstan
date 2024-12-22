# capstan_security::auditd
# Deploys auditd rules to monitor security-critical files and syscall invocations.
class capstan_security::auditd {
  $audit_rules_file = '/etc/audit/rules.d/99-capstan.rules'

  file { '/etc/audit':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
  }

  file { '/etc/audit/rules.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    require => File['/etc/audit'],
  }

  file { $audit_rules_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp('capstan_security/auditd_capstan.rules.epp'),
    notify  => Exec['capstan_augenrules_load'],
    require => File['/etc/audit/rules.d'],
  }

  exec { 'capstan_augenrules_load':
    command     => 'augenrules --load',
    refreshonly => true,
    path        => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
    onlyif      => 'which augenrules',
  }
}
