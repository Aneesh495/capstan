# capstan_core::staging
# Manages transactional catalog staging directory and rollback snapshot storage.
class capstan_core::staging (
  Stdlib::Absolutepath $staging_dir = $capstan_core::capstan_core::params::staging_dir,
) {
  $pending_dir   = "${staging_dir}/pending"
  $rollback_dir  = "${staging_dir}/rollback"
  $committed_dir = "${staging_dir}/committed"

  file { [$pending_dir, $rollback_dir, $committed_dir]:
    ensure  => directory,
    owner   => $capstan_core::params::user,
    group   => $capstan_core::params::group,
    mode    => '0750',
    require => Class['capstan_core::directories'],
  }

  # Staging cleanup sentinel to ensure orphaned transactions are pruned
  file { "${staging_dir}/.staging_policy":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "# Capstan Staging Policy: Atomic transactions only\nMAX_PENDING_HOURS=24\nAUTO_ROLLBACK_ON_ERROR=true\n",
  }
}
