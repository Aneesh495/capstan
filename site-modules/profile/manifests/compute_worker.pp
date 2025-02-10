# profile::compute_worker
# Dedicated edge compute worker node profile.
class profile::compute_worker {
  include profile::base
  include capstan_workload
}
