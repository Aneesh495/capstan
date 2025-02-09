# frozen_string_literal: true

require 'ipaddr'

# Puppet 4/8 modern function: capstan::cidr_split
# Divides a parent CIDR prefix into deterministic subnets of a target prefix length.
Puppet::Functions.create_function(:'capstan::cidr_split') do
  dispatch :split do
    param 'String', :parent_cidr
    param 'Integer', :target_prefix
    return_type 'Array[String]'
  end

  def split(parent_cidr, target_prefix)
    parent = IPAddr.new(parent_cidr)
    current_prefix = parent_cidr.split('/')[1].to_i
    raise ArgumentError, "Target prefix #{target_prefix} must be >= current prefix #{current_prefix}" if target_prefix < current_prefix

    subnets = []
    step = 2**(32 - target_prefix)
    count = 2**(target_prefix - current_prefix)

    start_ip = parent.to_i
    count.times do |i|
      subnet_ip = IPAddr.new(start_ip + (i * step), Socket::AF_INET)
      subnets << "#{subnet_ip}/#{target_prefix}"
    end

    subnets
  end
end
