#!/usr/bin/env bash
# Outputs the active Git commit SHA or local timestamp for catalog compilation tracking.
set -euo pipefail

if command -v git >/dev/null 2>&1 && [ -d .git ]; then
  git rev-parse --short HEAD 2>/dev/null || date +%s
else
  date +%s
fi
