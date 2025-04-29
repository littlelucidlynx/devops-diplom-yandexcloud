#!/bin/sh

cd 01_bucket
terraform init
terraform apply -auto-approve

cd ../02_infrastructure
terraform init -backend-config=backend.auto.tfvars -reconfigure
terraform apply -auto-approve