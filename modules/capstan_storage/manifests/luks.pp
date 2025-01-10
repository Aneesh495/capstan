# capstan_storage::luks
# Orchestrates hardware encrypted storage volumes and key slot lifecycle.
class capstan_storage::luks {
  $device      = $capstan_storage::params::luks_device
  $volume_name = $capstan_storage::params::luks_volume_name
  $key_file    = "${capstan_core::config_dir}/keys/luks.key"

  # Generate symmetric key if missing
  exec { 'capstan_generate_luks_key':
    command => "dd if=/dev/urandom of=${key_file} bs=512 count=1 && chmod 0400 ${key_file}",
    creates => $key_file,
    path    => ['/bin', '/usr/bin'],
  }

  luks_volume { $volume_name:
    ensure   => present,
    device   => $device,
    key_file => $key_file,
    require  => Exec['capstan_generate_luks_key'],
  }
}
