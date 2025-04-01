"""
Unit Tests for Merkle State Tree and Inclusion Proofs.
"""

from capstand.ledger.merkle import MerkleStateTree

def test_merkle_tree_construction():
    leaves = [
        "File[/etc/capstan/identity.json]:v1",
        "Wireguard_tunnel[wg0]:v1",
        "Sysctl[net.core.busy_poll]:v1",
        "Zfs_dataset[capstan_pool/state]:v1",
    ]
    tree = MerkleStateTree(leaves)
    assert tree.root_hash is not None
    assert len(tree.root_hash) == 64

def test_merkle_proof_verification():
    leaves = ["resA:1", "resB:2", "resC:3", "resD:4"]
    tree = MerkleStateTree(leaves)
    root = tree.root_hash

    # Verify proof for leaf 0
    leaf0_data = sorted(leaves)[0]
    proof0 = tree.generate_proof(0)
    assert MerkleStateTree.verify_proof(leaf0_data, proof0, root) is True

    # Tampered data should fail verification
    assert MerkleStateTree.verify_proof("resA:tampered", proof0, root) is False

def test_merkle_odd_leaves_handling():
    leaves = ["resA:1", "resB:2", "resC:3"]
    tree = MerkleStateTree(leaves)
    assert tree.root_hash is not None

    leaf1_data = sorted(leaves)[1]
    proof1 = tree.generate_proof(1)
    assert MerkleStateTree.verify_proof(leaf1_data, proof1, tree.root_hash) is True
