output "dynamodb_table_name" {
  value       = aws_dynamodb_table.main.name
  description = "Name of the DynamoDB table"
}

output "dynamodb_table_arn" {
  value       = aws_dynamodb_table.main.arn
  description = "ARN of the DynamoDB table"
}

output "lambda_role_arn" {
  value       = aws_iam_role.lambda_role.arn
  description = "IAM role ARN used by the Lambda functions"
}

output "api_endpoint" {
  value       = aws_apigatewayv2_api.http.api_endpoint
  description = "Base URL of the HTTP API"
}

output "lambda_role_name" {
  value       = aws_iam_role.lambda_role.name
  description = "IAM role name used by the Lambda functions"
}
