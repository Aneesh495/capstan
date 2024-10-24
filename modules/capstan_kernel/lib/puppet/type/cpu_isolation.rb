# frozen_string_literal: true

Puppet::Type.newtype(:cpu_isolation) do
  @doc = 'Manages dedicated isolated CPU core affinities and cgroups v2 cpuset boundaries.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Unique identifier for the CPU isolation domain (e.g., realtime_slice).'
  end

  newproperty(:isolated_cores, array_matching: :all) do
    desc 'List of logical CPU core IDs to dedicate exclusively to this slice.'
    validate do |value|
      raise ArgumentError, "CPU core ID must be an integer, got #{value}" unless value.to_s =~ /^\d+$/
    end
  end

  newproperty(:cgroup_path) do
    desc 'Filesystem path for cgroups v2 slice (e.g. /sys/fs/cgroup/realtime.slice).'
    defaultto '/sys/fs/cgroup/capstan_realtime.slice'
  end

  newproperty(:exclusive) do
    desc 'Whether CPU cores are strictly exclusive to tasks within this domain.'
    newvalues(:true, :false)
    defaultto :true
  end
end
