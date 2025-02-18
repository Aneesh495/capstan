"""
Puppet Compiler Bridge.
Executes local catalog synthesis and translates Puppet RAL JSON into an executable DAG.
"""

import os
import json
import subprocess
from typing import Dict, Any, List, Optional
from capstand.compiler.dag import DependencyDAG

class PuppetCompilerBridge:
    def __init__(self, workspace_root: Optional[str] = None):
        if workspace_root:
            self.root = workspace_root
        else:
            self.root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

        self.manifest_path = os.path.join(self.root, "manifests", "site.pp")
        self.modules_path = f"{os.path.join(self.root, 'modules')}:{os.path.join(self.root, 'site-modules')}"
        self.hiera_config = os.path.join(self.root, "hiera.yaml")

    def build_resource_dag(self, resources: List[Dict[str, Any]]) -> DependencyDAG:
        dag = DependencyDAG()
        for res in resources:
            ref = f"{res.get('type')}[{res.get('title')}]"
            dag.add_node(ref)

            # Process requires
            for req in res.get("require", []):
                dag.add_dependency(req, ref)

            # Process befores
            for b in res.get("before", []):
                dag.add_dependency(ref, b)

        return dag

    def compile_catalog_simulated(self, role: str = "edge_gateway") -> Dict[str, Any]:
        """
        Synthesizes a simulated compiled catalog for fast in-memory execution and test suites.
        """
        resources = [
            {"type": "Class", "title": "Capstan_core::Directories", "require": []},
            {"type": "Class", "title": "Capstan_core::Identity", "require": ["Class[Capstan_core::Directories]"]},
            {"type": "Class", "title": "Capstan_core::Journal", "require": ["Class[Capstan_core::Directories]"]},
            {"type": "Class", "title": "Capstan_core::Staging", "require": ["Class[Capstan_core::Directories]"]},
            {"type": "Class", "title": "Capstan_core::Service", "require": ["Class[Capstan_core::Identity]", "Class[Capstan_core::Staging]"]},
            {"type": "Class", "title": "Capstan_kernel::Sysctl", "require": ["Class[Capstan_core::Directories]"]},
            {"type": "Class", "title": "Capstan_network::Wireguard", "require": ["Class[Capstan_core::Identity]"]},
            {"type": "Class", "title": "Capstan_security::Auditd", "require": ["Class[Capstan_core::Directories]"]},
            {"type": "Class", "title": "Capstan_telemetry::Probes", "require": ["Class[Capstan_core::Directories]"]},
            {"type": "Class", "title": "Capstan_audit::Ledger", "require": ["Class[Capstan_core::Identity]"]},
        ]

        dag = self.build_resource_dag(resources)
        order = dag.topological_sort()

        return {
            "catalog_version": 1,
            "role": role,
            "resources": resources,
            "execution_order": order,
            "resource_count": len(resources),
        }
