# Temperature History Dashboard

A containerized full-stack web application that displays the **previous 12 months of temperature data** using a **React.js frontend**, **Express.js backend**, and **MySQL database**.
The entire stack runs on **Kubernetes** (via Docker Desktop) with **Ingress** routing.

---

## Features

- Displays monthly temperature values for the previous 12 months
- REST API served by Express.js
- React.js frontend with dynamic charts
- Persistent MySQL database running locally
- Fully containerized with Docker
- Kubernetes manifests for:
  - Frontend Deployment + Service
  - Backend Deployment + Service
  - MySQL Deployment + Persistent Volume
  - Ingress routing

---

## Architecture Overview
```
Client Web browser
|
Portforward (Ingress)
|
-(Kubernetes Cluster)-
|
Ingress controller
|  |
|  React App container (Frontend)
|
Express container (Backend)
|  |
-(Kubernetes Cluster)-
|  |
|  OpenWeather API
|
MySQL (Local Mac)
```
- React and Express run in separate containers
- MySQL runs directly on macOS (not containerized)
- Kubernetes handles routing & load balancing

---

## Tech Stack

- **Frontend:** React.js
- **Backend:** Node.js + Express
- **Database:** MySQL (local)
- **Containerization:** Docker
- **Orchestration:** Kubernetes (Docker Desktop)
- **Ingress:** NGINX ingress controller

---

## Screen Shots

(The input of year is currently not used.)
![App Screenshot](docs/Design/screenShots/Temperature_Kyoto_20251119.png)
![App Screenshot](docs/Design/screenShots/Temperature_Dummy_20251119.png)