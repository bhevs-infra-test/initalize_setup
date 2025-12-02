#!/bin/bash
set -e

terraform init

echo "==== [0] validate ===="
terraform validate

echo "==== [1/2] 팀(plan) ===="
terraform plan -target=module.project_teams -out=planfile.teams
if [ $? -ne 0 ]; then
  echo "Error: Terraform plan (teams) failed."
  exit 1
fi

echo "==== [1/2] 팀(apply) ===="
terraform apply -auto-approve planfile.teams

echo "==== [2/2] 나머지(plan) ===="
terraform plan -out=planfile.rest
if [ $? -ne 0 ]; then
  echo "Error: Terraform plan (rest) failed."
  exit 1
fi

echo "==== [2/2] 나머지(apply) ===="
terraform apply -auto-approve planfile.rest

echo "모든 리소스가 정상적으로 생성되었습니다."
