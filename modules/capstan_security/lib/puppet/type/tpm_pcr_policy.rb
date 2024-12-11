# frozen_string_literal: true

Puppet::Type.newtype(:tpm_pcr_policy) do
  @doc = 'Enforces TPM 2.0 platform configuration register policy digests for measured boot.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Policy identifier (e.g. measured_boot_baseline).'
  end

  newproperty(:pcr_indices, array_matching: :all) do
    desc 'Array of PCR indices to attest (e.g. [0, 2, 4, 7]).'
    defaultto [0, 2, 4, 7]
  end

  newproperty(:hash_alg) do
    desc 'Cryptographic hash algorithm for PCR bank (sha256, sha384).'
    newvalues(:sha256, :sha384)
    defaultto :sha256
  end

  newproperty(:fail_action) do
    desc 'Action on attestation failure (warn, reject, lock).'
    newvalues(:warn, :reject, :lock)
    defaultto :warn
  end

  newproperty(:policy_file) do
    desc 'Filesystem path where attested PCR hashes are recorded.'
    defaultto '/etc/capstan/tpm_pcr_policy.json'
  end
end
