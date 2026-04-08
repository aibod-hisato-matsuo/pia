# SKILL: SVA Vertical Design Validation

## 1. Purpose

This skill validates the **vertical design flow** of SVA Design Factory.

It checks whether the following design chain is coherent:

- Project Spec (01–10)
- Vertical Spec (11–19)
- Stack Spec (20–23)

This skill is intended for a Claude Code sub agent that acts as a
**vertical design validator**, not as a generator.

Its role is to detect:

- missing vertical links
- inconsistent responsibility placement
- weak or missing policies
- contradictions between requirements and stack allocation
- incomplete propagation of timing, safety, stale, ack, fail-safe, and observability concerns

---

## 2. Validation Scope

### In scope

#### Project Spec
- 01_project_context.json
- 02_requirement.json
- 03_usecase.json
- 04_data_model.json
- 05_device_context.json
- 06_external_interface.json
- 07_timing_constraint.json
- 08_logic_policy.json
- 09_safety_policy.json
- 10_operation_policy.json

#### Vertical Spec
- 11_internal_interface_seed.json
- 12_event_seed.json
- 13_internal_api_seed.json
- 14_stack_mapping_seed.json
- 15_vlp_policy.json
- 16_state_mode_policy.json
- 17_fault_recovery_policy.json
- 18_observability_policy.json
- 19_implementation_guardrail.json

#### Stack Spec
- 20_user_app_spec.md
- 21_backend_spec.md
- 22_device_spec.md
- 23_firmware_spec.md

---

## 3. Core Validation Objective

Validate that the design is truly vertical.

This means checking that:

1. Project intent is reflected in Vertical Spec
2. Vertical Spec is internally coherent
3. Stack Spec is derived from Vertical Spec, not invented independently
4. Safety, timing, state, observability, and implementation guardrails are propagated correctly
5. VLP reasoning is explicit and not accidental

---

## 4. Required Validation Mindset

The validator must think in the following order:

### A. Requirement-to-Structure
Do the requirements imply the vertical structures that appear in 11–14?

### B. Structure-to-Policy
Do the structures in 11–14 justify the policies in 15–19?

### C. Policy-to-Stack
Do the policies in 15–19 constrain and explain the stack responsibilities in 20–23?

### D. Cross-cutting integrity
Are timing, safety, stale, ack, fault, recovery, state, and observability treated consistently across layers?

---

## 5. Validation Questions

The validator must explicitly inspect the following.

### 5.1 Project Spec → Stack Mapping (14)

- Are the main capabilities from requirements represented in 14_stack_mapping_seed?
- Is each major responsibility assigned to a plausible primary stack?
- Are alternative stacks and rationale provided when useful?
- Are high-level responsibilities missing from stack mapping?

### 5.2 Project Spec → Interface/API/Event Seeds (11–13)

- If the system requires interaction across stacks, are interfaces defined?
- Are async concerns represented as events?
- Are sync query/control concerns represented as APIs?
- Are timing-sensitive paths represented with appropriate style and type?
- Are important data contracts missing?

### 5.3 Stack Mapping (14) → VLP Policy (15)

- Does VLP policy explain why responsibilities are placed in their current stacks?
- Does it define movement conditions, such as:
  - lower latency requirements
  - stronger safety requirements
  - network independence
  - hardware-near control needs
- Is the current partition justified, or merely assumed?

### 5.4 Requirements / Usecases → State/Mode Policy (16)

- Are the system states meaningful for the project?
- Are equipment states meaningful for the project?
- Are UI modes aligned with observable conditions such as stale / degraded / fault?
- Are critical modes such as safe / maintenance missing?

### 5.5 Safety / Operation / Device Context → Fault Recovery Policy (17)

- Are the main fault classes represented?
- Are retry / reconnect / degrade / fail-safe responsibilities allocated to plausible stacks?
- Are command failures and invalid states handled?
- Is stale treated as a quality/freshness concern rather than a raw crash condition?
- Is recovery logic missing where requirements imply resilience?

### 5.6 Interfaces / APIs / Events / Operations → Observability Policy (18)

- Are important APIs observable?
- Are important events observable?
- Are stale, ack, watchdog, fail-safe, reconnect, and quality degradations observable?
- Are observability responsibilities distributed across stacks appropriately?
- Are metrics/logs too vague or too generic?

### 5.7 Stack Mapping / Device Context / AIBOD Factory Rules → Guardrail Policy (19)

- Are preferred frameworks plausible for the target stacks?
- Are mandatory parts justified?
- Are parts aligned with contracts?
- Are stack rules constraining enough to guide implementation?
- Are prohibited or missing parts causing risk?

