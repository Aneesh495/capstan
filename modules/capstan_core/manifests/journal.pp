# capstan_core::journal
# Manages state convergence transaction journals, rollback snapshots, and rotation policies.
class capstan_core::journal (
  Stdlib::Absolutepath $journal_dir = $capstan_core::capstan_core::params::journal_dir,
  Integer[10, 1000]    $max_entries = $capstan_core::capstan_core::params::max_journal_entries,
) {
  $rotate_script = "${capstan_core::prefix}/bin/capstan-journal-rotate"

  file { $rotate_script:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => epp('capstan_core/journal_rotate.sh.epp', {
      'journal_dir' => $journal_dir,
      'max_entries' => $max_entries,
    }),
    require => Class['capstan_core::directories'],
  }

  # Hourly cron job to prune stale convergence transaction journals
  cron { 'capstan_journal_rotation':
    ensure  => present,
    command => $rotate_script,
    user    => 'root',
    minute  => 17,
    require => File[$rotate_script],
  }
}
