# 팀 ID
variable "admin_team_id" { type = string }
variable "dev_team_id"   { type = string }
variable "other_team_id" { type = string }

# 멤버 명단
variable "admins" { type = list(string) }
variable "devs"   { type = list(string) }
variable "others" { type = list(string) }