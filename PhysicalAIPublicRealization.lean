import Init

/-!
# Physical AI: outcome certification limits and conditional realization

A standalone, domain-independent mathematical companion to
`PhysicalAIPublicComposition.lean`. This file does not import that file.

日本語要旨
----------
モデル内で命令の正しさが成立することと、対象実行の結果が成立することを
区別する。同じ証拠と両立する対象実行に成功と不成功が残る場合の認定限界、
結果を正しく認定できる必要十分条件、事前保証を結果保証に移せる十分条件を
示す。対象実行が存在しない証拠を成功として認定しない条件も明示する。
具体的な観測・認証・実行制御の方式や、装置・業務との対応づけは与えない。

Reading the abstract vocabulary
-------------------------------
* `Context` fixes the command, relevant prior assumptions, and the requested
  outcome together. Histories compared at the same context have the same claim.
* `History` is an abstract execution history, not necessarily just a final state.
* `R x h` selects the target histories under consideration.
* `M x h` selects the histories covered by a verification model.
* `O x e h` says that evidence `e` is compatible with history `h` at context `x`.
  This is a relation: neither uniqueness nor functional evidence is assumed.
* `G x h` is the specified outcome predicate. It is not computed by this file.
* `C x e` is a positive, proposition-valued certification. Its negation means
  withholding that positive certification, not certifying failure or stopping
  a physical system.

Principal results
-----------------
A. `Examples.model_verified_but_target_not_correct` is a closed, non-vacuous
   counterexample to transferring model verification without a bridge condition.
B. `bad_compatible_history_forces_withholding` needs soundness alone.
   `ambiguous_evidence_blocks_exact_certification` additionally rules out
   simultaneous soundness and completeness on mixed-outcome evidence.
C. `sound_certification_iff_all_compatible_good` characterizes positive
   certifiability for possible evidence. `supported_certification_iff` makes
   nonempty support explicit, including at evidence with no compatible history.
D. `exact_certification_iff_separation` characterizes exact logical certification
   for a general compatibility relation, not just a deterministic summary.
E. `verified_model_transfers_to_evidence_outcomes` and
   `global_model_coverage_transfers` are positive, conditional transfer results.
   In particular, additional post-execution evidence is not universally required.

The finite examples use the same three anonymous histories throughout. They
include a successful history outside the original verification model, so being
outside that model is not identified with outcome failure. Two successful
histories remain indistinguishable in the positive evidence example: full
history reconstruction is not required.

Interpretation boundary
-----------------------
1. All guarantees are relative to the supplied `R`, `M`, `O`, and `G`. This file
   does not establish that they faithfully describe an actual physical system.
   In particular, the target range must not silently exclude relevant failures.
2. Compatibility with evidence is not a proof of evidence authenticity or of
   its association with a particular actual execution. Those are separate
   application obligations, not mechanisms supplied by this file.
3. Outcome satisfaction is not causal attribution. No causal semantics are
   defined, and no theorem claims that a command caused an observed outcome.
4. No unconditional physical safety, accident prevention, continuous-time safety,
   termination, latency, reliability, or deployment-scale result is claimed.
5. Soundness does not imply completeness. Withholding every certification is
   sound; it is incomplete when a successful compatible history exists.
6. Existential certifiers and `CertainOutcome` are logical predicates, not
   algorithms, evidence acquisition procedures, or executable decision systems.
   No decidability assumption or computational cost bound is asserted.
7. `AllCompatibleGood` alone is vacuous on an empty compatibility range.
   `CertainOutcome` also requires an actual witness in that range. This logical
   witness is not itself a physical observation or a progress guarantee.
8. No unique implementation, technical novelty, or confidentiality guarantee
   follows from these general logical results. No application architecture or
   operational implementation is disclosed.

Relationship to the composition companion
----------------------------------------
The indistinguishability principle is shared, not claimed as a new independent
principle. Here it is specialized to outcome certification with relational
compatibility and explicit model-to-target transfer obligations. The arbitrary-
length composition and pipeline development is intentionally not duplicated.

Verification and reproducibility
--------------------------------
Dependency: Lean 4 `Init` only; no Mathlib, Lake project, or companion file.
Run: `lean PhysicalAIPublicRealization.lean`
The final section prints axiom dependencies for every named theorem in this file.
There are no proof placeholders, added axioms, native-evaluation proofs, or
custom elaborators in this source.

Validation status of this delivered source: Lean compiler execution has NOT
been performed in the authoring environment because a Lean toolchain was not
available there. The definitions and proofs have been reviewed, and the central
finite-model conditions have been cross-checked separately. That cross-check
is not a Lean kernel check. No successful Lean version or build is claimed here.
-/

