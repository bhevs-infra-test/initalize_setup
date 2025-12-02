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
    repo_list = list(object({
      name       = string
      admin_team = optional(string)
      dev_team   = optional(string)
      other_team = optional(string)
    }))
  }))
}