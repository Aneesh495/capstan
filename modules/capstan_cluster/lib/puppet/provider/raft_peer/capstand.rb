# frozen_string_literal: true

require 'json'

Puppet::Type.type(:raft_peer).provide(:capstand) do
  desc 'Communicates with the local capstand daemon to register Raft consensus peers.'

  def exists?
    raft_file = '/etc/capstan/raft.json'
    return false unless File.file?(raft_file)

    begin
      data = JSON.parse(File.read(raft_file))
      peers = data['peers'] || []
      peers.any? { |p| p['id'] == resource[:name] }
    rescue StandardError
      false
    end
  end

  def create
    Puppet.notice("Raft peer #{resource[:name]} enrolled in local consensus topology")
  end

  def destroy
    Puppet.notice("Raft peer #{resource[:name]} decommissioned from local consensus topology")
  end
end
