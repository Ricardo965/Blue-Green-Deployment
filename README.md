# Blue-Green Deployment with Spring Boot on AWS EKS

## 📌 Overview

This repository contains a **Spring Boot banking application** that I deploy using a **Blue-Green deployment strategy** on a **Kubernetes cluster hosted in AWS (EKS)**.

All infrastructure provisioning (EKS cluster, EC2 agents for Jenkins, SonarQube, and Nexus) is handled with **Terraform**, and setup tasks are orchestrated through **Bash scripts**.

Much of this work is inspired by and credits the original structure from:  
👉 [https://github.com/devops-methodology/Blue-Green-Deployment](https://github.com/devops-methodology/Blue-Green-Deployment)

---

## 📁 Repository Structure

```

.
├── bankapp/               # Spring Boot source code and Jenkinsfile
├── cluster/               # Terraform to provision EKS cluster
├── manifests/             # Kubernetes manifests (blue/green deployment files)
├── multiple\_vms/          # Terraform to provision EC2 VMs for Jenkins, SonarQube, Nexus
├── scripts/               # Bash scripts for installing and configuring services
├── BlueGreen Deployment.pdf  # Documentation
└── README.md              # This file

```

---

## 🚀 Deployment Strategy: Blue-Green

I implemented a **Blue-Green Deployment** pattern to ensure **zero-downtime updates**. This means:

- Two identical environments: `blue` and `green`.
- Only one of them is live at any given time (serving traffic).
- New versions are deployed to the idle environment.
- Traffic is switched using a patch on the Kubernetes service (`kubectl patch svc`).

The active environment is chosen via a Jenkins pipeline parameter (`DEPLOY_ENV`), and optionally traffic is switched with a flag (`SWITCH_TRAFFIC`).

---

## ⚙️ Infrastructure Setup

### ☁️ Cluster Setup (`/cluster`)

Provisioning of the AWS EKS cluster is handled via Terraform. Files included:

- `main.tf`, `variables.tf`, `output.tf` — define EKS cluster
- `eks-rbac.md` — permissions guidance
- `monitor/prometheus-configmap.yaml` — basic monitoring setup

### 💻 VM Provisioning (`/multiple_vms`)

Creates EC2 virtual machines used to run:

- **Jenkins**
- **SonarQube**
- **Nexus Repository Manager**

Each machine is provisioned using Terraform modules under `/modules`, and configured with Bash scripts.

---

## 🛠️ Orchestration Scripts

Found in `/scripts`:

- `orchestrator.sh` – central orchestration script that provisions infrastructure and installs tools
- `install_jenkins.sh`, `install_docker.sh`, `install_kubectl.sh`, etc.
- `run_sonar.sh` and `run_nexus.sh` – start containerized SonarQube and Nexus

You can execute the entire provisioning flow with:

```bash
chmod +x scripts/orchestrator.sh
./scripts/orchestrator.sh
```

---

## 🧪 Jenkins Pipeline

The main CI/CD logic is defined in `bankapp/Jenkinsfile`. The pipeline:

1. Checks out the code
2. Runs **SonarQube analysis**
3. Performs **Trivy security scans** (file system + image)
4. Builds and pushes Docker image
5. Deploys MySQL and app to Kubernetes
6. Optionally switches live traffic to blue or green
7. Verifies deployment status

---

## 🔐 Jenkins Credentials Configuration

In Jenkins, you need to configure the following credentials in **Manage Jenkins > Credentials**:

| ID            | Type                     | Description                               |
| ------------- | ------------------------ | ----------------------------------------- |
| `sonar-token` | Secret Text              | Token from SonarQube for analysis         |
| `docker-cred` | Username & Password      | DockerHub credentials (for image push)    |
| `k8-token`    | Secret file (kubeconfig) | Kubeconfig file to access AWS EKS cluster |

---

## ⚙️ Jenkins Tool Configuration

In **Manage Jenkins > Global Tool Configuration**, ensure you configure the following:

- **Maven**:

  - Name: `maven`
  - Version: `3.9.9` (or latest)

- **Sonar Scanner**:

  - Name: `sonar-scanner`
  - Installed manually or via automatic installer

---

## 🔁 Webhook Setup

To automate Jenkins pipeline execution on code pushes:

1. Go to your GitHub repository settings → Webhooks
2. Add a new webhook:

   - Payload URL: `http://<jenkins-ip>:8080/github-webhook/`
   - Content type: `application/json`
   - Events: `Just the push event`

3. Make sure your Jenkins project is configured with **GitHub hook trigger for GITScm polling**

---

## 📦 Application Overview

Located in `bankapp/`, this is a Spring Boot app that simulates a basic banking system with:

- Controllers for account and transaction management
- A MySQL backend (deployed via `mysql-ds.yml`)
- HTML templates for dashboard, login, and transaction views

It’s packaged with `mvnw` (Maven Wrapper) and containerized using Docker.

---

## ✅ Getting Started

### 1. Provision Infrastructure

```bash
cd scripts
./orchestrator.sh
```

### 2. Set Up Jenkins and Create a Pipeline

- Use `bankapp/Jenkinsfile`
- Configure credentials and tools as listed above

### 3. Trigger a Build

Either push to the GitHub repo or run the Jenkins job manually and select:

- `DEPLOY_ENV` = `blue` or `green`
- `DOCKER_TAG` = same as above
- `SWITCH_TRAFFIC` = check if you want to move live traffic

---

## 🙏 Credits

Much of the pipeline logic and deployment design is based on the great work in:

**🔗 [https://github.com/devops-methodology/Blue-Green-Deployment](https://github.com/devops-methodology/Blue-Green-Deployment)**

---

## 📎 Contact

If you want to collaborate or learn more about this setup, feel free to reach out!

---
