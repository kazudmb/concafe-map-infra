locals {
  table_name          = "${var.project}-cafes"
  lambda_role_name    = "${var.project}-lambda-role"
  get_cafes_zip       = "${path.root}/get_cafes.zip"
  upsert_cafes_zip    = "${path.root}/upsert_cafes.zip"
  get_cafes_source    = "${path.module}/../../../../backend/get_cafes/main.py"
  upsert_cafes_source = "${path.module}/../../../../backend/upsert_cafes/main.py"
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_dynamodb_table" "cafes" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "area"
    type = "S"
  }

  global_secondary_index {
    name            = "gsi_area"
    hash_key        = "area"
    projection_type = "ALL"
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = local.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "ddb_rw" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [
      aws_dynamodb_table.cafes.arn,
      "${aws_dynamodb_table.cafes.arn}/index/*"
    ]
  }
}

resource "aws_iam_policy" "ddb_rw" {
  name   = "${var.project}-ddb-rw"
  policy = data.aws_iam_policy_document.ddb_rw.json
}

resource "aws_iam_role_policy_attachment" "ddb_rw_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.ddb_rw.arn
}

data "archive_file" "get_cafes" {
  type        = "zip"
  source_file = local.get_cafes_source
  output_path = local.get_cafes_zip
}

data "archive_file" "upsert_cafes" {
  type        = "zip"
  source_file = local.upsert_cafes_source
  output_path = local.upsert_cafes_zip
}

resource "aws_lambda_function" "get_cafes" {
  function_name = "${var.project}-get-cafes"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.handler"
  runtime       = var.lambda_runtime

  filename         = data.archive_file.get_cafes.output_path
  source_code_hash = data.archive_file.get_cafes.output_base64sha256

  environment {
    variables = {
      TABLE_NAME   = aws_dynamodb_table.cafes.name
      DEFAULT_AREA = var.default_area
    }
  }
}

resource "aws_lambda_function" "upsert_cafes" {
  function_name = "${var.project}-upsert-cafes"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.handler"
  runtime       = var.lambda_runtime

  filename         = data.archive_file.upsert_cafes.output_path
  source_code_hash = data.archive_file.upsert_cafes.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.cafes.name
    }
  }
}

resource "aws_apigatewayv2_api" "http" {
  name          = "${var.project}-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_origins = ["*"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "get_cafes" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.get_cafes.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_cafes" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /cafes"
  target    = "integrations/${aws_apigatewayv2_integration.get_cafes.id}"
}

resource "aws_lambda_permission" "api_get_cafes" {
  statement_id  = "AllowAPIGatewayInvokeGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_cafes.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "upsert_cafes" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.upsert_cafes.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_cafes" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /cafes"
  target    = "integrations/${aws_apigatewayv2_integration.upsert_cafes.id}"
}

resource "aws_lambda_permission" "api_post_cafes" {
  statement_id  = "AllowAPIGatewayInvokePost"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upsert_cafes.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true
}
