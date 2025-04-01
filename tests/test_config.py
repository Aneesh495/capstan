"""
Tests for Capstan Configuration Loader.
"""

import os
import tempfile
from capstand.config import CapstanConfig

def test_default_config():
    cfg = CapstanConfig()
    assert cfg.node_id == "edge-node-01"
    assert cfg.cluster_name == "edge-mesh-alpha"
    assert cfg.convergence_interval_sec == 10
    assert cfg.enable_ebpf is True

def test_config_from_file():
    content = """
[node]
id = edge-test-node
cluster = test-cluster
role = compute_worker

[engine]
convergence_interval_sec = 25
log_level = debug

[telemetry]
enable_ebpf = false
drift_threshold_percent = 8.5
"""
    with tempfile.NamedTemporaryFile("w", delete=False) as f:
        f.write(content)
        f_path = f.name

    try:
        cfg = CapstanConfig.from_file(f_path)
        assert cfg.node_id == "edge-test-node"
        assert cfg.cluster_name == "test-cluster"
        assert cfg.role == "compute_worker"
        assert cfg.convergence_interval_sec == 25
        assert cfg.log_level == "debug"
        assert cfg.enable_ebpf is False
        assert cfg.drift_threshold_percent == 8.5
    finally:
        os.remove(f_path)
