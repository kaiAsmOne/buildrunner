# variables.tf

variable "organization_name" {
  description = "Azure DevOps organization name"
  type        = string
}

variable "pat_token" {
  description = "Personal Access Token for Azure DevOps"
  type        = string
  sensitive   = true
}