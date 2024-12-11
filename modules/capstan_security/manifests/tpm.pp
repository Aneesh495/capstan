# capstan_security::tpm
# Enforces hardware measured boot integrity via TPM 2.0 PCR attestation policies.
class capstan_security::tpm {
  $pcr_policy_file = '/etc/capstan/tpm_pcr_policy.json'

  # Declare custom tpm_pcr_policy resource
  tpm_pcr_policy { 'measured_boot_baseline':
    ensure       => present,
    pcr_indices  => [0, 2, 4, 7],
    hash_alg     => 'sha256',
    fail_action  => 'warn',
    policy_file  => $pcr_policy_file,
  }
}
