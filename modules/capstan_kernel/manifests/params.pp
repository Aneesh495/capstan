# capstan_kernel::params
# Default parameters for kernel low-latency tuning, memory layout, and CPU pinning.
class capstan_kernel::params {
  $enable_sysctl_tuning = true
  $enable_cpu_isolation = false
  $isolated_cores       = []
  $enable_numa_tuning   = true
  $enable_hugepages     = false
  $hugepages_size_mb    = 2
  $hugepages_count      = 1024
  $io_scheduler         = 'kyber'
  $irq_balance_banned   = []
  $realtime_prio        = 80
}
