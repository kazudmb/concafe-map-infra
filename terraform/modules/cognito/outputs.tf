output "user_pool_id" {
  value       = try(aws_cognito_user_pool.this[0].id, null)
  description = "Cognito User Pool ID"
}

output "client_id" {
  value       = try(aws_cognito_user_pool_client.spa[0].id, null)
  description = "Cognito App Client ID"
}

output "domain" {
  value       = try(aws_cognito_user_pool_domain.this[0].domain, null)
  description = "Cognito domain prefix"
}
