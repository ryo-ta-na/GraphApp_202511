#!/bin/bash
kubectl delete namespace graphapp
docker rmi graphapp-ingress-backend-image:local
docker rmi graphapp-ingress-frontend-image:local
