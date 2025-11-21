resource "github_team_membership" "this" {
  for_each = toset(var.members)
  team_id  = var.team_id
  username = each.value
  role     = "member"
}