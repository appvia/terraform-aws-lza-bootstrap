

module "bootstrap_github" {
  source = "../../"

  available_regions         = ["eu-west-2", "us-east-1"]
  environment               = "Production"
  enable_github_integration = true
  git_repository            = "https://github.com/appvia/tf-aws-bootstrap.git"
  owner                     = "Engineering"

  ## Home region
  home_region = "eu-west-2"

  ## Cloudaccess configuration
  cloudaccess_repository_name                       = "appvia/lz-aws-cloudaccess"
  cloudaccess_role_readonly_name                    = "cloudaccess-ro"
  cloudaccess_role_readwrite_name                   = "cloudaccess"
  cloudaccess_terraform_state_key                   = "lz-aws-cloudaccess.tfstate"
  cloudaccess_terraform_state_readwrite_policy_name = "lza-terraform-state-rw"
  cloudaccess_terraform_state_readonly_policy_name  = "lza-terraform-state-ro"

  ## Stack names
  stack_cicd_iam_roles_name  = "lza-cicd-iam-roles"
  stack_oidc_provider_name   = "lza-oidc-provider"
  stack_terraform_state_name = "lza-terraform-state"

  ## OIDC provider thumbprints for GitHub
  oidc_provider_name = "token.actions.githubusercontent.com"
  oidc_provider_thumbprints = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
  oidc_provider_client_ids = [
    "sts.amazonaws.com",
    "https://github.com/appvia",
  ]

  tags = {
    Environment = "Production"
    GitRepo     = "https://github.com/appvia/tf-aws-bootstrap.git"
    Owner       = "Engineering"
    Product     = "LandingZone"
  }
}
