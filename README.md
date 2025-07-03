# DevOps Build Environments  
This repo is a collection of Azure DevOps Pipelines, Scripts, Terraform code or work in general  
relaterd to Build Environments for Azure DevOps Private Build Agents usually refered to as Runners.  

I published this repo while writing an blog post Regarding Runners / Pipeline Agents.  
The article is hosted here https://www.thorsrud.io/modern-architecture-and-hybrid-environments-automating-self-hosted-agents-for-azure/  
  

I have not used this code for a while so it might need some minor modifications.
I will run this pipeline ensuring it still works 100% and update this repo as needed.  
In this repo you will also find how to create a private runner for Ansible on Fedora or Ubuntu  
for use with Azure, Google Cloud and OnPrem. 
You will also find terraform code to create an Azure DevOps project for Runners.
  
  
Currently i only use MS Official Runner (The Gitlab runner image)  
I build fresh runners from the official repo every night  
My blog post above explains why I advice you to do the same.  


## Azure Pipeline for building MS Official Ubuntu Pipeline Agent

### Note


### Variable Group Setup  
Create a variable group in Azure DevOps with these variables:  

ARM_CLIENT_ID: Service Principal Client ID  
ARM_CLIENT_SECRET: Service Principal Secret (mark as secret)  
ARM_TENANT_ID: Azure Tenant ID  
ARM_SUBSCRIPTION_ID: Azure Subscription ID  
PAT_TOKEN: Personal Access Token for agent registration (mark as secret)  
ORGANIZATION_URL: Your Azure DevOps organization URL  

    
### Key Features Implemented:  
  
Automated Build: The pipeline builds a custom Ubuntu agent with all necessary tools  
Auto-Registration: Agents automatically register to the KaiAgents pool on startup  
VMSS Integration: Automatically updates the VM Scale Set with new images  
Nightly Builds: Scheduled to run every night at 02:00  
Rolling Updates: Uses rolling upgrade strategy to minimize downtime  
Autoscaling: VMSS configured to scale based on CPU usage  
  
The agents will automatically deregister when shutting down and re-register with a new name when starting up, ensuring clean pool management.  
