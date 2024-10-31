# capstan_kernel::numa
# Orchestrates NUMA memory policies, node binding, and memory zone balancing.
class capstan_kernel::numa (
  Enum['interleave', 'bind', 'preferred', 'local'] $default_policy = 'local',
) {
  $numa_policy_file = '/etc/capstan/numa_policy.json'

  # Generate NUMA configuration manifest
  file { $numa_policy_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => inline_epp(@(END)),
      {
        "default_policy": "<%= $default_policy %>",
        "numa_nodes_discovered": <%= $facts['capstan_numa'] ? { undef => 1, default => $facts['capstan_numa']['nodes_count'] } %>,
        "auto_balance": true,
        "prefer_node_local_allocations": true
      }
      END
  }

  # Ensure kernel automatic NUMA balancing is enabled unless single node
  $numa_balancing_val = $facts['capstan_numa'] ? {
    undef   => '0',
    default => $facts['capstan_numa']['nodes_count'] > 1 ? { true => '1', default => '0' },
  }

  exec { 'capstan_set_numa_balancing':
    command => "echo ${numa_balancing_val} > /proc/sys/kernel/numa_balancing",
    path    => ['/bin', '/usr/bin'],
    onlyif  => 'test -f /proc/sys/kernel/numa_balancing',
  }
}
