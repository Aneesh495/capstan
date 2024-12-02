# capstan_network::vrf
# Provisions Virtual Routing and Forwarding (VRF) domains for isolated mesh routing tables.
class capstan_network::vrf {
  $vrf_name  = $capstan_network::params::vrf_name
  $table_id  = $capstan_network::params::vrf_table_id
  $interface = $capstan_network::interface_name

  exec { "capstan_create_vrf_${vrf_name}":
    command => "ip link add ${vrf_name} type vrf table ${table_id} && ip link set ${vrf_name} up",
    path    => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
    unless  => "ip link show ${vrf_name}",
    onlyif  => 'which ip',
  }

  exec { "capstan_enslave_wg_to_vrf_${vrf_name}":
    command => "ip link set ${interface} master ${vrf_name}",
    path    => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
    onlyif  => "ip link show ${interface} && ip link show ${vrf_name}",
    require => Exec["capstan_create_vrf_${vrf_name}"],
  }
}
