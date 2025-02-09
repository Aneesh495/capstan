# frozen_string_literal: true

require 'digest'

# Puppet 4/8 modern function: capstan::merkle_root
# Computes the cryptographic SHA-256 Merkle root across an array of resource string digests.
Puppet::Functions.create_function(:'capstan::merkle_root') do
  dispatch :compute_root do
    param 'Array[String]', :hashes
    return_type 'String'
  end

  def compute_root(hashes)
    return Digest::SHA256.hexdigest('') if hashes.empty?
    return hashes.first if hashes.length == 1

    current = hashes.sort
    while current.length > 1
      next_level = []
      current.each_slice(2) do |left, right|
        right ||= left
        combined = Digest::SHA256.hexdigest(left + right)
        next_level << combined
      end
      current = next_level
    end

    current.first
  end
end
