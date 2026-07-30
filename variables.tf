
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "home_region" {
  description = "The AWS region we will use at the home region"
  type        = string
}

variable "available_regions" {
  description = "List of available regions for deployment we are configuring"
  type        = list(string)
}

variable "oidc_provider_thumbprints" {
  description = "OIDC provider thumbprints for GitHub or GitLab"
  type        = list(string)
  default     = []
}

variable "oidc_provider_client_ids" {
  description = "OIDC provider client IDs for GitHub or GitLab"
  type        = list(string)
  default     = []
}

variable "oidc_provider_name" {
  description = "OIDC provider name for GitHub or GitLab"
  type        = string
}

variable "github" {
  description = "Github configuration"
  type = object({
    enable_legacy_claims = optional(bool, true)
    organization_name    = string
    organization_id      = optional(string, "")
    repository_name      = string
    repository_id        = optional(string, "")
  })
  default = null
}

variable "gitlab" {
  description = "Gitlab configuration"
  type = object({
    organization_name = string
    repository_name   = string
  })
  default = null
}

variable "cloudaccess_terraform_state_key" {
  description = "S3 key to store Terraform state for CloudAccess"
  type        = string
  default     = "tf-aws-cloudaccess/terraform.tfstate"
}

variable "cloudaccess_role_readwrite_name" {
  description = "Name of the CloudAccess role for read-write access"
  type        = string
  default     = "cloudaccess"
}

variable "cloudaccess_role_readonly_name" {
  description = "Name of the CloudAccess role for read-only access"
  type        = string
  default     = "cloudaccess-ro"
}

variable "cloudaccess_terraform_state_readwrite_policy_name" {
  description = "Name of the policy for the CloudAccess role for read-write access"
  type        = string
  default     = "lza-cloudaccess-terraform-state-rw"
}

variable "cloudaccess_terraform_state_readonly_policy_name" {
  description = "Name of the policy for the CloudAccess role for read-only access"
  type        = string
  default     = "lza-cloudaccess-terraform-state-ro"
}

variable "stack_terraform_state_name" {
  description = "Is the name of the stackset used to provision the terraform state resources"
  type        = string
  default     = "lza-terraform-state"
}

variable "stack_accounts_table_name" {
  description = "Is the name of the stackset used to provision the accounts table resources"
  type        = string
  default     = "lza-accounts-table"
}

variable "stack_oidc_provider_name" {
  description = "Is the name of the stackset used to provision the OIDC provider resources"
  type        = string
  default     = "lza-oidc-provider"
}

variable "stack_cicd_iam_roles_name" {
  description = "Is the name of the stackset used to provision the IAM roles for CI/CD resources"
  type        = string
  default     = "lza-cicd-iam-roles"
}