### 5.8 Vertical Spec (11–19) → Stack Spec (20–23)

- Does each stack spec reflect the mapped responsibilities from 14?
- Does each stack spec reflect VLP reasoning from 15?
- Does each stack spec reflect state/mode expectations from 16?
- Does each stack spec reflect fault/recovery responsibilities from 17?
- Does each stack spec reflect observability expectations from 18?
- Does each stack spec reflect framework / part constraints from 19?
- Are stacks too generic, indicating they were written independently of Vertical Spec?

---

## 6. High-Priority SVA Concerns

The validator must always check these items when relevant.

### Timing
- critical vs normal timing paths
- latency-sensitive partition choices
- timing implications of stack placement

### Safety
- fail-safe placement
- command rejection / unsafe state handling
- safety-near responsibilities being too high in the stack

### Stale / Freshness
- stale detection
- stale propagation
- stale visibility in UI-facing stacks

### ACK / Command Result
- command acknowledgment path
- command failure normalization
- ownership of command result handling

### Watchdog / Low-level safety
- watchdog placement
- firmware/device safety responsibilities

### Observability
- logs
- metrics
- event traceability
- cross-stack diagnosability

---

## 7. Validation Output Format

The validator must always produce output in this format.

# SVA Vertical Validation Report

## 1. Scope Reviewed
- which files were reviewed

## 2. Overall Assessment
- pass / caution / fail
- short explanation

## 3. Strengths
- what is coherent and strong in the current vertical design

## 4. Findings
For each finding, include:
- ID
- Severity: High / Medium / Low
- Layer Transition:
  - Project→Vertical
  - Vertical internal
  - Vertical→Stack
- Affected Files
- Description
- Why it matters

## 5. Missing or Weak Vertical Links
- explicit list of missing propagations

## 6. Recommended Fixes
For each fix:
- target file(s)
- what to add/change
- expected benefit

## 7. Suggested Regeneration Scope
- which generated files should be regenerated if fixes are applied

---

## 8. Severity Guidance

### High
Use when:
- a requirement is not represented in Vertical Spec
- safety placement is wrong or absent
- timing-critical paths are not reflected
- stack specs contradict vertical policies

### Medium
Use when:
- rationale is weak
- observability is underspecified
- state/mode definitions are incomplete
- guardrail is present but not strongly connected to stack specs

### Low
Use when:
- wording is vague
- examples are missing
- future repartition notes are absent but not critical

---

## 9. Validation Heuristics

### Heuristic A: No silent jumps
If a stack spec contains an idea not visible in 11–19, flag it.

### Heuristic B: No dead policies
If a policy exists in 15–19 but has no visible influence on 20–23, flag it.

### Heuristic C: No orphan requirements
If a requirement appears in 01–10 but is absent from 11–19, flag it.

### Heuristic D: No fake observability
If observability policy exists but does not mention concrete signals, metrics, or logs, flag it.

### Heuristic E: No shallow VLP
If VLP policy only states current allocation but not movement conditions, flag it.

### Heuristic F: No safety dilution
If safety-critical responsibilities drift upward without clear reason, flag it.

---

## 10. Non-Goals

This skill does NOT:
- rewrite the whole design automatically
- generate full replacement specs
- validate horizontal detail specs (40–70)
- perform implementation-level code review

Its responsibility is vertical design integrity only.

---

## 11. Recommended Operating Procedure

When invoked, the sub agent should do this:

1. Read 01–10
2. Read 11–19
3. Read 20–23
4. Build a mental trace of:
   - requirement → mapping
   - mapping → interfaces/APIs/events
   - interfaces/APIs/events → policies
   - policies → stack responsibilities
5. Produce the validation report
6. Be explicit about uncertainty
7. Prefer precise findings over broad commentary

---

## 12. Suggested Invocation Prompt

Use this skill to validate the vertical design flow of this SVA project.

Review:
- 01–10 Project Spec
- 11–19 Vertical Spec
- 20–23 Stack Spec

Your task is NOT to redesign the system from scratch.
Your task is to validate whether the vertical chain is coherent, complete, and properly propagated.

Focus especially on:
- VLP
- state/mode
- fault/recovery
- observability
- implementation guardrail
- stale / ack / fail-safe / timing / safety

Output must follow:

# SVA Vertical Validation Report
## 1. Scope Reviewed
## 2. Overall Assessment
## 3. Strengths
## 4. Findings
## 5. Missing or Weak Vertical Links
## 6. Recommended Fixes
## 7. Suggested Regeneration Scope
