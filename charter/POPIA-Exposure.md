POPIA Exposure Assessment: Nomvula AgriFinance

1. Regulatory Context
As a South African financial cooperative handling member identity, asset, and credit data, Nomvula AgriFinance is legally classified as a **Responsible Party** under the **Protection of Personal Information Act (POPIA)**.

The technical architecture must provide explicit justifications mapped directly to the conditions for lawful data processing.


2. Processed Information & Data Classification
Nomvula AgriFinance collects, stores, and processes the following data categories:
* Personal Information: Full legal names, South African Identity / Passport numbers, physical addresses, phone numbers, and email contacts.
* Special Personal & Financial Information: Bank account records, credit histories, agricultural asset valuations, land deed documentation, harvest yield projections, and cooperative membership IDs.


3. POPIA Condition Mapping & Technical Justifications

Condition 7: Security Safeguards (Integrity and Confidentiality)
* Risk Scenario: Remote branch laptops or mobile field tablets caching unencrypted member loan files are physically stolen during field visits.
* Technical Control Requirement: 
  - Mandatory full-disk encryption and application-level encryption at rest (AES-256) for local SQLite/offline caches.
  - Encrypted transport channels (TLS 1.3) with mutual authentication for all store-and-forward batch uploads.
  - Enforced ephemeral token-based authentication on remote endpoints with short lease windows to limit exposure if a device is stolen.

Condition 4: Information Quality
* Risk Scenario: Intermittent rural network drops cause partial batch synchronization, leading to stale member balances, double-crediting, or false default flags.
* Technical Control Requirement:
  - Transaction queue idempotency mechanisms and atomic batch processing to prevent duplicate or corrupted records.
  - Deterministic state conflict resolution on the central cloud backend to ensure credit assessment records remain accurate and complete.

Condition 6: Openness & Auditability
* Risk Scenario: Unauthorized internal adjustments or tampering with loan terms occurring while field agents operate offline without real-time central oversight.
* Technical Control Requirement:
  - Immutable, cryptographically signed local audit trails committed on the endpoint and streamed to central logging (Wazuh SIEM) upon network restoration.
  - Centralized Role-Based Access Control (RBAC) strictly enforcing least privilege on cloud ingestion APIs.

Condition 8: Data Subject Participation & Retention (Condition 3)
* Risk Scenario: Indefinite retention of unapproved loan applications on local branch hard drives after regulatory retention periods elapse.
* Technical Control Requirement:
  - Automated data retention and pruning policies defined in code to purge cached personal data from branch devices once reconciled and acknowledged by the central store.
