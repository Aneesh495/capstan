# capstan_cluster::raft
# Configures Raft consensus node membership and cluster topology.
class capstan_cluster::raft {
  $raft_conf = '/etc/capstan/raft.json'
  $node_id   = $trusted['certname']

  file { $raft_conf:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => inline_epp(@(END)),
      {
        "cluster_name": "<%= $capstan_cluster::cluster_name %>",
        "node_id": "<%= $node_id %>",
        "raft_port": <%= $capstan_cluster::raft_port %>,
        "election_timeout_ms": <%= $capstan_cluster::election_timeout_ms %>,
        "heartbeat_interval_ms": <%= $capstan_cluster::heartbeat_interval_ms %>,
        "peers": <%= $capstan_cluster::peers.to_json %>
      }
      END
  }

  # Ensure each peer is declared via custom raft_peer resource
  $capstan_cluster::peers.each |$peer| {
    raft_peer { $peer['id']:
      ensure   => present,
      endpoint => $peer['endpoint'],
      role     => pick($peer['role'], 'voter'),
    }
  }
}
