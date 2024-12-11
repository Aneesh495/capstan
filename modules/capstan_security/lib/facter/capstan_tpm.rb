# frozen_string_literal: true

require 'facter'

# Facter Fact: capstan_tpm
# Inspects TPM 2.0 hardware presence and PCR digest banks.
Facter.add(:capstan_tpm) do
  confine kernel: 'Linux'

  setcode do
    tpm_data = {
      'present'      => false,
      'device_path'  => '/dev/tpmrm0',
      'version'      => 'none',
      'pcr_sha256'   => {},
    }

    if File.exist?('/dev/tpmrm0') || File.exist?('/dev/tpm0')
      tpm_data['present'] = true
      tpm_data['version'] = '2.0'

      # Read PCRs via tpm2_pcrread if utility installed
      if Facter::Core::Execution.which('tpm2_pcrread')
        begin
          raw = Facter::Core::Execution.execute('tpm2_pcrread sha256 2>/dev/null')
          raw.each_line do |line|
            if line =~ /^\s*(\d+)\s*:\s*(0x[0-9a-fA-F]+)/
              pcr_idx = Regexp.last_match(1)
              pcr_hash = Regexp.last_match(2)
              tpm_data['pcr_sha256'][pcr_idx] = pcr_hash
            end
          end
        rescue StandardError
          # Non-fatal execution failure
        end
      end
    end

    tpm_data
  end
end
