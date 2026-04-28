# ========================================
# VARIABLES DE CONFIGURACIÓN AWS
# ========================================

# Región de AWS donde se desplegará la infraestructura
variable "aws_region" {
  description = "Región de AWS para el despliegue de recursos"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d{1}$", var.aws_region))
    error_message = "La región debe tener formato válido (ej: us-east-1)"
  }
}

# ========================================
# VARIABLES DE BUCKET S3
# ========================================

# Nombre del bucket para el sitio web estático
variable "bucket_name" {
  description = "Nombre del bucket S3 para hosting web estático"
  type        = string
}

# Nombre del bucket para el backend de Terraform
variable "backend_bucket" {
  description = "Nombre del bucket S3 para almacenar estado de Terraform"
  type        = string
}

# ========================================
# VARIABLES DE TAGS
# ========================================

# Tag de entorno
variable "environment" {
  description = "Entorno de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "El entorno debe ser: dev, staging o prod"
  }
}

# Tag de propietario
variable "owner" {
  description = "Nombre del propietario de los recursos"
  type        = string
  default     = "Andres Ortiz"
}

# Tag de proyecto
variable "project" {
  description = "Nombre del proyecto"
  type        = string
  default     = "Betek"
}

# ========================================
# VARIABLES DE APLICACIÓN
# ========================================

# Ruta del archivo HTML principal
variable "index_html_path" {
  description = "Ruta del archivo index.html a desplegar"
  type        = string
  default     = "index.html"
}