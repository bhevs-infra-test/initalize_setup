module "repo" {
  source      = "../../modules/repository"
  name        = var.repo_name
  description = var.description

  team_permissions = merge(
    var.admin_team_id != "" ? { "admin" = { id = var.admin_team_id, permission = "maintain" } } : {},
    var.dev_team_id   != "" ? { "dev"   = { id = var.dev_team_id,   permission = "push" } }     : {},
    var.other_team_id != "" ? { "other" = { id = var.other_team_id, permission = "push" } }     : {}
  )
}