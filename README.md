# DevOps Build Environments  
This repository will allow you to start with a simple git clone to your machine.  
Followed by executing my Terraform Code.  
The Terraform Code will Then Create an Azure DevOps Project following MS CAF.  
  
Creating a Service Connection from Azure DevOps to the Azure Subscription specified in the Terraform Variables.  
With a pipeline that auto creates MS Official Runners  
In the Azure Subscription specified in the Terraform Variables.  
Creating all resources in Azure Automatically for you.  
With scheduled auto updates every night at 02:00.  
  
Furthermore:    

This repo is a collection of Azure DevOps Pipelines, Scripts, Terraform code or work in general  
relaterd to Build Environments for Azure DevOps Private Build Agents usually refered to as Runners.  

I published this repo while writing an blog post Regarding Runners / Pipeline Agents.  
The article is hosted here https://www.thorsrud.io/modern-architecture-and-hybrid-environments-automating-self-hosted-agents-for-azure/  
  

## Note  
I advise you to start by executing the terraform code in /terraform/AzureDevOps/Runners/    
The terraform code will create an AzureDevOps Project following MS CAF.  
Read the README.md in the /terraform/AzureDevOps/Runners/ folder for instructions.  
  
The Terraform code is a good way to automate Azure DevOps project creation in general.  
  
   
When the Terraform code is applied you will then have an Azure DevOps Project  
* With a Repository initialized with a clone of this project on github.  
* With a pipeline building new MS Official Runners every night at 02:00.  
  
The pipeline will create all the neccesary resources in Azure or update them if they already exists.  
  
Your end result will be a fully working private runner always up to date with the latest release from Microsoft  
( https://github.com/Microsoft/azure-pipelines-agent/  )  


In this repo you will also find shell scripts that can be executed on a clean Fedora / CentOs / Ubuntu VM , creating a fully working custom runner environment for Ansible and Terraform ready to be used with Azure, Google Cloud and OnPrem.  
The shell script are from 2016 before i learned the hard way why you should use the MS Official Runners instead of managing your own custom runner.    
The scripts are added in case someone can make use of them.  
  
  
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
