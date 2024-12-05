
locals {
  ## Organizational root id
  root_id = data.aws_organizations_organization.current.roots[0].id
}
