# profile::colo_hypervisor
# Low-latency trading and colocation compute hypervisor profile.
class profile::colo_hypervisor {
  include profile::base
  include capstan_workload
  include capstan_cluster
}
