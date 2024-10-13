# frozen_string_literal: true

require_relative '../../../../spec/spec_helper'

describe 'capstan_core' do
  it 'validates module structure and metadata definition' do
    metadata_path = File.expand_path('../../metadata.json', __dir__)
    expect(File.exist?(metadata_path)).to be true
    metadata = JSON.parse(File.read(metadata_path))
    expect(metadata['name']).to eq('capstan-capstan_core')
    expect(metadata['version']).to eq('1.0.0')
  end

  it 'verifies that all primary class manifests exist' do
    manifest_dir = File.expand_path('../../manifests', __dir__)
    expected_manifests = %w[init.pp params.pp directories.pp identity.pp service.pp journal.pp staging.pp facts.pp]
    expected_manifests.each do |manifest|
      expect(File.exist?(File.join(manifest_dir, manifest))).to be true
    end
  end
end
