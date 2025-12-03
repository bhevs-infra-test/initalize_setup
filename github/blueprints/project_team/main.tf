module "admin_team" {
  source = "../../modules/team"
  name   = length(trim(var.project_version, " ")) > 0 ? "${var.project_name}_${var.project_version}_admins" : "${var.project_name}_admins"
}
module "dev_team" {
  source = "../../modules/team"
  name   = length(trim(var.project_version, " ")) > 0 ? "${var.project_name}_${var.project_version}_devs" : "${var.project_name}_devs"
}
module "other_team" {
  source = "../../modules/team"
  name   = length(trim(var.project_version, " ")) > 0 ? "${var.project_name}_${var.project_version}_others" : "${var.project_name}_others"
}