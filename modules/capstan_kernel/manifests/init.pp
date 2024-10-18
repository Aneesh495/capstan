# capstan_kernel
#
# Orchestrates low-latency deterministic Linux kernel parameters, memory policies,
# CPU isolation boundaries, hugepage allocations, and I/O queue schedulers.
#
# @param enable_sysctl_tuning Apply optimized sysctl network and memory parameters.
# @param enable_cpu_isolation Isolate specific CPU cores from standard OS scheduler.
# @param isolated_cores List of CPU core IDs reserved for dedicated real-time execution.
# @param enable_numa_tuning Configure NUMA memory allocation policies and balancing.
# @param enable_hugepages Allocate static hugepage pools at boot.
# @param hugepages_count Number of hugepages to pre-allocate.
# @param io_scheduler Target I/O scheduler algorithm for block devices (none, kyber, bfq).
class capstan_kernel (
  Boolean       $enable_sysctl_tuning = $capstan_kernel::params::enable_sysctl_tuning,
  Boolean       $enable_cpu_isolation = $capstan_kernel::params::enable_cpu_isolation,
  Array[Integer]$isolated_cores       = $capstan_kernel::params::isolated_cores,
  Boolean       $enable_numa_tuning   = $capstan_kernel::params::enable_numa_tuning,
  Boolean       $enable_hugepages     = $capstan_kernel::params::enable_hugepages,
  Integer[0]    $hugepages_count      = $capstan_kernel::params::hugepages_count,
  Enum['none', 'kyber', 'bfq', 'mq-deadline'] $io_scheduler = $capstan_kernel::params::io_scheduler,
) inherits capstan_kernel::params {

  if $enable_sysctl_tuning {
    contain capstan_kernel::sysctl
  }

  if $enable_cpu_isolation and !empty($isolated_cores) {
    contain capstan_kernel::cpu_isolation
  }

  if $enable_numa_tuning {
    contain capstan_kernel::numa
  }

  if $enable_hugepages and $hugepages_count > 0 {
    contain capstan_kernel::hugepages
  }

  contain capstan_kernel::io_scheduler
  contain capstan_kernel::irq_balance
}
