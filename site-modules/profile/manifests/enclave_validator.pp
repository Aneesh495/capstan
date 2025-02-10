# profile::enclave_validator
# Hardware-attested air-gapped secure enclave profile.
class profile::enclave_validator {
  include profile::base
  include capstan_cluster
}
