variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "bucket_name" {
  description = "Frontend S3 bucket name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}
