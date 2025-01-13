# capstan_storage::snapshots
# Automates atomic dataset snapshot creation and retention management.
class capstan_storage::snapshots {
  $pool      = $capstan_storage::zfs_pool_name
  $retention = $capstan_storage::params::snapshot_retention
  $script    = "${capstan_core::prefix}/bin/capstan-snapshot-rotate"

  file { $script:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => epp('capstan_storage/snapshot_rotate.sh.epp', {
      'pool'      => $pool,
      'retention' => $retention,
    }),
  }

  cron { 'capstan_snapshot_rotation':
    ensure  => present,
    command => $script,
    user    => 'root',
    hour    => 3,
    minute  => 30,
    require => File[$script],
  }
}
