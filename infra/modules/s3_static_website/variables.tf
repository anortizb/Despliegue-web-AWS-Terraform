# Variable para el nombre del bucket
variable "bucket_name" {
  description = "Nombre del bucket S3 para el sitio web estático"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "El nombre del bucket debe contener solo minúsculas, números y guiones"
  }
}

# Variable para la ruta del archivo HTML
variable "index_file_path" {
  description = "Ruta del archivo index.html"
  type        = string
  default     = "index.html"
}

# Variable para el nombre del objeto en S3
variable "index_file_key" {
  description = "Nombre del archivo index en S3"
  type        = string
  default     = "index.html"
}

# Variable para tags comunes
variable "common_tags" {
  description = "Tags comunes para todos los recursos del módulo"
  type        = map(string)
  default     = {}
}

# Variable para tag de nombre específico del bucket
variable "bucket_tag_name" {
  description = "Tag Name específico para el bucket"
  type        = string
  default     = "S3 Static Website Bucket"
}