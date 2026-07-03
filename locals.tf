
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

  ## Cloudaccess role/state parameters common to every IAM roles stackset (GitHub, GitLab and
  ## both Azure DevOps stacksets)
  cloudaccess_common_parameters = {
    CloudAccessRoleReadOnlyName  = var.cloudaccess_role_readonly_name
    CloudAccessRoleReadWriteName = var.cloudaccess_role_readwrite_name
    TerraformStateKey            = var.cloudaccess_terraform_state_key
    TerraformStateROPolicyName   = var.cloudaccess_terraform_state_readonly_policy_name
    TerraformStateRWPolicyName   = var.cloudaccess_terraform_state_readwrite_policy_name
  }

  ## Parameters for the IAM roles stackset
  iam_roles_parameters = merge(local.cloudaccess_common_parameters, {
    IdentityProviderName = var.oidc_provider_name
    RepositoryName       = var.cloudaccess_repository_name
  })

  ## Parameters for the IAM roles stackset deployed to spoke accounts for Azure DevOps. Spoke
  ## accounts don't federate OIDC directly - Azure DevOps cannot independently re-federate a
  ## single authenticated pipeline task into multiple AWS accounts - so they instead trust the
  ## counterpart role in the management account via sts:AssumeRole, chained from there.
  azuredevops_spoke_iam_roles_parameters = merge(local.cloudaccess_common_parameters, {
    AzureDevOpsPrimaryRoleAccountId = data.aws_organizations_organization.current.master_account_id
  })

  ## Parameters for the IAM roles stack deployed to the management account for Azure DevOps -
  ## the only account whose roles are federated into directly via OIDC (see
  ## azuredevops_spoke_iam_roles_parameters above).
  azuredevops_management_iam_roles_parameters = merge(local.cloudaccess_common_parameters, {
    AzureDevOpsServiceConnection = var.azuredevops_service_connection
    IdentityProviderName         = var.oidc_provider_name
  })

  ## Tags applied to the stackset and the resources it creates
  tags = merge(var.tags, {})
}
