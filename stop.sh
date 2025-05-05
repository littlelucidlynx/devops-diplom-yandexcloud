#!/bin/sh

cd 02_infrastructure
terraform destroy -auto-approve

cd ../01_bucket
terraform destroy -auto-approve