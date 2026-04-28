# ========================================
# CONFIGURACIÓN DE TERRAFORM Y PROVIDERS
# ========================================

terraform {
  # Versión mínima requerida de Terraform
  required_version = ">= 1.0"

  # Providers requeridos con sus versiones
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ========================================
# CONFIGURACIÓN DEL PROVIDER AWS
# ========================================

# Provider de AWS con configuración de región y tags por defecto
provider "aws" {
  region = var.aws_region

  # Tags que se aplicarán automáticamente a todos los recursos compatibles
  default_tags {
    tags = {
      Environment = var.environment
      Owner       = var.owner
      Project     = var.project
      ManagedBy   = "Terraform"
      Repository  = "terraform-deploy-aws"
    }
  }
}

# ========================================
# DATA SOURCES
# ========================================

# Obtiene información de la cuenta AWS actual
data "aws_caller_identity" "current" {}

# Obtiene información de la región actual
data "aws_region" "current" {}

# ========================================
# LOCALS
# ========================================

# Variables locales calculadas para uso interno
locals {
  # Tags comunes para todos los recursos
  common_tags = {
    Environment = var.environment
    Owner       = var.owner
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  # Nombre estandarizado para el bucket
  bucket_tag_name = "${var.owner} - Static Website Bucket"

  # Información de cuenta
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

# ========================================
# MÓDULO: S3 STATIC WEBSITE
# ========================================

# Instanciación del módulo de sitio web estático
module "s3_static_website" {
  # Ruta relativa al módulo
  source = "./infra/modules/s3_static_website"

  # Parámetros de configuración del módulo
  bucket_name       = var.bucket_name
  index_file_path   = var.index_html_path
  index_file_key    = "index.html"
  common_tags       = local.common_tags
  bucket_tag_name   = local.bucket_tag_name
}