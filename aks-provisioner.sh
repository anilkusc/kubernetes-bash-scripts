#!/bin/bash

#TODO:Static Public IP
#TODO:Labels will be added and attached to azure ACR
#TODO:Add NAT Gateway

PROJECT_CODE=<Company-name>
# Set the environment that this deployment represent (dev, qa, prod,...)
ENVIRONMENT=<Environment-name>
SUBSCRIPTION_CODE=<Subscription-code>

# Primary location
LOCATION="westeurope"
# Location code will be used to setup multi-region resources
LOCATION_CODE="weu"

# Prefix is a combination of project and environment
PREFIX="${ENVIRONMENT}${PROJECT_CODE}"

# Azure subscription vars (uncomment if you will supply the values)
# SUBSCRIPTION_ID="REPLACE"
# TENANT_ID="REPLACE"
# export SUBSCRIPTION_ID=$SUBSCRIPTION_ID 
export TENANT_ID="<Tenant-Id>" 

### Resource groups
export RG_AKS="${PREFIX}-aks-${LOCATION_CODE}" 
export RG_AKS_NODES="${PREFIX}-aks-nodes-${LOCATION_CODE}" 
export RG_INFOSEC="central-infosec-${LOCATION_CODE}" 
export RG_SHARED="${PREFIX}-shared-${LOCATION_CODE}" 
export RG_DEVOPS="${PREFIX}-devops-${LOCATION_CODE}" 

### Azure Monitor
export SHARED_WORKSPACE_NAME="${PREFIX}-shared-logs" 
export HUB_EXT_WORKSPACE_NAME="${PREFIX}-hub-logs" 

# Creating Application Insights for each app
export APP_NAME="${PREFIX}-REPLACE-insights-${LOCATION_CODE}" 


# AKS primary subnet
export AKS_SUBNET_NAME="${PREFIX}-aks" 

# AKS exposed ingress services subnet
export SVC_SUBNET_NAME="${PREFIX}-ingress" 

# Virutal nodes subnet (for serverless burst scaling)
export VN_SUBNET_NAME="${PREFIX}-vn" 

# Development API Management subnet
export APIM_HOSTED_SUBNET_NAME="${PREFIX}-apim-dev" 

# Project devops/jump-box subnet
export PROJ_DEVOPS_AGENTS_SUBNET_NAME="${PREFIX}-devops" 

# Private enpoints subnet for connected Azure PaaS services and other resources
export PRIVATE_ENDPOINTS_SUBNET_NAME="${PREFIX}-pe" 

# Production/hub API Management subnet
export APIM_SUBNET_NAME="hub-apim-prod" 

# Production/hub self hosted agents
export DEVOPS_AGENTS_SUBNET_NAME="hub-devops" 

# Application gateway subnet
export AGW_SUBNET_NAME="hub-waf" 

# Hub DNS subnet
export DNS_SUBNET_NAME="hub-dns" 

# Azure Firewall Subnet name must be AzureFirewallSubnet
export FW_SUBNET_NAME="AzureFirewallSubnet" 

# IP ranges for each subnet (for simplicity some are created with /24)
# Always carefully plan your network size based on expected workloads

# 2046 allocated addresses (from 8.0 to 15.255)
export PROJ_VNET_ADDRESS_SPACE_1="10.165.8.0/21" 
# 2046 allocated addresses (from 16.0 to 23.255)
export PROJ_VNET_ADDRESS_SPACE_2="10.165.16.0/21" 
# Incase you need the next address space, you can use this
# export PROJ_VNET_ADDRESS_SPACE_3="10.165.24.0/22" 

# This /21 size would support around 60 node cluster (given that 30 pods/cluster is used)
export AKS_SUBNET_IP_PREFIX="10.165.8.0/21" 
export VN_SUBNET_IP_PREFIX="10.165.16.0/22" 
export SVC_SUBNET_IP_PREFIX="10.165.20.0/24" 
export APIM_HOSTED_SUBNET_IP_PREFIX="10.165.21.0/24" 
export PROJ_DEVOPS_AGENTS_SUBNET_IP_PREFIX="10.165.22.0/24" 
export PRIVATE_ENDPOINTS_SUBNET_NAME="10.165.23.0/24" 

