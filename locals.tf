
locals {
  ## Organizational root id
  root_id = data.aws_organizations_organization.current.roots[0].id

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

  ## Parameters for the OIDC provider stackset
  oidc_provider_parameters = {
    ClientIdList         = join(",", var.oidc_provider_client_ids)
    IdentityProviderName = var.oidc_provider_name
    ThumbprintList       = join(",", var.oidc_provider_thumbprints)
  }

  ## Parameters for the IAM roles stackset
  iam_roles_parameters = {
    CloudAccessRoleReadOnlyName  = var.cloudaccess_role_readonly_name
    CloudAccessRoleReadWriteName = var.cloudaccess_role_readwrite_name
    IdentityProviderName         = var.oidc_provider_name
    RepositoryName               = var.cloudaccess_repository_name
    TerraformStateKey            = var.cloudaccess_terraform_state_key
    TerraformStateROPolicyName   = var.cloudaccess_terraform_state_readonly_policy_name
    TerraformStateRWPolicyName   = var.cloudaccess_terraform_state_readwrite_policy_name
  }

  ## Tags applied to the stackset and the resources it creates
  tags = merge(var.tags, {})
}