set_option autoImplicit false

namespace PhysicalAIPublicRealization

universe u v w z

/-! ## 1. Abstract definitions -/

section Definitions

variable {Context : Type u} {History : Type v} {Evidence : Type w}

/-- A history is both in the chosen target range and compatible with the evidence. -/
def Compatible
    (R : Context → History → Prop)
    (O : Context → Evidence → History → Prop)
    (x : Context) (e : Evidence) (h : History) : Prop :=
  R x h ∧ O x e h

/-- Nonempty logical support. This is not an observation-production method. -/
def EvidencePossible
    (R : Context → History → Prop)
    (O : Context → Evidence → History → Prop)
    (x : Context) (e : Evidence) : Prop :=
  ∃ h, Compatible R O x e h

/-- All histories still compatible with the evidence satisfy the outcome. -/
def AllCompatibleGood
    (R : Context → History → Prop)
    (O : Context → Evidence → History → Prop)
    (G : Context → History → Prop)
    (x : Context) (e : Evidence) : Prop :=
  ∀ h, Compatible R O x e h → G x h

/-- No compatible failing history receives a positive certification. -/
def CertificationSound
    (R : Context → History → Prop)
    (O : Context → Evidence → History → Prop)
    (G : Context → History → Prop)
    (C : Context → Evidence → Prop) : Prop :=
  ∀ x e h, Compatible R O x e h → C x e → G x h

/-- Every compatible successful history receives a positive certification.
    This quantifies over all compatible evidence, not just one chosen report. -/
def CertificationComplete
    (R : Context → History → Prop)
    (O : Context → Evidence → History → Prop)
    (G : Context → History → Prop)
    (C : Context → Evidence → Prop) : Prop :=
  ∀ x e h, Compatible R O x e h → G x h → C x e

def CertificationExact
    (R : Context → History → Prop)
    (O : Context → Evidence → History → Prop)
    (G : Context → History → Prop)
    (C : Context → Evidence → Prop) : Prop :=
  CertificationSound R O G C ∧ CertificationComplete R O G C

/-- A positive certification must have at least one compatible target history. -/
def CertificationSupported
    (R : Context → History → Prop)
    (O : Context → Evidence → History → Prop)
    (C : Context → Evidence → Prop) : Prop :=
  ∀ x e, C x e → EvidencePossible R O x e

/-- Equal available evidence cannot leave opposite outcomes among target histories.
    This does not require that evidence identify a unique history. -/
def OutcomeSeparation
    (R : Context → History → Prop)
    (O : Context → Evidence → History → Prop)
    (G : Context → History → Prop) : Prop :=
  ∀ x e h k, Compatible R O x e h → Compatible R O x e k →
    (G x h ↔ G x k)

/-- A logical, supported positive-certification predicate. NOT an algorithm. -/
def CertainOutcome
    (R : Context → History → Prop)
    (O : Context → Evidence → History → Prop)
    (G : Context → History → Prop)
    (x : Context) (e : Evidence) : Prop :=
  EvidencePossible R O x e ∧ AllCompatibleGood R O G x e

/-- Verification is a theorem about every model history, not a Boolean flag. -/
def ModelVerified
    (M G : Context → History → Prop) (x : Context) : Prop :=
  ∀ h, M x h → G x h

/-- Every target history satisfies the specified outcome. -/
def TargetCorrect
    (R G : Context → History → Prop) (x : Context) : Prop :=
  ∀ h, R x h → G x h

/-- The evidence-compatible target histories lie in the verified model range. -/
def ModelCoversEvidence
    (R : Context → History → Prop)
    (O : Context → Evidence → History → Prop)
    (M : Context → History → Prop)
    (x : Context) (e : Evidence) : Prop :=
  ∀ h, Compatible R O x e h → M x h

/-- An explicit prior bridge from the target range to the verified model. -/
def ModelCoversTargets
    (R M : Context → History → Prop) (x : Context) : Prop :=
  ∀ h, R x h → M x h

end Definitions

/-! ## 2. What ambiguous evidence prevents -/

section Limits

variable {Context : Type u} {History : Type v} {Evidence : Type w}
variable (R : Context → History → Prop)
variable (O : Context → Evidence → History → Prop)
variable (G : Context → History → Prop)