# 2048 allocated addresses (from 0.0 to 7.255)
export HUB_EXT_VNET_ADDRESS_SPACE="10.165.0.0/21" 

export FW_SUBNET_IP_PREFIX="10.165.1.0/24" 
export AGW_SUBNET_IP_PREFIX="10.165.2.0/24" 
export APIM_SUBNET_IP_PREFIX="10.165.3.0/24" 
export DEVOPS_AGENTS_SUBNET_IP_PREFIX="10.165.4.0/24" 

export DNS_SUBNET_IP_PREFIX="10.165.5.0/24" 
export DNS_VM_NIC_IP="10.165.5.5" 

# AKS Service Principal
export AKS_SP_NAME="${PREFIX}-aks-sp--${LOCATION_CODE}" 
# The following will be loaded by AAD module
# AKS_SP_ID="REPLACE"
# AKS_SP_PASSWORD="REPLACE"
# export AKS_SP_NAME=$AKS_SP_NAME 
export AKS_SP_ID="<AKS-SP-ID>"
export AKS_SP_PASSWORD="<AKS-SP-PASSWORD>"

# AGIC Managed Identity
AGIC_MANAGED_IDENTITY_NAME="${PREFIX}-agic-identity-${LOCATION_CODE}"
export AGIC_MANAGED_IDENTITY_NAME=$AGIC_MANAGED_IDENTITY_NAME 
# or use Service Principal
AGIC_SP_NAME="${PREFIX}-agic-sp-${LOCATION_CODE}"
# AGIC_SP_ID=REPLACE
# AGIC_SP_Password=REPLACE
export AGIC_SP_NAME=$AGIC_SP_NAME 
export AGIC_SP_ID=$AGIC_SP_ID 
export AGIC_SP_Password=$AGIC_SP_Password 

### Azure Container Registry (ACR)
export CONTAINER_REGISTRY_NAME="acr${PREFIX}${SUBSCRIPTION_CODE}${LOCATION_CODE}" 

### Application Gateway (AGW)
export AGW_NAME="${PREFIX}-agw-${LOCATION_CODE}" 
export AGW_PRIVATE_IP="10.165.2.10" 
# export AGW_RESOURCE_ID=REPLACE 

### AKS Cluster
AKS_CLUSTER_NAME="${PREFIX}-aks-${LOCATION_CODE}"

# AKS version will be set at the cluster provisioning time
# AKS_VERSION=REPLACE

# Default node pool name must all small letters and not exceed 15 letters
AKS_DEFAULT_NODEPOOL="primary"

export AKS_CLUSTER_NAME=$AKS_CLUSTER_NAME 
export AKS_VERSION="1.19.7"
export AKS_DEFAULT_NODEPOOL=$AKS_DEFAULT_NODEPOOL 

# AKS Networking
# Make sure that all of these ranges are not overlapping to any connected network space (on Azure and otherwise)
# These addresses are lated to AKS services mainly and should not overlap with other networks as they might present a conflict
export AKS_SERVICE_CIDR="10.41.0.0/16" 
export AKS_DNS_SERVICE_IP="10.41.0.10" 
export AKS_DOCKER_BRIDGE_ADDRESS="172.17.0.1/16" 
# Range to be used when using kubenet (not Azure CNI)
export AKS_POD_CIDR="10.244.0.0/16" 

### Public IPs
export AKS_PIP_NAME="${AKS_CLUSTER_NAME}-pip" 
export AGW_PIP_NAME="${AGW_NAME}-pip" 
export FW_PIP_NAME="${FW_NAME}-pip"
### Tags
# Saving the key/value pairs into variables
export TAG_ENV_DEV="Environment=DEV" 
export TAG_ENV_STG="Environment=STG" 
export TAG_ENV_QA="Environment=QA" 
export TAG_ENV_PROD="Environment=PROD" 
export TAG_ENV_DR_PROD="Environment=DR-PROD" 
export TAG_PROJ_CODE="Project=${PROJECT_CODE}" 
export TAG_PROJ_SHARED="Project=Shared-Service" 
export TAG_DEPT_IT="Department=IT" 
export TAG_STATUS_EXP="Status=Experimental" 
export TAG_STATUS_PILOT="Status=PILOT" 
export TAG_STATUS_APPROVED="Status=APPROVED" 

