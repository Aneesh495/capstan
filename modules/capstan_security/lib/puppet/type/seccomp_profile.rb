# frozen_string_literal: true

Puppet::Type.newtype(:seccomp_profile) do
  @doc = 'Manages seccomp-bpf system call filter profile definitions.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Profile name (e.g. capstand_strict).'
  end

  newproperty(:default_action) do
    desc 'Default action for unlisted system calls (SCMP_ACT_ERRNO, SCMP_ACT_KILL, SCMP_ACT_ALLOW).'
    defaultto 'SCMP_ACT_ERRNO'
  end

  newproperty(:allowed_syscalls, array_matching: :all) do
    desc 'Array of system call names permitted by this filter profile.'
    defaultto []
  end

  newproperty(:profile_path) do
    desc 'Destination path for JSON profile.'
    defaultto '/etc/capstan/seccomp/capstand_strict.json'
  end
end
