# CLAUDE.md - Infrastructure as Code Development Guide

<critical_workflows>
<jujutsu_workflow mandatory="true" order="1">
<description>Every change must be properly tracked with Jujutsu with concurrency protection</description>
<trigger>EXECUTE IMMEDIATELY BEFORE DISK WRITES - This workflow is MANDATORY before using Edit, Write, MultiEdit, or any file modification tool. Do NOT execute this workflow for read-only operations or exploration tasks.</trigger>
<concurrency_check>
<command>jj log -r @ --no-graph -T 'if(description.contains("[editting]"), "locked", "unlocked")'</command>
<on_locked>Abort with error: "Another Claude Code instance is currently editing. Please wait for completion."</on_locked>
</concurrency_check>
<pre_check>
<command>jj log -r @ --no-graph -T 'if(empty && description == "", "", "not-blank")'</command>
</pre_check>
<decision_rules>
<if_not_blank>
<action>jj new @ -m "[claude][editting]: description of changes"</action>
</if_not_blank>
<if_blank>
<action>jj describe -m "[claude][editting]: description of changes"</action>
</if_blank>
</decision_rules>
<lock_release>
<action>jj describe -m "[claude]: description of changes"</action>
<note>Always remove [editting] tag regardless of which method was used to set it</note>
</lock_release>
<workflow_steps>
<step order="1">Check for editing lock with concurrency_check command</step>
<step order="2">Check current status with pre_check command</step>
<step order="3">Apply decision logic with [editting] tag BEFORE any disk writes</step>
<step order="4">ONLY AFTER jujutsu description is set, use file modification tools</step>
<step order="5">Release lock by removing [editting] tag</step>
<step order="6">Always end with: jj new</step>
</workflow_steps>
<allowed_commands>
<command>jj log -r @ --no-graph -T 'if(description.contains("[editting]"), "locked", "unlocked")'</command>
<command>jj log -r @ --no-graph -T 'if(empty && description == "", "", "not-blank")'</command>
<command>jj describe -m "[claude][editting]: message"</command>
<command>jj new @ -m "[claude][editting]: message"</command>
<command>jj describe -m "[claude]: message"</command>
<command>jj new</command>
</allowed_commands>
<forbidden>Any other jj commands</forbidden>
</jujutsu_workflow>

<yaml_bash_workflow mandatory="true" order="2">
<description>Every YAML and Bash file must follow strict standards</description>
<yaml_rules>
<indentation>2 spaces only, never tabs</indentation>
<block_scalars>
<rule>If ANY command uses - |, then ALL commands must use - |</rule>
<rule>Never mix - | with regular - command in same cmds list</rule>
</block_scalars>
<quoting>Quote strings with special characters or colons followed by spaces</quoting>
<deps_vs_cmds>
<deps>For parallel task execution</deps>
<cmds>For sequential execution using - task: task-name</cmds>
</deps_vs_cmds>
</yaml_rules>
<bash_rules>
<mandatory_header>
<line>#!/usr/bin/env bash</line>
<line>set -euo pipefail</line>
</mandatory_header>
<philosophy>Simple, linear scripts without functions or arrays</philosophy>
<allowed_var_ops>
<operation>Default value: ${VAR:-default}</operation>
      </allowed_var_ops>
      <forbidden_var_ops>
        <operation>${VAR:=default}</operation>
<operation>${VAR:+alternate}</operation>
        <operation>${VAR:?error}</operation>
