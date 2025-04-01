"""
Unit Tests for Capstan Raft Consensus Engine.
"""

from capstand.consensus.raft import RaftNode, NodeRole
from capstand.consensus.fsm import ClusterStateMachine

def test_raft_quorum_calculation():
    # 3 nodes total (node + 2 peers) -> quorum is 2
    node = RaftNode(node_id="node-1", peers=["node-2", "node-3"])
    assert node.quorum_size == 2

    # 5 nodes total (node + 4 peers) -> quorum is 3
    node5 = RaftNode(node_id="node-1", peers=["node-2", "node-3", "node-4", "node-5"])
    assert node5.quorum_size == 3

def test_raft_vote_request():
    node = RaftNode(node_id="node-1", peers=["node-2"])
    assert node.current_term == 0
    assert node.voted_for is None

    # Candidate requests vote with term 1
    resp = node.handle_request_vote(
        term=1,
        candidate_id="node-2",
        last_log_index=0,
        last_log_term=0,
    )
    assert resp["vote_granted"] is True
    assert resp["term"] == 1
    assert node.voted_for == "node-2"

    # Reject second candidate in same term
    resp2 = node.handle_request_vote(
        term=1,
        candidate_id="node-3",
        last_log_index=0,
        last_log_term=0,
    )
    assert resp2["vote_granted"] is False

def test_raft_append_entries_and_commit():
    node = RaftNode(node_id="node-1", peers=["node-2"])
    entries = [
        {"term": 1, "index": 1, "command": {"type": "bump_version", "val": 1}},
        {"term": 1, "index": 2, "command": {"type": "set_param", "key": "tier", "value": "tier1"}},
    ]

    resp = node.handle_append_entries(
        term=1,
        leader_id="node-2",
        prev_log_index=0,
        prev_log_term=0,
        entries=entries,
        leader_commit=2,
    )
    assert resp["success"] is True
    assert len(node.log) == 2
    assert node.commit_index == 2

def test_cluster_state_machine_fsm():
    fsm = ClusterStateMachine()
    res1 = fsm.apply({"type": "set_parameter", "key": "network.mtu", "value": 1420})
    assert res1["success"] is True
    assert fsm.cluster_parameters["network.mtu"] == 1420

    res2 = fsm.apply({"type": "register_peer", "peer": {"id": "peer-99", "ip": "10.42.0.99"}})
    assert res2["success"] is True
    assert len(fsm.active_mesh_peers) == 1
