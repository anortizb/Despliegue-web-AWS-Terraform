# ========================================
# CONFIGURACIÓN DE BACKEND REMOTO
# ========================================

# Terraform almacena el estado de la infraestructura en un archivo
# Este archivo
terraform {
  backend "s3" {
    # Bucket donde se almacenará el archivo de estado
    bucket = "andres-ortiz-terraform-state"
    
    # Ruta y nombre del archivo de estado dentro del bucket
    key = "terraform/state/terraform.tfstate"
    
    # Región del bucket de backend
    region = "us-east-1"
    
    # Cifrado del estado en reposo usando AES-256
    encrypt = true
  }
}