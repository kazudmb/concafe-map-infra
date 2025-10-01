locals {
  project              = var.project
  environment          = var.environment
  frontend_bucket_name = coalesce(var.frontend_bucket_name, "${var.project}-frontend")
  gha_role_name        = coalesce(var.existing_ci_role_name, "${var.project}-gha-ci")
}

data "aws_caller_identity" "current" {}

module "backend" {
  source      = "./modules/backend"
  project     = local.project
  environment = local.environment
  account_id  = data.aws_caller_identity.current.account_id
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
  to = module.backend.aws_dynamodb_table.cafes
  id = "${local.project}-${local.environment}"
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

import {
  to = module.github_oidc.aws_iam_role.gha_ci[0]
  id = local.gha_role_name
}

import {
  to = module.github_oidc.aws_iam_role_policy_attachment.gha_admin[0]
  id = "${local.gha_role_name}/arn:aws:iam::aws:policy/AdministratorAccess"
}

output "api_base_url" {
  value = module.backend.api_endpoint
}

output "frontend_bucket" {
  value = module.frontend.bucket_name
}

output "dynamodb_table" {
  value = module.backend.dynamodb_table_name
}

output "frontend_website_url" {
  value = module.frontend.website_url
}

output "frontend_cdn_domain" {
  value = module.frontend.cdn_domain
}

output "frontend_cdn_id" {
  value = module.frontend.cdn_id
}

output "cognito_user_pool_id" {
  value       = module.cognito.user_pool_id
  description = "Cognito User Pool ID"
}

output "cognito_client_id" {
  value       = module.cognito.client_id
  description = "Cognito App Client ID"
}

output "cognito_domain" {
  value       = module.cognito.domain
  description = "Cognito Hosted UI domain prefix"
}

output "gha_role_arn" {
  value       = module.github_oidc.gha_role_arn
  description = "GitHub Actions CI IAM Role ARN"
}
