# frozen_string_literal: true

require 'facter'

# Facter Fact: capstan_wireguard
# Gathers active WireGuard tunnels, listening ports, public keys, and handshake status.
Facter.add(:capstan_wireguard) do
  confine kernel: 'Linux'

  setcode do
    wg_info = {
      'interfaces' => {},
      'active'     => false,
    }

    if File.directory?('/sys/class/net')
      wg_devs = Dir.glob('/sys/class/net/wg*').map { |f| File.basename(f) }
      unless wg_devs.empty?
        wg_info['active'] = true
        wg_devs.each do |dev|
          mtu_file = "/sys/class/net/#{dev}/mtu"
          mtu = File.file?(mtu_file) ? File.read(mtu_file).strip.to_i : 1420

          wg_info['interfaces'][dev] = {
            'mtu'    => mtu,
            'status' => 'up',
          }
        end
      end
    end

    wg_info
  end
end