/-- A single compatible failure forces withholding under soundness alone. -/
theorem bad_compatible_history_forces_withholding
    (C : Context → Evidence → Prop)
    (sound : CertificationSound R O G C)
    (x : Context) (e : Evidence) (h : History)
    (compatible : Compatible R O x e h)
    (bad : ¬ G x h) :
    ¬ C x e := by
  intro certified
  exact bad (sound x e h compatible certified)

/-- Mixed outcomes at the same evidence exclude simultaneous soundness and
    completeness. They do not exclude sound withholding. -/
theorem ambiguous_evidence_blocks_exact_certification
    (x : Context) (e : Evidence) (h k : History)
    (compatibleH : Compatible R O x e h)
    (compatibleK : Compatible R O x e k)
    (good : G x h) (bad : ¬ G x k) :
    ¬ ∃ C : Context → Evidence → Prop, CertificationExact R O G C := by
  intro candidate
  cases candidate with
  | intro C exactness =>
    have withheld := bad_compatible_history_forces_withholding
      R O G C exactness.1 x e k compatibleK bad
    exact withheld (exactness.2 x e h compatibleH good)

/-- The identically withholding predicate is sound, even with ambiguous evidence. -/
theorem withholding_is_sound :
    CertificationSound R O G (fun _ _ => False) := by
  intro x e h compatible impossible
  exact False.elim impossible

/-- Withholding also satisfies the support requirement. -/
theorem withholding_is_supported :
    CertificationSupported R O (fun _ _ => False) := by
  intro x e impossible
  exact False.elim impossible

/-- A success that is compatible with some evidence witnesses incompleteness
    of universal withholding. No claim about physical stopping is made. -/
theorem withholding_misses_compatible_success
    (x : Context) (e : Evidence) (h : History)
    (compatible : Compatible R O x e h) (good : G x h) :
    ¬ CertificationComplete R O G (fun _ _ => False) := by
  intro complete
  exact complete x e h compatible good

end Limits

/-! ## 3. Positive certifiability and its non-vacuous boundary -/

section CertificationBoundary

variable {Context : Type u} {History : Type v} {Evidence : Type w}
variable (R : Context → History → Prop)
variable (O : Context → Evidence → History → Prop)
variable (G : Context → History → Prop)

/-- The logical universal condition gives a sound certification predicate. -/
theorem certain_outcome_is_sound :
    CertificationSound R O G (CertainOutcome R O G) := by
  intro x e h compatible certified
  exact certified.2 h compatible

/-- Empty evidence support cannot yield `CertainOutcome`. -/
theorem certain_outcome_is_supported :
    CertificationSupported R O (CertainOutcome R O G) := by
  intro x e certified
  exact certified.1

/-- Every sound positive certification entails the universal outcome condition. -/
theorem sound_certification_requires_all_compatible_good
    (C : Context → Evidence → Prop)
    (sound : CertificationSound R O G C)
    (x : Context) (e : Evidence) (certified : C x e) :
    AllCompatibleGood R O G x e := by
  intro h compatible
  exact sound x e h compatible certified

/-- Principal pointwise boundary, stated for evidence with nonempty support.
    The witness on the left is a logical predicate, not a decision procedure. -/
theorem sound_certification_iff_all_compatible_good
    (x : Context) (e : Evidence)
    (possible : EvidencePossible R O x e) :
    (∃ C : Context → Evidence → Prop,
      CertificationSound R O G C ∧ C x e) ↔
    AllCompatibleGood R O G x e := by
  constructor
  · intro candidate
    cases candidate with
    | intro C facts =>
      exact sound_certification_requires_all_compatible_good
        R O G C facts.1 x e facts.2
  · intro allGood
    exact ⟨CertainOutcome R O G, certain_outcome_is_sound R O G,
      ⟨possible, allGood⟩⟩

/-- The version that handles impossible evidence explicitly: supported positive
    certification is possible exactly at a nonempty all-good compatibility range. -/
theorem supported_certification_iff
    (x : Context) (e : Evidence) :
    (∃ C : Context → Evidence → Prop,
      CertificationSound R O G C ∧ CertificationSupported R O C ∧ C x e) ↔
    (EvidencePossible R O x e ∧ AllCompatibleGood R O G x e) := by
  constructor
  · intro candidate
    cases candidate with
    | intro C facts =>
      refine ⟨facts.2.1 x e facts.2.2, ?_⟩
      exact sound_certification_requires_all_compatible_good
        R O G C facts.1 x e facts.2.2
  · intro facts
    exact ⟨CertainOutcome R O G, certain_outcome_is_sound R O G,
      certain_outcome_is_supported R O G, facts⟩

/-- Every sound, supported positive certifier is contained in the logical
    predicate `CertainOutcome`. This is not a computable maximality claim. -/
