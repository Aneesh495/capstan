# frozen_string_literal: true

Puppet::Type.newtype(:wireguard_tunnel) do
  @doc = 'Manages WireGuard zero-trust network overlay interfaces and dynamic peer routes.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Interface name (e.g. wg0).'
  end

  newproperty(:node_ip) do
    desc 'CIDR IPv4 address assigned to this tunnel interface (e.g. 10.42.0.1/32).'
  end

  newproperty(:listen_port) do
    desc 'UDP port on which the WireGuard interface listens for incoming tunnels.'
    defaultto 51820
    validate do |value|
      port = value.to_i
      raise ArgumentError, "Invalid port: #{value}" unless port >= 1 && port <= 65535
    end
  end

  newproperty(:mtu) do
    desc 'Maximum Transmission Unit for the overlay tunnel interface.'
    defaultto 1420
  end

  newproperty(:peers, array_matching: :all) do
    desc 'Array of hash definitions for peer nodes (public_key, endpoint, allowed_ips).'
    defaultto []
  end
end
