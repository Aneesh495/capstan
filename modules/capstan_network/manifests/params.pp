# capstan_network::params
# Default parameters for WireGuard mesh, eBPF filters, and network interfaces.
class capstan_network::params {
  $interface_name     = 'wg0'
  $mesh_cidr          = '10.42.0.0/16'
  $node_ip            = '10.42.0.1/32'
  $listen_port        = 51820
  $peers              = []
  $enable_ebpf_xdp    = true
  $xdp_interface      = 'eth0'
  $xdp_mode           = 'skb'
  $enable_vrf         = true
  $vrf_table_id       = 1042
  $vrf_name           = 'vrf-edge'
  $mtu                = 1420
  $enable_shaping     = true
  $rate_limit_mbps    = 1000
}
