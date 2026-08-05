## Provision the terraform state dependencies within all accounts. This is
## deployed as a stack set to all accounts.
module "terraform_state" {
  source  = "appvia/stackset/aws"
  version = "0.2.10"

  capabilities         = local.capabilities
  description          = "Provisions the Terraform state bucket within all accounts"
  enabled_regions      = var.available_regions
  name                 = var.stack_terraform_state_name
  organizational_units = [local.root_id]
  parameters           = local.terraform_state_parameters
  region               = var.home_region
  tags                 = merge(local.tags, { "Name" = var.stack_terraform_state_name })

  template = templatefile("${path.module}/assets/cloudformation/terraform-state.yaml", {
    tags = local.tags
  })
}

## Provision the accounts table within the management account
resource "aws_cloudformation_stack" "accounts_table_management" {
  capabilities = local.capabilities
  name         = var.stack_accounts_table_name
  on_failure   = "ROLLBACK"
  parameters   = local.accounts_table_parameters
  tags         = merge(local.tags, { "Name" = var.stack_accounts_table_name })

  template_body = templatefile("${path.module}/assets/cloudformation/accounts-table.yaml", {
    tags = local.tags
  })

  lifecycle {
    ignore_changes = [
      capabilities,
    ]
  }
}

## Deployment of same stack to the management account
resource "aws_cloudformation_stack" "terraform_state_management" {
  capabilities = local.capabilities
  name         = var.stack_terraform_state_name
  on_failure   = "ROLLBACK"
  parameters   = local.terraform_state_parameters
  tags         = merge(local.tags, { "Name" = var.stack_terraform_state_name })

  template_body = templatefile("${path.module}/assets/cloudformation/terraform-state.yaml", {
    tags = local.tags
  })

  lifecycle {
    ignore_changes = [
      capabilities,
    ]
  }
}

## Provision the OIDC provider for GitHub or GitLab within all accounts
module "oidc_provider" {
  source  = "appvia/stackset/aws"
  version = "0.2.10"

  capabilities         = local.capabilities
  description          = "Provisions the OIDC provider within all accounts"
  name                 = var.stack_oidc_provider_name
  organizational_units = [local.root_id]
  parameters           = local.oidc_provider_parameters
  region               = var.home_region
  tags                 = merge(local.tags, { "Name" = var.stack_oidc_provider_name })

  template = templatefile("${path.module}/assets/cloudformation/oidc-identity.yaml", {
    tags = local.tags
  })
}

## Deployment of same stack to the management account
resource "aws_cloudformation_stack" "oidc_provider_management" {
  capabilities = local.capabilities
  name         = var.stack_oidc_provider_name
  on_failure   = "ROLLBACK"
  parameters   = local.oidc_provider_parameters
  tags         = merge(local.tags, { "Name" = var.stack_oidc_provider_name })

  template_body = templatefile("${path.module}/assets/cloudformation/oidc-identity.yaml", {
    tags = local.tags
  })

  lifecycle {
    ignore_changes = [
      capabilities,
    ]
  }
}

## Provision the IAM cloud access roles for Github within all accounts
module "iam_roles_github" {
  count   = local.is_using_github ? 1 : 0
  source  = "appvia/stackset/aws"
  version = "0.2.10"

  capabilities         = local.capabilities
  description          = "Provisions the IAM roles required for cloud access for Github"
  name                 = var.stack_cicd_iam_roles_name
  organizational_units = [local.root_id]
  parameters           = local.iam_roles_parameters
  region               = var.home_region
  tags                 = merge(local.tags, { "Name" = var.stack_cicd_iam_roles_name })

  template = templatefile("${path.module}/assets/cloudformation/github-pipeline-iam.yaml", {
    tags = var.tags
  })
}

## Deployment of same stack to the management account
resource "aws_cloudformation_stack" "iam_roles_github_management" {
  count = local.is_using_github ? 1 : 0

  capabilities = local.capabilities
  name         = var.stack_cicd_iam_roles_name
  on_failure   = "ROLLBACK"
  parameters   = local.iam_roles_parameters
  tags         = merge(local.tags, { "Name" = var.stack_cicd_iam_roles_name })

  template_body = templatefile("${path.module}/assets/cloudformation/github-pipeline-iam.yaml", {
    tags = var.tags
  })

  lifecycle {
    ignore_changes = [
      capabilities,
    ]
  }
}

## Provision the IAM cloud access roles for Gitlab within all accounts
module "iam_roles_gitlab" {
  count   = local.is_using_gitlab ? 1 : 0
  source  = "appvia/stackset/aws"
  version = "0.2.10"

  capabilities         = local.capabilities
  description          = "Provisions the IAM roles required for cloudaccess for Gitlab"
  name                 = var.stack_cicd_iam_roles_name
  organizational_units = [local.root_id]
  parameters           = local.iam_roles_parameters
  region               = var.home_region
  tags                 = merge(local.tags, { "Name" = var.stack_cicd_iam_roles_name })

  template = templatefile("${path.module}/assets/cloudformation/gitlab-pipeline-iam.yaml", {
    tags = var.tags
  })
}

## Deployment of same stack to the management account
resource "aws_cloudformation_stack" "iam_roles_gitlab_management" {
  count = local.is_using_gitlab ? 1 : 0

  capabilities = local.capabilities
  name         = var.stack_cicd_iam_roles_name
  on_failure   = "ROLLBACK"
  parameters   = local.iam_roles_parameters
  tags         = merge(local.tags, { "Name" = var.stack_cicd_iam_roles_name })

  template_body = templatefile("${path.module}/assets/cloudformation/gitlab-pipeline-iam.yaml", {
    tags = var.tags
  })

  lifecycle {
    ignore_changes = [
      capabilities,
    ]
  }
}

## Provision the IAM cloud access roles for Azure DevOps within spoke accounts. Azure DevOps
## cannot independently re-federate a single authenticated pipeline task into multiple AWS
## accounts, so spokes trust the management account's counterpart role via sts:AssumeRole
## rather than federating OIDC directly - see iam_roles_azuredevops_management below.
module "iam_roles_azuredevops" {
  count   = var.enable_azuredevops_integration ? 1 : 0
  source  = "appvia/stackset/aws"
  version = "0.2.10"

  capabilities         = local.capabilities
  description          = "Provisions the IAM roles required for cloudaccess for Azure DevOps"
  name                 = var.stack_cicd_iam_roles_name
  organizational_units = [local.root_id]
  parameters           = local.azuredevops_spoke_iam_roles_parameters
  region               = var.home_region
  tags                 = merge(local.tags, { "Name" = var.stack_cicd_iam_roles_name })

  template = templatefile("${path.module}/assets/cloudformation/azuredevops-pipeline-iam.yaml", {
    tags = var.tags
  })
}

## Deployment of the Azure DevOps IAM roles to the management account - the only account whose
## roles are federated into directly via OIDC (see module.iam_roles_azuredevops above).
resource "aws_cloudformation_stack" "iam_roles_azuredevops_management" {
  count = var.enable_azuredevops_integration ? 1 : 0

  capabilities = local.capabilities
  name         = var.stack_cicd_iam_roles_name
  on_failure   = "ROLLBACK"
  parameters   = local.azuredevops_management_iam_roles_parameters
  tags         = merge(local.tags, { "Name" = var.stack_cicd_iam_roles_name })

  template_body = templatefile("${path.module}/assets/cloudformation/azuredevops-management-pipeline-iam.yaml", {
    tags = var.tags
  })

  lifecycle {
    ignore_changes = [
      capabilities,
    ]
  }
}
