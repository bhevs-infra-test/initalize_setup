module "repo" {
  source      = "../../modules/repository"
  name        = var.repo_name
  description = var.description

  team_permissions = merge(
      var.use_admin ? { "admin" = { id = var.admin_team_id, permission = "maintain" } } : {},
      var.use_dev   ? { "dev"   = { id = var.dev_team_id,   permission = "push" } }     : {},
      var.use_other ? { "other" = { id = var.other_team_id, permission = "push" } }     : {}
  )
}