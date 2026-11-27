#!/bin/bash
# Exit immediately if a command fails
set -e

# Resolve repository root dynamically (2 levels up from tools/bicep_env/)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Target directory defaults to architecture/bicep per the Phase 2 specification
TARGET_DIR="${1:-${REPO_DIR}/architecture/bicep}"
COMPILED_DIR="${REPO_DIR}/architecture/compiled"
EVIDENCE_DIR="${REPO_DIR}/evidence/phase2"

echo "=================================================="
echo " Starting Bicep Modular Project Initialization..."
echo " Repository Root : ${REPO_DIR}"
echo " Target Directory: ${TARGET_DIR}"
echo " Compiled Output : ${COMPILED_DIR}"
echo "=================================================="

echo "[1/5] Creating project directory structure..."
mkdir -p "${TARGET_DIR}/modules"
mkdir -p "${COMPILED_DIR}"
mkdir -p "${EVIDENCE_DIR}"
cd "${TARGET_DIR}"
echo " Directory structure created successfully."

echo "[2/5] Writing networking module (modules/vnet.bicep)..."
cat << 'EOF' > "${TARGET_DIR}/modules/vnet.bicep"
@description('Region for the virtual network')
param location string

@description('Environment tag')
param environment string

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-fintech-${environment}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.0.0.0/16' ]
    }
    subnets: [
      {
        name: 'subnet-backend'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

output vnetId string = vnet.id
EOF
echo " -> modules/vnet.bicep written."

echo "[3/5] Writing storage account module (modules/storage.bicep)..."
cat << 'EOF' > "${TARGET_DIR}/modules/storage.bicep"
@description('Region for storage account')
param location string

@description('Globally unique storage account name')
param storageName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

output storageId string = storageAccount.id
EOF
echo " -> modules/storage.bicep written."

echo "[4/5] Writing key vault module (modules/keyvault.bicep)..."
cat << 'EOF' > "${TARGET_DIR}/modules/keyvault.bicep"
@description('Region for Key Vault')
param location string

@description('Key Vault name')
param keyVaultName string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
  }
}

output keyVaultId string = keyVault.id
EOF
echo " -> modules/keyvault.bicep written."

echo "[5/5] Writing main orchestrator file (main.bicep)..."
cat << 'EOF' > "${TARGET_DIR}/main.bicep"
@description('The Azure region for resources.')
param location string = 'southafricanorth'

@description('Environment classification.')
param environment string = 'dev'

var resourceSuffix = uniqueString(resourceGroup().id)

// Call Networking Module
module vnetModule './modules/vnet.bicep' = {
  name: 'vnetDeployment'
  params: {
    location: location
    environment: environment
  }
}

// Call Storage Module
module storageModule './modules/storage.bicep' = {
  name: 'storageDeployment'
  params: {
    location: location
    storageName: 'stfin${environment}${resourceSuffix}'
  }
}

// Call Key Vault Module
module kvModule './modules/keyvault.bicep' = {
  name: 'kvDeployment'
  params: {
    location: location
    keyVaultName: 'kv-fin-${environment}-${resourceSuffix}'
  }
}

output vnetId string = vnetModule.outputs.vnetId
output storageId string = storageModule.outputs.storageId
output keyVaultId string = kvModule.outputs.keyVaultId
EOF
echo " -> main.bicep written."

echo "=================================================="
echo " Project successfully initialized!"
echo " Source location  : ${TARGET_DIR}"
echo " Compiled location: ${COMPILED_DIR}"
echo ""
echo " To build and compile the ARM template, run:"
echo "   bicep build \"${TARGET_DIR}/main.bicep\" --outdir \"${COMPILED_DIR}\""
echo "=================================================="
