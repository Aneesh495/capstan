# capstan_security
#
# Enforces sovereign security hardening: TPM 2.0 measured boot PCR validation,
# seccomp-bpf system call filters, AppArmor containment, and ephemeral mTLS certificates.
#
# @param enable_tpm_attestation Validate hardware TPM 2.0 PCR registers.
# @param enable_seccomp Deploy seccomp-bpf syscall white-list profiles.
# @param enable_apparmor Enforce AppArmor containment profiles.
# @param enable_auditd Enforce immutable Linux audit daemon rules.
# @param enable_ssh_ca Deploy cryptographic SSH Certificate Authority trust anchor.
class capstan_security (
  Boolean $enable_tpm_attestation = $capstan_security::params::enable_tpm_attestation,
  Boolean $enable_seccomp         = $capstan_security::params::enable_seccomp,
  Boolean $enable_apparmor        = $capstan_security::params::enable_apparmor,
  Boolean $enable_auditd          = $capstan_security::params::enable_auditd,
  Boolean $enable_ssh_ca          = $capstan_security::params::enable_ssh_ca,
  Boolean $enable_mtls            = $capstan_security::params::enable_mtls,
) inherits capstan_security::params {

  if $enable_tpm_attestation {
    contain capstan_security::tpm
  }

  if $enable_seccomp {
    contain capstan_security::seccomp
  }

  if $enable_apparmor {
    contain capstan_security::apparmor
  }

  if $enable_auditd {
    contain capstan_security::auditd
  }

  if $enable_ssh_ca {
    contain capstan_security::ssh_ca
  }

  if $enable_mtls {
    contain capstan_security::mtls
  }
}
