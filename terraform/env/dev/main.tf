module "dataapp-aks" {
  source                = "../../modules/aks/"
  env                   = var.env
  rg_name               = var.rg_name
  rg_location           = var.rg_location
  vnet_address_space    = var.vnet_address_space
  subnet_address_prefix = var.subnet_address_prefix
  service_cidr          = var.service_cidr
  dns_service_ip        = var.dns_service_ip
  node_count            = var.node_count
  vm_size               = var.vm_size
  acrname               = var.acrname
}