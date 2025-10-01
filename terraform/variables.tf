variable "project" {
  description = "Project name prefix"
  type        = string
  default     = "concafe-map"
}


variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "frontend_bucket_name" {
  description = "S3 bucket name for frontend hosting"
  type        = string
  default     = null
}

variable "enable_cognito" {
  description = "Enable Cognito User Pool for auth"
  type        = bool
  default     = true
}

variable "cognito_domain_prefix" {
  description = "Cognito hosted UI domain prefix (must be globally unique in region). If null, a random suffix is used."
  type        = string
  default     = null
}

variable "cognito_callback_urls" {
  description = "OAuth callback URLs for SPA"
  type        = list(string)
  default = [
    "http://localhost:5173/",
  ]
}

variable "cognito_logout_urls" {
  description = "OAuth signout URLs for SPA"
  type        = list(string)
  default = [
    "http://localhost:5173/",
  ]
}

variable "google_client_id" {
  description = "Google OAuth Client ID (optional). When set with secret, Google login is enabled in Cognito Hosted UI."
  type        = string
  default     = null
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth Client Secret (optional)."
  type        = string
  default     = null
  sensitive   = true
}

# GitHub OIDC for Actions (optional)
variable "enable_github_oidc" {
  description = "Enable IAM OIDC provider + CI role for GitHub Actions"
  type        = bool
  default     = true
}

variable "github_owner" {
  description = "GitHub owner (org or user)"
  type        = string
  default     = "kazudmb"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "concafe-map-infra"
}

variable "github_oidc_thumbprints" {
  description = "Thumbprints for GitHub OIDC provider"
  type        = list(string)
  # Default includes common GitHub OIDC root CA thumbprint (may change over time)
  default = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

variable "existing_github_oidc_provider_arn" {
  description = "If provided, reuse existing GitHub OIDC provider ARN instead of creating a new one"
  type        = string
  default     = null
}

variable "existing_ci_role_name" {
  description = "If provided, reuse an existing CI IAM role name instead of creating a new one"
  type        = string
  default     = null
}
