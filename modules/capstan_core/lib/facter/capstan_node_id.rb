# frozen_string_literal: true

require 'facter'
require 'json'

# Facter Fact: capstan_node_id
# Returns the authoritative cryptographic node ID and identity metadata.
Facter.add(:capstan_node_id) do
  setcode do
    identity_file = '/etc/capstan/identity.json'
    if File.file?(identity_file)
      begin
        data = JSON.parse(File.read(identity_file))
        data['node_id'] || Facter.value(:networking)['fqdn']
      rescue StandardError
        Facter.value(:networking)['fqdn']
      end
    else
      # Fallback to system machine-id or hostname
      if File.file?('/etc/machine-id')
        File.read('/etc/machine-id').strip
      else
        Facter.value(:networking)['fqdn'] || 'capstan-edge-unknown'
      end
    end
  end
end
