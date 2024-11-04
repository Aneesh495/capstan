# capstan_kernel::hugepages
# Configures static hugepage allocation and hugetlbfs filesystem mount.
class capstan_kernel::hugepages {
  $count = $capstan_kernel::hugepages_count
  $unit_file = '/etc/systemd/system/capstan-hugepages.service'

  file { $unit_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('capstan_kernel/hugepages.service.epp', {
      'hugepages_count' => $count,
    }),
    notify  => Exec['capstan_hugepages_reload'],
  }

  exec { 'capstan_hugepages_reload':
    command     => 'systemctl daemon-reload && systemctl enable --now capstan-hugepages.service',
    refreshonly => true,
    path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
    onlyif      => 'which systemctl',
  }

  # Direct runtime allocation fallback
  exec { 'capstan_allocate_hugepages_runtime':
    command => "echo ${count} > /proc/sys/vm/nr_hugepages",
    path    => ['/bin', '/usr/bin'],
    onlyif  => "test -f /proc/sys/vm/nr_hugepages && test $(cat /proc/sys/vm/nr_hugepages) -lt ${count}",
  }
}
