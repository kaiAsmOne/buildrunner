##Variable Group Setup  
Create a variable group in Azure DevOps with these variables:  

ARM_CLIENT_ID: Service Principal Client ID  
ARM_CLIENT_SECRET: Service Principal Secret (mark as secret)  
ARM_TENANT_ID: Azure Tenant ID  
ARM_SUBSCRIPTION_ID: Azure Subscription ID  
PAT_TOKEN: Personal Access Token for agent registration (mark as secret)  
ORGANIZATION_URL: Your Azure DevOps organization URL  

    
##Key Features Implemented:  
  
Automated Build: The pipeline builds a custom Ubuntu agent with all necessary tools  
Auto-Registration: Agents automatically register to the KaiAgents pool on startup  
VMSS Integration: Automatically updates the VM Scale Set with new images  
Nightly Builds: Scheduled to run every night at 02:00  
Rolling Updates: Uses rolling upgrade strategy to minimize downtime  
Autoscaling: VMSS configured to scale based on CPU usage  
  
The agents will automatically deregister when shutting down and re-register with a new name when starting up, ensuring clean pool management.  
