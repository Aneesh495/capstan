#!/usr/bin/env python3
"""
Scans the entire repository tree to ensure zero em dashes (\u2014) or en dashes (\u2013)
exist in any text file, comment, manifest, documentation, or code file.
Strictly requires standard ASCII hyphens (-) or colons (:).
"""

import os
import sys
from pathlib import Path

FORBIDDEN_CHARS = {
    "\u2014": "EM DASH",
    "\u2013": "EN DASH",
}

IGNORE_DIRS = {
    ".git",
    "__pycache__",
    ".pytest_cache",
    ".bundle",
    "vendor",
    "build",
    "dist",
}

IGNORE_EXTENSIONS = {
    ".pyc",
    ".so",
    ".dylib",
    ".a",
    ".o",
    ".png",
    ".jpg",
    ".jpeg",
    ".gif",
    ".ico",
    ".pdf",
}

def scan_file(filepath: Path) -> list:
    violations = []
    try:
        with open(filepath, "r", encoding="utf-8", errors="replace") as f:
            for line_no, line in enumerate(f, start=1):
                for char, name in FORBIDDEN_CHARS.items():
                    if char in line:
                        violations.append((line_no, name, line.strip()))
    except Exception as e:
        violations.append((0, "READ_ERROR", str(e)))
    return violations

def main() -> int:
    root = Path(__file__).resolve().parent.parent
    total_files = 0
    total_violations = 0

    print(f"[*] Scanning repository for forbidden dash characters: {root}")

    for current_dir, dirs, files in os.walk(root):
        # Exclude ignored directories
        dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]

        for file in files:
            filepath = Path(current_dir) / file
            if filepath.suffix.lower() in IGNORE_EXTENSIONS:
                continue

            total_files += 1
            violations = scan_file(filepath)
            if violations:
                rel_path = filepath.relative_to(root)
                for line_no, name, text in violations:
                    print(f"FAIL: {rel_path}:{line_no} contains {name} -> {text}")
                    total_violations += 1

    print(f"[*] Scanned {total_files} files.")
    if total_violations > 0:
        print(f"ERROR: Found {total_violations} forbidden character violations!")
        return 1

    print("SUCCESS: 0 forbidden dash characters found. All files comply strictly.")
    return 0

if __name__ == "__main__":
    sys.exit(main())
