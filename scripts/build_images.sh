#!/bin/bash
docker build -t graphapp-ingress-backend-image:local ./backend
docker build -t graphapp-ingress-frontend-image:local ./frontend
# docker build \
#   --build-arg REACT_APP_API_BASE="http://graphapp-alb-191959315.ap-northeast-1.elb.amazonaws.com" \
#   -t graphapp-ingress-frontend-image:local ./frontend