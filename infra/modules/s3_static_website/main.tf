# ========================================
# BUCKET S3 PARA SITIO WEB ESTÁTICO
# ========================================

# Creación del bucket S3 principal
resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name

  tags = merge(
    var.common_tags,
    {
      Name = var.bucket_tag_name
    }
  )
}

# ========================================
# CONFIGURACIÓN DE PROPIEDAD DE OBJETOS
# ========================================

# Establece que el propietario del bucket controla todos los objetos
# Deshabilita el uso de ACLs (Access Control Lists) legacy
resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# ========================================
# CONFIGURACIÓN DE ACCESO PÚBLICO
# ========================================

# Configuración del bloqueo de acceso público
# Se deshabilitan los bloqueos para permitir acceso público controlado
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  # Permite el uso de ACLs públicas
  block_public_acls = false
  
  # Permite políticas de bucket públicas
  block_public_policy = false
  
  # No ignora las ACLs públicas existentes
  ignore_public_acls = false
  
  # Permite que el bucket sea público
  restrict_public_buckets = false
}

# ========================================
# CONFIGURACIÓN DE SITIO WEB ESTÁTICO
# ========================================

# Habilita el hosting de sitio web estático en el bucket
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  # Documento que se sirve por defecto
  index_document {
    suffix = var.index_file_key
  }

  # Documento que se sirve en caso de error 4xx
  error_document {
    key = var.index_file_key
  }
}

# ========================================
# POLÍTICA DE ACCESO PÚBLICO
# ========================================

# Política que permite lectura pública de todos los objetos
# Necesaria para que el sitio web sea accesible desde internet
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  # Asegura que la configuración de acceso público se aplique primero
  depends_on = [
    aws_s3_bucket_public_access_block.website,
    aws_s3_bucket_ownership_controls.website
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PublicReadGetObject"
        Effect = "Allow"
        # Permite acceso a cualquier principal
        Principal = "*"
        # Permite solo la operación de lectura
        Action   = "s3:GetObject"
        # Aplica a todos los objetos dentro del bucket
        Resource = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# ========================================
# OBJETO: ARCHIVO INDEX.HTML
# ========================================

# Sube el archivo index.html al bucket
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.website.id
  key    = var.index_file_key
  source = var.index_file_path
  
  content_type = "text/html"
  
  # Hash MD5 del archivo para detectar cambios
  # Si el archivo cambia, Terraform lo detecta y actualiza
  etag = filemd5(var.index_file_path)

  tags = merge(
    var.common_tags,
    {
      Name = "Website Index Page"
    }
  )
}