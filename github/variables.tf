variable "github_token" {
  description = "GitHub PAT Token"
  type        = string
  sensitive   = true
}

variable "github_org" {
  description = "Organization Name"
  type        = string
}

variable "projects" {
  description = "프로젝트 및 레포지토리 구성 리스트"
  type = list(object({
    name = string
    version = string
    repo_list = list(object({
      name       = string
      admin_team = optional(string)
      dev_team   = optional(string)
      other_team = optional(string)
    }))
  }))
}

variable "template_repo_name" {
  description = "템플릿 레포지토리 이름"
  type        = string
  default     = "project-repository-templates"
}

variable "teams" {
  description = "팀명과 멤버를 한 번에 관리하는 변수"
  type        = map(list(string))
}

variable "super_users" {
  description = "모든 팀에 공통으로 포함될 계정 리스트"
  type        = list(string)
}
