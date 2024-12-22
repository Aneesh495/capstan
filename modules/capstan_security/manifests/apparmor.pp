# capstan_security::apparmor
# Configures AppArmor containment profiles for the Capstan runtime daemon.
class capstan_security::apparmor {
  $profile_file = '/etc/apparmor.d/opt.capstan.bin.capstand'

  file { $profile_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @(END),
      #include <tunables/global>

      profile capstand /opt/capstan/bin/capstand {
        #include <abstractions/base>
        #include <abstractions/nameservice>

        capability net_admin,
        capability sys_admin,
        capability bpf,
        capability perfmon,

        /opt/capstan/** r,
        /opt/capstan/bin/capstand mr,
        /etc/capstan/** rw,
        /var/lib/capstan/** rwk,
        /run/capstan/** rwk,
        /proc/sys/net/** rw,
        /proc/sys/vm/** rw,
        /sys/devices/** r,
        /sys/fs/bpf/** rw,
        /sys/fs/cgroup/** rw,
      }
      END
    notify  => Exec['capstan_reload_apparmor_profile'],
  }

  exec { 'capstan_reload_apparmor_profile':
    command     => "apparmor_parser -r -W ${profile_file}",
    refreshonly => true,
    path        => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
    onlyif      => 'which apparmor_parser',
  }
}
