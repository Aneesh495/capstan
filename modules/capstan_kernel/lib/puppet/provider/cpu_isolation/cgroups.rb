# frozen_string_literal: true

Puppet::Type.type(:cpu_isolation).provide(:cgroups) do
  desc 'Manages CPU isolation using cgroups v2 cpuset controllers and sysfs.'

  defaultfor kernel: 'Linux'

  def exists?
    File.directory?(resource[:cgroup_path]) &&
      File.file?("#{resource[:cgroup_path]}/cpuset.cpus")
  end

  def create
    require 'fileutils'
    FileUtils.mkdir_p(resource[:cgroup_path])
    set_isolated_cores(resource[:isolated_cores])
  end

  def destroy
    require 'fileutils'
    if File.directory?(resource[:cgroup_path])
      FileUtils.rm_rf(resource[:cgroup_path])
    end
  end

  def isolated_cores
    cpus_file = "#{resource[:cgroup_path]}/cpuset.cpus"
    return [] unless File.file?(cpus_file)

    raw = File.read(cpus_file).strip
    return [] if raw.empty?

    # Parse ranges like "2-3,6" into array of integers
    cores = []
    raw.split(',').each do |part|
      if part.include?('-')
        first, last = part.split('-').map(&:to_i)
        cores.concat((first..last).to_a)
      else
        cores << part.to_i
      end
    end
    cores
  end

  def isolated_cores=(cores)
    set_isolated_cores(cores)
  end

  private

  def set_isolated_cores(cores)
    cpus_file = "#{resource[:cgroup_path]}/cpuset.cpus"
    formatted = Array(cores).map(&:to_s).join(',')
    File.write(cpus_file, "#{formatted}\n") if File.directory?(resource[:cgroup_path])
  end
end
