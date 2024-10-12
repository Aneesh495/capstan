# frozen_string_literal: true

require 'facter'
require 'json'

# Facter Fact: capstan_agent
# Returns structured information regarding the local Capstan autonomous agent release and socket status.
Facter.add(:capstan_agent) do
  setcode do
    agent_info = {
      'version'       => '1.0.0',
      'engine'        => 'capstand',
      'protocol'      => 'CAP1',
      'socket_alive'  => false,
      'socket_path'   => '/run/capstan/capstand.sock',
      'installed'     => false,
      'installed_dir' => '/opt/capstan',
    }

    if File.directory?('/opt/capstan')
      agent_info['installed'] = true
    end

    if File.socket?('/run/capstan/capstand.sock')
      agent_info['socket_alive'] = true
    end

    agent_info
  end
end
