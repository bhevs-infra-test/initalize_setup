module "add_admins" {
  source  = "../../modules/membership"
  team_id = var.admin_team_id
  members = var.admins
}
module "add_devs" {
  source  = "../../modules/membership"
  team_id = var.dev_team_id
  members = var.devs
}
module "add_others" {
  source  = "../../modules/membership"
  team_id = var.other_team_id
  members = var.others
}