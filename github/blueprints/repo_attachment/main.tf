module "repo" {
  source      = "../../modules/repository"
  name        = var.repo_name
  description = "Managed by Terraform"

  team_permissions = {
    "admin_group" = {
      id         = var.admin_team_id
      permission = "maintain"
    }
    "dev_group" = {
      id         = var.dev_team_id
      permission = "push"
    }
    "other_group" = {
      id         = var.other_team_id
      permission = "push"
    }
  }
}