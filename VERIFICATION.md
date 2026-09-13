# Verification

## Toolchain

The repository pins:

```text
leanprover/lean4:v4.33.1
```

in `lean-toolchain`.

Lean v4.33.1 is used because the formalization was prepared against that stable release line. The toolchain is intentionally pinned so that future Lean releases do not silently change the verification environment.

## Automatic CI

GitHub Actions runs `.github/workflows/lean-verify.yml` on:

- pushes to `main`,
- pull requests targeting `main`,
- manual `workflow_dispatch`.

The workflow:

1. checks out the repository;
2. installs the pinned Lean toolchain using `leanprover/lean-action`;
3. runs `scripts/verify.sh`;
4. preserves the Lean output in the workflow log.

## Local verification

With `elan` installed:

```bash
bash scripts/verify.sh
```

The script performs three checks:

1. verifies that the Lean source does not contain `sorry` or `admit` proof placeholders;
2. invokes Lean on the full source file;
3. fails if the resulting axiom-audit output contains `sorryAx`.

The source itself contains `#print axioms` commands for each named theorem, so the CI log exposes the transitive axiom dependencies reported by Lean.

## Important interpretation

A successful Lean run establishes that the declarations and proofs in the source are accepted by the pinned Lean kernel environment.

It does **not** establish that the abstract predicates in the model faithfully describe any particular physical system. Model fidelity, evidence authenticity, causal attribution, sensor behavior, and deployment assumptions remain separate application obligations.

## Why there is no Mathlib or Lake dependency

`PhysicalAIPublicRealization.lean` imports only:

```lean
import Init
```

The repository therefore avoids unnecessary package dependencies. A Lake project can be added later if the repository grows into a multi-file formalization, but it is not needed for the current one-file kernel.
