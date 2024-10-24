# capstan_kernel::cpu_isolation
# Configures systemd global affinity exclusions and cgroups v2 cpuset isolation.
class capstan_kernel::cpu_isolation {
  $isolated_cores = $capstan_kernel::isolated_cores
  $system_affinity_conf = '/etc/systemd/system.conf.d/10-capstan-cpu-affinity.conf'

  file { '/etc/systemd/system.conf.d':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $system_affinity_conf:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('capstan_kernel/cpu_affinity.conf.epp', {
      'isolated_cores' => $isolated_cores,
    }),
    require => File['/etc/systemd/system.conf.d'],
  }

  # Declare custom resource type cpu_isolation for the real-time slice
  cpu_isolation { 'capstan_realtime_slice':
    ensure         => present,
    isolated_cores => $isolated_cores,
    cgroup_path    => '/sys/fs/cgroup/capstan_realtime.slice',
    exclusive      => true,
  }
}
