# frozen_string_literal: true

Puppet::Type.newtype(:raft_peer) do
  @doc = 'Manages cluster Raft consensus peer membership.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Peer node identifier (e.g. edge-node-02).'
  end

  newproperty(:endpoint) do
    desc 'Raft protocol network address (e.g. 10.42.0.2:7000).'
  end

  newproperty(:role) do
    desc 'Consensus voting membership role (voter, non_voter, learner).'
    newvalues(:voter, :non_voter, :learner)
    defaultto :voter
  end
end
