output "user_pool_id" {
  value = aws_cognito_user_pool.photo_management_user_pool.id
}

output "user_pool_endpoint" {
  value = aws_cognito_user_pool.photo_management_user_pool.endpoint
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.photo_management_user_pool_client.id
}
