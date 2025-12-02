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