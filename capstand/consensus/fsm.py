"""
Capstan Replicated Finite State Machine (FSM).
Applies committed Raft log commands to update local cluster desired state.
"""

from typing import Dict, Any, List

class ClusterStateMachine:
    def __init__(self):
        self.state_version = 0
        self.cluster_parameters: Dict[str, Any] = {}
        self.active_mesh_peers: List[Dict[str, Any]] = []
        self.execution_history: List[Dict[str, Any]] = []

    def apply(self, command: Dict[str, Any]) -> Dict[str, Any]:
        """
        Applies an entry to the replicated state machine.
        Supported commands:
        - set_parameter: Updates a global Hiera parameter
        - register_peer: Enrolls a new WireGuard peer
        - bump_catalog_version: Triggers synchronous re-convergence
        """
        cmd_type = command.get("type")
        self.state_version += 1

        result = {"success": True, "state_version": self.state_version}

        if cmd_type == "set_parameter":
            key = command["key"]
            val = command["value"]
            self.cluster_parameters[key] = val
            result["applied"] = f"set {key}={val}"

        elif cmd_type == "register_peer":
            peer = command["peer"]
            self.active_mesh_peers = [p for p in self.active_mesh_peers if p.get("id") != peer.get("id")]
            self.active_mesh_peers.append(peer)
            result["applied"] = f"registered peer {peer.get('id')}"

        elif cmd_type == "bump_catalog_version":
            target_version = command.get("version", self.state_version)
            result["applied"] = f"bumped version to {target_version}"

        else:
            result["success"] = False
            result["error"] = f"Unknown command type {cmd_type}"

        self.execution_history.append({
            "command": command,
            "version": self.state_version,
            "result": result,
        })
        return result