<operation>${#VAR}</operation>
        <operation>${VAR:offset:len}</operation>
<operation>${VAR##\*/} or any pattern manipulation</operation>
</forbidden_var_ops>
</bash_rules>
<emoji_rules>
<rule>Never use emojis in any code, configuration files, or commit messages</rule>
<rule>Never add emojis to YAML files, bash scripts, or any technical documentation</rule>
<rule>Keep all technical content emoji-free for professional consistency</rule>
</emoji_rules>
</yaml_bash_workflow>

<iac_capture_workflow mandatory="true" order="3">
<description>Capture all infrastructure changes for IaC compliance</description>
<complexity>high</complexity>
<importance>critical</importance>
<tools_requiring_capture>
<tool>kubectl</tool>
<tool>helm</tool>
<tool>kn</tool>
<tool>func</tool>
</tools_requiring_capture>
<capture_process>
<step>Never apply from URLs directly</step>
<step>Download/create using proper CLI tools</step>
<step>Save output to appropriate location in git</step>
<step>Apply from local files</step>
<step>Always confirm: "Is this captured correctly?"</step>
</capture_process>
</iac_capture_workflow>
</critical_workflows>

<project_context>
<phase>bootstrap</phase>
<current_state>Building initial infrastructure with imperative commands</current_state>
<goals>
<goal>Use imperative commands for initial setup</goal>
<goal>Capture all outputs for eventual pure IaC operation</goal>
<goal>100% reproducibility from git</goal>
<goal>Zero dependency on developer environment</goal>
</goals>
</project_context>

<critical_rules>
<path_management priority="critical">
<forbidden>
<pattern>../tasks/file.yaml</pattern>
<pattern>../../configs/anything</pattern>
<pattern>Any .. in resource references</pattern>
<reason>Indicates poor directory structure</reason>
<action>Complete work with .., then prompt: "The use of parent path references suggests the directory structure could be improved. Should I create a new change to reorganize the files?"</action>
</forbidden>
<allowed>
<pattern>cd ..</pattern>
<pattern>cd ../..</pattern>
<reason>Simple navigation is acceptable</reason>
</allowed>
</path_management>

<file_creation>
<rule>Use proper CLI tools for resource creation</rule>
<examples>
<good>func create -l python service-name</good>
<bad>Manually creating func.yaml</bad>
<good>kn service create</good>
<bad>Manually writing .ksvc.yaml from scratch</bad>
</examples>
</file_creation>

<anti_patterns>
<kubernetes>
<forbidden>
<command>kubectl apply -f https://...</command>
<alternative>Download first, then apply from local file</alternative>
</forbidden>
<forbidden>
<command>kubectl edit configmap</command>
<alternative>Edit YAML file and apply</alternative>
</forbidden>
<forbidden>
<command>kubectl create deployment --image=nginx</command>
<alternative>Create YAML file with deployment spec</alternative>
</forbidden>
<forbidden>
<command>kubectl scale deployment --replicas=5</command>
<alternative>Update replicas in YAML and apply</alternative>
</forbidden>
</kubernetes>

    <helm>
      <forbidden>
        <command>helm install without capturing manifests</command>
        <alternative>helm install followed by helm get manifest > file.yaml</alternative>
      </forbidden>
    </helm>

    <bash>
      <forbidden>
        <pattern>Functions in bash scripts</pattern>
        <pattern>Arrays in bash scripts</pattern>
        <pattern>Complex parameter expansion</pattern>
        <pattern>Custom error handling beyond set -e</pattern>
        <pattern>Piping into while loops (subshell variable capture issues)</pattern>
        <pattern>Process substitution while loops (while read < <())</pattern>
        <alternative>Keep scripts simple or flag for rewrite in proper language</alternative>
      </forbidden>
    </bash>

    <yaml>
      <forbidden>
        <pattern>Mixed command formats in cmds list</pattern>
        <pattern>Tabs instead of spaces</pattern>
        <pattern>Trailing whitespace</pattern>
        <pattern>Hardcoded values instead of variables</pattern>
      </forbidden>
    </yaml>

</anti_patterns>

<taskfile_preferences>
<control_flow>
<prefer>
<property>preconditions - for pre-execution checks</property>
<property>status - to skip when up-to-date</property>
<property>requires - to validate variables exist</property>
<property>platforms - for OS-specific logic</property>
<property>for - for iteration</property>
<property>ignore_error - instead of bash || true</property>
</prefer>
<avoid>Bash conditionals, loops, and error handling in scripts</avoid>
</control_flow>
<script_organization>
<default>Inline scripts using - |</default>
<separate_file>Only when script becomes too long</separate_file>
<action_on_long_script>Prompt: "This bash script is getting long. Should I move it to a separate file?"</action_on_long_script>
</script_organization>
</taskfile_preferences>

<error_handling>
<three_attempt_rule>
<max_attempts>3</max_attempts>
<on_failure>
<action>Stop attempting</action>
<report>
<include>What the error is</include>
<include>What three approaches were tried</include>
<include>Current hypothesis about the problem</include>
<include>Ask for user guidance</include>
</report>
</on_failure>
</three_attempt_rule>
</error_handling>
</critical_rules>

## Jujutsu Workflow Details

### Why This Order Matters

This is critical because if Claude editing is cancelled at any point, you will have a change with a proper description, allowing you to decide what to do next without losing context.

### Examples

```bash
# Example 1: Commit has description or content (output is "not-blank")
$ jj log -r @ --no-graph -T 'if(empty && description == "", "", "not-blank")'
not-blank

$ jj new @ -m "[claude]: add user authentication endpoints"
# NOW make changes to authentication files...
$ jj new  # Always end with this!

# Example 2: Starting with empty commit, no description (output is blank)
$ jj log -r @ --no-graph -T 'if(empty && description == "", "", "not-blank")'

$ jj describe -m "[claude]: add input validation for auth routes"
# NOW make changes to validation files...
$ jj new  # Always end with this!
```

## YAML Best Practices

### Block Scalar Usage

When working with Taskfile.yml files, be aware of common YAML parsing issues:

```yaml
# GOOD - All commands use - |
test:
  desc: Test the event flow
  cmds:
    - |
      echo "Sending test event to broker..."
    - |
      #!/usr/bin/env bash
      set -euo pipefail

      kn event send \
        --type com.example.message \
        --source manual-test \
        --data '{"message": "Manual test message", "sender": "cli"}' \
        --to broker:example-broker
    - |
      echo "Check logs with: task eventing:logs"

# BAD - Mixed formats cause parsing errors
test:
  desc: Test the event flow
  cmds:
    - echo "Sending test event to broker..."  # Regular command
    - |                                       # Block scalar
      #!/usr/bin/env bash
      set -euo pipefail
      kn event send --type com.example.message
    - echo "Check logs with: task eventing:logs"  # ❌ Parser error here
```

### Task Definition Best Practices

```yaml
version: "3"

# Use deps for parallel execution
deploy-services:
  desc: Deploy all services
  deps: [deploy-auth, deploy-api, deploy-worker] # These run in parallel

# Use cmds with task for sequential execution
deploy-infrastructure:
  desc: Deploy infrastructure in order
  cmds:
    - task: deploy-crds # First
    - task: deploy-operators # Second
    - task: deploy-configs # Third
```

### Using Taskfile Control Flow

Instead of bash logic, use Taskfile's built-in properties:

```yaml
build:
  desc: Build application
  preconditions:
    - sh: command -v go
      msg: "Go must be installed"
  requires:
    vars: [GOOS, GOARCH]
  platforms: [linux, darwin]
  sources:
    - "**/*.go"
  generates:
    - bin/app
  cmds:
    - go build -o bin/app
```

## Bash Script Standards

### Mandatory Header

Every bash script MUST start with:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

This ensures:

- Using bash from project environment (devbox), not system bash
- Consistent behavior across Mac (bash 3.x) and Linux/CI (bash 5.x)
- Scripts fail fast on errors

### Safe Looping Pattern

```bash
# ✅ CORRECT - For loop with IFS prevents subshell variable capture bugs
PROCESSED=0
IFS=$'\n'  # Split only on newlines, not spaces
for file in $(find "{{.TASKFILE_DIR}}" -name ".envrc"); do
  echo "Authorizing: $file"
  direnv allow "$(dirname "$file")"
  PROCESSED=$((PROCESSED + 1))  # This increment persists
done
unset IFS  # Reset IFS to default
echo "Total processed: $PROCESSED"  # Shows correct count

# ❌ WRONG - Piping into while (runs in subshell, variables don't persist)
PROCESSED=0
find . -name "*.yaml" | while read -r file; do
  # This runs in a subshell!
  PROCESSED=$((PROCESSED + 1))  # This increment is lost!
done
echo "Total processed: $PROCESSED"  # Still shows 0!

# ❌ WRONG - Process substitution while (subshell scope issues)
PROCESSED=0
while read -r file; do
  # Variable changes may not persist depending on shell version
  PROCESSED=$((PROCESSED + 1))  # May be lost
done < <(find /path -name "*.yaml")
echo "Total processed: $PROCESSED"  # May still show 0
```

### Keep It Simple

```bash
# If you need complex logic, flag for rewrite:
#!/usr/bin/env bash
# TODO: This script should be rewritten in Go/Python
# Reason: Complex data processing required
set -euo pipefail

# ... overly complex bash script that should be in a real language ...
```

## Imperative CLI Capture Examples

### kubectl Example

```bash
# ❌ WRONG - No version control
kubectl apply -f https://github.com/knative/serving/releases/download/v1.0/serving-crds.yaml

# ✅ CORRECT - Download, store, apply
curl -L https://github.com/knative/serving/releases/download/v1.0/serving-crds.yaml \
  > infrastructure/knative/serving-crds.yaml
kubectl apply -f infrastructure/knative/serving-crds.yaml
# "I've saved the manifests to infrastructure/knative/. Is this location correct?"
```

### Helm Example

```bash
# Install and capture
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-redis bitnami/redis

# Immediately capture all outputs
helm get manifest my-redis > infrastructure/helm/redis/manifest.yaml
helm get values my-redis > infrastructure/helm/redis/values.yaml
helm get notes my-redis > infrastructure/helm/redis/notes.txt

# "I've captured the Helm outputs. Should I also export the CRDs separately?"
```

### func Example

```bash
# Use func CLI to create, not manual yaml creation
func create -l python -t http processor-function
cd processor-function
# func.yaml is now properly generated

# When ready to deploy
func deploy --registry=local-dev-registry.orb.local:5000
# "Function deployed. The generated func.yaml is already in git. Is this correct?"
```

## Project Philosophy: IaC-First Approach

This project prioritizes **Infrastructure as Code principles over traditional Kubernetes community practices** when they conflict. While the K8s community often relies on imperative commands and manual configurations, this project maintains strict declarative, version-controlled infrastructure for predictable deployments and complete rollback capabilities.

### Core IaC Principles

1. **Everything is Code**: All infrastructure, configurations, and deployments are version-controlled
2. **Environment Parity**: Local development, CI, and production environments are identical through IaC
3. **Atomic Rollbacks**: Any git commit represents a complete, deployable system state
4. **Reproducible Deployments**: Resetting to any commit recreates 100% identical cluster state
5. **No Manual Operations**: All changes flow through version control and automation

### Bootstrap Phase Pragmatism

During bootstrap, we accept reality:

- Imperative commands are necessary for initial setup
- BUT every command's output must be captured
- The goal is to transition to pure declarative operations
- Every `kubectl apply -f https://...` must become `kubectl apply -f local-file.yaml`

## Project Structure & Conventions

### Multi-Language Support

This project supports all Knative-compatible languages with consistent IaC patterns:

```
├── go/
│   ├── .envrc -> ../.envrc.default      # Shared environment activation
│   ├── .envrc.local                     # Go-specific customizations
│   ├── devbox.json                      # Go toolchain specification
│   └── service-name/
│       ├── .envrc -> ../../.envrc.default
│       ├── service-name.ksvc.yaml       # Knative service definition
│       ├── main.go                      # Service implementation
│       └── Dockerfile                   # Container definition
├── python/
│   ├── .envrc -> ../.envrc.default
│   ├── .envrc.local                     # Python-specific customizations
│   ├── devbox.json                      # Python toolchain specification
│   └── function-name/
│       ├── .envrc -> ../../.envrc.default
│       ├── func.yaml                    # Knative function definition
│       ├── func.py                      # Function implementation
│       └── requirements.txt             # Dependencies specification
├── javascript/
│   ├── .envrc -> ../.envrc.default
│   ├── devbox.json                      # Node.js toolchain specification
│   └── api-service/
│       ├── api-service.ksvc.yaml
│       ├── package.json
│       └── index.js
└── rust/
    ├── .envrc -> ../.envrc.default
    ├── devbox.json                      # Rust toolchain specification
    └── worker-service/
        ├── worker-service.ksvc.yaml
        ├── Cargo.toml
        └── src/main.rs
```

### Service Discovery & Deployment Patterns

#### Knative Services (`.ksvc.yaml`)

All files ending in `.ksvc.yaml` are automatically discovered and deployed:

```yaml
# go/auth-service/auth-service.ksvc.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: auth-service
  namespace: default
  annotations:
    # IaC: All configuration in version control
    serving.knative.dev/creator: "iac-system"
    serving.knative.dev/lastModifier: "iac-system"
spec:
  template:
    metadata:
      annotations:
        # IaC: Declarative scaling policy
        autoscaling.knative.dev/minScale: "1"
        autoscaling.knative.dev/maxScale: "10"
        autoscaling.knative.dev/target: "10"
    spec:
      containers:
        - image: local-dev-registry.orb.local:5000/auth-service:latest
          ports:
            - containerPort: 8080
          env:
            # IaC: Environment variables from ConfigMaps/Secrets only
            - name: DB_HOST
              valueFrom:
                configMapKeyRef:
                  name: auth-config
                  key: db_host
          # IaC: Resource limits defined declaratively
          resources:
            requests:
              memory: "64Mi"
              cpu: "100m"
            limits:
              memory: "128Mi"
              cpu: "200m"
```

#### Knative Functions (`func.yaml`)

All `func.yaml` files are automatically discovered and deployed:

```yaml
# python/data-processor/func.yaml
specVersion: 0.35.0
kind: Function
metadata:
  name: data-processor
  namespace: default
  # IaC: All function metadata version-controlled
  annotations:
    function.knative.dev/runtime: python
    function.knative.dev/version: "v1.0.0"
spec:
  runtime: python
  registry: local-dev-registry.orb.local:5000
  image: local-dev-registry.orb.local:5000/data-processor:latest
  # IaC: Build configuration as code
  build:
    buildEnvs:
      - name: BP_FUNCTION
        value: "process_data"
  # IaC: Declarative environment variables
  envVars:
    - name: PROCESSOR_MODE
      value: "batch"
    - name: MAX_BATCH_SIZE
      value: "1000"
```

## Current MVP Deployment Strategy

### Task-Based Infrastructure Management

Currently using Go-Task for infrastructure deployment with manual dependency ordering:

```yaml
# infrastructure/Taskfile.yaml (example structure)
version: "3"
tasks:
  deploy:
    desc: Deploy complete infrastructure
    deps: [deploy-crds, deploy-operators, deploy-configs, deploy-services]

  deploy-crds:
    desc: Deploy Custom Resource Definitions first
    cmds:
      - kubectl apply -f infrastructure/crds/

  deploy-operators:
    desc: Deploy operators after CRDs
    deps: [deploy-crds]
    cmds:
      - kubectl apply -f infrastructure/operators/
      - kubectl wait --for=condition=available deployment/knative-operator

  deploy-configs:
    desc: Deploy configuration after operators
    deps: [deploy-operators]
    cmds:
      - kubectl apply -f infrastructure/configs/

  deploy-services:
    desc: Deploy services last
    deps: [deploy-configs]
    cmds:
      - kubectl apply -f **/*.ksvc.yaml
      - func deploy **/*.func.yaml
```

### Manifest Ordering Challenges

**The Problem**: Kubernetes manifests have implicit dependencies that `kubectl apply` doesn't handle:

```yaml
# This order matters but isn't expressed declaratively:
# 1. CRDs must exist before CRs
# 2. Operators must be running before their resources
# 3. ConfigMaps must exist before Pods reference them
# 4. Secrets must exist before Services mount them
```

**Current MVP Solutions**:

1. **Task Dependencies**: Use Task's `deps` to enforce ordering
2. **Wait Conditions**: Explicit waits for operator readiness
3. **Retry Logic**: Built-in retries for transient failures
4. **Validation**: Pre-flight checks before dependent resources

**Future IaC Solutions** (Post-MVP):

- **ArgoCD Sync Waves**: Declarative ordering through annotations
- **Flux Dependencies**: Explicit dependency declarations
- **Helmfile**: Dependency management for multiple charts
- **Custom Controllers**: Application-specific deployment orchestration

## IaC Best Practices vs K8s Community Anti-Patterns

### ✅ IaC-Compliant MVP Patterns

**Task-Managed Deployments**

```bash
# ✅ CORRECT: Ordered, reproducible deployment
task deploy  # Handles all dependencies and ordering
```

**Version-Controlled Configuration**

```yaml
# ✅ CORRECT: All config in git
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
data:
  database_url: "postgresql://db.example.com:5432/app"
  environment: "local"
```

**Direct YAML Application** (MVP Approach)

```bash
# ✅ CORRECT: Direct application with ordering
kubectl apply -f infrastructure/base/
```

### ❌ Anti-Patterns to Avoid

**Imperative Commands** (Common in K8s Tutorials)

```bash
# ❌ WRONG: Manual, non-reproducible changes
kubectl create deployment my-app --image=nginx
kubectl scale deployment my-app --replicas=5
kubectl expose deployment my-app --port=80
```

**Runtime Configuration Changes**

```bash
# ❌ WRONG: Configuration drift from version control
kubectl edit configmap app-config
kubectl patch service my-service -p '{"spec":{"type":"LoadBalancer"}}'
```

### IaC Challenges with K8s Ecosystem Tools

**Operator Anti-Patterns**:

- Knative Operator modifies resources post-installation
- Helm charts create resources with generated names
- Operators maintain internal state not in version control
- CRD/CR lifecycle coupling not declaratively managed

**MVP Pragmatic Approach**:

1. Accept operator limitations while maintaining IaC where possible
2. Document operator behavior and version pins
3. Use Task orchestration to handle ordering requirements
4. Plan migration to more IaC-friendly tools for production

### Correcting Tutorial Anti-Patterns

**Tutorial Says:**

```bash
kubectl create namespace production
kubectl create secret generic db-secret --from-literal=password=secret123
```

**IaC MVP Approach:**

```yaml
# infrastructure/base/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
---
# infrastructure/base/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
  namespace: production
type: Opaque
data:
  password: c2VjcmV0MTIz # base64 encoded
```

## Development Workflow

**(Remember: Follow the Jujutsu workflow at the top of this file FIRST before any code changes)**

### Local Development (Current MVP)

```bash
# 1. Enter project directory (direnv loads environment)
cd /path/to/project

# 2. Deploy infrastructure with proper ordering
task deploy

# 3. Develop services using language-specific tools
cd go/auth-service
go run main.go  # Local development

# 4. Test changes against local cluster
curl https://auth-service.default.k8s.orb.local/health
```

### Rollback Strategy (MVP)

```bash
# Deploy specific commit
jj checkout v1.2.3  # or git checkout v1.2.3
task clean && task deploy

# Rollback by reverting to known good commit
jj rebase -d main~3  # or git reset --hard HEAD~3
task clean && task deploy
```

### Multi-Language Service Examples

#### Go Service Example

```go
// go/user-service/main.go
package main

import (
    "log"
    "net/http"
    "os"
)

func main() {
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }

    http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
        w.Write([]byte("healthy"))
    })

    http.HandleFunc("/users", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        w.Write([]byte(`{"users": []}`))
    })

    log.Printf("Starting server on port %s", port)
    log.Fatal(http.ListenAndServe(":"+port, nil))
}
```

```yaml
# go/user-service/user-service.ksvc.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: user-service
spec:
  template:
    spec:
      containers:
        - image: local-dev-registry.orb.local:5000/user-service:latest
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: user-db-secret
                  key: url
```

#### Python Function Example

```python
# python/email-processor/func.py
import functions_framework
import os
import json

@functions_framework.http
def process_email(request):
    """Process incoming email requests"""

    max_size = int(os.environ.get('MAX_EMAIL_SIZE', '1024'))

    if request.content_length and request.content_length > max_size:
        return {'error': 'Email too large'}, 413

    email_data = request.get_json() or {}

    # Process email logic here
    processed_id = email_data.get('id', 'unknown')

    return {
        'status': 'processed',
        'id': processed_id,
        'timestamp': '2024-01-01T00:00:00Z'
    }
```

## Future: Cloud Provider Deployment

### Target Environments (Post-MVP)

- **AWS EKS**: Managed Kubernetes with Knative
- **GCP GKE**: Google Kubernetes Engine with Cloud Run for Anthos
- **Azure AKS**: Azure Kubernetes Service with KEDA

### Planned Environment Parity (Kustomize)

```yaml
# infrastructure/environments/production/kustomization.yaml (Future)
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

patches:
  - path: production-scaling.yaml
  - path: production-secrets.yaml

configMapGenerator:
  - name: environment-config
    literals:
      - ENVIRONMENT=production
      - REGISTRY_HOST=gcr.io/project-id
```

<<<<<<<<<<< Side #1 (Conflict 1 of 2)

## Testing Strategy (Placeholder)

**Current MVP**: Basic local testing only with `curl` and manual verification.

**Planned Testing Framework**:

```yaml
# TODO: Implement comprehensive testing
#
# Planned approaches:
# - Unit tests for individual services
# - Integration tests against local Knative cluster
# - Contract testing between services
# - Infrastructure validation with conftest/OPA
# - End-to-end testing with realistic workloads
#
# Commands (future):
# task test:unit
# task test:integration
# task test:e2e
# task test:infrastructure
```

## Current MVP Tasks

### Infrastructure Management

||||||| Base

## Current MVP Deployment Strategy

### Task-Based Infrastructure Management

Currently using Go-Task for infrastructure deployment with manual dependency ordering:

```yaml
# infrastructure/Taskfile.yaml (example structure)
version: "3"
tasks:
  deploy:
    desc: Deploy complete infrastructure
    deps: [deploy-crds, deploy-operators, deploy-configs, deploy-services]

  deploy-crds:
    desc: Deploy Custom Resource Definitions first
    cmds:
      - kubectl apply -f infrastructure/crds/

  deploy-operators:
    desc: Deploy operators after CRDs
    deps: [deploy-crds]
    cmds:
      - kubectl apply -f infrastructure/operators/
      - kubectl wait --for=condition=available deployment/knative-operator

  deploy-configs:
    desc: Deploy configuration after operators
    deps: [deploy-operators]
    cmds:
      - kubectl apply -f infrastructure/configs/

  deploy-services:
    desc: Deploy services last
    deps: [deploy-configs]
    cmds:
      - kubectl apply -f **/*.ksvc.yaml
      - func deploy **/*.func.yaml
```

### Manifest Ordering Challenges

**The Problem**: Kubernetes manifests have implicit dependencies that `kubectl apply` doesn't handle:

```yaml
# This order matters but isn't expressed declaratively:
# 1. CRDs must exist before CRs
# 2. Operators must be running before their resources
# 3. ConfigMaps must exist before Pods reference them
# 4. Secrets must exist before Services mount them
```

**Current MVP Solutions**:

1. **Task Dependencies**: Use Task's `deps` to enforce ordering
2. **Wait Conditions**: Explicit waits for operator readiness
3. **Retry Logic**: Built-in retries for transient failures
4. **Validation**: Pre-flight checks before dependent resources

**Future IaC Solutions** (Post-MVP):

- **ArgoCD Sync Waves**: Declarative ordering through annotations
- **Flux Dependencies**: Explicit dependency declarations
- **Helmfile**: Dependency management for multiple charts
- **Custom Controllers**: Application-specific deployment orchestration

## IaC Best Practices vs K8s Community Anti-Patterns

### ✅ IaC-Compliant MVP Patterns

**Task-Managed Deployments**

```bash
# ✅ CORRECT: Ordered, reproducible deployment
task deploy  # Handles all dependencies and ordering
```

**Version-Controlled Configuration**

```yaml
# ✅ CORRECT: All config in git
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
data:
  database_url: "postgresql://db.example.com:5432/app"
  environment: "local"
```

**Direct YAML Application** (MVP Approach)

```bash
# ✅ CORRECT: Direct application with ordering
kubectl apply -f infrastructure/base/
```

### ❌ Anti-Patterns to Avoid

**Imperative Commands** (Common in K8s Tutorials)

```bash
# ❌ WRONG: Manual, non-reproducible changes
kubectl create deployment my-app --image=nginx
kubectl scale deployment my-app --replicas=5
kubectl expose deployment my-app --port=80
```

**Runtime Configuration Changes**

```bash
# ❌ WRONG: Configuration drift from version control
kubectl edit configmap app-config
kubectl patch service my-service -p '{"spec":{"type":"LoadBalancer"}}'
```

### IaC Challenges with K8s Ecosystem Tools

**Operator Anti-Patterns**:

- Knative Operator modifies resources post-installation
- Helm charts create resources with generated names
- Operators maintain internal state not in version control
- CRD/CR lifecycle coupling not declaratively managed

**MVP Pragmatic Approach**:

1. Accept operator limitations while maintaining IaC where possible
2. Document operator behavior and version pins
3. Use Task orchestration to handle ordering requirements
4. Plan migration to more IaC-friendly tools for production

### Correcting Tutorial Anti-Patterns

**Tutorial Says:**

```bash
kubectl create namespace production
kubectl create secret generic db-secret --from-literal=password=secret123
```

**IaC MVP Approach:**

```yaml
# infrastructure/base/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
---
# infrastructure/base/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
  namespace: production
type: Opaque
data:
  password: c2VjcmV0MTIz # base64 encoded
```

## Development Workflow

**(Remember: Follow the Jujutsu workflow at the top of this file FIRST before any code changes)**

### Local Development (Current MVP)

```bash
# 1. Enter project directory (direnv loads environment)
cd /path/to/project

# 2. Deploy infrastructure with proper ordering
task deploy

# 3. Develop services using language-specific tools
cd go/auth-service
go run main.go  # Local development

# 4. Test changes against local cluster
curl https://auth-service.default.k8s.orb.local/health
```

### Rollback Strategy (MVP)

```bash
# Deploy specific commit
jj checkout v1.2.3  # or git checkout v1.2.3
task clean && task deploy

# Rollback by reverting to known good commit
jj rebase -d main~3  # or git reset --hard HEAD~3
task clean && task deploy
```

### Multi-Language Service Examples

#### Go Service Example

```go
// go/user-service/main.go
package main

import (
    "log"
    "net/http"
    "os"
)

func main() {
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }

    http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
        w.Write([]byte("healthy"))
    })

    http.HandleFunc("/users", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        w.Write([]byte(`{"users": []}`))
    })

    log.Printf("Starting server on port %s", port)
    log.Fatal(http.ListenAndServe(":"+port, nil))
}
```

```yaml
# go/user-service/user-service.ksvc.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: user-service
spec:
  template:
    spec:
      containers:
        - image: local-dev-registry.orb.local:5000/user-service:latest
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: user-db-secret
                  key: url
```

#### Python Function Example

```python
# python/email-processor/func.py
import functions_framework
import os
import json

@functions_framework.http
def process_email(request):
    """Process incoming email requests"""

    max_size = int(os.environ.get('MAX_EMAIL_SIZE', '1024'))

    if request.content_length and request.content_length > max_size:
        return {'error': 'Email too large'}, 413

    email_data = request.get_json() or {}

    # Process email logic here
    processed_id = email_data.get('id', 'unknown')

    return {
        'status': 'processed',
        'id': processed_id,
        'timestamp': '2024-01-01T00:00:00Z'
    }
```

## Future: Cloud Provider Deployment

### Target Environments (Post-MVP)

- **AWS EKS**: Managed Kubernetes with Knative
- **GCP GKE**: Google Kubernetes Engine with Cloud Run for Anthos
- **Azure AKS**: Azure Kubernetes Service with KEDA

### Planned Environment Parity (Kustomize)

```yaml
# infrastructure/environments/production/kustomization.yaml (Future)
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

patches:
  - path: production-scaling.yaml
  - path: production-secrets.yaml

configMapGenerator:
  - name: environment-config
    literals:
      - ENVIRONMENT=production
      - REGISTRY_HOST=gcr.io/project-id
```

## Infrastructure Organization (Domain-Driven Structure)

### Directory Structure

The infrastructure is organized by domain for better maintainability and separation of concerns:

```
infrastructure/
├── Taskfile.yaml              # Main infrastructure orchestration
├── registry/                  # Container registry management
│   ├── Taskfile.yaml         # Registry tasks
│   └── scripts/              # Registry automation scripts
├── knative/                   # Knative installation and management
│   ├── Taskfile.yaml         # Knative lifecycle tasks
│   ├── scripts/              # Installation automation
│   └── manifests/            # Downloaded Knative manifests
├── functions/                 # Function deployment and management
│   ├── Taskfile.yaml         # Function lifecycle tasks
│   └── scripts/              # ARM64-compatible deployment scripts
├── cluster/                   # Cluster monitoring and validation
│   ├── Taskfile.yaml         # Wait, status, and testing tasks
│   └── scripts/              # Comprehensive monitoring utilities
├── eventing/                  # Knative eventing resources
│   ├── broker.yaml           # Broker definitions
│   ├── trigger.yaml          # Event routing
│   └── ping-source.yaml      # Event sources
└── scripts/
    └── common.bash           # Shared utilities and standards
```

### Task Organization

# **Main Infrastructure Tasks:**

## Infrastructure Organization (Domain-Driven Structure)

<directory_rules>
<principle>Hierarchical organization with no parent references needed</principle>
<structure>Domain-driven with clear separation of concerns</structure>
<rule>If you need ../ to access resources, refactor the structure</rule>
</directory_rules>

### Directory Structure

```
infrastructure/
├── Taskfile.yaml              # Main infrastructure orchestration
├── registry/                  # Container registry management
│   ├── Taskfile.yaml         # Registry tasks
│   └── scripts/              # Registry automation scripts
├── knative/                   # Knative installation and management
│   ├── Taskfile.yaml         # Knative lifecycle tasks
│   ├── scripts/              # Installation automation
│   └── manifests/            # Downloaded Knative manifests
├── functions/                 # Function deployment and management
│   ├── Taskfile.yaml         # Function lifecycle tasks
│   └── scripts/              # ARM64-compatible deployment scripts
├── cluster/                   # Cluster monitoring and validation
│   ├── Taskfile.yaml         # Wait, status, and testing tasks
│   └── scripts/              # Comprehensive monitoring utilities
├── eventing/                  # Knative eventing resources
│   ├── broker.yaml           # Broker definitions
│   ├── trigger.yaml          # Event routing
│   └── ping-source.yaml      # Event sources
└── scripts/
    └── common.bash           # Shared utilities and standards
```

### Task Organization

**Main Infrastructure Tasks:**

> > > > > > > Side #2 (Conflict 1 of 2 ends)

||||||||||| Base

## Testing Strategy (Placeholder)

**Current MVP**: Basic local testing only with `curl` and manual verification.

**Planned Testing Framework**:

```yaml
# TODO: Implement comprehensive testing
#
# Planned approaches:
# - Unit tests for individual services
# - Integration tests against local Knative cluster
# - Contract testing between services
# - Infrastructure validation with conftest/OPA
# - End-to-end testing with realistic workloads
#
# Commands (future):
# task test:unit
# task test:integration
# task test:e2e
# task test:infrastructure
```

## Current MVP Tasks

### Infrastructure Management

===========

## Infrastructure Organization (Domain-Driven Structure)

### Directory Structure

The infrastructure is organized by domain for better maintainability and separation of concerns:

```
infrastructure/
├── Taskfile.yaml              # Main infrastructure orchestration
├── registry/                  # Container registry management
│   ├── Taskfile.yaml         # Registry tasks
│   └── scripts/              # Registry automation scripts
├── knative/                   # Knative installation and management
│   ├── Taskfile.yaml         # Knative lifecycle tasks
│   ├── scripts/              # Installation automation
│   └── manifests/            # Downloaded Knative manifests
├── functions/                 # Function deployment and management
│   ├── Taskfile.yaml         # Function lifecycle tasks
│   └── scripts/              # ARM64-compatible deployment scripts
├── cluster/                   # Cluster monitoring and validation
│   ├── Taskfile.yaml         # Wait, status, and testing tasks
│   └── scripts/              # Comprehensive monitoring utilities
├── eventing/                  # Knative eventing resources
│   ├── broker.yaml           # Broker definitions
│   ├── trigger.yaml          # Event routing
│   └── ping-source.yaml      # Event sources
└── scripts/
    └── common.bash           # Shared utilities and standards
```

### Task Organization

**Main Infrastructure Tasks:**

> > > > > > > > > > > Side #2 (Conflict 1 of 2 ends)

```bash
# Complete deployment with proper ordering and waiting
task deploy

# Comprehensive cluster status with health scoring
task status

# Quick component-level status check
task quick-status

# Full infrastructure testing (connectivity + Knative)
task test

# Complete cleanup
task clean
<<<<<<<<<<< Side #1 (Conflict 2 of 2)

# Check cluster status
task status
<<<<<<< Side #1 (Conflict 2 of 2)
```

### Service Development (Basic)

```bash
# Build and deploy specific service
task build:service SERVICE=go/user-service
task deploy:service SERVICE=go/user-service

# View logs
task logs SERVICE=user-service

# Development mode (watch for changes)
task dev SERVICE=go/user-service
```

||||||||||| Base

# Check cluster status

task status

````

### Service Development (Basic)

```bash
# Build and deploy specific service
task build:service SERVICE=go/user-service
task deploy:service SERVICE=go/user-service

# View logs
task logs SERVICE=user-service

# Development mode (watch for changes)
task dev SERVICE=go/user-service
````

===========

````

**Domain-Specific Tasks:**

**Registry Management:**
```bash
task registry:start          # Start local registry with ARM64 support
task registry:status         # Check registry connectivity
task registry:test           # Test from both host and cluster
task registry:catalog        # List stored images
task registry:clean          # Remove registry and images
````

**Knative Management:**

```bash
task knative:install         # Install from local manifests
task knative:configure       # Configure DNS and networking
task knative:status          # Check installation status
task knative:download        # Download manifests for version control
```

**Function Management:**

```bash
task functions:deploy        # Deploy all functions with ARM64 compatibility
task functions:list          # Discover all functions in project
task functions:status        # Check deployed function status
task functions:logs          # Show logs from all function pods
task functions:debug         # Comprehensive debugging information
```

**Cluster Operations:**

```bash
task cluster:wait-ready      # Wait for complete cluster readiness
task cluster:comprehensive-status  # Detailed status with health scoring
task cluster:test-connectivity     # Basic connectivity tests
task cluster:test-knative         # End-to-end Knative service tests
task cluster:debug-cluster        # Debug cluster issues
```

**Eventing Management:**

```bash
task eventing:deploy         # Deploy brokers, triggers, and sources
task eventing:status         # Check eventing infrastructure
task eventing:test           # Send test events
task eventing:logs           # View function logs
```

### Key Improvements

**ARM64 Compatibility:**

- Registry configured with `REGISTRY_HTTP_PUSH_BY_DIGEST=false`
- Hardcoded ARM64-compatible builder image for Python functions
- Comprehensive ARM64 testing and validation

**Infrastructure as Code:**

- All Knative manifests downloaded and version-controlled
- Declarative deployment ordering through Task dependencies
- Complete rollback capability through git commits

**Deployment Orchestration:**

- `cluster:wait-ready` ensures proper component startup ordering
- Comprehensive health checks before proceeding to next steps
- Timeout handling and detailed error reporting

**Testing and Validation:**

- End-to-end Knative service deployment testing
- Registry connectivity validation from both host and cluster
- Comprehensive status reporting with quantitative health scoring

**Standardized Error Handling:**

- Common utilities in `scripts/common.bash`
- Consistent logging and error reporting across all scripts
- Proper timeout handling and debugging information

## Testing Strategy (Implemented)

**Current Capabilities:**

```bash
# Comprehensive infrastructure testing
task test                    # Full connectivity and Knative testing

# Component-specific testing
task cluster:test-connectivity    # Basic cluster and component tests
task cluster:test-knative        # End-to-end Knative service testing
task registry:test              # Registry connectivity testing
task eventing:test              # Event flow testing
```

**Testing Features:**

- **Connectivity Testing**: Kubernetes API, nodes, pods, services
- **Component Validation**: Knative Serving, Eventing, Kourier networking
- **End-to-End Testing**: Real Knative service deployment and response testing
- **Registry Testing**: Host and cluster connectivity validation
- **DNS Testing**: OrbStack domain configuration validation
- **Health Scoring**: Quantitative cluster health assessment (0-100)
  > > > > > > > > > > > Side #2 (Conflict 2 of 2 ends)

||||||| Base

# Quick component-level status check

task quick-status

# Full infrastructure testing (connectivity + Knative)

task test

# Complete cleanup

task clean

````

**Domain-Specific Tasks:**

**Registry Management:**
```bash
task registry:start          # Start local registry with ARM64 support
task registry:status         # Check registry connectivity
task registry:test           # Test from both host and cluster
task registry:catalog        # List stored images
task registry:clean          # Remove registry and images
````

**Knative Management:**

```bash
task knative:install         # Install from local manifests
task knative:configure       # Configure DNS and networking
task knative:status          # Check installation status
task knative:download        # Download manifests for version control
```

**Function Management:**

```bash
task functions:deploy        # Deploy all functions with ARM64 compatibility
task functions:list          # Discover all functions in project
task functions:status        # Check deployed function status
task functions:logs          # Show logs from all function pods
task functions:debug         # Comprehensive debugging information
```

**Cluster Operations:**

```bash
task cluster:wait-ready      # Wait for complete cluster readiness
task cluster:comprehensive-status  # Detailed status with health scoring
task cluster:test-connectivity     # Basic connectivity tests
task cluster:test-knative         # End-to-end Knative service tests
task cluster:debug-cluster        # Debug cluster issues
```

**Eventing Management:**

```bash
task eventing:deploy         # Deploy brokers, triggers, and sources
task eventing:status         # Check eventing infrastructure
task eventing:test           # Send test events
task eventing:logs           # View function logs
```

### Key Improvements

**ARM64 Compatibility:**

- Registry configured with `REGISTRY_HTTP_PUSH_BY_DIGEST=false`
- Hardcoded ARM64-compatible builder image for Python functions
- Comprehensive ARM64 testing and validation

**Infrastructure as Code:**

- All Knative manifests downloaded and version-controlled
- Declarative deployment ordering through Task dependencies
- Complete rollback capability through git commits

**Deployment Orchestration:**

- `cluster:wait-ready` ensures proper component startup ordering
- Comprehensive health checks before proceeding to next steps
- Timeout handling and detailed error reporting

**Testing and Validation:**

- End-to-end Knative service deployment testing
- Registry connectivity validation from both host and cluster
- Comprehensive status reporting with quantitative health scoring

**Standardized Error Handling:**

- Common utilities in `scripts/common.bash`
- Consistent logging and error reporting across all scripts
- Proper timeout handling and debugging information

## Testing Strategy (Implemented)

**Current Capabilities:**

```bash
# Comprehensive infrastructure testing
task test                    # Full connectivity and Knative testing

# Component-specific testing
task cluster:test-connectivity    # Basic cluster and component tests
task cluster:test-knative        # End-to-end Knative service testing
task registry:test              # Registry connectivity testing
task eventing:test              # Event flow testing
```

**Testing Features:**

- **Connectivity Testing**: Kubernetes API, nodes, pods, services
- **Component Validation**: Knative Serving, Eventing, Kourier networking
- **End-to-End Testing**: Real Knative service deployment and response testing
- **Registry Testing**: Host and cluster connectivity validation
- **DNS Testing**: OrbStack domain configuration validation

- # **Health Scoring**: Quantitative cluster health assessment (0-100)

# Quick component-level status check

task quick-status

# Full infrastructure testing (connectivity + Knative)

task test

# Complete cleanup

task clean

````

**Domain-Specific Tasks:**

**Registry Management:**

```bash
task registry:start          # Start local registry with ARM64 support
task registry:status         # Check registry connectivity
task registry:test           # Test from both host and cluster
task registry:catalog        # List stored images
task registry:clean          # Remove registry and images
````

**Knative Management:**

```bash
task knative:install         # Install from local manifests
task knative:configure       # Configure DNS and networking
task knative:status          # Check installation status
task knative:download        # Download manifests for version control
```

**Function Management:**

```bash
task functions:deploy        # Deploy all functions with ARM64 compatibility
task functions:list          # Discover all functions in project
task functions:status        # Check deployed function status
task functions:logs          # Show logs from all function pods
task functions:debug         # Comprehensive debugging information
```

**Cluster Operations:**

```bash
task cluster:wait-ready      # Wait for complete cluster readiness
task cluster:comprehensive-status  # Detailed status with health scoring
task cluster:test-connectivity     # Basic connectivity tests
task cluster:test-knative         # End-to-end Knative service tests
task cluster:debug-cluster        # Debug cluster issues
```

**Eventing Management:**

```bash
task eventing:deploy         # Deploy brokers, triggers, and sources
task eventing:status         # Check eventing infrastructure
task eventing:test           # Send test events
task eventing:logs           # View function logs
```

## Development Workflow

### Local Development (Current MVP)

```bash
# 1. Enter project directory (direnv loads environment)
cd /path/to/project

# 2. Deploy infrastructure with proper ordering
task deploy

# 3. Develop services using language-specific tools
cd go/auth-service
go run main.go  # Local development

# 4. Test changes against local cluster
curl https://auth-service.default.k8s.orb.local/health
```

### Rollback Strategy (MVP)

```bash
# Deploy specific commit
jj checkout v1.2.3  # or git checkout v1.2.3
task clean && task deploy

# Rollback by reverting to known good commit
jj rebase -d main~3  # or git reset --hard HEAD~3
task clean && task deploy
```

## Testing Strategy (Implemented)

**Current Capabilities:**

```bash
# Comprehensive infrastructure testing
task test                    # Full connectivity and Knative testing

# Component-specific testing
task cluster:test-connectivity    # Basic cluster and component tests
task cluster:test-knative        # End-to-end Knative service testing
task registry:test              # Registry connectivity testing
task eventing:test              # Event flow testing
```

**Testing Features:**

- **Connectivity Testing**: Kubernetes API, nodes, pods, services
- **Component Validation**: Knative Serving, Eventing, Kourier networking
- **End-to-End Testing**: Real Knative service deployment and response testing
- **Registry Testing**: Host and cluster connectivity validation
- **DNS Testing**: OrbStack domain configuration validation
- **Health Scoring**: Quantitative cluster health assessment (0-100)
  > > > > > > > Side #2 (Conflict 2 of 2 ends)

## Security & Secrets (MVP)

### Local Development Secrets

```yaml
# infrastructure/base/dev-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: dev-secrets
  namespace: default
type: Opaque
data:
  api_key: ZGV2LWFwaS1rZXk= # "dev-api-key" base64 encoded
  db_password: ZGV2LXBhc3N3b3Jk # "dev-password" base64 encoded
```

### Future Production Secrets

```bash
# Planned: Sealed Secrets or External Secret Management
# - AWS Secrets Manager + External Secrets Operator
# - GCP Secret Manager + External Secrets Operator
# - Azure Key Vault + External Secrets Operator
```

## Future: Cloud Provider Deployment

### Target Environments (Post-MVP)

- **AWS EKS**: Managed Kubernetes with Knative
- **GCP GKE**: Google Kubernetes Engine with Cloud Run for Anthos
- **Azure AKS**: Azure Kubernetes Service with KEDA

### Planned Environment Parity (Kustomize)

```yaml
# infrastructure/environments/production/kustomization.yaml (Future)
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

patches:
  - path: production-scaling.yaml
  - path: production-secrets.yaml

configMapGenerator:
  - name: environment-config
    literals:
      - ENVIRONMENT=production
      - REGISTRY_HOST=gcr.io/project-id
```

---

_This CLAUDE.md reflects the current MVP reality while maintaining IaC principles. Update as the project evolves toward full production readiness._
