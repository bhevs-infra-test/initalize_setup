#!/bin/bash
set -e

terraform init

echo "==== [0] validate ===="
terraform validate

echo "==== [1/2] 레포/유저 등 삭제 ===="
terraform destroy -auto-approve -target=module.repos -target=module.users

echo "==== [2/2] 팀 삭제 ===="
terraform destroy -auto-approve -target=module.project_teams

echo "모든 리소스가 정상적으로 삭제되었습니다."
