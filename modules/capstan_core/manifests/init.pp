# capstan_core
#
# Primary class managing node identity, supervisor daemon, filesystem layout,
# and convergence lifecycle on Capstan edge infrastructure.
#
# @param prefix Root installation directory prefix.
# @param config_dir Configuration directory for node settings.
# @param data_dir State data directory for persistence.
# @param run_dir Runtime ephemeral directory for sockets and PID files.
# @param log_dir System log destination for capstand.
# @param convergence_seconds Polling frequency for autonomic convergence loop.
# @param log_level Verbosity level for daemon logging.
# @param api_port Port for local inspection REST API.
class capstan_core (
  Stdlib::Absolutepath $prefix              = $capstan_core::params::prefix,
  Stdlib::Absolutepath $config_dir          = $capstan_core::params::config_dir,
  Stdlib::Absolutepath $data_dir            = $capstan_core::params::data_dir,
  Stdlib::Absolutepath $run_dir             = $capstan_core::params::run_dir,
  Stdlib::Absolutepath $log_dir             = $capstan_core::params::log_dir,
  Integer[1, 3600]     $convergence_seconds = $capstan_core::params::convergence_seconds,
  Enum['debug', 'info', 'warn', 'error'] $log_level = $capstan_core::params::log_level,
  Stdlib::Port         $api_port            = $capstan_core::params::api_port,
  Boolean              $service_enable      = $capstan_core::params::service_enable,
  Enum['running', 'stopped'] $service_ensure = $capstan_core::params::service_ensure,
) inherits capstan_core::params {

  # Anchor pattern to guarantee strict topological execution order
  contain capstan_core::directories
  contain capstan_core::identity
  contain capstan_core::journal
  contain capstan_core::staging
  contain capstan_core::service

  Class['capstan_core::directories']
  -> Class['capstan_core::identity']
  -> Class['capstan_core::journal']
  -> Class['capstan_core::staging']
  -> Class['capstan_core::service']
}
