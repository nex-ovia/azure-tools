### This is the file azcli.zsh that have the azure cli commangds to execute to give resource group access and to create new one too. 
#!/usr/bin/env zsh 

# Command to login
az login 

# Update the env file and source it with the following commands
source az.env

# Select and set the subscription ID 
az account set --subscription ${SUBSCRIPTION_ID} 

# Create a new resource group
az group create \                                                              
  --name "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION" \
  --tags $TAGS

# Verify the resource group creation
az group show \                                                                          
  --name "$RESOURCE_GROUP_NAME" \
  --query "tags"

# To update tags of the resource group
az group update \                                                                        
  --name "$RESOURCE_GROUP_NAME" \
  --tags $TAGS

# Assign Contributor role to a user for the resource group
az role assignment create \                                                              
  --assignee "$TARGET_USER" \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME"

# Verify the role assignment
az role assignment list \                                                               
  --assignee "$TARGET_USER" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME" \
  --output table

# Command to get the object id of a User
az ad user show \                                                                        
  --id "$TARGET_USER" \
  --query "id" -o tsv

# Command to get the object id of a Managed Identity from Logic App
az resource show \
  --resource-group $RESOURCE_GROUP_NAME \
  --name "$LOGICAPP_NAME" \
  --resource-type "Microsoft.Logic/workflows" \
  --query "identity.principalId" \
  -o tsv

# Command to give Key Vault access policy to the managed identity for secret get and list permissions
az keyvault set-policy \                                                              
  --name "$KEYVAULT_NAME" \
  --object-id "$TARGET_OBJECT_ID" \
  --secret-permissions get list

# Command to give Key Vault access policy to the managed identity for certificate get and list permissions
az keyvault set-policy \                                                              
  --name "$KEYVAULT_NAME" \
  --object-id "$TARGET_OBJECT_ID" \
  --certificate-permissions get list  

# Command to give Key Vault access policy to the managed identity for key get and list permissions
az keyvault set-policy \                                                              
  --name "$KEYVAULT_NAME" \
  --object-id "$TARGET_OBJECT_ID" \
  --key-permissions get list

# Verify the Key Vault access policy
az keyvault show \
  --name "$KEYVAULT_NAME" \
  --query "properties.accessPolicies[?objectId=='$TARGET_OBJECT_ID']"

az resource list \
  --query "[?identity.principalId=='$TARGET_OBJECT_ID'].{name:name,type:type,resourceGroup:resourceGroup}"

  az keyvault show \
  --name "$KEYVAULT_NAME" \
  --query "properties.accessPolicies"

