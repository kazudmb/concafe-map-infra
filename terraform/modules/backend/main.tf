module "dynamodb" {
  source  = "./dynamodb"
  project = var.project
}

module "iam" {
  source    = "./iam"
  project   = var.project
  table_arn = module.dynamodb.table_arn
}

module "lambda" {
  source           = "./lambda"
  project          = var.project
  table_name       = module.dynamodb.table_name
  lambda_role_arn  = module.iam.lambda_role_arn
  lambda_role_name = module.iam.lambda_role_name
  default_area     = var.default_area
  lambda_runtime   = var.lambda_runtime
}

module "api" {
  source                      = "./api"
  project                     = var.project
  get_lambda_invoke_arn       = module.lambda.get_lambda_invoke_arn
  get_lambda_function_name    = module.lambda.get_lambda_function_name
  upsert_lambda_invoke_arn    = module.lambda.upsert_lambda_invoke_arn
  upsert_lambda_function_name = module.lambda.upsert_lambda_function_name
}
