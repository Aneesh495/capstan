# capstan_storage::nvme_of
# Provisions NVMe over Fabrics (NVMe-oF) low-latency block transport exports.
class capstan_storage::nvme_of {
  $port      = $capstan_storage::params::nvme_port
  $transport = $capstan_storage::params::nvme_transport
  $subsystem = 'nqn.2026-11.io.capstan:edge-storage-subsys'

  exec { 'capstan_modprobe_nvmet':
    command => 'modprobe nvmet_tcp 2>/dev/null || true',
    path    => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
    onlyif  => 'which modprobe',
  }

  file { '/etc/capstan/nvme_of.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => inline_epp(@(END)),
      # Capstan NVMe-oF Configuration
      SUBSYSTEM="<%= $subsystem %>"
      TRANSPORT="<%= $transport %>"
      PORT=<%= $port %>
      END
  }
}
