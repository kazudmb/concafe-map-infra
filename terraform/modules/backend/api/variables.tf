variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "get_lambda_invoke_arn" {
  description = "Invoke ARN for GET Lambda"
  type        = string
}

variable "get_lambda_function_name" {
  description = "Function name for GET Lambda"
  type        = string
}

variable "upsert_lambda_invoke_arn" {
  description = "Invoke ARN for POST Lambda"
  type        = string
}

variable "upsert_lambda_function_name" {
  description = "Function name for POST Lambda"
  type        = string
}
