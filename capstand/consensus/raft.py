"""
Capstan Asynchronous Raft Consensus Engine.
Implements the core Raft distributed consensus protocol:
- Leader Election with randomized timers
- Log Entry Replication and Commitment
- Split-brain Prevention with Quorum Thresholds
"""

import asyncio
import enum
import time
import random
from typing import List, Dict, Any, Optional

class NodeRole(enum.Enum):
    FOLLOWER = "follower"
    CANDIDATE = "candidate"
    LEADER = "leader"

class LogEntry:
    def __init__(self, term: int, index: int, command: Dict[str, Any]):
        self.term = term
        self.index = index
        self.command = command
        self.timestamp = time.time()

    def to_dict(self) -> Dict[str, Any]:
        return {
            "term": self.term,
            "index": self.index,
            "command": self.command,
            "timestamp": self.timestamp,
        }

class RaftNode:
    def __init__(
        self,
        node_id: str,
        peers: List[str],
        election_timeout_ms: int = 300,
        heartbeat_interval_ms: int = 50,
    ):
        self.node_id = node_id
        self.peers = peers
        self.election_timeout_ms = election_timeout_ms
        self.heartbeat_interval_ms = heartbeat_interval_ms

        # Persistent state on all servers
        self.current_term = 0
        self.voted_for: Optional[str] = None
        self.log: List[LogEntry] = []

        # Volatile state on all servers
        self.commit_index = 0
        self.last_applied = 0
        self.role = NodeRole.FOLLOWER
        self.leader_id: Optional[str] = None

        # Volatile state on leaders
        self.next_index: Dict[str, int] = {}
        self.match_index: Dict[str, int] = {}

        self.last_heartbeat_time = time.time()
        self._running = False
        self._election_task: Optional[asyncio.Task] = None

    @property
    def quorum_size(self) -> int:
        total_nodes = len(self.peers) + 1
        return (total_nodes // 2) + 1

    def handle_request_vote(
        self,
        term: int,
        candidate_id: str,
        last_log_index: int,
        last_log_term: int,
    ) -> Dict[str, Any]:
        """
        Invoked by candidates to gather votes.
        """
        if term > self.current_term:
            self.current_term = term
            self.role = NodeRole.FOLLOWER
            self.voted_for = None

        vote_granted = False
        if term == self.current_term and (self.voted_for is None or self.voted_for == candidate_id):
            my_last_term = self.log[-1].term if self.log else 0
            my_last_index = self.log[-1].index if self.log else 0

            # Candidate log is at least as up-to-date as receiver log
            if (last_log_term > my_last_term) or (last_log_term == my_last_term and last_log_index >= my_last_index):
                vote_granted = True
                self.voted_for = candidate_id
                self.last_heartbeat_time = time.time()

        return {
            "term": self.current_term,
            "vote_granted": vote_granted,
        }

    def handle_append_entries(
        self,
        term: int,
        leader_id: str,
        prev_log_index: int,
        prev_log_term: int,
        entries: List[Dict[str, Any]],
        leader_commit: int,
    ) -> Dict[str, Any]:
        """
        Invoked by leader to replicate log entries and send heartbeats.
        """
        if term < self.current_term:
            return {"term": self.current_term, "success": False}

        self.last_heartbeat_time = time.time()
        self.leader_id = leader_id

        if term > self.current_term or self.role == NodeRole.CANDIDATE:
            self.current_term = term
            self.role = NodeRole.FOLLOWER
            self.voted_for = None

        # Verify entry at prev_log_index matches prev_log_term
        if prev_log_index > 0:
            if prev_log_index > len(self.log):
                return {"term": self.current_term, "success": False}
            if self.log[prev_log_index - 1].term != prev_log_term:
                return {"term": self.current_term, "success": False}

        # Append any new entries not already in the log
        for e in entries:
            entry = LogEntry(term=e["term"], index=e["index"], command=e["command"])
            if entry.index <= len(self.log):
                self.log[entry.index - 1] = entry
            else:
                self.log.append(entry)

        # Update commit index
        if leader_commit > self.commit_index:
            self.commit_index = min(leader_commit, len(self.log))

        return {"term": self.current_term, "success": True}

    def propose_command(self, command: Dict[str, Any]) -> Optional[LogEntry]:
        """
        Dispatched by leader to stage and replicate a new catalog state command.
        """
        if self.role != NodeRole.LEADER:
            return None

        new_index = len(self.log) + 1
        entry = LogEntry(term=self.current_term, index=new_index, command=command)
        self.log.append(entry)
        self.match_index[self.node_id] = new_index
        return entry
