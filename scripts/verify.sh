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
echo "[Step 1/7] Checking for forbidden dash characters..."
python3 scripts/check_no_em_dashes.py

# 2. Validate all Puppet manifests
echo ""
echo "[Step 2/7] Validating Puppet manifests..."
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
echo "[Step 3/7] Validating Python syntax..."
python_count=0
while IFS= read -r -d '' pyfile; do
  python3 -m py_compile "$pyfile"
  python_count=$((python_count + 1))
done < <(find . -type f -name "*.py" -not -path "*/.git/*" -not -path "*/build/*" -not -path "*/.venv/*" -print0)
echo "Validated ${python_count} Python source files without syntax errors."

# 4. Compile native C components and run C kernel tests
echo ""
echo "[Step 4/7] Building and testing native C extensions..."
if [ -f Makefile ]; then
  make clean >/dev/null 2>&1 || true
  make test
  echo "Native C components compiled and verified successfully."
else
  echo "No root Makefile found; skipping C compilation."
fi

# 5. Run Python test suite
echo ""
echo "[Step 5/7] Running pytest test suite..."
if [ -d tests ]; then
  if command -v pytest >/dev/null 2>&1; then
    pytest tests -v
  elif [ -x "$HOME/.local/bin/pytest" ]; then
    "$HOME/.local/bin/pytest" tests -v
  else
    python3 -m unittest discover tests -v
  fi
fi

# 6. Run Ruby RSpec tests
echo ""
echo "[Step 6/7] Running Ruby RSpec tests..."
if command -v rspec >/dev/null 2>&1; then
  rspec modules/capstan_core/spec/classes/init_spec.rb --format documentation
fi

# 7. Execute CLI Sanity Checks
echo ""
echo "[Step 7/7] Validating Capstan CLI entrypoints..."
./bin/capstan status >/dev/null
./bin/capstan plan >/dev/null
./bin/capstan top >/dev/null
echo "Capstan operator CLI validated successfully."

echo ""
echo "================================================================="
echo "       ALL CAPSTAN VERIFICATION CHECKS PASSED SUCCESSFULLY       "
echo "================================================================="
