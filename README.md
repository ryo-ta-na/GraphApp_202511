# Temperature History Dashboard

A containerized full-stack web application that displays the **previous 12 months of temperature data** provided by the OpenWeather API using a **React.js frontend**, **Express.js backend**, and **MySQL database**.
The entire stack runs on **Kubernetes** (via Docker Desktop) with portforwarding (both fronend and backend).

---

## Features

- Displays monthly temperature values for the previous 12 months
- REST API served by Express.js
- React.js frontend with dynamic charts
- Persistent MySQL database running locally
- Containerized with Docker
- Kubernetes manifests for:
  - Frontend Deployment + Service (Service not used in this architecture)
  - Backend Deployment + Service (Service not used in this architecture)
  - MySQL Deployment + Persistent Volume

---

## Architecture Overview
```
||: Frontend traffic
|: Backend traffic

Client Web browser
|  ||
|  Portforward (Frontend)
|  ||
Portforward (Backend)
|  ||
-(Kubernetes Cluster)-
|  ||
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
- Backend container directly accessed from the client web borwser

---

## Tech Stack

- **Frontend:** React.js
- **Backend:** Node.js + Express
- **Database:** MySQL (local)
- **Containerization:** Docker
- **Orchestration:** Kubernetes (Docker Desktop)

---

## Screen Shots

(The input of year is currently not used.)
![App Screenshot](docs/Design/screenShots/Temperature_Kyoto_20251119.png)
![App Screenshot](docs/Design/screenShots/Temperature_Dummy_20251119.png)

---

## Notes

- You need your own OpenWeather API key.
- The db-secret.yaml used at the backend is not tracked in this repository, so it need to be created under the k8s directory. The following is the template of db-secret.yaml.
```
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
  namespace: graphapp
type: Opaque
stringData:
  MYSQL_HOST: "host.docker.internal"
  MYSQL_USER: ""
  MYSQL_PASSWORD: ""
  MYSQL_DB: ""
  OPENWEATHER_KEY: ""
  ```