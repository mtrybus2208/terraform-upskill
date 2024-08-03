# photo-api-authorizer fn
resource "aws_lambda_function" "photo_api_authorizer" {
  function_name    = "${var.prefix}-photo-api-authorizer"
  s3_bucket        = var.photo_edit_lambda_bucket_id
  s3_key           = aws_s3_object.photo_api_authorizer.key
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.photo_api_authorizer_role.arn
  timeout          = 5
  source_code_hash = data.archive_file.photo_api_authorizer.output_base64sha256

  environment {
    variables = {
      VALID_TOKEN_MOCK = var.valid_token_mock
      REGION           = var.region
    }
  }
}

resource "aws_cloudwatch_log_group" "photo_api_authorizer_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.photo_api_authorizer.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "allow_api_gw_invoke_authorizer" {
  statement_id  = "allowInvokeFromAPIGatewayAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.photo_api_authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.photo_api.execution_arn}/*/*"
}

# get_images_for_user lambda fn 

resource "aws_lambda_function" "get_images_for_user" {
  function_name    = "${var.prefix}-get-images-for-user"
  s3_bucket        = var.photo_edit_lambda_bucket_id
  s3_key           = aws_s3_object.get_images_for_user.key
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.get_images_for_user_role.arn
  timeout          = 5
  source_code_hash = data.archive_file.get_images_for_user.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME         = var.photo_edit_lambda_bucket_name
      DYNAMODB_TABLE_NAME = var.image_metadata_table_name
      REGION              = var.region
    }
  }
}

resource "aws_cloudwatch_log_group" "get_images_for_user_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.get_images_for_user.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw_get_images_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_images_for_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.photo_api.execution_arn}/*/*"
}

# get_single_image lambda fn

resource "aws_lambda_function" "get_single_image" {
  function_name    = "${var.prefix}-get-single-image"
  s3_bucket        = var.photo_edit_lambda_bucket_id
  s3_key           = aws_s3_object.get_single_image.key
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.get_single_image_role.arn
  timeout          = 5
  source_code_hash = data.archive_file.get_single_image.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME         = var.photo_edit_lambda_bucket_name
      DYNAMODB_TABLE_NAME = var.image_metadata_table_name
      REGION              = var.region
    }
  }
}

resource "aws_cloudwatch_log_group" "get_single_image_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.get_single_image.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw_get_single_image_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_single_image.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.photo_api.execution_arn}/*/*"
}

# presigned_url_generator

resource "aws_lambda_function" "presigned_url_generator" {
  function_name    = "${var.prefix}-presigned-url-generator-handler"
  s3_bucket        = var.photo_edit_lambda_bucket_id
  s3_key           = aws_s3_object.presigned_url_generator.key
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.presigned_url_generator_role.arn
  timeout          = 5
  source_code_hash = data.archive_file.presigned_url_generator.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = var.photo_edit_lambda_bucket_name
      ENV         = var.environment
    }
  }
}


resource "aws_cloudwatch_log_group" "presigned_url_generator_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.presigned_url_generator.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.presigned_url_generator.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.photo_api.execution_arn}/*/*"
}