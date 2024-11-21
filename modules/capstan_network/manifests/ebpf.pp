# capstan_network::ebpf
# Attaches line-rate eBPF XDP packet filter bytecode to network interface.
class capstan_network::ebpf {
  $interface  = $capstan_network::params::xdp_interface
  $mode       = $capstan_network::params::xdp_mode
  $bpf_dir    = "${capstan_core::prefix}/lib/bpf"
  $bpf_filter = "${bpf_dir}/xdp_drop_invalid.o"

  file { $bpf_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Declare custom ebpf_filter resource
  ebpf_filter { "xdp_${interface}":
    ensure         => present,
    interface      => $interface,
    section        => 'xdp',
    mode           => $mode,
    pinned_map_dir => '/sys/fs/bpf/capstan',
    require        => File[$bpf_dir],
  }
}
