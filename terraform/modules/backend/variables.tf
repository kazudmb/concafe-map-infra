variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "default_area" {
  description = "Default cafe area"
  type        = string
  default     = "shinjuku"
}

variable "lambda_runtime" {
  description = "Python runtime for Lambda functions"
  type        = string
  default     = "python3.11"
}
