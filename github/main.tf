# ==================================================================
# 0. [Security] Organization 보안 정책 (Policies)
# ==================================================================
resource "github_organization_settings" "org_security" {
  billing_email = "choiseu@bhevs.co.kr"

  # [보안] Private 레포지토리의 기본 권한 제거 (팀을 통해서만 접근 가능)
  default_repository_permission = "none"

  # [보안] 멤버의 무분별한 레포 생성 및 Public 전환 차단
  members_can_create_repositories         = false
  members_can_create_public_repositories  = false
  members_can_create_private_repositories = false
  members_can_create_pages                = false

  # [보안] 조직 내 코드 유출 방지를 위해 Forking 차단
  members_can_fork_private_repositories   = false

  # [보안] 2FA 강제 (전사 공지 후 true로 변경 권장)
  # has_organization_projects = true
  # has_repository_projects   = true

  # [안전] 실수로 인한 설정 삭제 방지 (운영 필수 설정)
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
        key          = "${proj.name}-${repo.name}"
        project_name = proj.name
        repo_name    = "${proj.name}-${repo.name}"

        use_admin = repo.admin_team != null
        use_dev   = repo.dev_team   != null
        use_other = repo.other_team != null

        topics    = ["firmware", "automotive", lower(proj.name), lower(repo.name)]
      }
    ]
  ])
}

module "repos" {
  source = "./blueprints/repo_attachment"

  for_each = { for item in local.all_repos : item.key => item }

  repo_name = each.value.repo_name

  # [핵심] UI에서 직접 만드실 템플릿 레포지토리 이름 지정
  template_repo_name = "project-repository-templates"
  org_name           = var.github_org

  # 태그(Topics) 전달
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