#!/bin/sh

cd 01_bucket
terraform init
terraform apply -auto-approve

cd ../02_infrastructure
terraform init -backend-config=backend.auto.tfvars -reconfigure
terraform apply -auto-approve

kubectl create namespace myproject

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && \
helm repo update && \
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace=myproject

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && \
helm repo update && \
helm install prometheus prometheus-community/kube-prometheus-stack --namespace=myproject

cd ../03_app
kubectl apply -f deploy.yml
kubectl apply -f ingress.yml
kubectl apply -f sa_for_github.yml

kubectl --namespace myproject get secrets prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo