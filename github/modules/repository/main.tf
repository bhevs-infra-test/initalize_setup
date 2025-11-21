resource "github_repository" "this" {
  name        = var.name
  description = var.description
  visibility  = "private"
  auto_init   = true
}

resource "github_team_repository" "access" {
  for_each   = var.team_permissions

  team_id    = each.value.id
  permission = each.value.permission

  repository = github_repository.this.name
}