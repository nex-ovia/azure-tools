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