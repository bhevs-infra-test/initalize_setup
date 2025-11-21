module "admin_team" {
  source = "../../modules/team"
  name   = "${var.project_name}-Admins"
}
module "dev_team" {
  source = "../../modules/team"
  name   = "${var.project_name}-Devs"
}
module "other_team" {
  source = "../../modules/team"
  name   = "${var.project_name}-Others"
}