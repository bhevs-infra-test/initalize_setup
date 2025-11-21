#!/bin/bash
set -e

terraform init
terraform validate
terraform plan -out=planfile

if [ $? -ne 0 ]; then
  echo "Error: Terraform plan failed."
  exit 1
fi

terraform apply -auto-approve planfile

echo "생성되었습니다."