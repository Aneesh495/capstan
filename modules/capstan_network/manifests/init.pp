# capstan_network
#
# Primary class managing zero-trust WireGuard encrypted mesh overlay,
# eBPF XDP line-rate packet filters, traffic shaping, and VRF domain isolation.
#
# @param interface_name Tunnel device name for WireGuard mesh.
# @param mesh_cidr Global overlay subnet for the cluster.
# @param node_ip Dedicated IP address assigned to this node on the mesh.
# @param listen_port UDP port for WireGuard protocol handshakes.
# @param peers List of peer definitions containing public_key, endpoint, and allowed_ips.
# @param enable_ebpf_xdp Attach line-rate eBPF XDP filter to physical interface.
# @param enable_vrf Isolate mesh traffic into a dedicated routing table.
class capstan_network (
  String                $interface_name  = $capstan_network::params::interface_name,
  Stdlib::IP::Address   $mesh_cidr       = $capstan_network::params::mesh_cidr,
  Stdlib::IP::Address   $node_ip         = $capstan_network::params::node_ip,
  Stdlib::Port          $listen_port     = $capstan_network::params::listen_port,
  Array[Hash[String, Any]] $peers        = $capstan_network::params::peers,
  Boolean               $enable_ebpf_xdp = $capstan_network::params::enable_ebpf_xdp,
  Boolean               $enable_vrf      = $capstan_network::params::enable_vrf,
  Integer[1280, 9000]   $mtu             = $capstan_network::params::mtu,
) inherits capstan_network::params {

  contain capstan_network::wireguard

  if $enable_ebpf_xdp {
    contain capstan_network::ebpf
  }

  if $enable_vrf {
    contain capstan_network::vrf
  }

  contain capstan_network::traffic_shaping
  contain capstan_network::mtu
}