theorem sound_supported_certification_implies_certain_outcome
    (C : Context → Evidence → Prop)
    (sound : CertificationSound R O G C)
    (supported : CertificationSupported R O C)
    (x : Context) (e : Evidence) (certified : C x e) :
    CertainOutcome R O G x e := by
  exact ⟨supported x e certified,
    sound_certification_requires_all_compatible_good R O G C sound x e certified⟩

/-- On an empty range the universal condition is vacuous. -/
theorem impossible_evidence_has_vacuous_universal_condition
    (x : Context) (e : Evidence)
    (impossible : ¬ EvidencePossible R O x e) :
    AllCompatibleGood R O G x e := by
  intro h compatible
  exact False.elim (impossible ⟨h, compatible⟩)

/-- The supported certifier nevertheless withholds on that empty range. -/
theorem impossible_evidence_is_not_certified
    (x : Context) (e : Evidence)
    (impossible : ¬ EvidencePossible R O x e) :
    ¬ CertainOutcome R O G x e := by
  intro certified
  exact impossible certified.1

/-- A one-way logical guarantee for a designated actual history, provided its
    membership and evidence compatibility are established separately. -/
theorem certified_outcome_for_compatible_history
    (x : Context) (e : Evidence) (h : History)
    (compatible : Compatible R O x e h)
    (certified : CertainOutcome R O G x e) :
    G x h := by
  exact certified.2 h compatible

end CertificationBoundary

/-! ## 4. Exact certification and outcome-relevant separation -/

section Exactness

variable {Context : Type u} {History : Type v} {Evidence : Type w}
variable (R : Context → History → Prop)
variable (O : Context → Evidence → History → Prop)
variable (G : Context → History → Prop)

/-- Necessity: exact logical certification cannot mix opposite outcomes. -/
theorem exact_certification_implies_separation
    (C : Context → Evidence → Prop)
    (exactness : CertificationExact R O G C) :
    OutcomeSeparation R O G := by
  intro x e h k compatibleH compatibleK
  constructor
  · intro good
    exact exactness.1 x e k compatibleK
      (exactness.2 x e h compatibleH good)
  · intro good
    exact exactness.1 x e h compatibleH
      (exactness.2 x e k compatibleK good)

/-- Sufficiency: preserving outcome-relevant distinctions makes the supported
    universal predicate complete. No choice or decidability is needed. -/
theorem separation_makes_certain_outcome_complete
    (separation : OutcomeSeparation R O G) :
    CertificationComplete R O G (CertainOutcome R O G) := by
  intro x e h compatibleH good
  refine ⟨⟨h, compatibleH⟩, ?_⟩
  intro k compatibleK
  exact (separation x e h k compatibleH compatibleK).mp good

/-- A supported exact logical certifier exists under outcome separation. -/
theorem separation_supports_exact_certification
    (separation : OutcomeSeparation R O G) :
    ∃ C : Context → Evidence → Prop,
      CertificationExact R O G C ∧ CertificationSupported R O C := by
  exact ⟨CertainOutcome R O G,
    ⟨certain_outcome_is_sound R O G,
      separation_makes_certain_outcome_complete R O G separation⟩,
    certain_outcome_is_supported R O G⟩

/-- Principal global boundary for the specified target range and evidence
    relation. Exactness is about all compatible pairs, not about evidence
    availability for histories with no compatible evidence. -/
theorem exact_certification_iff_separation :
    (∃ C : Context → Evidence → Prop, CertificationExact R O G C) ↔
    OutcomeSeparation R O G := by
  constructor
  · intro candidate
    cases candidate with
    | intro C exactness =>
      exact exact_certification_implies_separation R O G C exactness
  · intro separation
    cases separation_supports_exact_certification R O G separation with
    | intro C facts => exact ⟨C, facts.1⟩

/-- Requiring nonempty support does not change the separation condition for
    existence of an exact certifier: the constructed one already has support. -/
theorem supported_exact_certification_iff_separation :
    (∃ C : Context → Evidence → Prop,
      CertificationExact R O G C ∧ CertificationSupported R O C) ↔
    OutcomeSeparation R O G := by
  constructor
  · intro candidate
    cases candidate with
    | intro C facts =>
      exact exact_certification_implies_separation R O G C facts.1
  · intro separation
    exact separation_supports_exact_certification R O G separation

end Exactness

/-! ## 5. Positive model-to-target transfer conditions -/

section ModelTransfer

