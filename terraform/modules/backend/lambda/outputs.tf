output "get_lambda_function_name" {
  value       = aws_lambda_function.get_cafes.function_name
  description = "Lambda function name for GET /cafes"
}

output "get_lambda_invoke_arn" {
  value       = aws_lambda_function.get_cafes.invoke_arn
  description = "Invoke ARN for GET Lambda"
}

output "upsert_lambda_function_name" {
  value       = aws_lambda_function.upsert_cafes.function_name
  description = "Lambda function name for POST /cafes"
}

output "upsert_lambda_invoke_arn" {
  value       = aws_lambda_function.upsert_cafes.invoke_arn
  description = "Invoke ARN for POST Lambda"
}
