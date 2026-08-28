# Project Charter — <Persona name>

_Complete this in Phase 1._

## Scope
_What this platform will and will not do._

- Development of infrastructure as code using OpenTofu and Bicep.
- Local emulation and validation workflows (Moto, Docker, GitHub Actions).
- Endpoint hardening and security baseline definitions for rural branch workstations.
- Threat modeling (v0 to v3) targeting offline sync, data tampering, and endpoint theft.
- Local AI feature modeling (e.g., credit fraud detection / anomaly detection).
- 100% text-native evidence logging (asciinema session casts, scanner output files, pipeline logs).

## Success criteria
_How we will know the platform is good enough._

- Objective 1 (Zero-Cost Code-Defined Architecture): Model and deploy an AWS-pattern cloud backend using OpenTofu against emulated APIs (Moto) at zero rand infrastructure cost.
- Objective 2 (Endpoint & Edge Security): Define declarative device configuration and encryption baselines for remote branch workstations handling offline queues.
- Objective 3 (Automated Pipeline Gates): Implement GitHub Actions workflows that automatically detect and block unencrypted storage configurations, secret leaks, and container vulnerabilities before deployment.
- Objective 4 (Measured Disaster Recovery): Prove measured Recovery Time Objectives (RTO) and Recovery Point Objectives (RPO) using executed backup/restore runbooks.
- Objective 5 (Defensible Compliance): Present an end-to-end e-portfolio where every architecture and security decision ties directly to a POPIA requirement and business risk.

## Assumptions
_What we are taking as given._

 Assumptions:
  - Branch agents will have occasional network connectivity to sync queued transaction batches.
  - Free-tier runners (GitHub Actions) and local toolchains provide complete validation parity.
 Constraints:
  - Infrastructure operational budget is R0.00 (Zero Standing Cost).
  - Repositories remain public, requiring absolute prevention of hardcoded secrets or real PII.
  - Roles must rotate between Build Lead and Assurance Lead at each phase boundary.

## Out of scope
_What we are deliberately not doing this year._

- Provisioning funded/metered live public cloud accounts during development.
- GUI-based console administration.
- Full production deployment of external proprietary banking core mainframes.
- Non-accessible visual evidence formats (screenshots are strictly excluded).

