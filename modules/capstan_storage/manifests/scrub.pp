# capstan_storage::scrub
# Automates weekly ZFS data pool scrub for silent data corruption detection.
class capstan_storage::scrub {
  $pool = $capstan_storage::zfs_pool_name

  cron { "capstan_zfs_scrub_${pool}":
    ensure   => present,
    command  => "zpool scrub ${pool} 2>/dev/null || true",
    user     => 'root',
    weekday  => 'Sunday',
    hour     => 2,
    minute   => 15,
  }
}
