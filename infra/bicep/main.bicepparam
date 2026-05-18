using 'main.bicep'

param location = 'eastus'
param appName = 'aca-copilot-ml'
param environmentName = 'aca-copilot-ml-env'
param containerImage = 'ghcr.io/OWNER/REPO/copilot-ml:TAG'
param appEnv = 'demo'