variable {Context : Type u} {History : Type v} {Evidence : Type w}
variable (R : Context → History → Prop)
variable (O : Context → Evidence → History → Prop)
variable (M G : Context → History → Prop)

/-- Model verification transfers when every compatible target history is in
    that model. Coverage is an explicit sufficient condition, not a necessity. -/
theorem verified_model_transfers_to_evidence_outcomes
    (x : Context) (e : Evidence)
    (verified : ModelVerified M G x)
    (covered : ModelCoversEvidence R O M x e) :
    AllCompatibleGood R O G x e := by
  intro h compatible
  exact verified h (covered h compatible)

/-- The same transfer yields a non-vacuous certification with nonempty support. -/
theorem verified_model_supports_outcome_certification
    (x : Context) (e : Evidence)
    (verified : ModelVerified M G x)
    (covered : ModelCoversEvidence R O M x e)
    (possible : EvidencePossible R O x e) :
    CertainOutcome R O G x e := by
  exact ⟨possible,
    verified_model_transfers_to_evidence_outcomes R O M G x e verified covered⟩

/-- A global bridge established a priori can already cover all target histories. -/
theorem global_model_coverage_transfers
    (x : Context)
    (verified : ModelVerified M G x)
    (covered : ModelCoversTargets R M x) :
    TargetCorrect R G x := by
  intro h target
  exact verified h (covered h target)

/-- The global bridge implies the evidence-specific bridge for any evidence. -/
theorem global_coverage_covers_each_evidence_range
    (x : Context) (e : Evidence)
    (covered : ModelCoversTargets R M x) :
    ModelCoversEvidence R O M x e := by
  intro h compatible
  exact covered h compatible.1

/-- If the target range is already proved good, compatible evidence need not
    distinguish histories in order to support positive certification. -/
theorem target_guarantee_supports_any_possible_evidence
    (x : Context) (e : Evidence)
    (correct : TargetCorrect R G x)
    (possible : EvidencePossible R O x e) :
    CertainOutcome R O G x e := by
  refine ⟨possible, ?_⟩
  intro h compatible
  exact correct h compatible.1

/-- A constant, wholly non-distinguishing evidence relation suffices when prior
    model coverage and verification already establish every target outcome.
    This prevents a claim that post-execution observation is always necessary. -/
theorem prior_coverage_can_suffice_without_distinguishing_evidence
    (x : Context)
    (verified : ModelVerified M G x)
    (covered : ModelCoversTargets R M x)
    (targetExists : ∃ h, R x h) :
    CertainOutcome R (fun (_ : Context) (_ : Unit) (_ : History) => True) G x () := by
  refine ⟨?_, ?_⟩
  · cases targetExists with
    | intro h target => exact ⟨h, target, True.intro⟩
  · intro h compatible
    exact verified h (covered h compatible.1)

end ModelTransfer

/-! ## 6. A limited postprocessing corollary

Only the available evidence is processed. No fresh information, target-range
restriction, or strengthening of the prior context is smuggled into this result.
-/

section Postprocessing

variable {Context : Type u} {History : Type v}
variable {Evidence : Type w} {Processed : Type z}

/-- Compatibility after a function of existing evidence; not a physical pipeline. -/
def ProcessedCompatibility
    (O : Context → Evidence → History → Prop)
    (process : Evidence → Processed)
    (x : Context) (q : Processed) (h : History) : Prop :=
  ∃ e, O x e h ∧ process e = q

theorem postprocessing_preserves_compatibility
    (R : Context → History → Prop)
    (O : Context → Evidence → History → Prop)
    (process : Evidence → Processed)
    (x : Context) (e : Evidence) (h : History)
    (compatible : Compatible R O x e h) :
    Compatible R (ProcessedCompatibility O process) x (process e) h := by
  exact ⟨compatible.1, ⟨e, compatible.2, rfl⟩⟩

/-- A shared mixed-outcome evidence item remains ambiguous after processing. -/
theorem postprocessing_cannot_resolve_ambiguous_outcomes
    (R : Context → History → Prop)
    (O : Context → Evidence → History → Prop)
    (G : Context → History → Prop)
    (process : Evidence → Processed)
    (x : Context) (e : Evidence) (h k : History)
    (compatibleH : Compatible R O x e h)
    (compatibleK : Compatible R O x e k)
    (good : G x h) (bad : ¬ G x k) :
    ¬ ∃ C : Context → Processed → Prop,
      CertificationExact R (ProcessedCompatibility O process) G C := by
  exact ambiguous_evidence_blocks_exact_certification
    R (ProcessedCompatibility O process) G x (process e) h k
    (postprocessing_preserves_compatibility R O process x e h compatibleH)
    (postprocessing_preserves_compatibility R O process x e k compatibleK)
    good bad

