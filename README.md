<!-- markdownlint-disable -->
<a href="https://www.appvia.io/"><img src="https://github.com/appvia/terraform-aws-lza-bootstrap/blob/main/appvia_banner.jpg?raw=true" alt="Appvia Banner"/></a><br/><p align="right"> <a href="https://registry.terraform.io/modules/appvia/lza-bootstrap/aws/latest"><img src="https://img.shields.io/static/v1?label=APPVIA&message=Terraform%20Registry&color=191970&style=for-the-badge" alt="Terraform Registry"/></a></a> <a href="https://github.com/appvia/terraform-aws-lza-bootstrap/releases/latest"><img src="https://img.shields.io/github/release/appvia/terraform-aws-lza-bootstrap.svg?style=for-the-badge&color=006400" alt="Latest Release"/></a> <a href="https://appvia-community.slack.com/join/shared_invite/zt-1s7i7xy85-T155drryqU56emm09ojMVA#/shared-invite/email"><img src="https://img.shields.io/badge/Slack-Join%20Community-purple?style=for-the-badge&logo=slack" alt="Slack Community"/></a> <a href="https://github.com/appvia/terraform-aws-lza-bootstrap/graphs/contributors"><img src="https://img.shields.io/github/contributors/appvia/terraform-aws-lza-bootstrap.svg?style=for-the-badge&color=FF8C00" alt="Contributors"/></a>

<!-- markdownlint-restore -->
<!--
  ***** CAUTION: DO NOT EDIT ABOVE THIS LINE ******
-->

