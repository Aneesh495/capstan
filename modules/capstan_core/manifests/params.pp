# capstan_core::params
# Default parameters and operating system specific configurations for capstan_core.
class capstan_core::params {
  $prefix              = '/opt/capstan'
  $config_dir          = '/etc/capstan'
  $data_dir            = '/var/lib/capstan'
  $run_dir             = '/run/capstan'
  $log_dir             = '/var/log/capstan'
  $journal_dir         = '/var/lib/capstan/journal'
  $staging_dir         = '/var/lib/capstan/staging'
  $ledger_dir          = '/var/lib/capstan/ledger'
  $user                = 'root'
  $group               = 'root'
  $service_name        = 'capstand'
  $service_enable      = true
  $service_ensure      = 'running'
  $convergence_seconds = 10
  $log_level           = 'info'
  $socket_path         = '/run/capstan/capstand.sock'
  $api_port            = 8443
  $telemetry_enabled   = true
  $max_journal_entries = 100
}
