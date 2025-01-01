# capstan_storage::params
# Default parameters for storage pool configuration, ZFS datasets, and encryption.
class capstan_storage::params {
  $enable_zfs            = true
  $zfs_pool_name         = 'capstan_pool'
  $enable_luks           = false
  $luks_device           = '/dev/nvme0n1'
  $luks_volume_name      = 'capstan_crypt'
  $enable_nvme_of        = false
  $nvme_transport        = 'tcp'
  $nvme_port             = 4420
  $enable_snapshots      = true
  $snapshot_retention    = 7
}
