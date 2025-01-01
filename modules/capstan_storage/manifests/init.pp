# capstan_storage
#
# Primary class managing resilient edge storage pools, ZFS datasets,
# LUKS2 cryptographic encryption, and NVMe over Fabrics fabric targets.
#
# @param enable_zfs Orchestrate local ZFS pool and datasets.
# @param zfs_pool_name Name of local root ZFS pool.
# @param enable_luks Manage hardware-encrypted LUKS2 volumes.
# @param enable_nvme_of Configure NVMe-oF low-latency storage network export.
# @param enable_snapshots Automate atomic dataset snapshot schedules.
class capstan_storage (
  Boolean $enable_zfs       = $capstan_storage::params::enable_zfs,
  String  $zfs_pool_name    = $capstan_storage::params::zfs_pool_name,
  Boolean $enable_luks      = $capstan_storage::params::enable_luks,
  Boolean $enable_nvme_of   = $capstan_storage::params::enable_nvme_of,
  Boolean $enable_snapshots = $capstan_storage::params::enable_snapshots,
) inherits capstan_storage::params {

  if $enable_zfs {
    contain capstan_storage::zfs
    contain capstan_storage::scrub
  }

  if $enable_luks {
    contain capstan_storage::luks
  }

  if $enable_nvme_of {
    contain capstan_storage::nvme_of
  }

  if $enable_snapshots {
    contain capstan_storage::snapshots
  }
}
