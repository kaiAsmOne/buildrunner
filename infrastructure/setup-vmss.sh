#!/bin/bash

RESOURCE_GROUP="rg-agents"
VMSS_NAME="vmss-kai-agents"
LOCATION="norwayeast"
VNET_NAME="vnet-agents"
SUBNET_NAME="subnet-agents"

# Create VNET
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --subnet-name $SUBNET_NAME \
  --subnet-prefix 10.0.1.0/24

# Create VMSS
az vmss create \
  --resource-group $RESOURCE_GROUP \
  --name $VMSS_NAME \
  --image "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Compute/galleries/agentImageGallery/images/UbuntuAgent/versions/latest" \
  --instance-count 2 \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_NAME \
  --public-ip-per-vm \
  --vm-sku Standard_D2s_v3 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --upgrade-policy-mode Rolling

# Configure autoscaling
az monitor autoscale create \
  --resource-group $RESOURCE_GROUP \
  --resource $VMSS_NAME \
  --resource-type Microsoft.Compute/virtualMachineScaleSets \
  --name autoscale-kai-agents \
  --min-count 1 \
  --max-count 10 \
  --count 2

# Add scale-out rule
az monitor autoscale rule create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name autoscale-kai-agents \
  --condition "Percentage CPU > 70 avg 5m" \
  --scale out 1

# Add scale-in rule
az monitor autoscale rule create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name autoscale-kai-agents \
  --condition "Percentage CPU < 30 avg 5m" \
  --scale in 1