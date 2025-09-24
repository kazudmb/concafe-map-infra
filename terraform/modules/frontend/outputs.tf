output "bucket_name" {
  value       = local.bucket_name
  description = "Frontend S3 bucket name"
}

output "website_url" {
  value       = "http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}"
  description = "S3 website endpoint"
}

output "cdn_domain" {
  value       = aws_cloudfront_distribution.frontend.domain_name
  description = "CloudFront distribution domain"
}

output "cdn_id" {
  value       = aws_cloudfront_distribution.frontend.id
  description = "CloudFront distribution ID"
}
