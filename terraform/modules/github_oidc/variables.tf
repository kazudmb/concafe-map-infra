variable "enable_github_oidc" {
  description = "Whether to create GitHub OIDC resources"
  type        = bool
}

variable "existing_github_oidc_provider_arn" {
  description = "Existing GitHub OIDC provider ARN"
  type        = string
  default     = null
}

variable "github_oidc_thumbprints" {
  description = "List of thumbprints for the GitHub OIDC provider"
  type        = list(string)
}

variable "github_owner" {
  description = "GitHub organization or user"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "gha_role_name" {
  description = "IAM role name for GitHub Actions"
  type        = string
}