#########################2#######################

# Only if needed: A browser window will open to complete the authentication :)
# az login

# You can also login using Service Principal (replace values in <>)
# az login --service-principal --username APP_ID --password PASSWORD --tenant TENANT_ID

# Make sure to set explicitly the subscription to avoid accessing incorrect one
# az account set --subscription "YOUR-SUBSCRIPTION-NAME"

#Make sure the active subscription is set correctly

echo "Setting up subscription and tenant id based on the signed in account"

SUBSCRIPTION_ACCOUNT=$(az account show)
echo $SUBSCRIPTION_ACCOUNT

# Get the tenant ID
TENANT_ID=$(echo $SUBSCRIPTION_ACCOUNT | jq -r .tenantId)
# or use TENANT_ID=$(az account show --query tenantId -o tsv)
echo $TENANT_ID
export TENANT_ID=$TENANT_ID 

# Get the subscription ID
SUBSCRIPTION_ID=$(echo $SUBSCRIPTION_ACCOUNT | jq -r .id)
# or use TENANT_ID=$(az account show --query tenantId -o tsv)
echo $SUBSCRIPTION_ID
export SUBSCRIPTION_ID=$SUBSCRIPTION_ID 

clear

echo $"Subscription Id: ${SUBSCRIPTION_ID}"
echo $"Tenant Id: ${TENANT_ID}"

echo "Login Script Completed"


echo "No configured preview features currently enabled!"
echo "Please uncomment the required features as needed."


# As the new resource provider takes time (several mins) to register, you can check the status here. Wait for the state to show "Registered"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/WindowsPreview')].{Name:name,State:properties.state}"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/AKS-AzurePolicyAutoApprove')].{Name:name,State:properties.state}"
az feature list -o table --query "[?contains(name, 'Microsoft.PolicyInsights/AKS-DataPlaneAutoApprove')].{Name:name,State:properties.state}"

# After registrations finish with status "Registered", you can update the provider
az provider register --namespace Microsoft.ContainerService

echo "Preview Providers Registration Completed"


# We will be using these tags to mark all of the deployments with project/Environment pairs
# ONLY execute ONCE the creation and adding of values

# Some variables are referenced in the 02-variables.sh script

az tag create --name Environment
az tag create --name Project
az tag create --name Department
az tag create --name Status

az tag add-value \
    --name Environment \
    --value DEV

az tag add-value \
    --name Environment \
    --value STG

az tag add-value \
    --name Environment \
    --value QA

az tag add-value \
    --name Environment \
    --value PROD

az tag add-value \
    --name Environment \
    --value DR-PROD

az tag add-value \
    --name Project \
    --value $PROJECT_CODE

az tag add-value \
    --name Project \
    --value Shared-Service

az tag add-value \
    --name Department \
    --value IT

az tag add-value \
    --name Status \
    --value Experimental

az tag add-value \
    --name Status \
    --value PILOT

az tag add-value \
    --name Status \
    --value Approved

echo "Tags Creation Completed"

######################################

az group create \
    --name $RG_AKS \
    --location $LOCATION \
    --tags $TAG_ENV $TAG_PROJ_CODE $TAG_DEPT_IT $TAG_STATUS_EXP

az group create \
    --name $RG_SHARED \
    --location $LOCATION \
    --tags $TAG_ENV $TAG_PROJ_SHARED $TAG_DEPT_IT $TAG_STATUS_EXP

echo "Resource Groups Creation Completed"

######################################

export PROJ_VNET_NAME="${PREFIX}-${LOCATION_CODE}"
export RG_SHARED="${PREFIX}-shared-${LOCATION_CODE}"

