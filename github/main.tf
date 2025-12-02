# ==================================================================
# 0. [Security] Organization 보안 정책
# ==================================================================
resource "github_organization_settings" "org_security" {
  billing_email = "choiseu@bhevs.co.kr"
  default_repository_permission = "none"

  members_can_create_repositories         = false
  members_can_create_public_repositories  = false
  members_can_create_private_repositories = false
  members_can_create_pages                = false
  lifecycle {
    prevent_destroy = true
  }
}

# ==================================================================
# 1. [Teams] 프로젝트별 표준 팀 생성 (Admins, Devs, Others)
# ==================================================================
module "project_teams" {
  source = "./blueprints/project_team"

  for_each = { for p in var.projects : p.name => p }

  project_name = each.key
}

# ==================================================================
# 2. [Repos] 레포지토리 생성 및 팀 연결 (Flatten 사용)
# ==================================================================
locals {
  all_repos = flatten([
    for proj in var.projects : [
      for repo in proj.repo_list : {
        key          = "${proj.name}-${repo.name}"
        project_name = proj.name
        repo_name    = "${proj.name}-${repo.name}"

        use_admin = repo.admin_team != null
        use_dev   = repo.dev_team   != null
        use_other = repo.other_team != null
      }
    ]
  ])
}

module "repos" {
  source = "./blueprints/repo_attachment"

  for_each = { for item in local.all_repos : item.key => item }

  repo_name = each.value.repo_name

  # 표준 팀 ID 연결
  admin_team_id = each.value.use_admin ? module.project_teams[each.value.project_name].admin_id : ""
  dev_team_id   = each.value.use_dev   ? module.project_teams[each.value.project_name].dev_id   : ""
  other_team_id = each.value.use_other ? module.project_teams[each.value.project_name].other_id : ""
}

# ==================================================================
# 3. [Users] 멤버 할당
# ==================================================================
locals {
  project_member_map = {
    "MB_GEN4.0"   = { admins = local.mb_admins, devs = local.mb_devs, others = local.mb_others }
    "FORD_GEN4.0" = { admins = local.ford_admins, devs = local.ford_devs, others = local.ford_others }
  }
}

module "users" {
  source = "./blueprints/user_attachment"

  for_each = local.project_member_map

  admin_team_id = module.project_teams[each.key].admin_id
  dev_team_id   = module.project_teams[each.key].dev_id
  other_team_id = module.project_teams[each.key].other_id

  admins = each.value.admins
  devs   = each.value.devs
  others = each.value.others
}