# capstan_workload
#
# Primary class managing process sandboxing, cgroups v2 resource control slices,
# and isolated network and mount namespaces for edge workloads.
#
# @param enable_cgroups_v2 Ensure cgroups v2 unified hierarchy is active.
# @param default_cpu_weight Relative CPU weight (1-10000) for standard workloads.
# @param default_memory_high_mb Memory high watermark before kernel throttling.
class capstan_workload (
  Boolean $enable_cgroups_v2     = true,
  Integer[1, 10000] $default_cpu_weight = 100,
  Integer[64, 1048576] $default_memory_high_mb = 2048,
) {
  contain capstan_workload::cgroups
  contain capstan_workload::namespaces
}
