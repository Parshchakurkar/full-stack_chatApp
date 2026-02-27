variable "env" {
  description = "provide environment name"
}
variable "rg-name" {
  description = "resource group name for chat app resources"
}

variable "rg-location" {
  description = "Resources location"
}

variable "vnet_address_space" {
  description = "Virtual network address space"
  type        = list(string)
}
variable "subnet_address_prefix" {
  description = "Virtual network subnet address prefix"
  type        = list(string)
}
variable "service_cidr" {
  description = "Kubernetes service CIDR"
  type        = string
}
variable "dns_service_ip" {
  description = "Kubernetes DNS service IP"
  type        = string
}
variable "node_count" {
  description = "Node count"
  default     = 2
}
variable "vm_size" {
  description = "vm size for the node"
}
variable "acrname" {
  description = "name of the container registry"
}
