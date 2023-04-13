# Oregon Strawberry Commission MSFT Lab

## RBAC

```azurecli
az login
az account list --query "[?isDefault]"
az account set --subscription "66effa16-8b4b-4047-b8e1-d390ceddd4a5"
az group create -n orscpeopledemo -l centralus
az ad sp create-for-rbac --name OregonStrawberryCommissionPeopleDemo --role contributor --scopes /subscriptions/66effa16-8b4b-4047-b8e1-d390ceddd4a5/resourceGroups/ServiceBusDemo --sdk-auth
```

```json
{
  "clientId": "b4fb1e15-0c59-4e7a-8191-c8991efd9b15",
  "clientSecret": "4Q48Q~uXCAd3pRgUw53vgO5TKhuvaQlIXq3oIac7",
  "subscriptionId": "66effa16-8b4b-4047-b8e1-d390ceddd4a5",
  "tenantId": "9637eecd-fbd4-438a-848a-4e29f4d8eae5",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

## Decompile Bicep from JSON

```azurecli
az bicep decompile --file .\servicebus_template.json
```

## Bicep

```azurecli
az deployment group create --resource-group ServiceBusDemo --template-file main.bicep
```

## Validate

```azurecli
az resource list --resource-group ServiceBusDemo
```

## Clean up

```azurecli
az group delete --name ServiceBusDemo
```
