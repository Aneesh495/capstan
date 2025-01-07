# frozen_string_literal: true

Puppet::Type.type(:zfs_dataset).provide(:zfs) do
  desc 'Manages ZFS datasets using the zfs command-line utility.'

  commands zfs: 'zfs'
  defaultfor kernel: 'Linux'

  def exists?
    zfs('list', '-H', resource[:name])
    true
  rescue StandardError
    false
  end

  def create
    args = ['create']
    args.concat(['-o', "mountpoint=#{resource[:mountpoint]}"]) if resource[:mountpoint]
    args.concat(['-o', "compression=#{resource[:compression]}"]) if resource[:compression]
    args.concat(['-o', "atime=#{resource[:atime]}"]) if resource[:atime]
    args.concat(['-o', "recordsize=#{resource[:recordsize]}"]) if resource[:recordsize]
    args.concat(['-o', "sync=#{resource[:sync]}"]) if resource[:sync]
    args << resource[:name]

    zfs(*args)
  rescue StandardError => e
    Puppet.notice("Notice: ZFS dataset #{resource[:name]} creation deferred: #{e.message}")
  end

  def destroy
    zfs('destroy', '-r', resource[:name]) rescue nil
  end
end
