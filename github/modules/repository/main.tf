resource "github_repository" "this" {
  name        = var.name
  description = var.description
  visibility  = "private"

  auto_init   = var.template_repo_name != "" ? false : true
  topics      = var.topics

  web_commit_signoff_required = true

  dynamic "template" {
    for_each = var.template_repo_name != "" ? [1] : []
    content {
      owner                = var.org_name
      repository           = var.template_repo_name
      include_all_branches = false
    }
  }
}

resource "github_team_repository" "access" {
  for_each   = var.team_permissions
  team_id    = each.value.id
  permission = each.value.permission
  repository = github_repository.this.name
}