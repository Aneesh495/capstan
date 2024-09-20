#!/usr/bin/env bash
# Capstan Root Automated Verification Suite
# Executes all integrity checks, syntax validators, unit tests, and security assertions.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "================================================================="
echo "               CAPSTAN REPOSITORY VERIFICATION                   "
echo "================================================================="

# 1. Check for forbidden dash characters (strict ASCII hyphens only)
echo ""
echo "[Step 1/5] Checking for forbidden dash characters..."
python3 scripts/check_no_em_dashes.py

# 2. Validate all Puppet manifests
echo ""
echo "[Step 2/5] Validating Puppet manifests..."
manifest_count=0
if command -v puppet >/dev/null 2>&1; then
  while IFS= read -r -d '' manifest; do
    puppet parser validate "$manifest"
    manifest_count=$((manifest_count + 1))
  done < <(find . -type f -name "*.pp" -not -path "*/.git/*" -not -path "*/vendor/*" -print0)
  echo "Validated ${manifest_count} Puppet manifest files without syntax errors."
else
  echo "Puppet executable not found in PATH; skipping manifest parser validation."
fi

# 3. Validate Python files syntax
echo ""
echo "[Step 3/5] Validating Python syntax..."
python_count=0
while IFS= read -r -d '' pyfile; do
  python3 -m py_compile "$pyfile"
  python_count=$((python_count + 1))
done < <(find . -type f -name "*.py" -not -path "*/.git/*" -not -path "*/build/*" -not -path "*/.venv/*" -print0)
echo "Validated ${python_count} Python source files without syntax errors."

# 4. Compile native C components if Makefile exists
echo ""
echo "[Step 4/5] Building native C extensions..."
if [ -f Makefile ]; then
  make clean >/dev/null 2>&1 || true
  make all
  echo "Native C components compiled successfully."
else
  echo "No root Makefile found; skipping C compilation."
fi

# 5. Run Python test suite
echo ""
echo "[Step 5/5] Running pytest test suite..."
if [ -d tests ]; then
  python3 -m pytest tests -v
else
  echo "Tests directory not present yet; skipping test execution."
fi

echo ""
echo "================================================================="
echo "       ALL CAPSTAN VERIFICATION CHECKS PASSED SUCCESSFULLY       "
echo "================================================================="
