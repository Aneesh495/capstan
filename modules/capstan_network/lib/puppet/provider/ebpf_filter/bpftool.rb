# frozen_string_literal: true

Puppet::Type.type(:ebpf_filter).provide(:bpftool) do
  desc 'Manages eBPF filter attachments using ip and bpftool.'

  commands ip: 'ip'
  defaultfor kernel: 'Linux'

  def exists?
    output = ip('link', 'show', 'dev', resource[:interface])
    output.include?('xdp')
  rescue StandardError
    false
  end

  def create
    dev = resource[:interface]
    mode_flag = case resource[:mode].to_s
                when 'native' then 'xdp'
                when 'hw'     then 'xdpoffload'
                else 'xdpgeneric'
                end

    # Check if bytecode object file exists before attaching
    obj_file = "/opt/capstan/lib/bpf/#{resource[:name]}.o"
    if File.file?(obj_file)
      ip('link', 'set', 'dev', dev, mode_flag, 'obj', obj_file, 'sec', resource[:section])
    else
      Puppet.notice("eBPF bytecode file #{obj_file} not found; recorded desired state attachment")
    end
  end

  def destroy
    dev = resource[:interface]
    ip('link', 'set', 'dev', dev, 'xdp', 'off') rescue nil
  end
end
