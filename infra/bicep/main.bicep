@description('Azure region for the demo resources.')
param location string = resourceGroup().location

@description('Container App name. Keep globally readable but not globally unique.')
param appName string = 'aca-copilot-ml'

@description('Container Apps managed environment name.')
param environmentName string = '${appName}-env'

@description('Container image to deploy. Prefer ghcr.io/<owner>/<repo>/copilot-ml:<sha> for workshop demos.')
param containerImage string

@description('Application environment label surfaced by /healthz.')
param appEnv string = 'demo'

@description('Optional registry server for private images, e.g. ghcr.io. Leave blank for public images.')
param registryServer string = ''

@description('Optional registry username for private images. Leave blank for public images.')
param registryUsername string = ''

@secure()
@description('Optional registry password/token for private images. Leave blank for public images.')
param registryPassword string = ''

var usePrivateRegistry = !empty(registryServer) && !empty(registryUsername) && !empty(registryPassword)
var tags = {
  workload: 'copilot-enablement-demo'
  costControl: 'container-apps-consumption-scale-to-zero'
  deleteAfter: 'workshop'
}

resource environment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: environmentName
  location: location
  tags: tags
  properties: {
    zoneRedundant: false
  }
}

resource app 'Microsoft.App/containerApps@2024-03-01' = {
  name: appName
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8080
        transport: 'auto'
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      registries: usePrivateRegistry ? [
        {
          server: registryServer
          username: registryUsername
          passwordSecretRef: 'registry-password'
        }
      ] : []
      secrets: usePrivateRegistry ? [
        {
          name: 'registry-password'
          value: registryPassword
        }
      ] : []
    }
    template: {
      containers: [
        {
          name: 'api'
          image: containerImage
          env: [
            {
              name: 'APP_ENV'
              value: appEnv
            }
            {
              name: 'APP_VERSION'
              value: '0.1.0'
            }
          ]
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
        rules: [
          {
            name: 'http-scale-rule'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}

output fqdn string = app.properties.configuration.ingress.fqdn
output healthUrl string = 'https://${app.properties.configuration.ingress.fqdn}/healthz'
