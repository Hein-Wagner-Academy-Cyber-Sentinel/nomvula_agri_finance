
# Threat Model - Version 0 (Phase 1)

_Keep this file. Later versions are separate files; do not overwrite._

## Assets:
* FICA & Identity Data Vault: South African ID documents, proof of residence, phone numbers, and farm title deeds collected from cooperative members under POPIA Condition 7 and FICA.
* Offline Transaction and Loan Origination Queues: Staged credit applications, repayment ledgers, and disbursement batches held locally on field laptops awaiting network connectivity.
* Central Financial Ledger & Emulated Cloud Storage: Master loan records, credit risk ratings, and transaction histories stored in backend cloud repositories (S3/Moto).
* Cloud API Keys & Branch Machine Credentials: Authentication tokens and cryptographic secrets used by remote branch workstations to upload store-and-forward batches.
* Cooperative Operational Trust: Nomvula's standing with rural smallholders farming communities and regulatory compliance with the the South African Information Regulator. 

## Actors:
* Opportunistic Physical Thieves: Criminals targeting unattended field laptops, tablets, or backup hard drives at vulnerable remote branch and depot desks.
* Ransomware Syndicates & Initial Access Brokers (IABs): Organised groups scanning South African cloud perimeters to lock critical credit workflows during time-sensitive seasonal windows.
* Malicious or Careless Insiders: Branch clerks altering loan approvals off-grid, or mobile agents connecting laptops to insecure public/cellular Wi-Fi.
* Network Eavesdroppers & Man-in-the-Middle (MitM) Interceptors: Adversaries intercepting or manipulating store-and-forward batch transmissions over unstable rural cellular networks.

## Entry points:
* Remote Branch and Depot Endpoints: Laptops and mobile workstations caching sensitive FICA and loan data in local offline databases (SQLite/flat files).
* Store-and-Forward Cloud Sync APIs: Ingestion endpoints that accept batched loan applications once connectivity is restored.
* Client and Field Web Portals: Cloud-facing web interfaces where members and loan officers submit identity documents.
* Cloud Infrastructure Configurations: Accidental public exposures of cloud storage buckets or misconfigured access control lists in infrastructure code.
* Software Supply Chain: Vulnerabilities introduced via third-party application dependencies or CI/CD pipelines.

## Top three material risks:
1. Unencrypted Offline Data Exposure via Physical Device Theft (POPIA Condition 7 Breach):
   * Scenario: A loan officer's laptop caching unencrypted farmer identity records, FICA files, and bank details is stolen at a remote depot desk.
   * Impact: Direct violation of POPIA Condition 7, leading to potential Information Regulator fines of up to R10 million, severe member identity fraud, and loss of operating license.

2. Offline Batch Tampering and Replay Attacks During Reconnection:
   * Scenario: An attacker intercepts or alters store-and-forward batch data transmitted over an unsecured rural cellular connection before it reaches the cloud ledger.
   * Impact: Fraudulent loan approvals, double disbursements, and corrupted financial ledgers that cause direct monetary loss to the cooperative.

3. Time-Critical Ransomware Outage During Seasonal Planting/Harvesting Windows:
   * Scenario: A ransomware syndicate compromises remote staff credentials via phishing and encrypts the central cloud database.
   * Impact: Complete operational freeze during seasonal planting when smallholder farmers urgently need seed capital, resulting in crop failure, widespread loan defaults, and reputational collapse.
