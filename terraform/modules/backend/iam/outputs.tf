output "lambda_role_arn" {
  value       = aws_iam_role.lambda_role.arn
  description = "IAM role ARN for Lambda functions"
}

output "lambda_role_name" {
  value       = aws_iam_role.lambda_role.name
  description = "IAM role name for Lambda functions"
}

output "ddb_policy_arn" {
  value       = aws_iam_policy.ddb_rw.arn
  description = "DynamoDB read/write policy ARN"
}
