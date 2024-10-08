# capstan_core::identity
# Configures cryptographic host identity and Ed25519 node keypair.
class capstan_core::identity (
  String $cluster_name = lookup('capstan::cluster_name', String, 'first', 'edge-mesh-alpha'),
  String $role         = lookup('capstan::role', String, 'first', 'edge_gateway'),
  String $tier         = lookup('capstan::tier', String, 'first', 'tier1'),
  String $region       = lookup('capstan::region', String, 'first', 'region-us-east'),
) {
  $node_id = $trusted['certname']
  $private_key_path = "${capstan_core::config_dir}/keys/node_ed25519.key"
  $public_key_path  = "${capstan_core::config_dir}/keys/node_ed25519.pub"
  $identity_file    = "${capstan_core::config_dir}/identity.json"

  # Generate Ed25519 private key if missing
  exec { 'capstan_generate_node_key':
    command => "openssl genpkey -algorithm ed25519 -out ${private_key_path} && chmod 0600 ${private_key_path}",
    creates => $private_key_path,
    path    => ['/usr/bin', '/usr/local/bin', '/bin'],
  }

  # Derive Ed25519 public key
  exec { 'capstan_derive_public_key':
    command     => "openssl pkey -in ${private_key_path} -pubout -out ${public_key_path} && chmod 0644 ${public_key_path}",
    creates     => $public_key_path,
    refreshonly => true,
    subscribe   => Exec['capstan_generate_node_key'],
    path        => ['/usr/bin', '/usr/local/bin', '/bin'],
  }

  file { $identity_file:
    ensure  => file,
    owner   => $capstan_core::params::user,
    group   => $capstan_core::params::group,
    mode    => '0640',
    content => epp('capstan_core/node_identity.json.epp', {
      'node_id'         => $node_id,
      'cluster_name'    => $cluster_name,
      'role'            => $role,
      'tier'            => $tier,
      'region'          => $region,
      'public_key_path' => $public_key_path,
    }),
    require => Exec['capstan_generate_node_key'],
  }
}
