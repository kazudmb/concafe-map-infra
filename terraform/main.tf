data "aws_caller_identity" "current" {}

locals {
  project              = var.project
  account_id           = data.aws_caller_identity.current.account_id
  frontend_bucket_name = coalesce(var.frontend_bucket_name, "${var.project}-artifact-${local.account_id}")
  gha_role_name        = coalesce(var.existing_ci_role_name, "${var.project}-gha-ci")
}

module "backend" {
  source  = "./modules/backend"
  project = local.project
}

module "frontend" {
  source      = "./modules/frontend"
  project     = local.project
  bucket_name = local.frontend_bucket_name
  region      = var.aws_region
  account_id  = data.aws_caller_identity.current.account_id
}

module "cognito" {
  source                = "./modules/cognito"
  project               = local.project
  enable_cognito        = var.enable_cognito
  cognito_domain_prefix = var.cognito_domain_prefix
  cognito_callback_urls = var.cognito_callback_urls
  cognito_logout_urls   = var.cognito_logout_urls
  google_client_id      = var.google_client_id
  google_client_secret  = var.google_client_secret
}

module "github_oidc" {
  source                            = "./modules/github_oidc"
  enable_github_oidc                = var.enable_github_oidc
  existing_github_oidc_provider_arn = var.existing_github_oidc_provider_arn
  github_oidc_thumbprints           = var.github_oidc_thumbprints
  github_owner                      = var.github_owner
  github_repo                       = var.github_repo
  gha_role_name                     = local.gha_role_name
}
