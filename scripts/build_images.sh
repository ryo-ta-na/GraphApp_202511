#!/bin/bash
docker build -t graphapp-ingress-backend-image:local ./backend
docker build -t graphapp-ingress-frontend-image:local ./frontend
