# ========================================
# OUTPUTS PRINCIPALES
# ========================================

# URL del sitio web desplegado
output "website_url" {
  description = "URL completa del sitio web estático"
  value       = module.s3_static_website.website_url
}

# Endpoint del sitio web
output "website_endpoint" {
  description = "Endpoint S3 del sitio web"
  value       = module.s3_static_website.website_endpoint
}

# Nombre del bucket
output "bucket_name" {
  description = "Nombre del bucket S3 creado"
  value       = module.s3_static_website.bucket_name
}

# ARN del bucket
output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = module.s3_static_website.bucket_arn
}

# ========================================
# OUTPUTS INFORMATIVOS
# ========================================

# Región de despliegue
output "deployment_region" {
  description = "Región donde se desplegó la infraestructura"
  value       = local.region
}

# ID de cuenta AWS
output "aws_account_id" {
  description = "ID de la cuenta AWS utilizada"
  value       = local.account_id
}

# Environment
output "environment" {
  description = "Entorno de despliegue"
  value       = var.environment
}