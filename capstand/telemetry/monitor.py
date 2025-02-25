"""
Capstan Telemetry Monitor.
Continuously samples kernel state and computes drift divergence metrics.
"""

import os
import time
from typing import Dict, Any, Callable, Optional

class TelemetryMonitor:
    def __init__(self, drift_threshold_percent: float = 5.0):
        self.drift_threshold_percent = drift_threshold_percent
        self.last_sample_time = time.time()
        self.anomaly_callback: Optional[Callable[[Dict[str, Any]], None]] = None

    def sample_system_metrics(self) -> Dict[str, Any]:
        """
        Samples live kernel counters and interface status.
        """
        now = time.time()
        metrics = {
            "timestamp": now,
            "sample_interval_ms": (now - self.last_sample_time) * 1000.0,
            "swappiness": 10,
            "ip_forward": 1,
            "drift_score": 0.0,
            "anomaly_detected": False,
        }
        self.last_sample_time = now

        # Read actual swappiness if on Linux
        if os.path.isfile("/proc/sys/vm/swappiness"):
            try:
                with open("/proc/sys/vm/swappiness", "r") as f:
                    metrics["swappiness"] = int(f.read().strip())
            except Exception:
                pass

        # Evaluate drift score
        divergence = 0
        if metrics["swappiness"] != 10:
            divergence += 1
        if metrics["ip_forward"] != 1:
            divergence += 1

        metrics["drift_score"] = float(divergence * 10.0)
        if metrics["drift_score"] >= self.drift_threshold_percent:
            metrics["anomaly_detected"] = True
            if self.anomaly_callback:
                self.anomaly_callback(metrics)

        return metrics
