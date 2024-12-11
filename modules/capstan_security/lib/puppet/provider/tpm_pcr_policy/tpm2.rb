# frozen_string_literal: true

require 'json'

Puppet::Type.type(:tpm_pcr_policy).provide(:tpm2) do
  desc 'Attests TPM 2.0 PCR values using tpm2-tools and writes policy manifest.'

  defaultfor kernel: 'Linux'

  def exists?
    File.exist?(resource[:policy_file])
  end

  def create
    write_policy
  end

  def destroy
    File.delete(resource[:policy_file]) if File.exist?(resource[:policy_file])
  end

  private

  def write_policy
    policy = {
      'policy_name' => resource[:name],
      'hash_alg'    => resource[:hash_alg].to_s,
      'pcr_indices' => resource[:pcr_indices],
      'fail_action' => resource[:fail_action].to_s,
      'recorded_at' => Time.now.utc.iso8601,
      'status'      => 'attested',
    }

    File.write(resource[:policy_file], JSON.pretty_generate(policy))
  end
end
