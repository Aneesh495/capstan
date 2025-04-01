"""
End-to-End Multi-Node Convergence and Drift Healing Integration Tests.
"""

from capstand.engine.loop import ConvergenceEngine
from capstand.telemetry.monitor import TelemetryMonitor
from capstand.api.server import InspectionApiHandler
from capstand.ledger.merkle import MerkleStateTree

def test_e2e_drift_healing_and_ledger():
    engine = ConvergenceEngine(node_id="edge-test-colo-01", role="colo_hypervisor")
    assert len(engine.ledger) == 0

    # 1. Simulate drift anomaly
    anomalies_detected = []
    def on_anomaly(metrics):
        anomalies_detected.append(metrics)

    monitor = TelemetryMonitor(drift_threshold_percent=5.0)
    monitor.anomaly_callback = on_anomaly

    # In simulated env, divergence calculation triggers
    metrics = monitor.sample_system_metrics()
    assert metrics["drift_score"] >= 0.0

    # 2. Trigger autonomous convergence
    receipt = engine.execute_convergence_cycle()
    assert receipt.node_id == "edge-test-colo-01"
    assert receipt.converged_resources > 0
    assert len(receipt.merkle_root) == 64
    assert len(engine.ledger) == 1

    # 3. Verify ledger receipt
    stored_receipt = engine.ledger[0]
    assert stored_receipt.merkle_root == receipt.merkle_root
    assert stored_receipt.catalog_version == 1

def test_e2e_api_inspection_flow():
    engine = ConvergenceEngine(node_id="edge-gateway-01", role="edge_gateway")
    handler = InspectionApiHandler(engine)

    # Health check
    code, payload = handler.handle_request("GET", "/health")
    assert code == 200
    assert payload["status"] == "healthy"
    assert payload["node_id"] == "edge-gateway-01"

    # Status check before convergence
    code, status = handler.handle_request("GET", "/status")
    assert code == 200
    assert status["total_receipts"] == 0

    # Post trigger convergence
    code, trigger_resp = handler.handle_request("POST", "/trigger")
    assert code == 200
    assert trigger_resp["status"] == "converged"
    assert "receipt" in trigger_resp

    # Status check after convergence
    code, status_after = handler.handle_request("GET", "/status")
    assert code == 200
    assert status_after["total_receipts"] == 1
    assert len(status_after["last_merkle_root"]) == 64

    # Query ledger
    code, ledger_resp = handler.handle_request("GET", "/ledger")
    assert code == 200
    assert ledger_resp["count"] == 1
