variable "repo_name" {
    description = "Nombre del repositorio de GitHub"
    type        = string
}
variable "webhook_url" {
    description = "URL del webhook handler"
    type        = string
}
variable "content_type" {
    description = "Tipo de contenido del repositorio de GitHub"
    type        = string
    default = "json"
}