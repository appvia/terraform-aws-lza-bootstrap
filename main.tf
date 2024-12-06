
locals {
  ## Stack capabilities
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]

  ## Terraform State StackSet Parameters
  terraform_state_parameters = {
    Environment = var.environment
    GitRepo     = var.git_repository
    Product     = var.product
    Owner       = var.owner
  }

  ## Parameters for the OIDC provider stackset
  oidc_provider_parameters = {
    ClientIdList         = join(",", var.oidc_provider_client_ids)
    Environment          = var.environment
    GitRepo              = var.git_repository
    IdentityProviderName = var.oidc_provider_name
    Owner                = var.owner
    Product              = var.product
    ThumbprintList       = join(",", var.oidc_provider_thumbprints)
  }

  ## Parameters for the IAM roles stackset
  iam_roles_parameters = {
    CloudAccessRoleReadOnlyName  = var.cloudaccess_role_readonly_name
    CloudAccessRoleReadWriteName = var.cloudaccess_role_readwrite_name
    Environment                  = var.environment
    GitRepo                      = var.git_repository
    IdentityProviderName         = var.oidc_provider_name
    Owner                        = var.owner
    Product                      = var.product
    RepositoryName               = var.cloudaccess_repository_name
    TerraformStateKey            = var.cloudaccess_terraform_state_key
    TerraformStateROPolicyName   = var.cloudaccess_terraform_state_readonly_policy_name
    TerraformStateRWPolicyName   = var.cloudaccess_terraform_state_readwrite_policy_name
  }
}

## Provision the terraform state dependencies within all accounts. This is
## deployed as a stackset to all accounts.
module "terraform_state" {
  source  = "appvia/stackset/aws"
  version = "0.1.3"

  capabilities         = local.capabilities
  description          = "Provisions the Terraform state bucket and DynamoDB table within all accounts"
  enabled_regions      = var.available_regions
  name                 = var.stack_terraform_state_name
  organizational_units = [local.root_id]
  parameters           = local.terraform_state_parameters
  region               = var.home_region
  tags                 = var.tags
  template             = file("${path.module}/assets/cloudformation/terraform-state.yaml")
}

## Deployment of same stack to the management account
resource "aws_cloudformation_stack" "terraform_state_management" {
  capabilities  = local.capabilities
  name          = var.stack_terraform_state_name
  on_failure    = "ROLLBACK"
  parameters    = local.terraform_state_parameters
  tags          = var.tags
  template_body = file("${path.module}/assets/cloudformation/terraform-state.yaml")

  lifecycle {
    ignore_changes = [
      capabilities,
    ]
  }
}

## Provision the OIDC provider for GitHub or GitLab within all accounts
module "oidc_provider" {
  source  = "appvia/stackset/aws"
  version = "0.1.3"

  capabilities         = local.capabilities
  description          = "Provisions the OIDC provider within all accounts"
  name                 = var.stack_oidc_provider_name
  organizational_units = [local.root_id]
  parameters           = local.oidc_provider_parameters
  region               = var.home_region
  tags                 = var.tags
  template             = file("${path.module}/assets/cloudformation/oidc-identity.yaml")
}

## Deployment of same stack to the management account
resource "aws_cloudformation_stack" "oidc_provider_management" {
  capabilities  = local.capabilities
  name          = var.stack_oidc_provider_name
  on_failure    = "ROLLBACK"
  parameters    = local.oidc_provider_parameters
  tags          = var.tags
  template_body = file("${path.module}/assets/cloudformation/oidc-identity.yaml")

  lifecycle {
    ignore_changes = [
      capabilities,
    ]
  }
}

## Provision the IAM cloud access roles for Github within all accounts
module "iam_roles_github" {
  count   = var.enable_github_integration ? 1 : 0
  source  = "appvia/stackset/aws"
  version = "0.1.3"

  capabilities         = local.capabilities
  description          = "Provisions the IAM roles required for cloudaccess for Github"
  name                 = var.stack_cicd_iam_roles_name
  organizational_units = [local.root_id]
  parameters           = local.iam_roles_parameters
  region               = var.home_region
  tags                 = var.tags
  template             = file("${path.module}/assets/cloudformation/github-pipeline-iam.yaml")
}

## Deployment of same stack to the management account
resource "aws_cloudformation_stack" "iam_roles_github_management" {
  count = var.enable_github_integration ? 1 : 0

  capabilities  = local.capabilities
  name          = var.stack_cicd_iam_roles_name
  on_failure    = "ROLLBACK"
  parameters    = local.iam_roles_parameters
  tags          = var.tags
  template_body = file("${path.module}/assets/cloudformation/github-pipeline-iam.yaml")

  lifecycle {
    ignore_changes = [
      capabilities,
    ]
  }
}

## Provision the IAM cloud access roles for Gitlab within all accounts
module "iam_roles_gitlab" {
  count   = var.enable_gitlab_integration ? 1 : 0
  source  = "appvia/stackset/aws"
  version = "0.1.3"

  capabilities         = local.capabilities
  description          = "Provisions the IAM roles required for cloudaccess for Gitlab"
  name                 = var.stack_cicd_iam_roles_name
  organizational_units = [local.root_id]
  parameters           = local.iam_roles_parameters
  region               = var.home_region
  tags                 = var.tags
  template             = file("${path.module}/assets/cloudformation/gitlab-pipeline-iam.yaml")
}

## Deployment of same stack to the management account
resource "aws_cloudformation_stack" "iam_roles_gitlab_management" {
  count = var.enable_gitlab_integration ? 1 : 0

  capabilities  = local.capabilities
  name          = var.stack_cicd_iam_roles_name
  on_failure    = "ROLLBACK"
  parameters    = local.iam_roles_parameters
  tags          = var.tags
  template_body = file("${path.module}/assets/cloudformation/gitlab-pipeline-iam.yaml")

  lifecycle {
    ignore_changes = [
      capabilities,
    ]
  }
}
