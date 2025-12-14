# Ziraat DevOps Challenge – Kubernetes Microservice Demo

## 1. Project Overview

This repository contains my solution for the **Ziraat DevOps Challenge**.

The goal of the challenge is to demonstrate that I can:

- Containerize applications using **Docker**
- Automate image builds and pushes using **CI/CD (Jenkins Pipeline)**
- Deploy microservices into a **Kubernetes** cluster
- Expose them to the outside world using **NodePort** services
- Enable **Horizontal Pod Autoscaling (HPA)** based on CPU usage
- Manage the whole setup as **Infrastructure as Code (IaC)** with scripts

The application consists of two components:

- **HelloZiraat API**
  - Simple ASP.NET Web API
  - Returns: `Hello Ziraat Team from Merve`
  - Listens on **port 11130** 
- **HelloZiraat Web**
  - Simple ASP.NET Web application
  - Communicates with the API
  - Listens on **port 52369**

Both components are containerized and deployed as independent services to Kubernetes, following a **microservice-style** architecture.

---
## 2. Architecture

This project follows a simple microservice-style architecture consisting of two independent components running inside a Kubernetes cluster. 

Each component is packaged as a Docker image and deployed using Kubernetes Deployments, while external access is provided via NodePort Services.

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
  - If average CPU > 20% → more API pods are created (scale out)
  - If average CPU < 20% → pods are removed gradually (scale in)
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
- Checkout source code
- Build & Push API image → Docker Hub
- Build & Push Web image → Docker Hub
- Deploy Kubernetes manifests `(kubectl apply -f k8s/)`
- Rollout status checks
- Failure handling with rollback


**Infrastructure as Code**
- Kubernetes manifests (YAML) under `k8s/`
  `api-deployment.yaml`
  `api-service.yaml`
  `api-hpa.yaml`
  `web-deployment.yaml`
  `web-service.yaml`
- Bonus operational script: `scripts/cluster-status.sh`

## 5. How to Run (Kubernetes Deployment)

This project includes scripts and Kubernetes manifests to easily deploy, test, and remove the entire application from a Kubernetes cluster.

### 5.1 Prerequisites

Before running the project, make sure you have:

- **Docker Desktop** installed and **Kubernetes enabled**
- **kubectl** installed and configured (Docker Desktop sets this automatically)
- Jenkins running
- Docker Hub credentials configured in Jenkins

Verify your Kubernetes cluster:

```
kubectl get nodes
```

You should see output similar to:
```
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   ...
```
### 5.2 Run Deployment via Jenkins
The deployment is performed by Jenkins using the **Jenkinsfile**.

**What Jenkins does automatically:**

- Clones repository
- Builds Docker images for API & Web
- Pushes images to Docker Hub
- Applies Kubernetes manifests in k8s/
- Waits for rollout completion
- Rolls back on failure

All Kubernetes resources (API, Web, HPA) can be deployed using a single PowerShell script.

### 5.3 Access the Application

List services:
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

To trigger HPA quickly, send continuous requests to the API NodePort.


```
1..20 | ForEach-Object { Start-Job { while ($true) { try { iwr http://localhost:30080 -UseBasicParsing | Out-Null } catch {} } } }

```
Monitor scaling:
```
kubectl get hpa -w
kubectl get pods
kubectl top pods

```
Expected behavior:

- CPU increases
- HPA increases API replicas from 1 → up to 5
- New API pods appear and become Running

To stop the test, remove jobs:
```
Get-Job | Stop-Job
Get-Job | Remove-Job
```

### 5.5 Cluster Status
This project includes a bonus script to list cluster resources.
It prints:

- Pods
- Services
- HPA


## 6. Conclusion

This project demonstrates the complete DevOps workflow required by the **Ziraat DevOps Challenge**, covering containerization, automation, orchestration, and scalability.

**Delivered Outcomes**

- Dockerized API & Web applications
- Jenkins pipeline for automated build, push, and deployment
- Kubernetes Deployments + NodePort Services
- HPA-based autoscaling for API
- Infrastructure fully defined as code (YAML)
- Bonus script to inspect cluster state

**Overall Result**

The final system is:

- Scalable
- Resilient
- Automated
- Maintainable
- Production-realistic
