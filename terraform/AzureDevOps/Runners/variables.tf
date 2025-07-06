variable "azure_devops_org_url" {
  description = "Azure DevOps Organization URL"
  type        = string
}

variable "azure_devops_pat" {
  description = "Azure DevOps Personal Access Token"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}
