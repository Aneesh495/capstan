"""
Capstan Inspection HTTP and Unix Socket API Server.
Provides local status, cluster health, and manual convergence triggers.
"""

import json
from typing import Dict, Any, Optional, Tuple
from capstand.engine.loop import ConvergenceEngine

class InspectionApiHandler:
    def __init__(self, engine: ConvergenceEngine):
        self.engine = engine

    def handle_request(self, method: str, path: str, body: Optional[bytes] = None) -> Tuple[int, Dict[str, Any]]:
        method = method.upper()

        if method == "GET" and path == "/health":
            return (200, {"status": "healthy", "node_id": self.engine.node_id})

        elif method == "GET" and path == "/status":
            return (200, {
                "node_id": self.engine.node_id,
                "role": self.engine.role,
                "catalog_version": self.engine.current_catalog_version,
                "last_merkle_root": self.engine.last_merkle_root,
                "is_converging": self.engine.is_converging,
                "total_receipts": len(self.engine.ledger),
            })

        elif method == "GET" and path == "/ledger":
            receipts = [r.to_dict() for r in self.engine.ledger[-10:]]
            return (200, {"receipts": receipts, "count": len(receipts)})

        elif method == "POST" and path == "/trigger":
            receipt = self.engine.execute_convergence_cycle()
            return (200, {"status": "converged", "receipt": receipt.to_dict()})

        return (404, {"error": "Not Found", "path": path})
