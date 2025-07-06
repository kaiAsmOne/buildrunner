# Create Azure DevOps Project for Runners

The Terraform code in this folder will create an Azure DevOps Project according to Microsoft Cloud Adoptation Framework.
A Service Connection to the Azure Subscription specified will be created.

This is pretty self explaining by looking at the code. use a terraform.tfvars similar to what you see below or use Azure Key Vault , HashiCorp Vault or similar tools for production
  
  
Example terraform.tfvars  

azure_devops_pat = "YourPAT"  
azure_devops_org_url = "https://dev.azure.com/org/"  
subscription_id = "YourSubscriptionID"
tenant_id = "YourTenantID"