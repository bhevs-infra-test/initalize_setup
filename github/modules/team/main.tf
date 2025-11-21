resource "github_team" "this" {
  name        = var.name
  description = "Managed by Terraform"
  privacy     = "closed"
}