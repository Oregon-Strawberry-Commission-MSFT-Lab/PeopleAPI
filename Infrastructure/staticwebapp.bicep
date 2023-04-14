@allowed([ 'eastus2', 'eastasia', 'westeurope', 'westus2' ])
param location string = 'eastus2'

@description('Name of Static Web App')
param staticWebAppName string = 'peopledemo7'

@allowed([ 'Free', 'Standard' ])
param sku string = 'Free'

resource staticWebApp 'Microsoft.Web/staticSites@2022-09-01' = {
  name: staticWebAppName
  location: location
  sku: {
      name: sku
      size: sku
  }
  properties: {}
}

resource resManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'peopledemo-script-cloudflaredns-managed-identity'
  location: location
}

// resource UpdateCloudflareDNS 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
//   name: 'CloudflareDNS'
//   location: location
//   kind: 'AzurePowerShell'
//   identity: {
//     type: 'UserAssigned'
//     userAssignedIdentities: {
//       '${resManagedIdentity.id}' : {}
//     }
//   }
//   properties: {
//     azPowerShellVersion: '8.3' // or azCliVersion: '2.40.0'
//     environmentVariables: [
//       {
//         name: 'HostName'
//         value: staticWebApp.properties.defaultHostname
//       }
//       {
//         name: 'APIKey'
//         secureValue: 'UF7pSYdhpwJt5ELrUVathnsoeL-0q53mmiU7H02D'
//       }
//       {
//         name: 'ZoneID'
//         secureValue: '314f753caf8b5bb78e934cc8a12683d9'
//       }
//       {
//         name: 'RecordID'
//         secureValue: '8ba9fdeb9416f3a22465749979cc747d'
//       }
//     ]
//     scriptContent: '''
//       $body = @{
//           type = "CNAME"
//           name = "www"
//           content = "${Env:HostName}"
//           ttl = 360
//           proxied = $false
//       } | ConvertTo-Json

//       $output = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/${Env:ZoneID}/dns_records/${Env:RecordID}" `
//                         -Method 'PUT' `
//                         -Headers @{
//                             'Authorization' = "Bearer ${Env:APIKey}"
//                             'Content-Type'  = 'application/json'
//                         } `
//                         -Body $body

//       Write-Output $output
//       $DeploymentScriptOutputs = @{}
//       $DeploymentScriptOutputs['text'] = $output
//     '''
//     supportingScriptUris: []
//     timeout: 'PT30M'
//     cleanupPreference: 'Always'
//     retentionInterval: 'P1D'
//   }
// }

// resource staticWebAppDNS 'Microsoft.Web/staticSites/customDomains@2022-09-01' = {
//   name: 'www.orsclab.com'
//   parent: staticWebApp
//   properties: {
//     validationMethod: 'cname-delegation'
//   }
//   dependsOn: [
//     UpdateCloudflareDNS
//   ]
// }

resource staticWebAppDNS 'Microsoft.Web/staticSites/customDomains@2022-09-01' = {
  name: 'www.orsclab.com'
  parent: staticWebApp
  properties: {
    validationMethod: 'dns-txt-token'
  }
}

// resource UpdateCloudflareDNS 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
//   name: 'CloudflareDNS'
//   location: location
//   kind: 'AzurePowerShell'
//   identity: {
//     type: 'UserAssigned'
//     userAssignedIdentities: {
//       '${resManagedIdentity.id}' : {}
//     }
//   }
//   properties: {
//     azPowerShellVersion: '8.3' // or azCliVersion: '2.40.0'
//     environmentVariables: [
//       {
//         name: 'TXTRecordContent'
//         value: staticWebAppDNS.properties.validationToken
//       }
//       {
//         name: 'APIKey'
//         secureValue: 'UF7pSYdhpwJt5ELrUVathnsoeL-0q53mmiU7H02D'
//       }
//       {
//         name: 'ZoneID'
//         secureValue: '314f753caf8b5bb78e934cc8a12683d9'
//       }
//     ]
//     scriptContent: '''
//       $headers = @{
//           "Authorization" = "Bearer ${Env:APIKey}"
//           "Content-Type" = "application/json"
//       }
      
//       $body = @{
//           type = "TXT"
//           name = "www"
//           content = "${Env:TXTRecordContent}"
//       } | ConvertTo-Json
      
//       $output = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/${Env:ZoneID}/dns_records" -Method Post -Headers $headers -Body $body
//       Write-Output $output
//       $DeploymentScriptOutputs = @{}
//       $DeploymentScriptOutputs['text'] = $output
//     '''
//     supportingScriptUris: []
//     timeout: 'PT30M'
//     cleanupPreference: 'Always'
//     retentionInterval: 'P1D'
//   }
// }

resource UpdateCloudflareDNS 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'CloudflareDNS'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resManagedIdentity.id}' : {}
    }
  }
  properties: {
    azPowerShellVersion: '8.3' // or azCliVersion: '2.40.0'
    environmentVariables: [
      {
        name: 'HostName'
        value: staticWebApp.properties.defaultHostname
      }
      {
        name: 'TXTRecordContent'
        value: staticWebAppDNS.properties.validationToken
      }
      {
        name: 'APIKey'
        secureValue: 'UF7pSYdhpwJt5ELrUVathnsoeL-0q53mmiU7H02D'
      }
      {
        name: 'ZoneID'
        secureValue: '314f753caf8b5bb78e934cc8a12683d9'
      }
      {
        name: 'RecordID'
        secureValue: '8ba9fdeb9416f3a22465749979cc747d'
      }
    ]
    scriptContent: '''
      $cnamebody = @{
          type = "CNAME"
          name = "www"
          content = "${Env:HostName}"
          ttl = 360
          proxied = $false
      } | ConvertTo-Json

      Write-Output "Making CName Call:"
      $output = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/${Env:ZoneID}/dns_records/${Env:RecordID}" `
                        -Method 'PUT' `
                        -Headers @{
                            'Authorization' = "Bearer ${Env:APIKey}"
                            'Content-Type'  = 'application/json'
                        } `
                        -Body $cnamebody

      Write-Output $output
      $DeploymentScriptOutputs = @{}
      $DeploymentScriptOutputs['cname'] = $output

      $txtbody = @{
          type = "TXT"
          name = "www"
          content = "${Env:TXTRecordContent}"
      } | ConvertTo-Json
      
      Write-Output ""
      Write-Output "Making TXT Call:"
      $txtoutput = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/${Env:ZoneID}/dns_records" `
                      -Method Post `
                      -Headers @{
                        "Authorization" = "Bearer ${Env:APIKey}"
                        "Content-Type" = "application/json"
                      } `
                      -Body $txtbody
      Write-Output $txtoutput
      $DeploymentScriptOutputs = @{}
      $DeploymentScriptOutputs['txt'] = $txtoutput
    '''
    supportingScriptUris: []
    timeout: 'PT30M'
    cleanupPreference: 'Always'
    retentionInterval: 'P1D'
  }
}
