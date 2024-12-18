# frozen_string_literal: true

require 'json'
require 'fileutils'

Puppet::Type.type(:seccomp_profile).provide(:json) do
  desc 'Manages JSON seccomp-bpf filter profile manifests on disk.'

  def exists?
    File.exist?(resource[:profile_path])
  end

  def create
    dir = File.dirname(resource[:profile_path])
    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    payload = {
      'profile_name'    => resource[:name],
      'defaultAction'   => resource[:default_action],
      'architectures'   => ['SCMP_ARCH_X86_64', 'SCMP_ARCH_AARCH64'],
      'syscalls'        => [
        {
          'names'  => resource[:allowed_syscalls],
          'action' => 'SCMP_ACT_ALLOW',
        }
      ]
    }

    File.write(resource[:profile_path], JSON.pretty_generate(payload))
  end

  def destroy
    File.delete(resource[:profile_path]) if File.exist?(resource[:profile_path])
  end
end
