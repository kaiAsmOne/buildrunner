terraform {
  required_version = ">= 1.9"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.46"
    }    
    time = {
      source  = "hashicorp/time"
      version = "~> 0.7"
    }

  }

}

provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
provider "azuread" {
  tenant_id = var.tenant_id
}

provider "azuredevops" {
  org_service_url       = var.azure_devops_org_url
  personal_access_token = var.azure_devops_pat
}
provider "time" {}

