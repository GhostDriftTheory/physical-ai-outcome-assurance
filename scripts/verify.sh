#!/usr/bin/env bash
set -euo pipefail

FILE="PhysicalAIPublicRealization.lean"
OUTPUT="lean-verification-output.txt"

echo "== Lean version =="
lean --version

echo
echo "== Source placeholder check =="

# Match proof-placeholder tokens in source code. Comments in this repository do not
# intentionally contain these standalone tokens.
if grep -nE '(^|[^A-Za-z0-9_])(sorry|admit)([^A-Za-z0-9_]|$)' "$FILE"; then
  echo
  echo "ERROR: proof placeholder token found in $FILE"
  exit 1
fi

echo "No sorry/admit proof placeholders found."

echo
echo "== Lean kernel check and axiom audit =="
lean "$FILE" 2>&1 | tee "$OUTPUT"

echo
echo "== Reject sorryAx dependencies =="
if grep -q 'sorryAx' "$OUTPUT"; then
  echo "ERROR: Lean reported a dependency on sorryAx."
  exit 1
fi

echo "No sorryAx dependency reported."
echo
echo "Verification completed successfully."