end Postprocessing

/-! ## 7. Closed, anonymous finite counterexamples and positive examples

One context and three histories. No device or workflow interpretation is given.

  history | target | original model | outcome | coarse evidence | finer evidence
  a       | yes    | yes            | true    | ()              | true
  b       | yes    | no             | true    | ()              | true
  c       | yes    | no             | false   | ()              | false

The finer evidence is not a function of the coarse evidence. It is a separate
mathematical relation; this file does not specify how to obtain it.
-/

namespace Examples

inductive History where
  | a
  | b
  | c

def targets (_ : Unit) (_ : History) : Prop := True

def model (_ : Unit) (h : History) : Prop := h = History.a

def outcome (_ : Unit) (h : History) : Prop := h ≠ History.c

def coarseEvidence (_ : Unit) (_ : Unit) (_ : History) : Prop := True

def label : History → Bool
  | .a => true
  | .b => true
  | .c => false

def finerEvidence (_ : Unit) (e : Bool) (h : History) : Prop := label h = e

theorem outcome_a : outcome () History.a := by
  intro impossible
  cases impossible

theorem outcome_b : outcome () History.b := by
  intro impossible
  cases impossible

theorem not_outcome_c : ¬ outcome () History.c := by
  intro claimed
  exact claimed rfl

theorem a_ne_b : History.a ≠ History.b := by
  intro impossible
  cases impossible

theorem b_outside_model : ¬ model () History.b := by
  intro impossible
  cases impossible

/-- The verification model is inhabited and its assertion genuinely holds. -/
theorem original_model_is_verified : ModelVerified model outcome () := by
  intro h inModel
  change h = History.a at inModel
  cases inModel
  exact outcome_a

/-- A closed counterexample with an inhabited verified model, a successful
    target history, and a failing target history. No application hypothesis. -/
theorem model_verified_but_target_not_correct :
    ModelVerified model outcome () ∧
    (∃ h, model () h) ∧
    (∃ h, targets () h ∧ outcome () h) ∧
    (∃ h, targets () h ∧ ¬ outcome () h) ∧
    ¬ TargetCorrect targets outcome () := by
  refine ⟨original_model_is_verified, ⟨History.a, rfl⟩,
    ⟨History.a, True.intro, outcome_a⟩,
    ⟨History.c, True.intro, not_outcome_c⟩, ?_⟩
  intro targetCorrect
  exact not_outcome_c (targetCorrect History.c True.intro)

theorem coarse_evidence_is_possible :
    EvidencePossible targets coarseEvidence () () := by
  exact ⟨History.a, True.intro, True.intro⟩

/-- Not merely a constant-false certification: every sound certifier withholds. -/
theorem no_sound_certifier_accepts_coarse_evidence :
    ∀ C : Unit → Unit → Prop,
      CertificationSound targets coarseEvidence outcome C → ¬ C () () := by
  intro C sound
  exact bad_compatible_history_forces_withholding
    targets coarseEvidence outcome C sound () () History.c
    ⟨True.intro, True.intro⟩ not_outcome_c

/-- Explicit success and failure at the same evidence rule out exactness. -/
theorem coarse_evidence_has_no_exact_certifier :
    ¬ ∃ C : Unit → Unit → Prop,
      CertificationExact targets coarseEvidence outcome C := by
  exact ambiguous_evidence_blocks_exact_certification
    targets coarseEvidence outcome () () History.a History.c
    ⟨True.intro, True.intro⟩ ⟨True.intro, True.intro⟩ outcome_a not_outcome_c

theorem finer_true_implies_outcome
    (h : History) (compatible : Compatible targets finerEvidence () true h) :
    outcome () h := by
  cases h with
  | a => exact outcome_a
  | b => exact outcome_b
  | c =>
    have impossible : (false : Bool) = true := compatible.2
    cases impossible

theorem finer_false_implies_no_outcome
    (h : History) (compatible : Compatible targets finerEvidence () false h) :
    ¬ outcome () h := by
  cases h with
  | a =>
    have impossible : (true : Bool) = false := compatible.2
    cases impossible
  | b =>
    have impossible : (true : Bool) = false := compatible.2
    cases impossible
  | c => exact not_outcome_c

