# capstan_gateway
#
# Primary class managing edge reverse proxy, TLS termination, and health probes.
#
# @param ingress_port External TCP port for inbound edge traffic.
# @param backend_port Internal port where workload containers or services listen.
# @param enable_tls_termination Terminate TLS at gateway before routing internally.
class capstan_gateway (
  Stdlib::Port $ingress_port           = 443,
  Stdlib::Port $backend_port           = 8080,
  Boolean      $enable_tls_termination = true,
) {
  contain capstan_gateway::proxy
  contain capstan_gateway::health
}
