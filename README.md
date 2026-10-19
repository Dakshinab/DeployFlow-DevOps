# DeployFlow 🚀

A complete DevOps pipeline project: a containerized Python Flask API, deployed on AWS
with Infrastructure as Code, automated CI/CD, and full monitoring.

## 📋 What This Project Does

A simple task-management API — taken through the **entire DevOps lifecycle**:
local development → version control → cloud infrastructure → automated CI/CD → monitoring.

The app is small on purpose. The power is in the **pipeline around it** — exactly how
real companies ship software.

## 🏗️ Architecture

```
                    ┌──────────────────┐
                    │   Developer      │
                    │   (WSL2 + Git)   │
                    └────────┬─────────┘
                             │ git push
                             ▼
                    ┌──────────────────┐
                    │    GitHub        │
                    │  (source code)   │
                    └────────┬─────────┘
                             │ triggers
                             ▼
                    ┌──────────────────┐
                    │ GitHub Actions   │
                    │  (CI/CD pipeline)│
                    └────────┬─────────┘
                             │ build + scan
                             ▼
                    ┌──────────────────┐
                    │  Docker Image    │
                    │  (registry)      │
                    └────────┬─────────┘
                             │ deploy
                             ▼
        ┌────────────────────────────────────────┐
        │              AWS Cloud                  │
        │  ┌──────┐   ┌────────────┐  ┌────────┐ │
        │  │ VPC  │──▶│ EC2 + App  │  │  S3    │ │
        │  └──────┘   └─────┬──────┘  └────────┘ │
        │                   ▼                    │
        │  ┌──────────────────────────────┐      │
        │  │ Monitoring: CloudWatch +     │      │
        │  │ Prometheus / Grafana         │      │
        │  └──────────────────────────────┘      │
        └────────────────────────────────────────┘
```

## 🛠️ Tech Stack

| Area | Tools |
|---|---|
| App | Python, Flask |
| Containers | Docker |
| Cloud | AWS (EC2, VPC, IAM, S3, CloudWatch) |
| Infrastructure as Code | Terraform |
| CI/CD | GitHub Actions |
| Security | Trivy (image vulnerability scanning) |
| Monitoring | Prometheus, Grafana |
| Orchestration | Kubernetes (kind, local) |

## 📁 Project Structure

```
DeployFlow/
├── app.py              # Flask API (routes: /, /todos, /health)
├── requirements.txt    # Pinned Python dependencies
├── Dockerfile          # Image build recipe (multi-layer)
├── README.md           # You are here
├── terraform/          # (Phase 3) AWS infrastructure as code
├── .github/workflows/  # (Phase 4) CI/CD pipeline
└── k8s/                # (Phase 6) Kubernetes manifests
```

## 🚀 Quick Start (Local)

```bash
# 1. Build the image
docker build -t deployflow:v1 .

# 2. Run the container
docker run -d -p 5000:5000 --name deployflow deployflow:v1

# 3. Test it
curl http://localhost:5000/health
# → {"status":"ok"}

curl -X POST http://localhost:5000/todos \
  -H "Content-Type: application/json" \
  -d '{"task":"learn docker"}'

curl http://localhost:5000/todos
# → ["learn docker"]
```

Stop and clean up:

```bash
docker stop deployflow && docker rm deployflow
```

## 🗺️ Roadmap (Phases)

- [x] **Phase 1** — Containerize Flask API with Docker
- [x] **Phase 2** — Version control with Git/GitHub
- [ ] **Phase 3** — Provision AWS infrastructure with Terraform (EC2, VPC, IAM, S3)
- [ ] **Phase 4** — CI/CD pipeline with GitHub Actions + Trivy scanning
- [ ] **Phase 5** — Monitoring: CloudWatch alarms + Prometheus/Grafana dashboards
- [ ] **Phase 6** — Kubernetes deployment (kind)
- [ ] **Phase 7** — Cost cleanup & documentation

## 💡 Key DevOps Practices Demonstrated

- **Immutable infrastructure** — app ships as a container image, not manual installs
- **Pinned dependencies** — `requirements.txt` versions locked for repeatable builds
- **Multi-layer Docker builds** — dependency caching for fast rebuilds
- **Infrastructure as Code** — all AWS resources defined in Terraform, no manual clicks
- **Pipeline as Code** — CI/CD defined in YAML, versioned alongside the app
- **Security scanning** — Trivy checks images for vulnerabilities before deploy
- **Observability** — health endpoints, metrics, alarms
- **Cost awareness** — AWS Free Tier usage, resources terminated after each phase

## 👤 Author

**Dakshina** — Aspiring DevOps Engineer


---
*Built as a hands-on learning project covering the full DevOps lifecycle.*
