# Bicep Modular Environment Setup Tool

## 1. Overview & Purpose

This tool automates the initial scaffolding of a modular **Azure Landing Zone as Code** using Microsoft Bicep, as defined in the **Phase 2 Build It Anywhere** specification (*Defining an Azure Landing Zone in Bicep*).

Rather than writing monolithic infrastructure definitions, this tool sets up an enterprise-grade modular architecture following Zero Trust, POPIA, and Azure Well-Architected Framework principles.

---

## 2. Target Directory Structure

When executed, `setup.sh` dynamically resolves the repository root and initializes the prescribed Phase 2 folders:

```text
nomvula_agri_finance/
├── architecture/
│   ├── bicep/                     <-- Bicep source code
│   │   ├── main.bicep             <-- Root orchestrator template
│   │   └── modules/               <-- Reusable child resource modules
│   │       ├── vnet.bicep         <-- Virtual network and subnet segmentation
│   │       ├── storage.bicep      <-- Encrypted storage with public access disabled
│   │       └── keyvault.bicep     <-- Key Vault with Azure RBAC authorization
│   └── compiled/                  <-- Target for compiled ARM JSON templates
├── evidence/
│   └── phase2/                    <-- Target for validation run text logs
└── tools/
    └── bicep_env/
        ├── setup.sh               <-- Scaffolding script
        └── README.md              <-- This documentation
```

---

## 3. Scaffolding Modules Overview

### A. Networking (`modules/vnet.bicep`)
- **Resource**: `Microsoft.Network/virtualNetworks@2023-09-01`
- **Address Space**: `10.0.0.0/16`
- **Subnets**: Backend subnet (`10.0.1.0/24`) for workload isolation.
- **Outputs**: `vnetId` for downstream resource binding.

### B. Encrypted Storage (`modules/storage.bicep`)
- **Resource**: `Microsoft.Storage/storageAccounts@2023-01-01`
- **Security Invariants**:
  - `minimumTlsVersion`: `TLS1_2` (Strict TLS enforcement).
  - `supportsHttpsTrafficOnly`: `true` (HTTPS encrypted in transit).
  - `allowBlobPublicAccess`: `false` (Zero public exposure, POPIA compliant).
- **SKU**: `Standard_LRS`, kind `StorageV2`.
- **Outputs**: `storageId`.

### C. Secrets & Identity Vault (`modules/keyvault.bicep`)
- **Resource**: `Microsoft.KeyVault/vaults@2023-07-01`
- **Access Control**: `enableRbacAuthorization: true` (Least-privilege Entra ID RBAC rather than legacy access policies).
- **Tenant Scope**: Tied strictly to `subscription().tenantId`.
- **Outputs**: `keyVaultId`.

### D. Main Orchestrator (`main.bicep`)
- **Default Region**: `southafricanorth` (Absa / South African data sovereignty).
- **Unique Naming**: Uses deterministic `uniqueString(resourceGroup().id)` to avoid name collisions across deployments.
- **Module Wiring**: Orchestrates deployment across all three modules with typed parameters and exposes composite resource outputs.

---

## 4. How to Use the Setup Script

### Step 1: Make Script Executable
Ensure the setup script has execution permissions:
```bash
chmod +x /home/michael/alp-env/nomvula_agri_finance/tools/bicep_env/setup.sh
```

### Step 2: Run Initialization
You can execute `setup.sh` directly from any directory:

```bash
# Standard run (scaffolds into architecture/bicep/):
/home/michael/alp-env/nomvula_agri_finance/tools/bicep_env/setup.sh

# Or supply an explicit target path if desired:
/home/michael/alp-env/nomvula_agri_finance/tools/bicep_env/setup.sh /custom/path/bicep
```

### Step 3: Compile Bicep to ARM Template
Compile your Bicep code into ARM JSON without deploying:
```bash
cd /home/michael/alp-env/nomvula_agri_finance
bicep build architecture/bicep/main.bicep --outdir architecture/compiled
```

A return code of `0` or no terminal output signifies successful compilation without syntax warnings or linter errors.

---

## 5. Phase 2 Validation Next Steps

Once the Bicep source is generated and compiled into `architecture/compiled/`, run your three Phase 2 validation tools to capture evidence in `evidence/phase2/`:

1. **Bicep Linter**: Runs automatically during `bicep build`.
2. **PSRule for Azure**: Validates your templates against the Well-Architected Framework:
   ```bash
   pwsh -Command "Assert-PSRule -InputPath architecture/compiled/main.json -OutputFormat NUnit3 -OutputPath evidence/phase2/psrule.xml"
   ```
3. **ARM Template Test Toolkit (TTK)**:
   ```bash
   pwsh -Command "Test-AzTemplate -TemplatePath architecture/compiled/main.json" > evidence/phase2/ttk-output.txt
   ```

---

## 6. Accessibility & Evidence Rule Compliance
- **Text-Only Deliverables**: No screenshots. All architectures are expressed as human-readable, screen-reader friendly Bicep and Markdown files.
- **Screen Reader Readiness**: Headings, lists, and code blocks follow strict WCAG 2.1 AA semantics.
