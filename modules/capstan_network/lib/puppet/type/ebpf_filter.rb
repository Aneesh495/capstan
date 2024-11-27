# frozen_string_literal: true

Puppet::Type.newtype(:ebpf_filter) do
  @doc = 'Manages eBPF XDP and tc packet filters attached to network devices.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Identifier for the eBPF program attachment.'
  end

  newproperty(:interface) do
    desc 'Target network device name (e.g. eth0, wg0).'
    validate do |value|
      raise ArgumentError, 'Interface name must be non-empty string' if value.to_s.empty?
    end
  end

  newproperty(:section) do
    desc 'ELF section name containing the BPF bytecode program (e.g. xdp, classifier).'
    defaultto 'xdp'
  end

  newproperty(:mode) do
    desc 'Attachment mode (native, skb, hw).'
    newvalues(:native, :skb, :hw)
    defaultto :skb
  end

  newproperty(:pinned_map_dir) do
    desc 'Path in /sys/fs/bpf where maps are pinned.'
    defaultto '/sys/fs/bpf/capstan'
  end
end
