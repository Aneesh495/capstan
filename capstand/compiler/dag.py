"""
Directed Acyclic Graph (DAG) for Resource Dependency Resolution.
Implements cycle detection and topological sorting via Kahn's algorithm.
"""

from typing import Dict, List, Set, Optional

class CycleError(Exception):
    pass

class DependencyDAG:
    def __init__(self):
        self.nodes: Set[str] = set()
        self.edges: Dict[str, Set[str]] = {}       # u -> set(v) where u must run before v
        self.in_degree: Dict[str, int] = {}

    def add_node(self, node: str):
        if node not in self.nodes:
            self.nodes.add(node)
            self.edges[node] = set()
            self.in_degree[node] = 0

    def add_dependency(self, before: str, after: str):
        """
        Declares that 'before' must be executed prior to 'after'.
        """
        self.add_node(before)
        self.add_node(after)

        if after not in self.edges[before]:
            self.edges[before].add(after)
            self.in_degree[after] += 1

    def topological_sort(self) -> List[str]:
        """
        Computes topological ordering using Kahn's algorithm.
        Raises CycleError if a dependency cycle exists.
        """
        in_deg = dict(self.in_degree)
        zero_in_degree = [node for node in self.nodes if in_deg[node] == 0]
        sorted_order = []

        while zero_in_degree:
            # Deterministic ordering for reproducibility
            zero_in_degree.sort()
            curr = zero_in_degree.pop(0)
            sorted_order.append(curr)

            for neighbor in self.edges.get(curr, set()):
                in_deg[neighbor] -= 1
                if in_deg[neighbor] == 0:
                    zero_in_degree.append(neighbor)

        if len(sorted_order) != len(self.nodes):
            remaining = set(self.nodes) - set(sorted_order)
            raise CycleError(f"Dependency cycle detected among resources: {remaining}")

        return sorted_order
