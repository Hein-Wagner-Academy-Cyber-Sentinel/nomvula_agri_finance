
# Role Assignment Matrix - Nomvula AgriFinance

## 1. Identity Governance Principles

All role assignments enforce **Least Priviledge** and **Separation of Duties** access the 'mg-nomvula-root' management group hierarchy:
* **Zero Standing Privillege:** No human user holds permanent active administrative permissions on protection subscriptions or resource groups.
* **Tier Isolation:** Field officers and branch supervisors interact strictly through the application ingestion tier ('rg-app-prod-sanorth-01') and have zero direct RBAC permissions on the data vault ('rg-data-prod-sanorth-01') or network perimeter ('rg-network-prod-sanorth-01').

## 2. RBAC Assignment Matrix

| Persona / Security Group | Entra ID / Azure RBAC Role | Assignment Scope | Permitted Actions | Business & Security Justification |
| :--- | :--- | :--- | :--- | :--- |
| **Field Loan Officer** (`grp-nomvula-field-officers`) | Custom: `Nomvula Loan Submitter` | `/subscriptions/<prod-sub>/resourceGroups/rg-app-prod-sanorth-01`[cite: 2] | Authenticate via Entra ID + mTLS device certificate; POST queued offline loan and FICA batches to the ingestion API[cite: 2]. | Allows rural field agents to capture loan applications offline and sync batches when signal returns, without read, modify, or delete access to backend storage or ledgers[cite: 2]. |
| **Remote Branch Supervisor** (`grp-nomvula-branch-leads`) | `Reader` + Custom: `Nomvula Queue Reconciler` | `/subscriptions/<prod-sub>/resourceGroups/rg-app-prod-sanorth-01`[cite: 2] | View branch batch sync status, review flagged duplicate/offline exceptions, and trigger queue replay[cite: 2]. | Supports local depot supervision and conflict resolution over intermittent rural links while preventing any infrastructure or database changes[cite: 2]. |
| **Head Office Credit Analyst** (`grp-nomvula-credit-analysts`) | Custom: `Nomvula Ledger Reviewer` | `/subscriptions/<prod-sub>/resourceGroups/rg-data-prod-sanorth-01` (App-layer read view only)[cite: 2] | Read-only access to reconciled member credit profiles and FICA verification records[cite: 2]. | Enables central underwriting and POPIA Condition 8 data-subject access queries without permitting record deletion or schema modifications[cite: 2]. |
| **Cloud Platform Engineer** (`grp-nomvula-platform-ops`) | `Contributor` (PIM Eligible Only) | `/subscriptions/<prod-sub>`[cite: 2] | Activate time-bound (4-hour) elevation with peer approval to deploy vetted Bicep/CI/CD updates and manage application containers[cite: 2]. | Prevents unauthorized configuration drift and limits blast radius if a developer workstation is compromised[cite: 2]. |
| **Network & Security Administrator** (`grp-nomvula-sec-admins`) | `Network Contributor` + `Key Vault Administrator` (PIM Eligible Only) | `/subscriptions/<prod-sub>/resourceGroups/rg-network-prod-sanorth-01` & `rg-security-prod-sanorth-01`[cite: 7] | Manage NSG firewall rules, Private Endpoints, TLS certificates, and Key Vault secrets via JIT elevation. | Separates network and cryptographic key management from application deployment (Separation of Duties). |
| **Security & Compliance Auditor** (`grp-nomvula-sec-auditors`) | `Security Reader` + `Reader` | Management Group: `mg-nomvula-root`[cite: 2] | Inspect security posture, NSG rules, SIEM/Wazuh telemetry, and POPIA resource tags across Platform and Workload zones[cite: 2]. | Provides independent POPIA Condition 7 assurance across the entire tenant with zero write or modification rights[cite: 2]. |
| **Emergency Break-Glass Accounts** (`bg-nomvula-01`, `bg-nomvula-02`) | `Global Administrator` + `Owner` | Tenant Root (`/`) and `mg-nomvula-root`[cite: 2] | Full tenant and subscription recovery during identity provider outages or Conditional Access misconfiguration lockouts[cite: 2]. | Cloud-only accounts excluded from Conditional Access, protected by FIDO2 hardware keys in split physical safes, and monitored with immediate SIEM alerts[cite: 2]. |


