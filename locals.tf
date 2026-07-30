
locals {
  ## Organizational root id
  root_id = data.aws_organizations_organization.current.roots[0].id
  ## Indicates we are using Github
  is_using_github = var.github != null
  ## Indicates we are using Gitlab
  is_using_gitlab = var.gitlab != null
  ## Stack capabilities
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]

  ## Terraform State StackSet Parameters
  terraform_state_parameters = {}

  ## Accounts Table Parameters
  accounts_table_parameters = {
    AccountsTableName        = "lz-aws-accounts"
    AccountsTableNameHashKey = "account_name"
    BillingMode              = "PAY_PER_REQUEST"
  }

  ## Parameters for the OIDC provider stack set
  oidc_provider_parameters = {
    ClientIdList         = join(",", var.oidc_provider_client_ids)
    IdentityProviderName = var.oidc_provider_name
    ThumbprintList       = join(",", var.oidc_provider_thumbprints)
  }

  ## The parameters when using Github
  github_parameters = local.is_using_github ? {
    GithubOrganizationID   = var.github.organization_id
    GithubOrganizationName = var.github.organization_name
    RepositoryID           = var.github.repository_id
    RepositoryName         = var.github.repository_name
  } : {}

  ## The parameters when using Gitlab
  gitlab_parameters = local.is_using_gitlab ? {
    GitlabOrganizationName = var.gitlab.organization_name
    RepositoryName         = var.gitlab.repository_name
  } : {}

  ## Merged parameters for the IAM roles stack set
  iam_roles_parameters = merge(local.github_parameters, local.gitlab_parameters, {
    CloudAccessRoleReadOnlyName  = var.cloudaccess_role_readonly_name
    CloudAccessRoleReadWriteName = var.cloudaccess_role_readwrite_name
    IdentityProviderName         = var.oidc_provider_name
    TerraformStateKey            = var.cloudaccess_terraform_state_key
    TerraformStateROPolicyName   = var.cloudaccess_terraform_state_readonly_policy_name
    TerraformStateRWPolicyName   = var.cloudaccess_terraform_state_readwrite_policy_name
  })

  ## Tags applied to the stack set and the resources it creates
  tags = merge(var.tags, {})
}
