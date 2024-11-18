# frozen_string_literal: true

Puppet::Type.type(:wireguard_tunnel).provide(:wg) do
  desc 'Manages WireGuard interfaces using iproute2 and wg tools.'

  commands ip: 'ip', wg: 'wg'
  defaultfor kernel: 'Linux'

  def exists?
    return false unless File.exist?('/sys/class/net/' + resource[:name])
    true
  rescue StandardError
    false
  end

  def create
    dev = resource[:name]
    ip('link', 'add', 'dev', dev, 'type', 'wireguard')
    ip('address', 'add', resource[:node_ip], 'dev', dev)
    ip('link', 'set', 'mtu', resource[:mtu].to_s, 'dev', dev)
    ip('link', 'set', 'up', 'dev', dev)
    sync_peers
  end

  def destroy
    dev = resource[:name]
    ip('link', 'set', 'down', 'dev', dev)
    ip('link', 'del', 'dev', dev)
  rescue StandardError => e
    Puppet.warning("Error tearing down wireguard interface #{dev}: #{e.message}")
  end

  def sync_peers
    dev = resource[:name]
    Array(resource[:peers]).each do |peer|
      next unless peer.is_a?(Hash) && peer['public_key']
      args = ['set', dev, 'peer', peer['public_key']]
      args.concat(['endpoint', peer['endpoint']]) if peer['endpoint']
      if peer['allowed_ips']
        allowed = Array(peer['allowed_ips']).join(',')
        args.concat(['allowed-ips', allowed])
      end
      args.concat(['persistent-keepalive', '25'])
      wg(*args) rescue nil
    end
  end
end
