# Project Analysis: Knative Development Platform

After analyzing both CLAUDE.md and README.md files, here's what I learned about this fascinating project:

## Project Vision & Core Philosophy

This is a **modernization platform** designed to help companies transition from monolithic applications to **serverless, container-based infrastructure** using Knative. The project embodies a strong **Infrastructure as Code (IaC) philosophy** - everything must be version-controlled, reproducible, and declarative.

The project is currently in **bootstrap phase**, accepting the pragmatic reality that imperative commands are needed initially, but with the strict requirement that *every output must be captured* for eventual pure IaC operation.

## Architecture & Technology Stack

**Core Infrastructure:**
- **OrbStack** (macOS-specific Kubernetes runtime)
- **Knative** (Serving + Eventing for serverless)
- **Devbox + direnv** (reproducible development environments)
- **Local container registry** at `local-dev-registry.orb.local:5000`
- **Automatic DNS** via OrbStack: `https://<service>.default.k8s.orb.local`

**Multi-language Support:**
- Go, Python, JavaScript, Rust
- Each language has its own toolchain specification via `devbox.json`
- Consistent environment loading through symlinked `.envrc` patterns

## Strict Development Standards

**Version Control (Jujutsu):**
```bash
# Before ANY changes, check commit status:
jj log -r @ --no-graph -T 'if(empty && description == "", "", "not-blank")'
# Then either describe existing commit or create new one with [claude]: prefix
```

**Code Standards:**
- **Bash scripts MUST start with:** `#!/usr/bin/env bash` + `set -euo pipefail`
- **YAML consistency:** If ANY command uses `- |`, then ALL must use `- |`
- **No parent path references:** Using `../` indicates poor directory structure
- **Simple bash only:** No functions, arrays, or complex parameter expansion

## Service Discovery & Deployment

**Automatic Discovery Patterns:**
- Any `func.yaml` → Knative Function deployment
- Any `.ksvc.yaml` → Knative Service deployment
- Future: Any `Dockerfile`/`Containerfile` → Custom container

**Environment Hierarchy:**
```
go/auth/
├── .envrc -> ../../.envrc.default    # Shared activation logic
├── .envrc.local                      # Project customization
├── .env                              # Environment variables
├── devbox.json                       # Tool specification
└── auth.ksvc.yaml                    # Service definition
```

## Infrastructure Philosophy

**IaC-First Approach:** This project prioritizes Infrastructure as Code over traditional Kubernetes practices. While K8s community often uses imperative commands, this project maintains strict declarative, version-controlled infrastructure.

**Three Critical Workflows:**
1. **Jujutsu workflow:** Every change properly tracked
2. **YAML/Bash standards:** Consistent formatting and structure  
3. **IaC capture:** All infrastructure changes captured for version control

**Anti-patterns explicitly forbidden:**
- `kubectl apply -f https://...` (must download first)
- `kubectl edit` commands (edit YAML files instead)
- Manual scaling commands (update YAML and apply)

## Key Inconsistencies I Noticed

**Task Runner Discrepancy:**
- CLAUDE.md extensively discusses `task` and `Taskfile.yaml`
- README.md uses `just` and `justfile` throughout
- This suggests either the documentation is out of sync or there was a migration

**Project Scope:**
- CLAUDE.md implies broader infrastructure scope with multiple cloud providers
- README.md is very focused on local macOS development with OrbStack

## Current State vs Future Vision

**Current MVP (Local Development):**
- Full Knative setup on macOS via OrbStack
- Multi-language development environment
- Automatic service discovery and deployment
- Local testing and development workflow

**Future Plans:**
- CI/CD integration 
- Production deployment to AWS EKS, GCP GKE, Azure AKS
- Kustomize-based environment management
- External secret management integration

## What Makes This Project Unique

1. **Convention over Configuration:** Automatic service discovery eliminates manual deployment configuration
2. **Language Agnostic:** Teams can use different languages while sharing infrastructure
3. **Reproducible Environments:** Devbox ensures identical tooling across team members
4. **IaC Discipline:** Even during bootstrap, everything must be captured for version control
5. **Local-First Development:** Full production-like environment running locally

This is a sophisticated approach to modernizing development workflows while maintaining strict infrastructure discipline. The project shows deep understanding of both the pragmatic needs of development teams and the operational requirements of production systems.