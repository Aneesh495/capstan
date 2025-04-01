"""
Unit Tests for Compiler Dependency DAG and Cycle Detection.
"""

import pytest
from capstand.compiler.dag import DependencyDAG, CycleError

def test_dag_linear_execution():
    dag = DependencyDAG()
    dag.add_dependency("Class[Core::Directories]", "Class[Core::Identity]")
    dag.add_dependency("Class[Core::Identity]", "Class[Core::Service]")

    order = dag.topological_sort()
    assert order == [
        "Class[Core::Directories]",
        "Class[Core::Identity]",
        "Class[Core::Service]",
    ]

def test_dag_diamond_dependency():
    dag = DependencyDAG()
    # A -> B -> D
    # A -> C -> D
    dag.add_dependency("A", "B")
    dag.add_dependency("A", "C")
    dag.add_dependency("B", "D")
    dag.add_dependency("C", "D")

    order = dag.topological_sort()
    assert order[0] == "A"
    assert order[-1] == "D"
    assert "B" in order[1:3]
    assert "C" in order[1:3]

def test_dag_cycle_detection():
    dag = DependencyDAG()
    dag.add_dependency("A", "B")
    dag.add_dependency("B", "C")
    dag.add_dependency("C", "A") # Cycle!

    with pytest.raises(CycleError) as exc_info:
        dag.topological_sort()
    assert "Dependency cycle detected" in str(exc_info.value)
