"""
Capstan Daemon Configuration Loader.
Parses INI and JSON configuration files.
"""

import os
import configparser
from dataclasses import dataclass
from typing import Optional

@dataclass
class CapstanConfig:
    node_id: str = "edge-node-01"
    cluster_name: str = "edge-mesh-alpha"
    role: str = "edge_gateway"
    convergence_interval_sec: int = 10
    log_level: str = "info"
    socket_path: str = "/run/capstan/capstand.sock"
    api_port: int = 8443
    data_dir: str = "/var/lib/capstan"
    journal_dir: str = "/var/lib/capstan/journal"
    staging_dir: str = "/var/lib/capstan/staging"
    ledger_dir: str = "/var/lib/capstan/ledger"
    enable_ebpf: bool = True
    drift_threshold_percent: float = 5.0

    @classmethod
    def from_file(cls, path: str) -> "CapstanConfig":
        cfg = cls()
        if not os.path.isfile(path):
            return cfg

        parser = configparser.ConfigParser()
        parser.read(path)

        if parser.has_section("node"):
            cfg.node_id = parser.get("node", "id", fallback=cfg.node_id)
            cfg.cluster_name = parser.get("node", "cluster", fallback=cfg.cluster_name)
            cfg.role = parser.get("node", "role", fallback=cfg.role)

        if parser.has_section("engine"):
            cfg.convergence_interval_sec = parser.getint("engine", "convergence_interval_sec", fallback=cfg.convergence_interval_sec)
            cfg.log_level = parser.get("engine", "log_level", fallback=cfg.log_level)
            cfg.socket_path = parser.get("engine", "socket_path", fallback=cfg.socket_path)
            cfg.api_port = parser.getint("engine", "api_port", fallback=cfg.api_port)

        if parser.has_section("storage"):
            cfg.data_dir = parser.get("storage", "data_dir", fallback=cfg.data_dir)
            cfg.journal_dir = parser.get("storage", "journal_dir", fallback=cfg.journal_dir)
            cfg.staging_dir = parser.get("storage", "staging_dir", fallback=cfg.staging_dir)
            cfg.ledger_dir = parser.get("storage", "ledger_dir", fallback=cfg.ledger_dir)

        if parser.has_section("telemetry"):
            cfg.enable_ebpf = parser.getboolean("telemetry", "enable_ebpf", fallback=cfg.enable_ebpf)
            cfg.drift_threshold_percent = parser.getfloat("telemetry", "drift_threshold_percent", fallback=cfg.drift_threshold_percent)

        return cfg
