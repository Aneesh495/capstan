# frozen_string_literal: true

Puppet::Type.type(:luks_volume).provide(:cryptsetup) do
  desc 'Manages LUKS2 encrypted volumes using the cryptsetup command.'

  commands cryptsetup: 'cryptsetup'
  defaultfor kernel: 'Linux'

  def exists?
    File.exist?("/dev/mapper/#{resource[:name]}")
  end

  def create
    dev = resource[:device]
    target = resource[:name]
    key = resource[:key_file]

    # Format if not already LUKS
    begin
      cryptsetup('isLuks', dev)
    rescue StandardError
      cryptsetup('luksFormat', '--type', 'luks2', '--cipher', resource[:cipher], '--key-size', resource[:key_size].to_s, '--key-file', key, dev) if File.exist?(key)
    end

    # Open volume mapping
    cryptsetup('open', '--type', 'luks2', '--key-file', key, dev, target) if File.exist?(key)
  rescue StandardError => e
    Puppet.notice("LUKS volume #{target} operation deferred: #{e.message}")
  end

  def destroy
    cryptsetup('close', resource[:name]) rescue nil
  end
end
