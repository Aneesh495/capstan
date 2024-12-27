# capstan_security::ssh_ca
# Establishes SSH Certificate Authority trust anchor for cryptographic operator authentication.
class capstan_security::ssh_ca {
  $ca_pubkey_file = '/etc/ssh/capstan_ssh_ca.pub'
  $sshd_config = '/etc/ssh/sshd_config.d/50-capstan-ca.conf'

  file { '/etc/ssh/sshd_config.d':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $ca_pubkey_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "# Capstan Sovereign SSH Certificate Authority Trust Anchor\nssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICapstanSovereignCA2026MasterAnchorKey root@capstan-ca\n",
  }

  file { $sshd_config:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "TrustedUserCAKeys ${ca_pubkey_file}\nPasswordAuthentication no\nPubkeyAuthentication yes\n",
    require => File[$ca_pubkey_file],
  }
}
