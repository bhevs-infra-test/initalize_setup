variable "repo_name" {
  type = string
}

variable "description" {
  type    = string
  default = "Managed by Terraform"
}

variable "admin_team_id" {
  type    = string
  default = ""
}

variable "dev_team_id" {
  type    = string
  default = ""
}

variable "other_team_id" {
  type    = string
  default = ""
}

variable "use_admin" {
  type    = bool
  default = false
}

variable "use_dev" {
  type    = bool
  default = false
}

variable "use_other" {
  type    = bool
  default = false
}

variable "template_repo_name" {
  type    = string
  default = null
}

variable "org_name" {
  type    = string
  default = ""
}

variable "repo_topics" {
  type    = list(string)
  default = []
}