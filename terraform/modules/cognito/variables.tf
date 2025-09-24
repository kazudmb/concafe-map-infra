variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "enable_cognito" {
  description = "Whether to provision Cognito resources"
  type        = bool
}

variable "cognito_domain_prefix" {
  description = "Optional Cognito domain prefix"
  type        = string
  default     = null
}

variable "cognito_callback_urls" {
  description = "Cognito OAuth callback URLs"
  type        = list(string)
}

variable "cognito_logout_urls" {
  description = "Cognito OAuth logout URLs"
  type        = list(string)
}

variable "google_client_id" {
  description = "Optional Google client ID"
  type        = string
  default     = null
  sensitive   = true
}

variable "google_client_secret" {
  description = "Optional Google client secret"
  type        = string
  default     = null
  sensitive   = true
}
