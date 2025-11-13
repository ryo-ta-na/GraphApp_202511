#!/bin/bash
kubectl delete namespace graphapp
docker rmi graphapp-backend:local
docker rmi graphapp-frontend:local
