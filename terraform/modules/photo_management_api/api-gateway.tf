resource "aws_apigatewayv2_api" "photo_api" {
  name          = "${var.environment}-photo-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = [var.allowed_origins]
    allow_methods = ["POST", "GET", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
  }
}

resource "aws_apigatewayv2_authorizer" "photo_api_authorizer" {
  name                              = "photo-api-authorizer"
  api_id                            = aws_apigatewayv2_api.photo_api.id
  authorizer_type                   = "JWT"
  identity_sources                  = ["$request.header.Authorization"]
    jwt_configuration {
      audience = [var.user_pool_client_id]
      issuer   = "https://${var.user_pool_endpoint}"
    } 
}

resource "aws_apigatewayv2_stage" "photo_api_stage" {
  api_id      = aws_apigatewayv2_api.photo_api.id
  name        = var.stage
  auto_deploy = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_integration" "photo_post_integration" {
  api_id             = aws_apigatewayv2_api.photo_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.presigned_url_generator.arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "photo_post_route" {
  api_id             = aws_apigatewayv2_api.photo_api.id
  route_key          = "POST /photos"
  target             = "integrations/${aws_apigatewayv2_integration.photo_post_integration.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.photo_api_authorizer.id
}

# get all images
resource "aws_apigatewayv2_integration" "photo_get_integration" {
  api_id             = aws_apigatewayv2_api.photo_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.get_images_for_user.arn
  integration_method = "GET"
}

resource "aws_apigatewayv2_route" "photo_get_route" {
  api_id             = aws_apigatewayv2_api.photo_api.id
  route_key          = "GET /users/{userName}/photos"
  target             = "integrations/${aws_apigatewayv2_integration.photo_get_integration.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.photo_api_authorizer.id
}

# get single photo
resource "aws_apigatewayv2_route" "photo_get_single_route" {
  api_id             = aws_apigatewayv2_api.photo_api.id
  route_key          = "GET /users/{userName}/photos/{imageId}"
  target             = "integrations/${aws_apigatewayv2_integration.photo_get_single_integration.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.photo_api_authorizer.id
}

resource "aws_apigatewayv2_integration" "photo_get_single_integration" {
  api_id             = aws_apigatewayv2_api.photo_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.get_single_image.arn
  integration_method = "GET"
}
 