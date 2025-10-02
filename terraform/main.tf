locals {
  project              = var.project
  frontend_bucket_name = coalesce(var.frontend_bucket_name, "${var.project}-frontend")
  gha_role_name        = coalesce(var.existing_ci_role_name, "${var.project}-gha-ci")
}

data "aws_caller_identity" "current" {}

module "backend" {
  source     = "./modules/backend"
  project    = local.project
  account_id = data.aws_caller_identity.current.account_id
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

import {
  to = module.backend.aws_dynamodb_table.main
  id = local.project
}

import {
  to = module.backend.aws_iam_role.lambda_role
  id = "${local.project}-lambda-role"
}

import {
  to = module.backend.aws_iam_policy.ddb_rw
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.project}-ddb-rw"
}

import {
  to = module.backend.aws_lambda_function.get_cafes
  id = "${local.project}-get-cafes"
}

import {
  to = module.backend.aws_lambda_function.upsert_cafes
  id = "${local.project}-upsert-cafes"
}

import {
  to = module.backend.aws_lambda_permission.api_get_cafes
  id = "${local.project}-get-cafes/AllowAPIGatewayInvokeGet"
}

import {
  to = module.backend.aws_lambda_permission.api_post_cafes
  id = "${local.project}-upsert-cafes/AllowAPIGatewayInvokePost"
}