![Github Actions](https://github.com/appvia/terraform-aws-lza-bootstrap/actions/workflows/terraform.yml/badge.svg)

# Terraform AWS LZA Bootstrap Module

## Introduction

Bootstrap your AWS Landing Zone Accelerator (LZA) foundations with a single, repeatable workflow. This module solves the "day-zero" problem of standing up shared Terraform state, CI/CD identity, and CloudAccess roles across a multi-account AWS Organization, so subsequent landing zone modules can deploy consistently.

At a high level, it orchestrates CloudFormation StackSets for organization-wide resources (Terraform state, OIDC provider, CI/CD IAM roles) and mirrors key stacks into the management account to keep local operations consistent. It is designed for multi-account, multi-region landing zone strategies where a central management account drives shared platform services.

## Features

- Secure bootstrap for organization-wide Terraform state, with standardized stack names and tags.
- Centralized CI/CD identity and access through OIDC providers (GitHub or GitLab).
- CloudAccess role provisioning for read-only and read-write workflows.
- Multi-account rollout using StackSets with management account parity.
- Configurable per-organization naming and tagging to align with platform conventions.

## Usage Gallery

### Golden Path (Simple)

Most common deployment: GitHub OIDC with a minimal set of overrides.

```hcl
module "lza_bootstrap" {
  source = "appvia/lza-bootstrap/aws"

  home_region         = "eu-west-2"
  available_regions   = ["eu-west-2", "us-east-1"]
  enable_github_integration = true

  oidc_provider_name        = "token.actions.githubusercontent.com"
  oidc_provider_thumbprints = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  oidc_provider_client_ids  = ["sts.amazonaws.com"]

  cloudaccess_repository_name = "appvia/lz-aws-cloudaccess"

  tags = {
    Environment = "Production"
    Owner       = "Platform"
    Product     = "LandingZone"
  }
}
```

### Power User (Advanced)

GitLab OIDC, custom naming, and explicit CloudAccess policy names.

```hcl
module "lza_bootstrap" {
  source = "appvia/lza-bootstrap/aws"

  home_region       = "eu-west-2"
  available_regions = ["eu-west-2", "us-east-1", "us-west-2"]
  enable_gitlab_integration = true

  oidc_provider_name        = "gitlab.com"
  oidc_provider_thumbprints = ["A1B2C3D4E5F60718293A4B5C6D7E8F9012345678"]
  oidc_provider_client_ids  = ["https://gitlab.com"]

  cloudaccess_repository_name                       = "appvia/lz-aws-cloudaccess"
  cloudaccess_role_readonly_name                    = "cloudaccess-ro"
  cloudaccess_role_readwrite_name                   = "cloudaccess"
  cloudaccess_terraform_state_key                   = "lz-aws-cloudaccess/terraform.tfstate"
  cloudaccess_terraform_state_readonly_policy_name  = "lza-terraform-state-ro"
  cloudaccess_terraform_state_readwrite_policy_name = "lza-terraform-state-rw"

  stack_terraform_state_name = "lza-terraform-state"
  stack_accounts_table_name  = "lza-accounts-table"
  stack_oidc_provider_name   = "lza-oidc-provider"
  stack_cicd_iam_roles_name  = "lza-cicd-iam-roles"

  tags = {
    Environment = "Production"
    Owner       = "Platform"
    GitRepo     = "https://gitlab.com/appvia/lz-aws-bootstrap"
  }
}
```

### Migration (Edge Case)

Bootstrap an organization where Terraform state and CI/CD roles already exist, using a distinct state key and explicit naming to avoid collisions.

```hcl
module "lza_bootstrap" {
  source = "appvia/lza-bootstrap/aws"

  home_region       = "eu-west-2"
  available_regions = ["eu-west-2"]
  enable_github_integration = true

  oidc_provider_name        = "token.actions.githubusercontent.com"
  oidc_provider_thumbprints = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  oidc_provider_client_ids  = ["sts.amazonaws.com"]

  cloudaccess_repository_name = "appvia/lz-aws-cloudaccess"
  cloudaccess_terraform_state_key = "legacy/cloudaccess/terraform.tfstate"

  stack_terraform_state_name = "legacy-terraform-state"
  stack_oidc_provider_name   = "legacy-oidc-provider"
  stack_cicd_iam_roles_name  = "legacy-cicd-iam-roles"

  tags = {
    Environment = "Migration"
    Owner       = "Platform"
    Product     = "LandingZone"
  }
}
```

## Operational Context

- StackSets require AWS Organizations trusted access for CloudFormation.
- StackSet deployments can take several minutes per region and account.
- The management account also receives direct stacks for Terraform state and OIDC identity.
- Ensure the deploying principal has `organizations:DescribeOrganization` and StackSet permissions.

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_available_regions"></a> [available\_regions](#input\_available\_regions) | List of available regions for deployment we are configuring | `list(string)` | n/a | yes |
| <a name="input_cloudaccess_repository_name"></a> [cloudaccess\_repository\_name](#input\_cloudaccess\_repository\_name) | Name of the CloudAccess repository | `string` | n/a | yes |
| <a name="input_home_region"></a> [home\_region](#input\_home\_region) | The AWS region we will use at the home region | `string` | n/a | yes |
| <a name="input_oidc_provider_name"></a> [oidc\_provider\_name](#input\_oidc\_provider\_name) | OIDC provider name for GitHub or GitLab | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | n/a | yes |
| <a name="input_cloudaccess_role_readonly_name"></a> [cloudaccess\_role\_readonly\_name](#input\_cloudaccess\_role\_readonly\_name) | Name of the CloudAccess role for read-only access | `string` | `"cloudaccess-ro"` | no |
| <a name="input_cloudaccess_role_readwrite_name"></a> [cloudaccess\_role\_readwrite\_name](#input\_cloudaccess\_role\_readwrite\_name) | Name of the CloudAccess role for read-write access | `string` | `"cloudaccess"` | no |
| <a name="input_cloudaccess_terraform_state_key"></a> [cloudaccess\_terraform\_state\_key](#input\_cloudaccess\_terraform\_state\_key) | S3 key to store Terraform state for CloudAccess | `string` | `"tf-aws-cloudaccess/terraform.tfstate"` | no |
| <a name="input_cloudaccess_terraform_state_readonly_policy_name"></a> [cloudaccess\_terraform\_state\_readonly\_policy\_name](#input\_cloudaccess\_terraform\_state\_readonly\_policy\_name) | Name of the policy for the CloudAccess role for read-only access | `string` | `"lza-cloudaccess-terraform-state-ro"` | no |
| <a name="input_cloudaccess_terraform_state_readwrite_policy_name"></a> [cloudaccess\_terraform\_state\_readwrite\_policy\_name](#input\_cloudaccess\_terraform\_state\_readwrite\_policy\_name) | Name of the policy for the CloudAccess role for read-write access | `string` | `"lza-cloudaccess-terraform-state-rw"` | no |
| <a name="input_enable_github_integration"></a> [enable\_github\_integration](#input\_enable\_github\_integration) | Enable GitHub integration for CI/CD | `bool` | `false` | no |
| <a name="input_enable_gitlab_integration"></a> [enable\_gitlab\_integration](#input\_enable\_gitlab\_integration) | Enable GitLab integration for CI/CD | `bool` | `false` | no |
| <a name="input_oidc_provider_client_ids"></a> [oidc\_provider\_client\_ids](#input\_oidc\_provider\_client\_ids) | OIDC provider client IDs for GitHub or GitLab | `list(string)` | `[]` | no |
| <a name="input_oidc_provider_thumbprints"></a> [oidc\_provider\_thumbprints](#input\_oidc\_provider\_thumbprints) | OIDC provider thumbprints for GitHub or GitLab | `list(string)` | `[]` | no |
| <a name="input_stack_accounts_table_name"></a> [stack\_accounts\_table\_name](#input\_stack\_accounts\_table\_name) | Is the name of the stackset used to provision the accounts table resources | `string` | `"lza-accounts-table"` | no |
| <a name="input_stack_cicd_iam_roles_name"></a> [stack\_cicd\_iam\_roles\_name](#input\_stack\_cicd\_iam\_roles\_name) | Is the name of the stackset used to provision the IAM roles for CI/CD resources | `string` | `"lza-cicd-iam-roles"` | no |
| <a name="input_stack_oidc_provider_name"></a> [stack\_oidc\_provider\_name](#input\_stack\_oidc\_provider\_name) | Is the name of the stackset used to provision the OIDC provider resources | `string` | `"lza-oidc-provider"` | no |
| <a name="input_stack_terraform_state_name"></a> [stack\_terraform\_state\_name](#input\_stack\_terraform\_state\_name) | Is the name of the stackset used to provision the terraform state resources | `string` | `"lza-terraform-state"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
