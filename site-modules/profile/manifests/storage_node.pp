# profile::storage_node
# Resilient edge storage mesh node profile.
class profile::storage_node {
  include profile::base
  include capstan_storage
  include capstan_cluster
}
