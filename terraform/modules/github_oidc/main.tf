locals {
  oidc_enabled = var.enable_github_oidc
}

resource "aws_iam_openid_connect_provider" "github" {
  count = local.oidc_enabled && var.existing_github_oidc_provider_arn == null ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.github_oidc_thumbprints
}

locals {
  provider_arn = coalesce(
    var.existing_github_oidc_provider_arn,
    try(aws_iam_openid_connect_provider.github[0].arn, null)
  )
}

data "aws_iam_policy_document" "gha_assume" {
  count = local.oidc_enabled ? 1 : 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [local.provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/*",
        "repo:${var.github_owner}/${var.github_repo}:ref:refs/tags/*",
        "repo:${var.github_owner}/${var.github_repo}:pull_request"
      ]
    }
  }
}

resource "aws_iam_role" "gha_ci" {
  count              = local.oidc_enabled ? 1 : 0
  name               = var.gha_role_name
  assume_role_policy = data.aws_iam_policy_document.gha_assume[0].json
  description        = "CI role assumed by GitHub Actions via OIDC"
}

resource "aws_iam_role_policy_attachment" "gha_admin" {
  count      = local.oidc_enabled ? 1 : 0
  role       = aws_iam_role.gha_ci[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
