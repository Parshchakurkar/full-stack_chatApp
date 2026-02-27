module "acrcreation" {
  source = "../modules/acr"
    rg-name = var.rg-name
    acrname = var.acrname

}