/-- Finer evidence separates outcome truth, not all histories. -/
theorem finer_evidence_separates :
    OutcomeSeparation targets finerEvidence outcome := by
  intro x e h k compatibleH compatibleK
  cases x
  cases e with
  | false =>
    constructor
    · intro good
      exact False.elim (finer_false_implies_no_outcome h compatibleH good)
    · intro good
      exact False.elim (finer_false_implies_no_outcome k compatibleK good)
  | true =>
    constructor
    · intro _
      exact finer_true_implies_outcome k compatibleK
    · intro _
      exact finer_true_implies_outcome h compatibleH

theorem finer_evidence_has_supported_exact_certifier :
    ∃ C : Unit → Bool → Prop,
      CertificationExact targets finerEvidence outcome C ∧
      CertificationSupported targets finerEvidence C := by
  exact separation_supports_exact_certification
    targets finerEvidence outcome finer_evidence_separates

/-- A concrete positive certification with two different compatible histories. -/
theorem finer_positive_evidence_is_certified :
    CertainOutcome targets finerEvidence outcome () true := by
  refine ⟨⟨History.a, True.intro, rfl⟩, ?_⟩
  intro h compatible
  exact finer_true_implies_outcome h compatible

theorem finer_negative_evidence_is_not_certified :
    ¬ CertainOutcome targets finerEvidence outcome () false := by
  exact bad_compatible_history_forces_withholding
    targets finerEvidence outcome (CertainOutcome targets finerEvidence outcome)
    (certain_outcome_is_sound targets finerEvidence outcome)
    () false History.c ⟨True.intro, rfl⟩ not_outcome_c

/-- The positive certificate does not require reconstructing the full history.
    This is a logical existence example, not a confidentiality mechanism. -/
theorem certification_without_full_history_reconstruction :
    History.a ≠ History.b ∧
    Compatible targets finerEvidence () true History.a ∧
    Compatible targets finerEvidence () true History.b ∧
    outcome () History.a ∧ outcome () History.b ∧
    CertainOutcome targets finerEvidence outcome () true := by
  exact ⟨a_ne_b, ⟨True.intro, rfl⟩, ⟨True.intro, rfl⟩,
    outcome_a, outcome_b, finer_positive_evidence_is_certified⟩

/-- A successful target history may lie outside the original verification model. -/
theorem successful_outside_model_history_is_certified :
    ¬ model () History.b ∧ outcome () History.b ∧
    Compatible targets finerEvidence () true History.b ∧
    CertainOutcome targets finerEvidence outcome () true := by
  exact ⟨b_outside_model, outcome_b, ⟨True.intro, rfl⟩,
    finer_positive_evidence_is_certified⟩

/-- The model-coverage bridge is sufficient, not necessary for certifiability. -/
theorem original_model_coverage_is_not_necessary_for_certification :
    CertainOutcome targets finerEvidence outcome () true ∧
    ¬ ModelCoversEvidence targets finerEvidence model () true := by
  refine ⟨finer_positive_evidence_is_certified, ?_⟩
  intro covered
  exact b_outside_model (covered History.b ⟨True.intro, rfl⟩)

/-- An additional anonymous evidence relation, solely to witness the positive
    model-transfer theorem. No way of constructing this evidence is supplied. -/
def modelRangeEvidence (_ : Unit) (_ : Unit) (h : History) : Prop :=
  h = History.a

theorem model_range_evidence_is_covered :
    ModelCoversEvidence targets modelRangeEvidence model () () := by
  intro h compatible
  exact compatible.2

theorem model_range_evidence_is_possible :
    EvidencePossible targets modelRangeEvidence () () := by
  exact ⟨History.a, True.intro, rfl⟩

/-- A nonempty positive instance of the conditional model-to-evidence bridge. -/
theorem conditional_model_transfer_has_positive_instance :
    CertainOutcome targets modelRangeEvidence outcome () () := by
  exact verified_model_supports_outcome_certification
    targets modelRangeEvidence model outcome () () original_model_is_verified
    model_range_evidence_is_covered model_range_evidence_is_possible

/-- An explicit change of target range for a separate prior-coverage example.
    The earlier full-target counterexample is NOT modified or repaired by this. -/
def restrictedTargets (_ : Unit) (h : History) : Prop :=
  h = History.a ∨ h = History.b

def coveringModel (_ : Unit) (h : History) : Prop :=
  h = History.a ∨ h = History.b

theorem covering_model_is_verified : ModelVerified coveringModel outcome () := by
  intro h inModel
  cases inModel with
  | inl isA =>
    cases isA
    exact outcome_a
  | inr isB =>
    cases isB
    exact outcome_b

theorem covering_model_covers_restricted_targets :
    ModelCoversTargets restrictedTargets coveringModel () := by
  intro h inRange
  exact inRange

