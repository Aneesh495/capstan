# capstan_cluster
#
# Primary class managing decentralized Raft consensus clustering and dynamic peer quorum.
#
# @param cluster_name Unique identifier of the distributed cluster mesh.
# @param raft_port TCP port for Raft RPC communications.
# @param election_timeout_ms Upper bound for Raft leader election timer.
# @param heartbeat_interval_ms Leader heartbeat frequency.
# @param peers Array of hash definitions for cluster peers.
class capstan_cluster (
  String                $cluster_name          = lookup('capstan::cluster_name', String, 'first', 'edge-mesh-alpha'),
  Stdlib::Port          $raft_port             = 7000,
  Integer[50, 5000]     $election_timeout_ms   = 300,
  Integer[10, 1000]     $heartbeat_interval_ms = 50,
  Array[Hash[String, Any]] $peers              = [],
) {
  contain capstan_cluster::raft
}
