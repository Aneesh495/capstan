# capstan_workload::cgroups
# Configures systemd slice hierarchies for deterministic resource limits under cgroups v2.
class capstan_workload::cgroups {
  $slice_file = '/etc/systemd/system/capstan-workload.slice'

  file { $slice_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @(END),
      [Unit]
      Description=Capstan Workload Isolation Slice (cgroups v2)
      Documentation=https://github.com/Aneesh495/capstan

      [Slice]
      CPUWeight=100
      CPUQuota=400%
      MemoryHigh=2G
      MemoryMax=4G
      MemoryZSwapMax=512M
      IOWeight=100
      TasksMax=2048
      END
    notify  => Exec['capstan_workload_slice_reload'],
  }

  exec { 'capstan_workload_slice_reload':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
    path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
    onlyif      => 'which systemctl',
  }
}
