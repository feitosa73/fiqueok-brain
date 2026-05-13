variable "admin_password" {
  type      = string
  sensitive = true
}

variable "my_ip" {
  type        = string
  description = "Seu IP atual/32"
}

variable "ts_auth_key" {
  type      = string
  sensitive = true
}

variable "location" {
  default = "denmarkeast"
}

variable "rg_name" {
  default = "RG-COM-CAS-013"
}