az network vnet create \
    --resource-group $RG_SHARED \
    --name $PROJ_VNET_NAME \
    --address-prefixes $PROJ_VNET_ADDRESS_SPACE_1 $PROJ_VNET_ADDRESS_SPACE_2 \
    --tags $TAG_ENV $TAG_PROJ_CODE $TAG_DEPT_IT $TAG_STATUS_EXP

# AKS primary subnet
az network vnet subnet create \
    --resource-group $RG_SHARED \
    --vnet-name $PROJ_VNET_NAME \
    --name $AKS_SUBNET_NAME \
    --address-prefix $AKS_SUBNET_IP_PREFIX

# Create subnet for kubernetes exposed services (usually by internal load-balancer)
# Good security practice to isolate exposed services from the internal services
az network vnet subnet create \
    --resource-group $RG_SHARED \
    --vnet-name $PROJ_VNET_NAME \
    --name $SVC_SUBNET_NAME \
    --address-prefix $SVC_SUBNET_IP_PREFIX

# Get the id for project vnet.
PROJ_VNET_ID=$(az network vnet show \
    --resource-group $RG_SHARED \
    --name $PROJ_VNET_NAME \
    --query id --out tsv)
    
az network public-ip create \
    -g $RG_AKS \
    -n $AKS_PIP_NAME \
    -l $LOCATION \
    --sku Standard \
    --tags $TAG_ENV $TAG_PROJ_CODE $TAG_DEPT_IT $TAG_STATUS_EXP
    
az aks get-versions -l $LOCATION -o table

# To get the latest "production" supported version use the following (even if preview flag is activated):
AKS_VERSION=$(az aks get-versions -l ${LOCATION} --query "orchestrators[?isPreview==null].{Version:orchestratorVersion} | [-1]" -o tsv)
echo $AKS_VERSION

# Get latest AKS versions. 
# Note that this command will get the latest preview version if preview flag is activated)
# AKS_VERSION=$(az aks get-versions -l ${LOCATION} --query 'orchestrators[-1].orchestratorVersion' -o tsv)
# echo $AKS_VERSION

export AKS_VERSION=$AKS_VERSION 

# Get the public IP for AKS outbound traffic
AKS_PIP_ID=$(az network public-ip show -g $RG_AKS --name $AKS_PIP_NAME --query id -o tsv)

AKS_SUBNET_ID=$(az network vnet subnet show -g $RG_SHARED --vnet-name $PROJ_VNET_NAME --name $AKS_SUBNET_NAME --query id -o tsv)


 az aks create \
    --resource-group $RG_AKS \
    --name $AKS_CLUSTER_NAME \
    --location $LOCATION \
    --kubernetes-version $AKS_VERSION \
    --generate-ssh-keys \
    --load-balancer-outbound-ips $AKS_PIP_ID \
    --vnet-subnet-id $AKS_SUBNET_ID \
    --network-plugin azure \
    --network-policy calico \
    --service-cidr $AKS_SERVICE_CIDR \
    --dns-service-ip $AKS_DNS_SERVICE_IP \
    --docker-bridge-address $AKS_DOCKER_BRIDGE_ADDRESS \
    --nodepool-name $AKS_DEFAULT_NODEPOOL \
    --node-count 1 \
    --max-pods 30 \
    --node-vm-size "Standard_D4s_v3" \
    --vm-set-type VirtualMachineScaleSets \
    --service-principal <service-principal> \
    --client-secret <client-secret>\
    --tags $TAG_ENV $TAG_PROJ_CODE $TAG_DEPT_IT $TAG_STATUS_EXP

 
export SECOND_NOODEPOOL="app-pool"

az aks nodepool add \
    --resource-group $RG_AKS \
    --cluster-name $AKS_CLUSTER_NAME \
    --os-type Linux \
    --name $SECOND_NOODEPOOL \
    --node-count 3 \
    --max-pods 30 \
    --kubernetes-version $AKS_VERSION \
    --node-vm-size "Standard_DS2_v2" \
    --mode User \
    --labels app=smartpulse \
    --no-wait

echo "AKS Scripts Execution Completed"   
