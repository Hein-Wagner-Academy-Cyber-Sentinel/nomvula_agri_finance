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
