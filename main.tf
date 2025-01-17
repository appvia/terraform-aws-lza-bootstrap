## Provision the terraform state dependencies within all accounts. This is
## deployed as a stackset to all accounts.
module "terraform_state" {
  source  = "appvia/stackset/aws"
  version = "0.1.10"

  capabilities         = local.capabilities
  description          = "Provisions the Terraform state bucket and DynamoDB table within all accounts"
  enabled_regions      = var.available_regions
  name                 = var.stack_terraform_state_name
  organizational_units = [local.root_id]
  parameters           = local.terraform_state_parameters
  region               = var.home_region
  tags                 = local.tags

  template = templatefile("${path.module}/assets/cloudformation/terraform-state.yaml", {
    tags = local.tags
  })
}

## Deployment of same stack to the management account
resource "aws_cloudformation_stack" "terraform_state_management" {
  capabilities = local.capabilities
  name         = var.stack_terraform_state_name
  on_failure   = "ROLLBACK"
  parameters   = local.terraform_state_parameters
  tags         = local.tags

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
  version = "0.1.10"

  capabilities         = local.capabilities
  description          = "Provisions the OIDC provider within all accounts"
  name                 = var.stack_oidc_provider_name
  organizational_units = [local.root_id]
  parameters           = local.oidc_provider_parameters
  region               = var.home_region
  tags                 = local.tags

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
  tags         = local.tags

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
  count   = var.enable_github_integration ? 1 : 0
  source  = "appvia/stackset/aws"
  version = "0.1.10"

  capabilities         = local.capabilities
  description          = "Provisions the IAM roles required for cloudaccess for Github"
  name                 = var.stack_cicd_iam_roles_name
  organizational_units = [local.root_id]
  parameters           = local.iam_roles_parameters
  region               = var.home_region
  tags                 = var.tags

  template = templatefile("${path.module}/assets/cloudformation/github-pipeline-iam.yaml", {
    tags = var.tags
  })
}

## Deployment of same stack to the management account
resource "aws_cloudformation_stack" "iam_roles_github_management" {
  count = var.enable_github_integration ? 1 : 0

  capabilities = local.capabilities
  name         = var.stack_cicd_iam_roles_name
  on_failure   = "ROLLBACK"
  parameters   = local.iam_roles_parameters
  tags         = var.tags

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
  count   = var.enable_gitlab_integration ? 1 : 0
  source  = "appvia/stackset/aws"
  version = "0.1.10"

  capabilities         = local.capabilities
  description          = "Provisions the IAM roles required for cloudaccess for Gitlab"
  name                 = var.stack_cicd_iam_roles_name
  organizational_units = [local.root_id]
  parameters           = local.iam_roles_parameters
  region               = var.home_region
  tags                 = var.tags

  template = templatefile("${path.module}/assets/cloudformation/gitlab-pipeline-iam.yaml", {
    tags = var.tags
  })
}

## Deployment of same stack to the management account
resource "aws_cloudformation_stack" "iam_roles_gitlab_management" {
  count = var.enable_gitlab_integration ? 1 : 0

  capabilities = local.capabilities
  name         = var.stack_cicd_iam_roles_name
  on_failure   = "ROLLBACK"
  parameters   = local.iam_roles_parameters
  tags         = var.tags

  template_body = templatefile("${path.module}/assets/cloudformation/gitlab-pipeline-iam.yaml", {
    tags = var.tags
  })

  lifecycle {
    ignore_changes = [
      capabilities,
    ]
  }
}
