variable "grupo" {
  description = "Número o identificador del grupo"
  type        = string
  default     = "g2" # Número del grupo
}

variable "ami_id" {
  description = "ID de la AMI de Ubuntu 22.04 LTS en la región us-east-1"
  type        = string
  default     = "ami-080e1f13689e07408" # AMI estándar de Ubuntu 22.04 en us-east-1 (Learner Lab)
}

variable "tipo_manager" {
  description = "Tipo de instancia para el nodo Manager"
  type        = string
  default     = "t3.medium"
}

variable "tipo_worker" {
  description = "Tipo de instancia para los nodos Worker"
  type        = string
  default     = "t3.small"
}