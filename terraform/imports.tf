import {
  to = module.backend.module.dynamodb.aws_dynamodb_table.main
  id = local.project
}

import {
  to = module.backend.module.iam.aws_iam_role.lambda_role
  id = "${local.project}-lambda-role"
}

import {
  to = module.backend.module.iam.aws_iam_policy.ddb_rw
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.project}-ddb-rw"
}

import {
  to = module.backend.module.lambda.aws_lambda_function.get_cafes
  id = "${local.project}-get-cafes"
}

import {
  to = module.backend.module.lambda.aws_lambda_function.upsert_cafes
  id = "${local.project}-upsert-cafes"
}

import {
  to = module.backend.module.api.aws_lambda_permission.api_get_cafes
  id = "${local.project}-get-cafes/AllowAPIGatewayInvokeGet"
}

import {
  to = module.backend.module.api.aws_lambda_permission.api_post_cafes
  id = "${local.project}-upsert-cafes/AllowAPIGatewayInvokePost"
}

import {
  to = module.github_oidc.aws_iam_role.gha_ci[0]
  id = local.gha_role_name
}

import {
  to = module.github_oidc.aws_iam_role_policy_attachment.gha_admin[0]
  id = "${local.gha_role_name}/arn:aws:iam::aws:policy/AdministratorAccess"
}
