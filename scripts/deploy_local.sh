#!/bin/bash
kubectl apply -f ./k8s/namespace.yaml
kubectl apply -f ./k8s/db-secret.yaml
kubectl apply -f ./k8s/backend-deployment.yaml
kubectl apply -f ./k8s/frontend-deployment.yaml
kubectl apply -f ./k8s/hpa.yaml