#!/bin/bash
docker build -t graphapp-backend-image:local ./backend
docker build -t graphapp-frontend-image:local ./frontend
