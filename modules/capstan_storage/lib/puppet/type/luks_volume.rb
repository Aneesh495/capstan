# frozen_string_literal: true

Puppet::Type.newtype(:luks_volume) do
  @doc = 'Manages LUKS2 hardware block-level encrypted volume mappings and key slots.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Mapped device-mapper target name (e.g. capstan_crypt).'
  end

  newproperty(:device) do
    desc 'Underlying raw physical block device (e.g. /dev/nvme0n1).'
  end

  newproperty(:cipher) do
    desc 'Encryption cipher and mode.'
    defaultto 'aes-xts-plain64'
  end

  newproperty(:key_size) do
    desc 'Cryptographic key size in bits.'
    defaultto 512
  end

  newproperty(:key_file) do
    desc 'Path to symmetric key file for automated volume unlock.'
    defaultto '/etc/capstan/keys/luks.key'
  end
end
