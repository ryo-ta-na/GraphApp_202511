#!/bin/bash
kubectl apply -f ./k8s/namespace.yaml
kubectl apply -f ./k8s/db-secret.yaml
kubectl apply -f ./k8s/deployment-backend.yaml
kubectl apply -f ./k8s/deployment-frontend.yaml
kubectl apply -f ./k8s/hpa.yaml
kubectl apply -f ./k8s/ingress.yaml