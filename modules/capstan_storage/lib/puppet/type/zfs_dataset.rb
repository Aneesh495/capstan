# frozen_string_literal: true

Puppet::Type.newtype(:zfs_dataset) do
  @doc = 'Manages ZFS datasets, filesystem mountpoints, and compression algorithms.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Dataset path (e.g. capstan_pool/state).'
  end

  newproperty(:mountpoint) do
    desc 'Filesystem path where dataset is mounted.'
  end

  newproperty(:compression) do
    desc 'Compression algorithm (lz4, zstd, gzip, off).'
    newvalues(:lz4, :zstd, :gzip, :off)
    defaultto :lz4
  end

  newproperty(:atime) do
    desc 'Access time update behavior (on, off).'
    newvalues(:on, :off)
    defaultto :off
  end

  newproperty(:recordsize) do
    desc 'Suggested block record size (e.g. 64k, 128k, 1M).'
    defaultto '128k'
  end

  newproperty(:sync) do
    desc 'Synchronous write transaction behavior (standard, always, disabled).'
    newvalues(:standard, :always, :disabled)
    defaultto :standard
  end
end
