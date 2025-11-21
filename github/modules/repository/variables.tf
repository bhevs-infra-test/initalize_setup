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