# Physical AI Outcome Assurance

[![Lean verification](https://github.com/GhostDriftTheory/physical-ai-outcome-assurance/actions/workflows/lean-verify.yml/badge.svg)](https://github.com/GhostDriftTheory/physical-ai-outcome-assurance/actions/workflows/lean-verify.yml)

A small, standalone Lean 4 formalization of **outcome-certification limits and conditional realization in Physical AI**.

This repository distinguishes:

1. correctness established inside a verification model,
2. the executions to which that verification can legitimately be transferred, and
3. what may be certified about realized outcomes from the available evidence.

The formalization is intentionally abstract. It does **not** disclose an operational architecture for sensing, evidence authentication, execution control, gating, or physical-system implementation.

## Main result

The central distinction is:

> **A command being correct in a model does not, by itself, establish that the requested physical outcome was realized in a particular target execution.**

The file then formalizes both sides of the boundary:

- when ambiguous evidence prevents sound positive certification;
- when sound positive certification is possible;
- when exact certification is equivalent to outcome-relevant separation;
- when verification of a model can be transferred to evidence-compatible target executions;
- why post-processing information that already fails to distinguish opposite outcomes cannot repair that ambiguity.

The formalization also makes explicit that post-execution evidence is **not universally necessary**: if prior verification and coverage already establish the outcome for every target execution, non-distinguishing evidence may suffice.

## Repository contents

- `PhysicalAIPublicRealization.lean` — the complete formalization and closed finite examples.
- `lean-toolchain` — pins the Lean version used by CI.
- `scripts/verify.sh` — local verification entry point.
- `.github/workflows/lean-verify.yml` — automatic verification on pushes and pull requests.
- `VERIFICATION.md` — reproducibility and interpretation notes.

## Verification

This repository is pinned to Lean **v4.33.1**.

Run locally:

```bash
bash scripts/verify.sh
```

or directly:

```bash
lean PhysicalAIPublicRealization.lean
```

The source imports only Lean 4 `Init`; Mathlib and a Lake project are not required.

The Lean file contains `#print axioms` commands for every named theorem so that transitive axiom dependencies are visible in the verification output.

## What the formalization does not claim

The results are relative to the abstract target-range, model, evidence-compatibility, and outcome predicates supplied to the theorems. In particular, this repository does not by itself establish:

- that an abstract model faithfully represents a particular physical system;
- authenticity or provenance of real-world evidence;
- causal attribution of an outcome to a command;
- unconditional physical safety or accident prevention;
- continuous-time correctness, termination, latency, reliability, or deployment-scale guarantees;
- an algorithm for evidence acquisition or certification;
- a unique implementation or technical novelty.

These boundaries are part of the formal statement, not implementation omissions.

## Relationship to composition

This repository is intended as a companion to work on compositional assurance.

The two questions are different:

- **Composition:** when do locally established guarantees remain valid when AI systems, devices, or stages are connected?
- **Realization:** when may a guarantee about a command or model be transferred to a claim about the outcome of a target execution?

The shared indistinguishability principle is not presented as a new mathematical principle; here it is specialized to outcome certification and model-to-target transfer.

## License

No license file is included by default. Add the license that matches the intended publication and reuse policy before public release.
