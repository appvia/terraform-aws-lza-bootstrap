<!-- markdownlint-disable -->
<a href="https://www.appvia.io/"><img src="https://github.com/appvia/terraform-aws-lza-bootstrap/blob/main/appvia_banner.jpg?raw=true" alt="Appvia Banner"/></a><br/><p align="right"> <a href="https://registry.terraform.io/modules/appvia/lza-bootstrap/aws/latest"><img src="https://img.shields.io/static/v1?label=APPVIA&message=Terraform%20Registry&color=191970&style=for-the-badge" alt="Terraform Registry"/></a></a> <a href="https://github.com/appvia/terraform-aws-lza-bootstrap/releases/latest"><img src="https://img.shields.io/github/release/appvia/terraform-aws-lza-bootstrap.svg?style=for-the-badge&color=006400" alt="Latest Release"/></a> <a href="https://appvia-community.slack.com/join/shared_invite/zt-1s7i7xy85-T155drryqU56emm09ojMVA#/shared-invite/email"><img src="https://img.shields.io/badge/Slack-Join%20Community-purple?style=for-the-badge&logo=slack" alt="Slack Community"/></a> <a href="https://github.com/appvia/terraform-aws-lza-bootstrap/graphs/contributors"><img src="https://img.shields.io/github/contributors/appvia/terraform-aws-lza-bootstrap.svg?style=for-the-badge&color=FF8C00" alt="Contributors"/></a>

<!-- markdownlint-restore -->
<!--
  ***** CAUTION: DO NOT EDIT ABOVE THIS LINE ******
-->

![Github Actions](https://github.com/appvia/terraform-aws-lza-bootstrap/actions/workflows/terraform.yml/badge.svg)

# Terraform AWS LZA Bootstrap Module

## Description

The purpose of this module is to provide a bootstrap module for getting a landing zone within a initial configurable state. This module will create the following resources:

- Terraform State Dependencies
- Terraform IAM Policies
- Cloudaccess IAM Roles & Policies

Once provisioned we can utilize the landing zone to deploy further resources.

## Usage

a) Firstly we need to ensure "Trusted Access" is permitted within Cloudformation, see https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacksets-orgs-activate-trusted-access.html
b) Run the pipeline locally to provision the resources
c) Once the resources are provisioned, we can push the local terraform state to the S3 bucket.
d) Move the pipeline under CI/CD

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
