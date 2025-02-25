"""
Capstan Cryptographic State Convergence Receipt.
Encapsulates signed attestations of post-convergence Merkle root hashes.
"""

import time
import json
import hashlib
from typing import Dict, Any, Optional

class ConvergenceReceipt:
    def __init__(
        self,
        node_id: str,
        catalog_version: int,
        merkle_root: str,
        converged_resources: int,
        duration_ms: float,
        signature: Optional[str] = None,
    ):
        self.node_id = node_id
        self.catalog_version = catalog_version
        self.merkle_root = merkle_root
        self.converged_resources = converged_resources
        self.duration_ms = duration_ms
        self.timestamp = time.time()
        self.signature = signature or self._generate_simulated_sig()

    def _generate_simulated_sig(self) -> str:
        # Generates deterministic signature hash for verification
        content = f"{self.node_id}:{self.catalog_version}:{self.merkle_root}:{self.timestamp}"
        return hashlib.sha256(content.encode("utf-8")).hexdigest()

    def to_dict(self) -> Dict[str, Any]:
        return {
            "node_id": self.node_id,
            "catalog_version": self.catalog_version,
            "merkle_root": self.merkle_root,
            "converged_resources": self.converged_resources,
            "duration_ms": self.duration_ms,
            "timestamp": self.timestamp,
            "signature": self.signature,
        }

    def to_json(self) -> str:
        return json.dumps(self.to_dict())

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "ConvergenceReceipt":
        receipt = cls(
            node_id=data["node_id"],
            catalog_version=data["catalog_version"],
            merkle_root=data["merkle_root"],
            converged_resources=data["converged_resources"],
            duration_ms=data["duration_ms"],
            signature=data.get("signature"),
        )
        receipt.timestamp = data.get("timestamp", receipt.timestamp)
        return receipt
