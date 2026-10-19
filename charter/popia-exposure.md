POPIA Exposure Assessment: Nomvula AgriFinance

1. Regulatory Context
As a South African financial cooperative handling member identity, asset, and credit data, Nomvula AgriFinance is legally classified as a **Responsible Party** under the **Protection of Personal Information Act (POPIA)**.

The technical architecture must provide explicit justifications mapped directly to the conditions for lawful data processing.


2. Processed Information & Data Classification
Nomvula AgriFinance collects, stores, and processes the following data categories:
* Identity & Contact Personal Infromation: Full legal names, South African Identity / Passport numbers, physical addresses, phone numbers, and email contacts.
* Sensitive Financial & Operational Personal Information: Bank account records, credit histories, agricultural asset valuations, land deed documentation, harvest yield projections, and cooperative membership IDs.


3. POPIA Condition Mapping & Technical Justifications

Condition 3: Purpose Specification (Retention & Restriction of Records)
* Risk Scenario: Indefinite retention of unapproved loan applications or synced member batches on local branch hard drives after the operational and regulatory purpose has ended.
* Chosen Technical Measures & Justification:
  * Automated data retention and pruning policies defined in code to purge locally cached personal data from branch devices once batches are reconciled and acknowledged by the central store, satisfying Section 14 retention limits.

Condition 5: Information Quality
* Risk Scenario: Intermittent rural network drops cause partial batch synchronization, leading to stale member balances, double-crediting, or false default flags.
* Technical Control Requirement:
  - Transaction queue idempotency mechanisms and atomic batch processing to prevent duplicate or corrupted records.
  - Deterministic state conflict resolution on the central cloud backend to ensure credit assessment records remain accurate and complete.

Condition 6: Openness & Auditability
* Technical Control Requirement:
  - Immutable, cryptographically signed local audit trails committed on the endpoint and streamed to central logging (Wazuh SIEM) upon network restoration.
  - Centralized Role-Based Access Control (RBAC) strictly enforcing least privilege on cloud ingestion APIs.

Condition 7: Security Safeguards (Section 19 Integrity and Confidentiality)
Section 19 of POPIA requires Nomvula AgriFinance to take appropriate, reasonable technical and organisational measures to prevent loss of, damage to, or unauthorised access to personal information, without mandating specific technologies by name. To meet this obligation in a high-risk rural environment, our team chose the following technical measures:
* Risk Scenario 1 (Physical Device Theft): Remote branch laptops or mobile field tablets caching member loan files are physically stolen during field visits.
  * Chosen Technical Measures & Justification: We selected full-disk encryption and application-level encryption at rest (AES-256) for local SQLite offline caches, alongside short-lived ephemeral authentication tokens, so that physical theft of a device does not expose readable member PII.
* Risk Scenario 2 (Insecure Rural Transit): Store-and-forward loan batches are intercepted over untrusted rural cellular or satellite links.
  * Chosen Technical Measures & Justification: We selected TLS 1.3 with mutual authentication (mTLS) for all batch uploads to prevent man-in-the-middle interception and ensure only verified branch endpoints can submit data to the cloud ingestion API.
* Risk Scenario 3 (Offline Tampering): Unauthorized internal adjustments or tampering with loan terms occurring while field agents operate offline without real-time central oversight.
  * Chosen Technical Measures & Justification: We chose immutable, cryptographically signed local audit logs streamed to central monitoring (Wazuh SIEM) upon reconnection, paired with strict Role-Based Access Control (RBAC) enforcing least privilege on cloud ingestion APIs.

Condition 8: Data Subject Participation & Retention (Condition 3)
* Risk Scenario: Indefinite retention of unapproved loan applications on local branch hard drives after regulatory retention periods elapse.
* Technical Control Requirement:
  - Automated data retention and pruning policies defined in code to purge cached personal data from branch devices once reconciled and acknowledged by the central store.
