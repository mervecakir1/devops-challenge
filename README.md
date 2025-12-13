# Ziraat DevOps Challenge – Kubernetes Microservice Demo

## 1. Project Overview

This repository contains my solution for the **Ziraat DevOps Challenge**.

The goal of the challenge is to demonstrate that I can:

- Containerize applications using **Docker**
- Automate image builds and pushes using **CI/CD (GitHub Actions)**
- Deploy microservices into a **Kubernetes** cluster
- Expose them to the outside world using **NodePort** services
- Enable **Horizontal Pod Autoscaling (HPA)** based on CPU usage
- Manage the whole setup as **Infrastructure as Code (IaC)** with scripts

The application consists of two components:

- **HelloZiraat API**
  - Simple ASP.NET Web API
  - Returns: `Hello Ziraat Team from Merve`
  - Listens on **port 11130** (as required by the challenge)
- **HelloZiraat Web**
  - Simple ASP.NET Web application
  - Frontend that communicates with the API
  - Listens on **port 52369**

Both components are containerized and deployed as independent services to Kubernetes, following a **microservice-style** architecture.

---
## 2. Architecture

This project follows a simple microservice-style architecture consisting of two independent components running inside a Kubernetes cluster. Each component is packaged as a Docker image and deployed using Kubernetes Deployments, while external access is provided via NodePort Services.

### How the system works

- The **Web application** is exposed to users through a NodePort.  
  It serves the frontend and communicates with the API.
- The **API service** runs as a separate microservice and is also exposed through a NodePort inside the cluster.
- Kubernetes manages the lifecycle of both applications, ensuring automatic restarts and load distribution.
- The API Deployment is configured with **Horizontal Pod Autoscaling (HPA)** so that the system can scale based on CPU load.

### Component Summary

| Component            | Responsibility                                 | Kubernetes Object                 |
|---------------------|-------------------------------------------------|-----------------------------------|
| **HelloZiraat API** | Returns backend message for the challenge       | Deployment + NodePort Service     |
| **HelloZiraat Web** | Frontend UI communicating with the API          | Deployment + NodePort Service     |
| **HPA (API)**       | Automatically scales API pods (1–5 replicas)    | HorizontalPodAutoscaler           |
| **metrics-server**  | Provides CPU metrics required for autoscaling   | Kubernetes Add-on                 |

### High-Level Request Flow

User → Web Service (NodePort) → Web Pod
                     ↓
               API Service (NodePort) → API Pod(s)


### Why this architecture?

- **Scalable:** API pods automatically scale based on CPU usage.  
- **Decoupled:** Web and API operate as separate microservices.  
- **Portable:** All components run as Docker containers.  
- **Resilient:** Kubernetes maintains application health and availability.  
- **Automation-friendly:** Fully compatible with CI/CD and IaC practices.

## 3. Autoscaling (HPA)

In addition to the basic scaling thresholds, the HPA is configured to monitor
the CPU utilization of the `hello-ziraat-api` Deployment. The autoscaler uses
a `Resource` metric of type `Utilization`, meaning it continuously checks the
percentage of CPU usage across all API pods.

Key autoscaling details:
- **Target Deployment:** hello-ziraat-api
- **Metric Type:** CPU (Resource/Utilization)
- **Scaling Behavior:** 
  - If average CPU > 50% → more API pods are created (scale out)
  - If average CPU < 50% → pods are removed gradually (scale in)
- **Minimum Replicas:** 1  
- **Maximum Replicas:** 5  

## 4. Technologies Used

**Programming & Frameworks**
- C# / ASP.NET Core Web API
- ASP.NET Web Application

**Containerization**
- Docker
- Docker Hub Registry

**Orchestration**
- Kubernetes (Docker Desktop Kubernetes)
- Deployments, Services, Horizontal Pod Autoscaler (HPA)

**Monitoring**
- metrics-server (for CPU metrics)

**CI/CD**
- GitHub Actions (automated Docker builds & pushes)

**Infrastructure as Code**
- Kubernetes manifests (YAML)
- PowerShell scripts (deploy/delete/load testing)

## 5. How to Run (Kubernetes Deployment)

This project includes scripts and Kubernetes manifests to easily deploy, test, and remove the entire application from a Kubernetes cluster.

### 5.1 Prerequisites

Before running the project, make sure you have:

- **Docker Desktop** installed and **Kubernetes enabled**
- **kubectl** installed and configured (Docker Desktop sets this automatically)
- **Docker Hub account** (required for pulling images)
- A clone of this repository

Verify your Kubernetes cluster:

```
kubectl get nodes
```

You should see output similar to:
```
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   ...
```
### 5.2 Deploy the Entire Application

All Kubernetes resources (API, Web, HPA) can be deployed using a single PowerShell script.

Navigate to the scripts directory:

```
cd scripts
.\deploy.ps1
```
This script performs the following:

- Deploys the **HelloZiraat API** (Deployment + NodePort Service)
- Deploys the **HelloZiraat Web** (Deployment + NodePort Service)
- Applies the **Horizontal Pod Autoscaler** (HPA) for the API
- Ensures everything starts in the correct order

