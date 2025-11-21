# ==================================================================
# 1. [Base] 팀 생성
# ==================================================================

module "mb_teams" {
  source       = "./blueprints/project_team"
  project_name = "MB_GEN4.0"
}

module "ford_teams" {
  source       = "./blueprints/project_team"
  project_name = "FORD_GEN4.0"
}

# ==================================================================
# 2. [Repos] 리포지토리 생성 (팀 ID와 연결)
# ==================================================================

# MB 프로젝트 레포들
module "mb_repos" {
  source   = "./blueprints/repo_attachment"
  for_each = toset(["firmware", "bsp", "application", "tools"])

  repo_name = "MB_GEN4.0-${each.value}"

  admin_team_id = module.mb_teams.admin_id
  dev_team_id   = module.mb_teams.dev_id
  other_team_id = module.mb_teams.other_id
}

# FORD 프로젝트 레포들
module "ford_repos" {
  source   = "./blueprints/repo_attachment"
  for_each = toset(["infotainment", "adas", "gateway"])

  repo_name = "FORD_GEN4.0-${each.value}"

  admin_team_id = module.ford_teams.admin_id
  dev_team_id   = module.ford_teams.dev_id
  other_team_id = module.ford_teams.other_id
}

# ==================================================================
# 3. [Users] 멤버십 연결
# ==================================================================

module "mb_users" {
  source = "./blueprints/user_attachment"

  admin_team_id = module.mb_teams.admin_id
  dev_team_id   = module.mb_teams.dev_id
  other_team_id = module.mb_teams.other_id

  admins = local.mb_admins
  devs   = local.mb_devs
  others = local.mb_others
}

module "ford_users" {
  source = "./blueprints/user_attachment"

  admin_team_id = module.ford_teams.admin_id
  dev_team_id   = module.ford_teams.dev_id
  other_team_id = module.ford_teams.other_id

  admins = local.ford_admins
  devs   = local.ford_devs
  others = local.ford_others
}