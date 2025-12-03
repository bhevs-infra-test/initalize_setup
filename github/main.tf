# ==================================================================
# 0. [Security] Organization 보안 정책 (Policies)
# ==================================================================
resource "github_organization_settings" "org_security" {
  # [프로필 및 연락처]
  billing_email      = "evsinfo@bhevs.co.kr"
  company            = "BH EVS"
  blog               = "https://www.bhevs.co.kr/"
  email              = "tech@bhevs.co.kr"
  location           = "서울 강서구 마곡중앙8로3길 35 (07793)"
  name               = "BH EVS"
  description        = "BH EVS Code and Version Management."

  # [프로젝트 관리 기능]
  has_organization_projects     = false
  has_repository_projects       = false

  # [권한 및 생성 통제 (거버넌스)]
  default_repository_permission               = "none"
  members_can_create_repositories             = false
  members_can_create_public_repositories      = false
  members_can_create_private_repositories     = false
  # members_can_create_internal_repositories    = false
  members_can_create_pages                    = false
  members_can_create_public_pages             = false
  # members_can_create_private_pages            = false

  # [데이터 유출 방지]
  members_can_fork_private_repositories    = false
  web_commit_signoff_required              = true

  # [보안 자동화 (GHAS & Dependabot)]
  # advanced_security_enabled_for_new_repositories                  = false
  dependabot_alerts_enabled_for_new_repositories                  = true
  dependabot_security_updates_enabled_for_new_repositories        = true
  dependency_graph_enabled_for_new_repositories                   = true
  # secret_scanning_enabled_for_new_repositories                    = true
  # secret_scanning_push_protection_enabled_for_new_repositories    = true

  lifecycle {
    prevent_destroy = true
  }
}

# ==================================================================
# 1. [Ruleset] 조직 전체 브랜치 보호 규칙(Only Enterprise Plan)
# ==================================================================
# resource "github_organization_ruleset" "global_protection" {
#   name        = "Global Main Branch Protection"
#   target      = "branch"
#   enforcement = "active"
#
#   # 모든 레포지토리의 main, master 브랜치에 자동 적용
#   conditions {
#     ref_name {
#       include = ["refs/heads/main", "refs/heads/master"]
#       exclude = []
#     }
#     repository_name {
#       include = ["~ALL"]
#       exclude = []
#     }
#   }
#
#   rules {
#     # [Merge 조건] PR 필수, 승인 1명 이상 필요
#     pull_request {
#       required_approving_review_count = 1
#       dismiss_stale_reviews_on_push   = true
#     }
#
#     # [보안] 이력 조작(Force Push) 및 브랜치 삭제 차단
#     non_fast_forward = true
#     deletion         = true
#
#     # [CI/CD] 상태 체크 (Jenkins 연동 완료 시 주석 해제)
#     # required_status_checks {
#     #   required_check {
#     #     context = "continuous-integration/jenkins/pr-merge"
#     #   }
#     # }
#   }
# }

# ==================================================================
# 2. [Teams] 프로젝트별 팀 생성
# ==================================================================
module "project_teams" {
  source = "./blueprints/project_team"
  for_each = { for p in var.projects : p.name => p }
  project_name = each.key
}

# ==================================================================
# 3. [Repos] 레포지토리 생성 (템플릿 & 태그 적용)
# ==================================================================
locals {
  all_repos = flatten([
    for proj in var.projects : [
      for repo in proj.repo_list : {
        key          = "${proj.name}_${repo.name}"
        project_name = proj.name
        repo_name    = "${proj.name}_${repo.name}"

        use_admin = repo.admin_team != null
        use_dev   = repo.dev_team   != null
        use_other = repo.other_team != null

        topics = [
          replace(lower(proj.name), "/[^a-z0-9-]/", "-"),
          replace(lower(repo.name), "/[^a-z0-9-]/", "-")
        ]
      }
    ]
  ])

  teams_with_super = {
    for team, members in var.teams :
    team => concat(var.super_users, members)
  }

  project_member_map = {
    for proj in var.projects :
    proj.name => {
      admins = flatten([for repo in proj.repo_list : repo.admin_team != null ? local.teams_with_super[repo.admin_team] : []])
      devs   = flatten([for repo in proj.repo_list : repo.dev_team   != null ? local.teams_with_super[repo.dev_team]   : []])
      others = flatten([for repo in proj.repo_list : repo.other_team != null ? local.teams_with_super[repo.other_team] : []])
    }
  }
}

module "repos" {
  source = "./blueprints/repo_attachment"

  for_each = { for item in local.all_repos : item.key => item }

  repo_name = each.value.repo_name
  template_repo_name = var.template_repo_name
  org_name           = var.github_org
  repo_topics        = each.value.topics

  # 팀 연결 로직
  admin_team_id = each.value.use_admin ? module.project_teams[each.value.project_name].admin_id : ""
  dev_team_id   = each.value.use_dev   ? module.project_teams[each.value.project_name].dev_id   : ""
  other_team_id = each.value.use_other ? module.project_teams[each.value.project_name].other_id : ""

  use_admin = each.value.use_admin
  use_dev   = each.value.use_dev
  use_other = each.value.use_other
}

# ==================================================================
# 4. [Users] 멤버 할당
# ==================================================================
module "users" {
  source = "./blueprints/user_attachment"
  for_each = local.project_member_map

  admins         = each.value.admins
  devs           = each.value.devs
  others         = each.value.others
  admin_team_id  = module.project_teams[each.key].admin_id
  dev_team_id    = module.project_teams[each.key].dev_id
  other_team_id  = module.project_teams[each.key].other_id
}