Verify the deployment:
```
kubectl get pods
kubectl get services
kubectl get hpa
```
Expected results:

- API and Web pods in **Running** state
- Services exposed on NodePort
- HPA resource created and monitoring CPU usage

### 5.3 Access the Application

List exposed services:
```
kubectl get services
```
Expected example output:

```
hello-ziraat-api-service   NodePort   ...   11130:30080/TCP
hello-ziraat-web-service   NodePort   ...   52369:30081/TCP
```
Access the application using:

- Web UI:
http://localhost:30081

- API Endpoint:
http://localhost:30080

### 5.4 Load Testing (Trigger Autoscaling)

To generate CPU load that triggers autoscaling:


```
.\start-load-test.ps1

```
This script:

- Creates a load-generator pod
- Continuously sends requests to the API
- Increases CPU usage, causing the HPA to scale up pods

Monitor behavior:
```
kubectl get hpa -w
kubectl get pods
kubectl top pods
```
When CPU usage exceeds 50%, HPA increases the number of API pods automatically.

### 5.5 Stop Load Testing

To stop generating load:
```
.\stop-load-test.ps1
```

This deletes the load-generator pod.

### 5.6 Tear Down (Remove All Resources)

To delete all Kubernetes resources created by this project:
```
.\delete.ps1
```

This removes:
- API Deployment + Service
- Web Deployment + Service
- HPA
- load-generator pod (if running)

Verify cleanup:
```
kubectl get pods
kubectl get services
kubectl get hpa
```
## 5. CI/CD Pipeline (GitHub Actions)

This project uses **GitHub Actions** to automatically build and publish Docker images for both microservices:  
- **HelloZiraat API**  
- **HelloZiraat Web**

The CI/CD pipeline is triggered whenever a new commit is pushed to the **main** branch.

### 5.1 What the Pipeline Does

The workflow performs the following tasks automatically:

1. **Checks out the repository source code**  
2. **Builds Docker images** for both the API and Web applications  
3. **Logs in to Docker Hub** using repository secrets  
4. **Pushes the images** with the `latest` tag  
5. Makes the images **available for Kubernetes** to pull during deployment  

This fully eliminates the need for manual Docker builds.

---

### 5.2 Required Secrets

The workflow uses two GitHub Actions secrets to authenticate with Docker Hub:

- **DOCKERHUB_USERNAME**  
- **DOCKERHUB_TOKEN**

These can be set from:

GitHub → Repository → Settings → Secrets and Variables → Actions


Your Docker Hub token must have **read/write** permissions.

---

### 5.3 Workflow Trigger

The pipeline runs automatically on:

```
on:
  push:
    branches:
      - "main"
```

You can also trigger it manually from:
GitHub → Actions → devops-challenge → Run workflow

### 5.4 Workflow File Location

The full CI/CD configuration is stored under:
```
.github/workflows/devops-challenge.yml
```

Inside this YAML file, both services are built and published through:

- docker/build-push-action@v6

- docker/login-action@v3

- actions/checkout@v4

### 5.5 Why CI/CD Is Important for This Project?

This challenge explicitly requires automated container builds.

Using GitHub Actions:
- Guarantees clean, reproducible builds
- Ensures Kubernetes always pulls the latest Docker image
- Reduces manual effort and human error
- Demonstrates real-world DevOps practices

## 6. Conclusion

This project demonstrates the complete DevOps workflow required by the **Ziraat DevOps Challenge**, covering containerization, automation, orchestration, and scalability.

Throughout the implementation, I delivered:

### ✔ Containerization
Both the Web and API applications were packaged as lightweight Docker images and published to Docker Hub.

### ✔ CI/CD Automation
A GitHub Actions pipeline was built to automatically:
- Build Docker images
- Push them to Docker Hub
- Keep deployments consistent and reproducible

### ✔ Kubernetes Deployments
Each microservice was deployed as an independent Kubernetes Deployment with its own NodePort Service.

### ✔ Horizontal Pod Autoscaling (HPA)
CPU-based autoscaling dynamically adjusts API replicas between 1 and 5, ensuring the system can handle fluctuating traffic loads.

### ✔ Infrastructure as Code (IaC)
All Kubernetes configurations and automation scripts were stored in the repository, making the infrastructure fully reproducible.

---

### Overall Result

This solution fulfills all of the challenge requirements:

- **Dockerized applications**  
- **Automated builds and registry uploads**  
- **Kubernetes-based microservice deployment**  
- **Externally exposed services**  
- **Autoscaling with HPA**  
- **Infrastructure managed as code**  

The final system is:
- Scalable  
- Maintainable  
- Fully automated  
- Production-realistic  

---

If needed, the system can be extended with:
- Ingress controller  
- Logging & monitoring stack (ELK, Prometheus, Grafana)  
- Canary deployments or blue/green strategies  
- Helm chart packaging  

This challenge was completed using best practices in DevOps, Kubernetes, and CI/CD automation.
