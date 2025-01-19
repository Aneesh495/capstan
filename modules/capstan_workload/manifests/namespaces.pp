# capstan_workload::namespaces
# Configures persistent network and mount namespace scaffolding.
class capstan_workload::namespaces {
  $netns_dir = '/var/run/netns'

  file { $netns_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/capstan/sandbox_policy.json':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @(END),
      {
        "isolation": "strict",
        "namespaces": ["net", "mnt", "ipc", "uts", "pid"],
        "readonly_rootfs": true,
        "no_new_privs": true
      }
      END
  }
}
