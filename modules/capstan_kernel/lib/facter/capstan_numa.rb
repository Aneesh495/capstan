# frozen_string_literal: true

require 'facter'

# Facter Fact: capstan_numa
# Discovers NUMA nodes, socket affinities, and memory distribution across sockets.
Facter.add(:capstan_numa) do
  confine kernel: 'Linux'

  setcode do
    numa_data = {
      'nodes_count' => 1,
      'nodes'       => {},
    }

    node_dirs = Dir.glob('/sys/devices/system/node/node[0-9]*')
    if node_dirs.empty?
      numa_data['nodes_count'] = 1
      numa_data['nodes']['node0'] = {
        'cpulist'   => '0',
        'memtotal_kb' => 0,
      }
    else
      numa_data['nodes_count'] = node_dirs.length
      node_dirs.each do |dir|
        node_name = File.basename(dir)
        cpulist_file = File.join(dir, 'cpulist')
        meminfo_file = File.join(dir, 'meminfo')

        cpus = File.file?(cpulist_file) ? File.read(cpulist_file).strip : '0'
        memtotal = 0

        if File.file?(meminfo_file)
          File.foreach(meminfo_file) do |line|
            if line =~ /MemTotal:\s+(\d+)\s+kB/
              memtotal = Regexp.last_match(1).to_i
              break
            end
          end
        end

        numa_data['nodes'][node_name] = {
          'cpulist'     => cpus,
          'memtotal_kb' => memtotal,
        }
      end
    end

    numa_data
  end
end
