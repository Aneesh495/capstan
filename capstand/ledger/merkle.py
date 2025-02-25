"""
Capstan Cryptographic Merkle State Tree.
Computes SHA-256 state tree across converged resource states with audit proof generation.
"""

import hashlib
from typing import List, Tuple, Dict, Any, Optional

def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()

class MerkleNode:
    def __init__(self, hash_val: str, left=None, right=None):
        self.hash = hash_val
        self.left = left
        self.right = right

class MerkleStateTree:
    def __init__(self, leaves: List[str]):
        self.raw_leaves = sorted(leaves) if leaves else [""]
        self.leaf_hashes = [sha256(leaf.encode("utf-8")) for leaf in self.raw_leaves]
        self.root: Optional[MerkleNode] = self._build_tree(self.leaf_hashes)

    @property
    def root_hash(self) -> str:
        return self.root.hash if self.root else sha256(b"")

    def _build_tree(self, hashes: List[str]) -> MerkleNode:
        nodes = [MerkleNode(h) for h in hashes]

        while len(nodes) > 1:
            next_level = []
            for i in range(0, len(nodes), 2):
                left = nodes[i]
                if i + 1 < len(nodes):
                    right = nodes[i + 1]
                else:
                    right = MerkleNode(left.hash) # duplicate odd leaf

                combined_hash = sha256((left.hash + right.hash).encode("utf-8"))
                parent = MerkleNode(combined_hash, left=left, right=right)
                next_level.append(parent)

            nodes = next_level

        return nodes[0]

    def generate_proof(self, leaf_index: int) -> List[Tuple[str, str]]:
        """
        Generates inclusion proof for leaf at leaf_index.
        Returns list of (sibling_hash, direction: 'L' or 'R').
        """
        if leaf_index < 0 or leaf_index >= len(self.leaf_hashes):
            raise IndexError("Leaf index out of bounds")

        proof = []
        current_level = list(self.leaf_hashes)
        idx = leaf_index

        while len(current_level) > 1:
            if idx % 2 == 0:
                # Target is left; sibling is right
                sibling_idx = idx + 1 if idx + 1 < len(current_level) else idx
                proof.append((current_level[sibling_idx], "R"))
            else:
                # Target is right; sibling is left
                sibling_idx = idx - 1
                proof.append((current_level[sibling_idx], "L"))

            # Advance to parent level
            next_level = []
            for i in range(0, len(current_level), 2):
                l = current_level[i]
                r = current_level[i + 1] if i + 1 < len(current_level) else l
                next_level.append(sha256((l + r).encode("utf-8")))

            idx //= 2
            current_level = next_level

        return proof

    @staticmethod
    def verify_proof(leaf_data: str, proof: List[Tuple[str, str]], expected_root: str) -> bool:
        current = sha256(leaf_data.encode("utf-8"))

        for sibling_hash, direction in proof:
            if direction == "R":
                current = sha256((current + sibling_hash).encode("utf-8"))
            else:
                current = sha256((sibling_hash + current).encode("utf-8"))

        return current == expected_root
