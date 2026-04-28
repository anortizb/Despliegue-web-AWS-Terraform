# Despliegue de Infraestructura como Código con Terraform en AWS

Proyecto de despliegue automatizado de un sitio web estático en AWS S3 utilizando Terraform y GitHub Actions con arquitectura modular.

## Tabla de Contenidos

- [Descripción](#descripción)
- [Arquitectura](#arquitectura)
- [Requisitos Previos](#requisitos-previos)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Configuración Inicial](#configuración-inicial)
- [Despliegue](#despliegue)
- [Destrucción de Recursos](#destrucción-de-recursos)
- [Variables de Configuración](#variables-de-configuración)
- [Outputs](#outputs)
- [Módulos](#módulos)
- [CI/CD Pipeline](#cicd-pipeline)
- [Buenas Prácticas Implementadas](#buenas-prácticas-implementadas)
- [Troubleshooting](#troubleshooting)
- [Contribución](#contribución)
- [Licencia](#licencia)

---

## Descripción

Sistema de Infrastructure as Code (IaC) para CloudNova S.A.S que despliega un sitio web estático de bienvenida en AWS S3 utilizando Terraform con las siguientes características:

- ✅ Arquitectura modular y reutilizable
- ✅ Despliegue automatizado vía GitHub Actions
- ✅ Backend remoto en S3 con versionado
- ✅ Configuración parametrizada sin hardcoding
- ✅ Gestión de tags estandarizada
- ✅ Bootstrap automático de infraestructura de estado
- ✅ Workflows independientes para deploy y destroy

---

## Arquitectura

### Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────┐
│                      GitHub Repository                       │
│  ┌────────────────┐              ┌────────────────┐         │
│  │  deploy.yml    │              │  destroy.yml   │         │
│  │  (Workflow)    │              │  (Workflow)    │         │
│  └────────┬───────┘              └────────┬───────┘         │
└───────────┼──────────────────────────────┼─────────────────┘
            │                              │
            │ GitHub Actions               │
            ▼                              ▼
┌─────────────────────────────────────────────────────────────┐
│                         AWS Cloud                            │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         S3 Backend Bucket (Estado Terraform)         │  │
│  │  • terraform.tfstate                                 │  │
│  │  • Versionado habilitado                            │  │
│  │  • Cifrado AES-256                                   │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         S3 Website Bucket (Sitio Web Estático)       │  │
│  │  • index.html                                        │  │
│  │  • Static Website Hosting                            │  │
│  │  • Acceso público configurado                        │  │
│  │  • Bucket Policy para GetObject                      │  │
│  └──────────────────────────────────────────────────────┘  │
│                           │                                  │
│                           │ HTTP                             │
│                           ▼                                  │
│                  ┌─────────────────┐                        │
│                  │   Usuarios Web  │                        │
│                  └─────────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

### Flujo de Despliegue

```
Developer Push → GitHub Actions → Bootstrap Backend → Terraform Init →
Terraform Validate → Terraform Plan → Terraform Apply → Deploy Website
```

---

## Requisitos Previos

### Software Necesario

- **Git:** 2.x o superior
- **Cuenta AWS:** Con permisos administrativos
- **Cuenta GitHub:** Para repositorio y Actions

### Permisos AWS Requeridos

El usuario IAM debe tener los siguientes permisos:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:PutBucketPolicy",
        "s3:PutBucketVersioning",
        "s3:PutBucketWebsite",
        "s3:PutPublicAccessBlock",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## Estructura del Proyecto

```
terraform-deploy-aws/
├── .github/
│   └── workflows/
│       ├── deploy.yml              # Pipeline de despliegue
│       └── destroy.yml             # Pipeline de destrucción
│
├── infra/
│   └── modules/
│       └── s3_static_website/      # Módulo de sitio web estático
│           ├── main.tf             # Recursos principales
│           ├── variables.tf        # Variables del módulo
│           └── outputs.tf          # Outputs del módulo
│
├── .gitignore                      # Archivos ignorados por Git
├── backend.tf                      # Configuración de backend remoto
├── main.tf                         # Configuración principal
├── variables.tf                    # Variables globales
├── terraform.tfvars                # Valores de variables
├── outputs.tf                      # Outputs globales
├── index.html                      # Página web estática
└── README.md                       # Este archivo
```

---

## Configuración Inicial

### 1. Clonar el Repositorio

```bash
git clone https://github.com/tu-usuario/terraform-deploy-aws.git
cd terraform-deploy-aws
```

### 2. Configurar Secretos en GitHub

Navega a: `Settings` → `Secrets and variables` → `Actions` → `New repository secret`

Agrega los siguientes secretos:

| Nombre | Descripción | Ejemplo |
|--------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | Access Key ID de AWS | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Secret Access Key de AWS | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |

### 3. Personalizar Variables

Edita `terraform.tfvars`:

```hcl
# AWS Configuration
aws_region = "us-east-1"

# S3 Buckets
bucket_name    = "tu-nombre-web-estatica"
backend_bucket = "tu-nombre-terraform-state"

# Tags
environment = "dev"
owner       = "Tu Nombre"
project     = "Betek"
```

### 4. Personalizar index.html

Modifica el archivo `index.html` con tu información:

```html
<div class="info-item">
    <span class="label">Estudiante:</span>
    <span class="value">Tu Nombre</span>
</div>
```

---

## Despliegue

### Opción 1: Despliegue Automático (Recomendado)

Realiza un push a la rama `main`:

```bash
git add .
git commit -m "Deploy infrastructure"
git push origin main
```

GitHub Actions ejecutará automáticamente el pipeline de despliegue.

### Opción 2: Despliegue Manual

1. Ve a `Actions` en tu repositorio de GitHub
2. Selecciona `Terraform Infrastructure Deploy`
3. Click en `Run workflow`
4. Selecciona la rama `main`
5. Click en `Run workflow`

### Opción 3: Despliegue Local

```bash
# Configurar credenciales AWS
export AWS_ACCESS_KEY_ID="tu-access-key"
export AWS_SECRET_ACCESS_KEY="tu-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Crear bucket de backend manualmente (primera vez)
aws s3api create-bucket \
  --bucket tu-nombre-terraform-state \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket tu-nombre-terraform-state \
  --versioning-configuration Status=Enabled

# Inicializar Terraform
terraform init

# Validar configuración
terraform validate

# Generar plan
terraform plan

# Aplicar cambios
terraform apply
```

### Verificar Despliegue

Después del despliegue exitoso, verás los outputs:

```
Outputs:

website_url = "http://tu-nombre-web-estatica.s3-website-us-east-1.amazonaws.com"
bucket_name = "tu-nombre-web-estatica"
deployment_region = "us-east-1"
```

Accede a la URL del sitio web en tu navegador.

---

## Destrucción de Recursos

### Proceso de Destrucción

1. Ve a `Actions` en GitHub
2. Selecciona `Terraform Infrastructure Destroy`
3. Click en `Run workflow`
4. **Campo 1:** Escribe exactamente `DESTROY` para confirmar
5. **Campo 2:** Selecciona si mantener el bucket de backend:
   - `yes`: Mantiene el bucket con historial de estado
   - `no`: Elimina completamente el bucket de backend
6. Click en `Run workflow`

### Destrucción Local

```bash
# Destruir recursos
terraform destroy

# Opcional: Eliminar bucket de backend
aws s3 rb s3://tu-nombre-terraform-state --force
```

---

## Variables de Configuración

### Variables Globales (variables.tf)

| Variable | Tipo | Descripción | Valor por Defecto | Requerida |
|----------|------|-------------|-------------------|-----------|
| `aws_region` | string | Región de AWS | `us-east-1` | No |
| `bucket_name` | string | Nombre del bucket web | - | Sí |
| `backend_bucket` | string | Nombre del bucket backend | - | Sí |
| `environment` | string | Entorno de despliegue | `dev` | No |
| `owner` | string | Propietario de recursos | `Andres Ortiz` | No |
| `project` | string | Nombre del proyecto | `Betek` | No |
| `index_html_path` | string | Ruta del archivo HTML | `index.html` | No |

### Variables del Módulo S3

| Variable | Tipo | Descripción | Requerida |
|----------|------|-------------|-----------|
| `bucket_name` | string | Nombre del bucket | Sí |
| `index_file_path` | string | Ruta del archivo index.html | Sí |
| `index_file_key` | string | Nombre del archivo en S3 | Sí |
| `common_tags` | map(string) | Tags comunes | No |
| `bucket_tag_name` | string | Tag Name del bucket | No |

---

## Outputs

### Outputs Principales

| Output | Descripción | Ejemplo |
|--------|-------------|---------|
| `website_url` | URL completa del sitio web | `http://bucket.s3-website-us-east-1.amazonaws.com` |
| `website_endpoint` | Endpoint S3 del sitio | `bucket.s3-website-us-east-1.amazonaws.com` |
| `bucket_name` | Nombre del bucket creado | `andres-ortiz-web-estatica` |
| `bucket_arn` | ARN del bucket | `arn:aws:s3:::andres-ortiz-web-estatica` |
| `deployment_region` | Región de despliegue | `us-east-1` |
| `aws_account_id` | ID de cuenta AWS | `123456789012` |
| `environment` | Entorno activo | `dev` |

---

## Módulos

### s3_static_website

Módulo responsable de crear y configurar un bucket S3 para hosting de sitio web estático.

**Componentes:**

- **Bucket S3:** Contenedor principal
- **Ownership Controls:** Desactiva ACLs legacy
- **Public Access Block:** Configura acceso público controlado
- **Website Configuration:** Habilita hosting estático
- **Bucket Policy:** Permite lectura pública de objetos
- **S3 Object:** Archivo index.html

**Características:**

- Configuración completa de static website hosting
- Gestión de acceso público mediante políticas
- Soporte para custom tags
- Detección automática de cambios en archivos (etag)
- Outputs informativos para integración

**Uso:**

```hcl
module "s3_static_website" {
  source = "./infra/modules/s3_static_website"

  bucket_name     = "mi-sitio-web"
  index_file_path = "index.html"
  index_file_key  = "index.html"
  common_tags     = local.common_tags
}
```

---

## CI/CD Pipeline

### Workflow: Deploy

**Trigger:**
- Push a rama `main`
- Pull Request a `main`
- Ejecución manual (workflow_dispatch)

**Pasos:**

1. **Checkout:** Clona el repositorio
2. **AWS Credentials:** Configura autenticación AWS
3. **Bootstrap Backend:** Crea bucket de estado si no existe
4. **Setup Terraform:** Instala Terraform CLI
5. **Init:** Inicializa Terraform y descarga providers
6. **Format Check:** Valida formato del código
7. **Validate:** Valida sintaxis y configuración
8. **Plan:** Genera plan de ejecución
9. **Apply:** Aplica cambios (solo en push a main)
10. **Outputs:** Muestra información del despliegue

**Duración aproximada:** 2-3 minutos

### Workflow: Destroy

**Trigger:**
- Solo ejecución manual con confirmación

**Pasos:**

1. **Validation:** Verifica confirmación "DESTROY"
2. **Checkout:** Clona el repositorio
3. **AWS Credentials:** Configura autenticación
4. **Setup Terraform:** Instala Terraform
5. **Init:** Inicializa Terraform
6. **Destroy Plan:** Genera plan de destrucción
7. **Destroy:** Elimina recursos
8. **Clean Backend:** Elimina bucket backend (opcional)
9. **Summary:** Muestra resumen de destrucción

**Duración aproximada:** 1-2 minutos

---

## Buenas Prácticas Implementadas

### 1. Infrastructure as Code

- ✅ Toda la infraestructura definida como código
- ✅ Versionado en Git
- ✅ Revisiones mediante Pull Requests
- ✅ Historial completo de cambios

### 2. Parametrización

- ✅ Sin hardcoding de valores
- ✅ Variables con validaciones
- ✅ Valores por defecto sensatos
- ✅ Separación de configuración por entorno

### 3. Modularidad

- ✅ Módulos reutilizables
- ✅ Separación de responsabilidades
- ✅ Interfaces claras (inputs/outputs)
- ✅ Facilita testing y mantenimiento

### 4. Estado Remoto

- ✅ Backend en S3
- ✅ Versionado habilitado
- ✅ Cifrado en reposo
- ✅ Acceso público bloqueado

### 5. Seguridad

- ✅ Credenciales en GitHub Secrets
- ✅ Principio de mínimo privilegio
- ✅ Cifrado de datos sensibles
- ✅ Políticas restrictivas

### 6. Tags Estandarizados

- ✅ Tags obligatorios en todos los recursos
- ✅ Tags por defecto en el provider
- ✅ Tags adicionales por recurso
- ✅ Facilita facturación y auditoría

### 7. Automatización

- ✅ CI/CD con GitHub Actions
- ✅ Bootstrap automático de backend
- ✅ Validaciones automáticas
- ✅ Deploy sin intervención manual

### 8. Documentación

- ✅ Código comentado
- ✅ README completo
- ✅ Diagramas de arquitectura
- ✅ Guías de troubleshooting

---

## Troubleshooting

### Error: Bucket ya existe

**Problema:**
```
Error: creating S3 Bucket: BucketAlreadyExists
```

**Solución:**
Los nombres de bucket S3 son globalmente únicos. Cambia el nombre en `terraform.tfvars`:

```hcl
bucket_name = "tu-nombre-unico-web-estatica-12345"
```

### Error: Access Denied

**Problema:**
```
Error: error creating S3 bucket: AccessDenied
```

**Solución:**
Verifica que las credenciales AWS tengan permisos suficientes:

```bash
aws sts get-caller-identity
aws s3 ls  # Debe listar buckets sin error
```

### Error: State Lock

**Problema:**
```
Error: Error locking state: ConditionalCheckFailedException
```

**Solución:**
Otro proceso tiene el estado bloqueado. Espera a que termine o fuerza el unlock:

```bash
terraform force-unlock LOCK_ID
```

### Sitio Web No Carga

**Problema:**
La URL del sitio web retorna 403 o 404

**Solución:**
1. Verifica que el archivo index.html exista en el bucket:
```bash
aws s3 ls s3://tu-bucket-name/
```

2. Verifica la política del bucket:
```bash
aws s3api get-bucket-policy --bucket tu-bucket-name
```

3. Verifica la configuración de website:
```bash
aws s3api get-bucket-website --bucket tu-bucket-name
```

### Error de Formato

**Problema:**
```
Error: Terraform Format Check failed
```

**Solución:**
Formatea el código:

```bash
terraform fmt -recursive
```

### Backend No Inicializa

**Problema:**
```
Error: Failed to get existing workspaces: S3 bucket does not exist
```

**Solución:**
El bucket de backend no existe. El workflow lo crea automáticamente, pero para ejecución local:

```bash
aws s3api create-bucket \
  --bucket tu-backend-bucket \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket tu-backend-bucket \
  --versioning-configuration Status=Enabled
```

---

## Comandos Útiles

### Terraform

```bash
# Inicializar
terraform init

# Validar sintaxis
terraform validate

# Formatear código
terraform fmt -recursive

# Verificar formato
terraform fmt -check

# Generar plan
terraform plan

# Aplicar cambios
terraform apply

# Aplicar sin confirmación
terraform apply -auto-approve

# Destruir recursos
terraform destroy

# Mostrar outputs
terraform output

# Mostrar estado
terraform show

# Listar recursos
terraform state list

# Refrescar estado
terraform refresh
```

### AWS CLI

```bash
# Listar buckets
aws s3 ls

# Ver contenido de bucket
aws s3 ls s3://bucket-name/

# Obtener política de bucket
aws s3api get-bucket-policy --bucket bucket-name

# Ver configuración de website
aws s3api get-bucket-website --bucket bucket-name

# Verificar identidad
aws sts get-caller-identity

# Eliminar bucket y contenido
aws s3 rb s3://bucket-name --force
```

### Git

```bash
# Ver estado
git status

# Agregar cambios
git add .

# Commit
git commit -m "Mensaje"

# Push
git push origin main

# Ver logs
git log --oneline

# Ver diferencias
git diff
```

---

## Ampliaciones Futuras

### Posibles Mejoras

- [ ] Agregar CloudFront CDN para mejor performance
- [ ] Implementar certificados SSL/TLS con ACM
- [ ] Configurar dominio personalizado con Route 53
- [ ] Agregar WAF para protección
- [ ] Implementar logs de acceso en S3
- [ ] Configurar alertas con CloudWatch
- [ ] Agregar módulo IAM para roles específicos
- [ ] Implementar múltiples entornos (dev, staging, prod)
- [ ] Agregar tests automatizados con Terratest
- [ ] Implementar pipeline de DR (Disaster Recovery)

### Módulos Adicionales Sugeridos

```
infra/modules/
├── s3_static_website/     # ✅ Implementado
├── cloudfront/            # CDN
├── route53/               # DNS
├── acm/                   # Certificados SSL
└── waf/                   # Web Application Firewall
```

---

## Contribución

### Proceso

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

### Estándares

- Código formateado con `terraform fmt`
- Variables documentadas
- Commits descriptivos
- Tests cuando sea aplicable

---

## Recursos Adicionales

### Documentación Oficial

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

### Tutoriales Recomendados

- [Terraform AWS Tutorial](https://learn.hashicorp.com/collections/terraform/aws-get-started)
- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [GitHub Actions CI/CD](https://docs.github.com/en/actions/guides/about-continuous-integration)

### Comunidad

- [Terraform Community](https://discuss.hashicorp.com/c/terraform-core/)
- [AWS Forums](https://forums.aws.amazon.com/)
- [Stack Overflow - Terraform Tag](https://stackoverflow.com/questions/tagged/terraform)

---

## Información del Proyecto

### Metadata

- **Proyecto:** CloudNova S.A.S - Despliegue Web Estático
- **Curso:** Betek
- **Estudiante:** Andres Ortiz
- **Tecnologías:** Terraform, AWS S3, GitHub Actions
- **Versión:** 1.0.0
- **Licencia:** MIT

### Contacto

Para preguntas, sugerencias o reportar problemas, por favor abre un issue en el repositorio.

---

## Licencia

MIT License

Copyright (c) 2025 Andres Ortiz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

**Última actualización:** Abril 2025

**Estado del Proyecto:** ✅ Activo y Funcional
