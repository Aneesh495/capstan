# capstan_core::directories
# Manages system directory hierarchy for binary storage, state, journals, and runtime files.
class capstan_core::directories {
  $directories = [
    $capstan_core::prefix,
    "${capstan_core::prefix}/bin",
    "${capstan_core::prefix}/lib",
    $capstan_core::config_dir,
    "${capstan_core::config_dir}/conf.d",
    "${capstan_core::config_dir}/keys",
    $capstan_core::data_dir,
    $capstan_core::capstan_core::params::journal_dir,
    $capstan_core::capstan_core::params::staging_dir,
    $capstan_core::capstan_core::params::ledger_dir,
    $capstan_core::run_dir,
    $capstan_core::log_dir,
  ]

  file { $directories:
    ensure => directory,
    owner  => $capstan_core::params::user,
    group  => $capstan_core::params::group,
    mode   => '0750',
  }

  file { "${capstan_core::config_dir}/keys":
    ensure => directory,
    owner  => $capstan_core::params::user,
    group  => $capstan_core::params::group,
    mode   => '0700',
  }
}
