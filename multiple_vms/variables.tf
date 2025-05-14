# variables.tf
# Variables para configuración de Azure
variable "subscription_id" {
  description = "ID de suscripción de Azure"
  type        = string
}

variable "client_id" {
  description = "ID de cliente para autenticación"
  type        = string
}

variable "client_secret" {
  description = "Secreto de cliente para autenticación"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "ID de inquilino de Azure"
  type        = string
}

variable "region" {
  type        = string
  description = "region de despliegue"
}

variable "prefix_name" {
  type        = string
  description = "prefijo para nombres de recursos"
}

variable "user" {
  type        = string
  description = "usuario ssh"
}

variable "password" {
  type        = string
  description = "password ssh"
}

variable "servers" {
  type        = set(string)
  description = "nombre de los servidores que se van a desplegar"
}
variable "webhook_handler_url" {
  type        = string
  description = "Webhook handler URL"
  default     = "jenkins-machine"
}