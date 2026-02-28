data "" "name" {
  
}
module "acrcreation" {
  source = "../modules/acr"
    rg_name = var.rg_name
    acrname = var.acrname
}