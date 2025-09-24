locals {
  cognito_enabled = var.enable_cognito
  cognito_providers = local.cognito_enabled ? (
    (var.google_client_id != null && var.google_client_secret != null) ? ["COGNITO", "Google"] : ["COGNITO"]
  ) : []
}

resource "random_id" "cognito_suffix" {
  count       = local.cognito_enabled ? 1 : 0
  byte_length = 3
}

resource "aws_cognito_user_pool" "this" {
  count = local.cognito_enabled ? 1 : 0

  name = "${var.project}-users"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = false
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  count        = local.cognito_enabled ? 1 : 0
  domain       = coalesce(var.cognito_domain_prefix, "${var.project}-${try(random_id.cognito_suffix[0].hex, "")}")
  user_pool_id = aws_cognito_user_pool.this[0].id
}

resource "aws_cognito_identity_provider" "google" {
  count         = local.cognito_enabled && var.google_client_id != null && var.google_client_secret != null ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.this[0].id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
    authorize_scopes = "openid email profile"
  }

  attribute_mapping = {
    email = "email"
  }
}

resource "aws_cognito_user_pool_client" "spa" {
  count                         = local.cognito_enabled ? 1 : 0
  name                          = "${var.project}-spa"
  user_pool_id                  = aws_cognito_user_pool.this[0].id
  generate_secret               = false
  explicit_auth_flows           = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
  supported_identity_providers  = local.cognito_providers
  prevent_user_existence_errors = "ENABLED"

  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  allowed_oauth_flows_user_pool_client = true
  callback_urls                        = var.cognito_callback_urls
  logout_urls                          = var.cognito_logout_urls

  depends_on = [aws_cognito_identity_provider.google]
}
