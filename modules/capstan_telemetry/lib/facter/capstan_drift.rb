# frozen_string_literal: true

require 'facter'
require 'json'

# Facter Fact: capstan_drift
# Reports current live system state divergence against active compiled catalog.
Facter.add(:capstan_drift) do
  setcode do
    drift_data = {
      'drift_score'        => 0.0,
      'diverged_resources' => 0,
      'last_converged_at'  => 'unknown',
      'in_sync'            => true,
    }

    drift_file = '/var/lib/capstan/metrics/drift.json'
    if File.file?(drift_file)
      begin
        raw = JSON.parse(File.read(drift_file))
        drift_data['drift_score']        = raw.fetch('drift_score', 0.0).to_f
        drift_data['diverged_resources'] = raw.fetch('diverged_resources', 0).to_i
        drift_data['last_converged_at']  = raw.fetch('last_converged_at', 'unknown')
        drift_data['in_sync']            = (drift_data['drift_score'] < 1.0)
      rescue StandardError
        # Graceful fallback to default in-sync state
      end
    end

    drift_data
  end
end
