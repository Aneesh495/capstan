# frozen_string_literal: true

require 'facter'

# Facter Fact: capstan_ebpf
# Gathers Linux kernel eBPF JIT compiler status, map limits, and BPF filesystem mount.
Facter.add(:capstan_ebpf) do
  confine kernel: 'Linux'

  setcode do
    ebpf_info = {
      'jit_enabled'      => false,
      'jit_harden'       => 0,
      'bpffs_mounted'    => false,
      'bpf_helper_probe' => false,
    }

    if File.file?('/proc/sys/net/core/bpf_jit_enable')
      val = File.read('/proc/sys/net/core/bpf_jit_enable').strip.to_i
      ebpf_info['jit_enabled'] = (val == 1)
    end

    if File.file?('/proc/sys/net/core/bpf_jit_harden')
      ebpf_info['jit_harden'] = File.read('/proc/sys/net/core/bpf_jit_harden').strip.to_i
    end

    if File.directory?('/sys/fs/bpf')
      ebpf_info['bpffs_mounted'] = true
    end

    ebpf_info
  end
end
