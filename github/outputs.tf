output "all_repos" {
  value = [for repo in local.all_repos : {
    key        = repo.key
    repo_name  = repo.repo_name
    topics     = repo.topics
    admin_team = repo.use_admin
    dev_team   = repo.use_dev
    other_team = repo.use_other
  }]
}

output "all_teams" {
  value = keys(var.teams)
}

output "all_team_members" {
  value = var.teams
}

output "project_member_map" {
  value = local.project_member_map
}

output "debug_topics" {
  value = [for repo in local.all_repos : {
    key    = repo.key
    topics = repo.topics
  }]
}