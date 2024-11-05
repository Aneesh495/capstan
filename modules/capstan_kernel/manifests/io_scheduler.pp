# capstan_kernel::io_scheduler
# Deploys udev rules to enforce deterministic queue scheduling across all block devices.
class capstan_kernel::io_scheduler {
  $io_scheduler = $capstan_kernel::io_scheduler
  $udev_rule    = '/etc/udev/rules.d/60-capstan-schedulers.rules'

  file { $udev_rule:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('capstan_kernel/udev_io_scheduler.rules.epp', {
      'io_scheduler' => $io_scheduler,
    }),
    notify  => Exec['capstan_reload_udev_rules'],
  }

  exec { 'capstan_reload_udev_rules':
    command     => 'udevadm control --reload && udevadm trigger --type=devices --subsystem-match=block',
    refreshonly => true,
    path        => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
    onlyif      => 'which udevadm',
  }
}
