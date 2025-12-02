variable "name" {
  type = string
}
variable "description" {
  type = string
}
variable "team_permissions" {
  type = map(object({
    id         = string
    permission = string
  }))
}

variable "topics" {
  description = "List of topics for the repository"
  type        = list(string)
  default     = []
}

variable "template_repo_name" {
  description = "Name of the template repository to use"
  type        = string
  default     = ""
}

variable "org_name" {
  description = "Organization name owning the template repository"
  type        = string
  default     = ""
}