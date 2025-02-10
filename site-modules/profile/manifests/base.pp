# profile::base
# Foundation profile applied to every managed node in the Capstan cluster.
class profile::base {
  # Strict topological class order
  include capstan_core
  include capstan_kernel
  include capstan_network
  include capstan_security
  include capstan_telemetry
  include capstan_audit

  Class['capstan_core']
  -> Class['capstan_kernel']
  -> Class['capstan_network']
  -> Class['capstan_security']
  -> Class['capstan_telemetry']
  -> Class['capstan_audit']
}
