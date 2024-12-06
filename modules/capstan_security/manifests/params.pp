# capstan_security::params
# Default parameters for TPM 2.0 PCR checks, seccomp sandboxing, AppArmor, and mTLS.
class capstan_security::params {
  $enable_tpm_attestation = false
  $expected_pcr_values    = {}
  $enable_seccomp         = true
  $enable_apparmor        = true
  $enable_auditd          = true
  $enable_ssh_ca          = true
  $enable_mtls            = true
  $cert_validity_days     = 30
}
