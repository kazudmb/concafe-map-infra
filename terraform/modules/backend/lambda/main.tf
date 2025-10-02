locals {
  get_cafes_source_path      = "${path.module}/../../../../backend/get_cafes/main.py"
  upsert_cafes_source_path   = "${path.module}/../../../../backend/upsert_cafes/main.py"
  get_cafes_source_exists    = fileexists(local.get_cafes_source_path)
  upsert_cafes_source_exists = fileexists(local.upsert_cafes_source_path)
}

data "archive_file" "get_cafes" {
  count       = local.get_cafes_source_exists ? 1 : 0
  type        = "zip"
  source_file = local.get_cafes_source_path
  output_path = "${path.module}/get_cafes.zip"
}

data "archive_file" "get_cafes_placeholder" {
  count                   = local.get_cafes_source_exists ? 0 : 1
  type                    = "zip"
  output_path             = "${path.module}/get_cafes_placeholder.zip"
  source_content          = <<PY
def handler(event, context):
    raise RuntimeError("Placeholder artifact. Deploy real code via backend pipeline.")
PY
  source_content_filename = "main.py"
}

data "archive_file" "upsert_cafes" {
  count       = local.upsert_cafes_source_exists ? 1 : 0
  type        = "zip"
  source_file = local.upsert_cafes_source_path
  output_path = "${path.module}/upsert_cafes.zip"
}

data "archive_file" "upsert_cafes_placeholder" {
  count                   = local.upsert_cafes_source_exists ? 0 : 1
  type                    = "zip"
  output_path             = "${path.module}/upsert_cafes_placeholder.zip"
  source_content          = <<PY
def handler(event, context):
    raise RuntimeError("Placeholder artifact. Deploy real code via backend pipeline.")
PY
  source_content_filename = "main.py"
}

locals {
  get_cafes_package_path    = try(data.archive_file.get_cafes[0].output_path, data.archive_file.get_cafes_placeholder[0].output_path)
  get_cafes_package_hash    = try(data.archive_file.get_cafes[0].output_base64sha256, data.archive_file.get_cafes_placeholder[0].output_base64sha256)
  upsert_cafes_package_path = try(data.archive_file.upsert_cafes[0].output_path, data.archive_file.upsert_cafes_placeholder[0].output_path)
  upsert_cafes_package_hash = try(data.archive_file.upsert_cafes[0].output_base64sha256, data.archive_file.upsert_cafes_placeholder[0].output_base64sha256)
}

resource "aws_lambda_function" "get_cafes" {
  function_name = "${var.project}-get-cafes"
  role          = var.lambda_role_arn
  handler       = "main.handler"
  runtime       = var.lambda_runtime

  filename         = local.get_cafes_package_path
  source_code_hash = local.get_cafes_package_hash

  environment {
    variables = {
      TABLE_NAME   = var.table_name
      DEFAULT_AREA = var.default_area
    }
  }

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

resource "aws_lambda_function" "upsert_cafes" {
  function_name = "${var.project}-upsert-cafes"
  role          = var.lambda_role_arn
  handler       = "main.handler"
  runtime       = var.lambda_runtime

  filename         = local.upsert_cafes_package_path
  source_code_hash = local.upsert_cafes_package_hash

  environment {
    variables = {
      TABLE_NAME = var.table_name
    }
  }

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}
