# TaskFlow — DevOps Portfolio Project

A production-grade .NET Core MVC application deployed with a full DevOps stack.

## Architecture
```
GitHub Actions CI/CD
       │
       ▼
Docker Build & Push (DockerHub)
       │
       ▼
AWS EC2 (Ubuntu) via Terraform
       │
       ▼
Docker Compose
├── TaskFlow App (.NET Core MVC)
├── Prometheus (Metrics Scraping)
└── Grafana (Monitoring Dashboard)
```

## Tech Stack

| Layer | Technology |
|---|---|
| Application | .NET 9 Core MVC |
| Containerization | Docker |
| Orchestration | Kubernetes (K8s) |
| Infrastructure | Terraform (AWS) |
| CI/CD | GitHub Actions |
| Monitoring | Prometheus + Grafana |
| Cloud | AWS EC2, VPC, S3 |
| OS | Ubuntu 22.04 |

## Features

- Task management with Create, Complete, Delete
- Health check endpoint `/health` for Kubernetes probes
- Prometheus metrics endpoint `/metrics`
- Real-time Grafana dashboard with 7 panels
- Horizontal Pod Autoscaler (2-5 replicas)
- Multi-stage Docker build for optimized image size

## Grafana Dashboard Panels

- Requests by Route (time series)
- Request Rate per second
- Active Requests (live)
- Average Response Time
- Memory Usage (MB)
- CPU Usage %
- Total Requests (stat)

## Project Structure
```
taskflow/
├── src/
│   └── TaskFlow.Web/        # .NET Core MVC App
│       ├── Controllers/
│       ├── Models/
│       └── Views/
├── Dockerfile
├── docker-compose.yml
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── hpa.yaml
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── monitoring/
│   └── prometheus.yml
└── .github/
    └── workflows/
        └── deploy.yml
```

## Running Locally

### Prerequisites
- Docker Desktop
- WSL2 (Ubuntu)
- .NET 9 SDK

### Run with Docker Compose
```bash
git clone https://github.com/YOUR_USERNAME/taskflow-devops.git
cd taskflow-devops
docker compose up -d --build
```

| Service | URL |
|---|---|
| TaskFlow App | http://localhost:8090 |
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 |

Grafana login: `admin / admin123`

## Infrastructure (Terraform)
```bash
cd terraform
aws configure
terraform init
terraform plan
terraform apply
```

## CI/CD Pipeline

On every push to `main`:
1. Build & test .NET app
2. Build Docker image
3. Push to DockerHub
4. Deploy to AWS EC2 via SSH

## Monitoring

Prometheus scrapes `/metrics` every 15 seconds.
Grafana dashboards show real-time request rate, memory, CPU, and response times.
