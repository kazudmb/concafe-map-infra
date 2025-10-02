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
