# capstan_network::wireguard
# Configures WireGuard network interface, cryptographic keypair, and active mesh peers.
class capstan_network::wireguard {
  $interface = $capstan_network::interface_name
  $conf_file = "/etc/wireguard/${interface}.conf"
  $private_key_file = "/etc/wireguard/${interface}.key"
  $public_key_file = "/etc/wireguard/${interface}.pub"

  file { '/etc/wireguard':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  # Generate WireGuard Curve25519 private key
  exec { 'capstan_generate_wg_key':
    command => "wg genkey | tee ${private_key_file} | wg pubkey > ${public_key_file} && chmod 0600 ${private_key_file}",
    creates => $private_key_file,
    path    => ['/usr/bin', '/bin', '/usr/local/bin'],
    onlyif  => 'which wg',
  }

  # Declare custom resource type wireguard_tunnel
  wireguard_tunnel { $interface:
    ensure      => present,
    node_ip     => $capstan_network::node_ip,
    listen_port => $capstan_network::listen_port,
    mtu         => $capstan_network::mtu,
    peers       => $capstan_network::peers,
  }
}
