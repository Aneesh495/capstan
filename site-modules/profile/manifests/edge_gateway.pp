# profile::edge_gateway
# Ingress and routing gateway profile for edge facilities.
class profile::edge_gateway {
  include profile::base
  include capstan_gateway
  include capstan_cluster
}
