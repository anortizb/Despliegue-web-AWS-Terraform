# Outputs del módulo S3 Static Website

# ID del bucket creado
output "bucket_id" {
  description = "ID del bucket S3"
  value       = aws_s3_bucket.website.id
}

# ARN del bucket
output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.website.arn
}

# Nombre del bucket
output "bucket_name" {
  description = "Nombre del bucket S3"
  value       = aws_s3_bucket.website.bucket
}

# Endpoint del sitio web
output "website_endpoint" {
  description = "Endpoint del sitio web estático"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

# URL completa del sitio web
output "website_url" {
  description = "URL completa del sitio web con protocolo HTTP"
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}

# Domain del bucket para referencia
output "bucket_domain_name" {
  description = "Domain name del bucket S3"
  value       = aws_s3_bucket.website.bucket_domain_name
}

# Region del bucket
output "bucket_region" {
  description = "Región del bucket S3"
  value       = aws_s3_bucket.website.region
}