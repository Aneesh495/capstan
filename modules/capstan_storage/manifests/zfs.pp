# capstan_storage::zfs
# Provisions primary datasets for persistent state, transaction journals, and container volumes.
class capstan_storage::zfs {
  $pool = $capstan_storage::zfs_pool_name

  # Declare custom zfs_dataset resources
  zfs_dataset { "${pool}/state":
    ensure      => present,
    mountpoint  => '/var/lib/capstan/state',
    compression => 'lz4',
    atime       => 'off',
    recordsize  => '128k',
  }

  zfs_dataset { "${pool}/journal":
    ensure      => present,
    mountpoint  => '/var/lib/capstan/journal',
    compression => 'zstd',
    atime       => 'off',
    recordsize  => '64k',
    sync        => 'always',
  }

  zfs_dataset { "${pool}/volumes":
    ensure      => present,
    mountpoint  => '/var/lib/capstan/volumes',
    compression => 'lz4',
    atime       => 'off',
    recordsize  => '128k',
  }
}
