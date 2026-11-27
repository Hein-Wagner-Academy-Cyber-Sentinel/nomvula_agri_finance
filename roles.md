# Role Rotation Record — Pair 5 (Nomvula AgriFinance)

## Team Members
* Lutho Mathontsi
* Michael Robberts

## Role Definitions
* **Build Lead:** Owns the infrastructure code, container definitions, diagram source files, and pipeline configuration for the phase.
* **Assurance Lead:** Owns the threat model, scanner findings and their remediation, identity/policy documentation, runbooks, and the evidence record.

---

## Phase 2: Architecture and Identity as Code (Current Phase)
* **Window:** September to 11 December 2026
* **Build Lead:** Michael Robberts
  * **Phase 2 Responsibilities:** Azure landing zone in Bicep (`architecture/bicep/`), compiled ARM template (`architecture/compiled/`), naming and tagging standard (`architecture/naming-and-tagging.md`), offline validation runs (Bicep lint/build, ARM-TTK, PSRule in `evidence/phase2/`), and Mermaid architecture diagram (`architecture/diagram.mmd`).
* **Assurance Lead:** Lutho Mathontsi
  * **Phase 2 Responsibilities:** Identity model (`architecture/identity/role-assignment-matrix.md`, Conditional Access JSON policies in `architecture/identity/conditional-access/`, `architecture/identity/privileged-access-procedure.md`), endpoint policy configurations and rationale (`architecture/endpoint-policy/`), control mapping (`architecture/control-mapping.md`), written diagram description (`architecture/diagram-description.md`), design rationale (`architecture/design-rationale.md`), accepted findings log (`architecture/accepted-findings.md`), and Threat Model v1 (`threat-model/threat-model-v1.md`).



 Phase 1: Foundation and Charter (Completed)
* Window: From 21 August 2026
* Build Lead: Lutho Mathontsi
  * Phase 1 Responsibilities: Toolchain installation and verification, Moto emulation test, asciinema toolchain recording, and starter CI pipeline verification.
* Assurance Lead: Michael Robberts
  * Phase 1 Responsibilities: Project charter, business profile, POPIA exposure assessment, and Threat Model v0.