/-- A non-vacuous prior-only example still containing two successful histories. -/
theorem prior_coverage_without_distinguishing_evidence_has_positive_instance :
    CertainOutcome restrictedTargets coarseEvidence outcome () () := by
  exact prior_coverage_can_suffice_without_distinguishing_evidence
    restrictedTargets coveringModel outcome () covering_model_is_verified
    covering_model_covers_restricted_targets ⟨History.a, Or.inl rfl⟩

/-- An incompatible evidence relation for checking the non-vacuity guard. -/
def impossibleEvidence (_ : Unit) (_ : Unit) (_ : History) : Prop := False

theorem impossible_evidence_has_no_support :
    ¬ EvidencePossible targets impossibleEvidence () () := by
  intro possible
  cases possible with
  | intro h compatible => exact compatible.2

/-- Universal truth on an empty evidence range is not a positive certification. -/
theorem empty_evidence_range_does_not_create_certification :
    AllCompatibleGood targets impossibleEvidence outcome () () ∧
    ¬ CertainOutcome targets impossibleEvidence outcome () () := by
  exact ⟨impossible_evidence_has_vacuous_universal_condition
      targets impossibleEvidence outcome () () impossible_evidence_has_no_support,
    impossible_evidence_is_not_certified
      targets impossibleEvidence outcome () () impossible_evidence_has_no_support⟩

end Examples

/-! ## 8. Axiom audit

Every named theorem in this file is listed. These commands report actual
transitive axiom dependencies when run; they are not pre-recorded results.
-/

#print axioms bad_compatible_history_forces_withholding
#print axioms ambiguous_evidence_blocks_exact_certification
#print axioms withholding_is_sound
#print axioms withholding_is_supported
#print axioms withholding_misses_compatible_success
#print axioms certain_outcome_is_sound
#print axioms certain_outcome_is_supported
#print axioms sound_certification_requires_all_compatible_good
#print axioms sound_certification_iff_all_compatible_good
#print axioms supported_certification_iff
#print axioms sound_supported_certification_implies_certain_outcome
#print axioms impossible_evidence_has_vacuous_universal_condition
#print axioms impossible_evidence_is_not_certified
#print axioms certified_outcome_for_compatible_history
#print axioms exact_certification_implies_separation
#print axioms separation_makes_certain_outcome_complete
#print axioms separation_supports_exact_certification
#print axioms exact_certification_iff_separation
#print axioms supported_exact_certification_iff_separation
#print axioms verified_model_transfers_to_evidence_outcomes
#print axioms verified_model_supports_outcome_certification
#print axioms global_model_coverage_transfers
#print axioms global_coverage_covers_each_evidence_range
#print axioms target_guarantee_supports_any_possible_evidence
#print axioms prior_coverage_can_suffice_without_distinguishing_evidence
#print axioms postprocessing_preserves_compatibility
#print axioms postprocessing_cannot_resolve_ambiguous_outcomes
#print axioms Examples.outcome_a
#print axioms Examples.outcome_b
#print axioms Examples.not_outcome_c
#print axioms Examples.a_ne_b
#print axioms Examples.b_outside_model
#print axioms Examples.original_model_is_verified
#print axioms Examples.model_verified_but_target_not_correct
#print axioms Examples.coarse_evidence_is_possible
#print axioms Examples.no_sound_certifier_accepts_coarse_evidence
#print axioms Examples.coarse_evidence_has_no_exact_certifier
#print axioms Examples.finer_true_implies_outcome
#print axioms Examples.finer_false_implies_no_outcome
#print axioms Examples.finer_evidence_separates
#print axioms Examples.finer_evidence_has_supported_exact_certifier
#print axioms Examples.finer_positive_evidence_is_certified
#print axioms Examples.finer_negative_evidence_is_not_certified
#print axioms Examples.certification_without_full_history_reconstruction
#print axioms Examples.successful_outside_model_history_is_certified
#print axioms Examples.original_model_coverage_is_not_necessary_for_certification
#print axioms Examples.model_range_evidence_is_covered
#print axioms Examples.model_range_evidence_is_possible
#print axioms Examples.conditional_model_transfer_has_positive_instance
#print axioms Examples.covering_model_is_verified
#print axioms Examples.covering_model_covers_restricted_targets
#print axioms Examples.prior_coverage_without_distinguishing_evidence_has_positive_instance
#print axioms Examples.impossible_evidence_has_no_support
#print axioms Examples.empty_evidence_range_does_not_create_certification

end PhysicalAIPublicRealization
