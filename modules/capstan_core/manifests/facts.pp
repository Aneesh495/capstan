# capstan_core::facts
# Manages external facts directory and static facts deployment.
class capstan_core::facts {
  $facts_dir = '/etc/puppetlabs/facter/facts.d'

  file { ['/etc/puppetlabs', '/etc/puppetlabs/facter', $facts_dir]:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${facts_dir}/capstan_environment.yaml":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "# Capstan External Environment Fact\ncapstan_tier: tier1\ncapstan_managed: true\n",
    require => File[$facts_dir],
  }
}
