terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.0"
    }
  }
}

provider "azuredevops" {
  org_service_url       = var.azure_devops_org_url
# pat_token should be set via environment variable AZDO_PERSONAL_ACCESS_TOKEN if running locally
  personal_access_token = var.azure_devops_pat
}
variable "azure_devops_org_url" {
  description = "Azure DevOps Organization URL"
  type        = string
}

variable "azure_devops_pat" {
  description = "Azure DevOps Personal Access Token"
  type        = string
  sensitive   = true
}

locals {
  azure_devops_org_url = "https://dev.azure.com/kai0411/"
  azure_devops_pat = ""
}
# Create the project following Cloud Adoption Framework
resource "azuredevops_project" "plz_msrunners" {
  name        = "plz-msrunners"
  description = "Project to automate build process and deployment of MS Official Runners"
  visibility  = "private"

  version_control    = "Git"
  work_item_template = "Agile" # CAF recommends Agile for iterative development

  features = {
    "boards"       = "enabled"
    "repositories" = "enabled"
    "pipelines"    = "enabled"
    "testplans"    = "enabled"
    "artifacts"    = "enabled"
  }
}

# Create main repository
resource "azuredevops_git_repository" "plz_msrunners_repo" {
  project_id = azuredevops_project.plz_msrunners.id
  name       = "plz-msrunners"

  initialization {
    init_type = "Clean"
  }
}

# Create branch policy for master branch - enforce code review
resource "azuredevops_branch_policy_min_reviewers" "master_policy" {
  project_id = azuredevops_project.plz_msrunners.id

  enabled  = true
  blocking = true

  settings {
    reviewer_count                         = 2
    submitter_can_vote                     = false
    last_pusher_cannot_approve             = true
    allow_completion_with_rejects_or_waits = false
    on_push_reset_approved_votes           = true

    scope {
      repository_id  = azuredevops_git_repository.plz_msrunners_repo.id
      repository_ref = "refs/heads/master"
      match_type     = "Exact"
    }
  }
}

# Build validation policy - trigger pipeline on PR to master
resource "azuredevops_branch_policy_build_validation" "master_build_policy" {
  project_id = azuredevops_project.plz_msrunners.id

  enabled  = true
  blocking = true

  settings {
    display_name        = "Build Validation"
    build_definition_id = azuredevops_build_definition.pipeline_runner.id
    valid_duration      = 720
    filename_patterns = [
      "/pipeline/azure-pipeline-runner.yml"
    ]

    scope {
      repository_id  = azuredevops_git_repository.plz_msrunners_repo.id
      repository_ref = "refs/heads/master"
      match_type     = "Exact"
    }
  }
}

# Create the build pipeline that triggers on master commits
resource "azuredevops_build_definition" "pipeline_runner" {
  project_id = azuredevops_project.plz_msrunners.id
  name       = "plz-msrunners-pipeline"
  path       = "\\CAF-Pipelines" # Organize pipelines following CAF structure

  ci_trigger {
    use_yaml = true
  }

  # Trigger on master branch commits
  repository {
    repo_type           = "TfsGit"
    repo_id             = azuredevops_git_repository.plz_msrunners_repo.id
    branch_name         = "refs/heads/master"
    yml_path            = "/pipeline/azure-pipeline-runner.yml"
    report_build_status = true
  }

  # CAF recommends organizing build definitions
  variable {
    name  = "BuildConfiguration"
    value = "Release"
  }

  variable {
    name  = "CAF.Environment"
    value = "Production"
  }
}

# Create development branch for CAF best practices
resource "azuredevops_git_repository_branch" "develop" {
  repository_id = azuredevops_git_repository.plz_msrunners_repo.id
  name          = "develop"
  ref_branch    = "master"
}

# Create feature branch policy template following CAF
resource "azuredevops_branch_policy_min_reviewers" "develop_policy" {
  project_id = azuredevops_project.plz_msrunners.id

  enabled  = true
  blocking = false # Less restrictive for development

  settings {
    reviewer_count     = 1
    submitter_can_vote = true

    scope {
      repository_id  = azuredevops_git_repository.plz_msrunners_repo.id
      repository_ref = "refs/heads/develop"
      match_type     = "Exact"
    }
  }
}

# Create service connection placeholder (you'll need to configure this manually or with additional resources)
# This follows CAF principle of least privilege access

# Teams following CAF RACI model
resource "azuredevops_team" "platform_team" {
  project_id  = azuredevops_project.plz_msrunners.id
  name        = "Platform Team"
  description = "Responsible for platform infrastructure and runners"
}

resource "azuredevops_team" "security_team" {
  project_id  = azuredevops_project.plz_msrunners.id
  name        = "Security Team"
  description = "Security oversight and compliance review"
}

# Variable group for pipeline configuration following CAF
resource "azuredevops_variable_group" "pipeline_config" {
  project_id   = azuredevops_project.plz_msrunners.id
  name         = "CAF-Pipeline-Configuration"
  description  = "Configuration variables following Cloud Adoption Framework"
  allow_access = true

  variable {
    name  = "Environment"
    value = "Production"
  }

  variable {
    name  = "ResourceGroup"
    value = "rg-plz-msrunners-prod"
  }

  variable {
    name  = "SubscriptionId"
    value = "" # Set this to your Azure subscription ID
  }

  variable {
    name         = "ServicePrincipalSecret"
    secret_value = "" # This should be set securely
    is_secret    = true
  }
}

# Outputs
output "project_id" {
  description = "The ID of the created project"
  value       = azuredevops_project.plz_msrunners.id
}

output "repository_id" {
  description = "The ID of the created repository"
  value       = azuredevops_git_repository.plz_msrunners_repo.id
}

output "pipeline_id" {
  description = "The ID of the created pipeline"
  value       = azuredevops_build_definition.pipeline_runner.id
}

output "project_url" {
  description = "URL to the project"
  value       = "${var.azure_devops_org_url}/${azuredevops_project.plz_msrunners.name}"
}
