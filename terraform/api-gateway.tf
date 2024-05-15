resource "aws_apigatewayv2_api" "photo_api" {
  name = "${local.environment}-photo-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "photo_api_stage" {
  api_id      = aws_apigatewayv2_api.photo_api.id
  name        = local.environment
  auto_deploy = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_integration" "photo_post_integration" {
  api_id           = aws_apigatewayv2_api.photo_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.presigned_url_generator.arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "photo_post_route" {
  api_id    = aws_apigatewayv2_api.photo_api.id
  route_key = "POST /photo"
  target    = "integrations/${aws_apigatewayv2_integration.photo_post_integration.id}"
}