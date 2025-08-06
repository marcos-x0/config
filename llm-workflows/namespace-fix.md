# Namespace Architecture Fix - Multi-Tenant Knative Infrastructure

> **🚨 CRITICAL: TEST-DRIVEN DEVELOPMENT APPROACH MANDATORY 🚨**  
> Every change MUST be validated with tests before proceeding to the next step.  
> Use BOTH the bash prototype AND TypeScript tests as validation tools.  
> DO NOT modify deployment code without first having tests that demonstrate the issue and validate the fix.

## Problem Statement

The Knative infrastructure project was bootstrapped using the `default` namespace for simplicity. Now we need to evolve to a **multi-tenant architecture** that supports:

- Multiple teams deploying to the same cluster
- Multiple applications running simultaneously  
- Multiple test suites running in parallel
- Complete isolation between deployments

## Current Issue Discovered

**TypeScript Infrastructure Tests** expect functions in namespaces like `infra-unit-sender-function`, but functions are only deployed in `default` namespace.

**Test Failure**:
```
Error: getaddrinfo ENOTFOUND sender-function.infra-unit-sender-function.svc.cluster.local
```

**Working Bash Prototype** uses `default` namespace:
```bash
curl -X POST http://sender-function.default.svc.cluster.local
```

## Namespace Pattern

**Format**: `${ENV_PREFIX}-${TEST_TYPE}-${FUNCTION_NAME}`
**Example**: `infra-unit-sender-function`

**Environment Variables Available**:
- `ENV_PREFIX=infra`
- `DEFAULT_TEST_TYPE=unit` 
- `ORBSTACK_DOMAIN=k8s.orb.local`

## Current Architecture State

### Working Test Environment  
- **Bash prototype**: `javascript/sender-function/test-sender-unit.bash`
- **Uses**: `http://sender-function.default.svc.cluster.local`  
- **Status**: ✅ Works perfectly, validates message chaining logic
- **TDD Role**: Primary validation tool for namespace changes - easily modifiable for testing

> **🚨 CRITICAL TDD REMINDER 🚨**  
> The bash prototype is your immediate feedback loop. Modify it to test new namespaces BEFORE changing deployment code.

### Failing TypeScript Tests
- **Location**: `infrastructure/cluster/knative/test/unit/message-transformation.spec.ts`
- **Expects**: `http://sender-function.infra-unit-sender-function.svc.cluster.local`
- **Status**: ❌ DNS resolution fails - namespace doesn't exist
- **TDD Role**: Integration validation for complete namespace architecture

## Current Test Framework Knowledge

### TypeScript Test Infrastructure Status
**Phase 1.2 Complete** - First working CloudEvents integration validated:
- ✅ **HTTP.binary()** method: Returns standard fetch Response, use `.json()` method
- ✅ **httpTransport()** method: Returns `{body: string, headers: object}`, use `JSON.parse(response.body)`
- ✅ **Message transformation**: Confirmed `"start" → "start->sender"` logic works
- ✅ **testMode functionality**: `testMode: true` bypasses eventing pipeline for isolated testing

### Test Container Architecture
**Container Environment**: Red Hat UBI8 with Node.js 20
- **Available**: curl, Node.js runtime, basic shell tools
- **Missing**: kubectl, jq (not needed - TypeScript handles JSON)
- **Network**: Can reach cluster services via `service.namespace.svc.cluster.local`
- **Environment Variables**: `ENV_PREFIX=infra`, `DEFAULT_TEST_TYPE=unit`, `ORBSTACK_DOMAIN=k8s.orb.local`

### Function Response Structure (Validated)
```json
{
  "success": true,
  "message": "Test mode: Event processed without forwarding",
  "eventId": "generated-uuid",
  "processedMessage": "start->sender", 
  "testMode": true
}
```

### Test Execution Commands
```bash
# Rebuild test container
task clean-container && task build-container

# Run specific tests
docker exec knative-test-runner npm run test -- --testNamePattern="Basic Message Chaining"

# Check environment in container
docker exec knative-test-runner node -e "console.log(process.env.ENV_PREFIX)"
```

### Current Deployment Structure
```
javascript/
├── sender-function/          # Deployed to 'default' namespace
└── receiver-function/        # Deployed to 'default' namespace

infrastructure/cluster/knative/test/
├── sender-function/          # Test copy - NOT deployed anywhere
└── receiver-function/        # Test copy - NOT deployed anywhere
```

## Task-Based Infrastructure System

The project uses **Go-Task** with cascading Taskfiles:

```
├── Taskfile.yaml                                    # Root orchestration
├── infrastructure/Taskfile.yaml                     # Infrastructure layer
├── infrastructure/cluster/Taskfile.yaml             # Cluster management
├── infrastructure/cluster/knative/Taskfile.yaml     # Knative platform
├── infrastructure/cluster/knative/functions/Taskfile.yaml  # Function deployment
└── infrastructure/cluster/knative/test/Taskfile.yaml       # Test infrastructure
```

**Current Deployment**: `task deploy` uses default namespace throughout

## Managed Kubernetes Cloud Provider Considerations

> **Important**: This architecture is designed to run on managed Kubernetes services from major cloud providers (AWS EKS, Google GKE, Azure AKS). Some implementation details may differ from self-managed clusters.

### Cloud Provider Specific Adaptations

**AWS EKS with Knative**:
- May use AWS Load Balancer Controller instead of Kourier for ingress
- IAM roles for service accounts (IRSA) for cross-service authentication
- EKS-managed node groups handle cluster-level resources

**Google GKE with Cloud Run for Anthos**:
- Native Knative integration with GKE Autopilot
- Cloud IAM integration for service accounts
- Managed certificates and DNS through Google Cloud

**Azure AKS with KEDA**:
- Azure Service Operator for cloud resource integration
- Azure Active Directory integration for RBAC
- Azure DNS and certificate management

### Sections Less Relevant for Managed Kubernetes

The following sections are primarily for self-managed clusters and may be handled automatically by cloud providers:

- **Cluster-level RBAC setup** (see [Platform Manifests](#platform-manifests-already-correct))
- **Network policy enforcement** (see [Multi-Tenant Architecture Principles](#multi-tenant-architecture-principles))
- **Storage class configuration** (see [Secondary Implementation Priorities](#secondary-can-remain-cluster-scoped))
- **Node and cluster resource management** (see [Resource Isolation](#multi-tenant-architecture-principles))

Cloud providers typically handle these cluster-level concerns through their managed service offerings, allowing focus on application-level namespace architecture.

## Kubernetes & Knative Namespace Best Practices

### Resource Scoping Rules

**Namespace-scoped Resources** (require namespace specification):
- Knative Services (functions)
- Knative Brokers and Triggers  
- Deployments, Pods, Services
- ConfigMaps, Secrets, ServiceAccounts
- Roles and RoleBindings
- PersistentVolumeClaims

**Cluster-scoped Resources** (do not use namespaces):
- CustomResourceDefinitions (CRDs) - including Knative CRDs
- ClusterRoles and ClusterRoleBindings
- StorageClasses, Nodes, PersistentVolumes
- Knative Serving/Eventing platform components

### Knative Eventing Namespace Patterns

**Best Practice**: Keep brokers and triggers in the same namespace
- **One broker per namespace** is the recommended pattern
- Cross-namespace triggers require special RBAC permissions (`knsubscribe` verb)
- Service discovery follows pattern: `service-name.namespace.svc.cluster.local`

**Advanced Pattern**: Broker-to-broker routing for cross-namespace events
- Events can route from Broker A (namespace-1) to Broker B (namespace-2)
- Requires proper service account configuration and RBAC permissions
- Used for security isolation (e.g., PII vs non-PII events)

### Multi-Tenant Architecture Principles

**Namespace Naming Convention**: `${TEAM_CODE}-${APP_NAME}` or `${ENV_PREFIX}-${TEST_TYPE}-${FUNCTION_NAME}`

**Resource Isolation**:
- Each namespace gets its own ResourceQuota to prevent "noisy neighbor" issues
- Network policies enforce communication boundaries
- RBAC ensures principle of least privilege access

**Service Discovery**:
- Within namespace: `http://service-name` 
- Cross-namespace: `http://service-name.namespace.svc.cluster.local`

## Architecture Requirements

### 1. Namespace-Aware Deployment Pipeline

**Current**:
```bash
task deploy  # Always uses 'default'
```

**Needed**:
```bash
task deploy NAMESPACE=infra-unit-sender-function
task deploy TEAM_CODE=team1 APP_NAME=order-processor
```

### 2. Dynamic Namespace Creation
- Create namespace if it doesn't exist
- Set up namespace-specific resources (secrets, configmaps)
- Configure RBAC/permissions per namespace

### 3. Parameterized Resource Deployment
All resources need namespace templating:
- **Functions**: `func deploy --namespace=${NAMESPACE}`
- **Brokers**: Deploy to specific namespace
- **Triggers**: Reference services in correct namespace  
- **SinkBindings**: Target correct namespace

### 4. Service URL Construction
```
http://${SERVICE_NAME}.${NAMESPACE}.svc.cluster.local
```

### 5. Cross-Namespace Communication
- Functions in namespace A may need brokers in namespace B
- Proper service discovery and networking
- Security policies for cross-namespace access

## Development Process Context

### Current Testing Workflow Status

**Phase 1.2 Complete**: First working CloudEvents integration test
- ✅ **HTTP.binary()** method validated
- ✅ **httpTransport()** method validated  
- ✅ **Message transformation** logic confirmed (`"start" → "start->sender"`)
- ✅ **testMode functionality** prevents actual eventing pipeline

**Phase 2 Blocked**: Infrastructure validation needs namespace support

### Validation Tools Available

1. **Bash Prototype** (`javascript/sender-function/test-sender-unit.bash`):
   - Runs in host environment
   - Can be easily modified to test different namespaces
   - Immediate feedback loop for deployment changes

2. **TypeScript Tests** (`unit/message-transformation.spec.ts`):
   - Runs in containerized environment
   - Proper integration test for namespace architecture
   - Validates CloudEvents SDK integration

### Recommended Development Loop

1. **Modify Taskfiles** to add namespace support
2. **Deploy to test namespace** using new Task commands
3. **Run bash prototype** with modified namespace to verify deployment
4. **Run TypeScript tests** to validate full integration
5. **Iterate** until both validation methods pass

## Specific Implementation Tasks

### 1. Update Function Deployment
**File**: `infrastructure/cluster/knative/functions/scripts/deploy-functions.bash`

**Current**:
```bash
func deploy
```

**Needed**:
```bash
func deploy --namespace=${NAMESPACE:-default}
```

### 2. Update Task Parameters
**Files**: All `Taskfile.yaml` files need namespace variable support

**Pattern**:
```yaml
vars:
  NAMESPACE: '{{.NAMESPACE | default "default"}}'
cmds:
  - kubectl create namespace {{.NAMESPACE}} --dry-run=client -o yaml | kubectl apply -f -
```

### 3. Update Test Functions Deployment
**File**: `infrastructure/cluster/knative/test/Taskfile.yaml`

Create task to deploy test functions to test namespaces:
```yaml
deploy-test-functions:
  vars:
    NAMESPACE: "{{.ENV_PREFIX}}-{{.DEFAULT_TEST_TYPE}}-{{.FUNCTION_NAME}}"
  cmds:
    - task: deploy-sender-function NAMESPACE={{.NAMESPACE}}
    - task: deploy-receiver-function NAMESPACE={{.NAMESPACE}}
```

### 4. Update Knative Resources
**Files**: All YAML manifests need namespace parameterization

**Broker Example**:
```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: example-broker
  namespace: ${NAMESPACE}
```

## Success Criteria

### Immediate Success
Run this command and see both tests pass:
```bash
docker exec knative-test-runner npm run test -- --testNamePattern="Basic Message Chaining"
```

### Long-term Success
Multiple teams can deploy simultaneously:
```bash
# Team 1
task deploy TEAM_CODE=team1 APP_NAME=orders

# Team 2  
task deploy TEAM_CODE=team2 APP_NAME=inventory

# Testing
task deploy ENV_PREFIX=infra TEST_TYPE=unit FUNCTION_NAME=sender-function
```

## Validation Strategy

### Step 1: Modify Bash Prototype
Change the URL in `javascript/sender-function/test-sender-unit.bash`:
```bash
# From:
http://sender-function.default.svc.cluster.local

# To:
http://sender-function.infra-unit-sender-function.svc.cluster.local
```

### Step 2: Deploy to Test Namespace
```bash
task deploy-test-functions
```

### Step 3: Run Bash Validation
```bash
./javascript/sender-function/test-sender-unit.bash
```

### Step 4: Run TypeScript Tests
```bash
docker exec knative-test-runner npm run test -- --testNamePattern="Basic Message Chaining"
```

## Manifest Analysis by Scope

Based on the project's file tree and Kubernetes resource scoping:

### Namespace-Scoped Manifests (NEED namespace parameter)
**Functions**:
- `infrastructure/cluster/knative/test/sender-function/func.yaml`
- `infrastructure/cluster/knative/test/receiver-function/func.yaml`

**Eventing Resources**:
- `infrastructure/cluster/knative/eventing/broker.yaml` - Each namespace needs its own broker
- Any trigger YAML files - Must reference services in same namespace
- Any sinkbinding YAML files - Must target services in same namespace

**Application Resources**:
- Secrets, ConfigMaps for function configuration
- ServiceAccounts for function execution
- Roles/RoleBindings for function permissions

### Cluster-Scoped Manifests (NO namespace needed)
**Platform Components**:
- `infrastructure/cluster/knative/manifests/serving/v1.18.1/serving-crds.yaml`
- `infrastructure/cluster/knative/manifests/serving/v1.18.1/serving-core.yaml`
- `infrastructure/cluster/knative/manifests/eventing/v1.18.2/eventing-crds.yaml`
- `infrastructure/cluster/knative/manifests/eventing/v1.18.2/eventing-core.yaml`
- `infrastructure/cluster/knative/manifests/networking/v1.18.0/kourier.yaml`

**Storage and Network**:
- StorageClasses (if any)
- ClusterRoles/ClusterRoleBindings for platform access

### Resource Deployment Strategy

**Per-Namespace Resources** (deployed once per team/app/test):
- Knative Services (functions)
- Broker for event routing
- Namespace-specific secrets/configmaps
- ServiceAccount with appropriate permissions

**Shared Platform Resources** (deployed once per cluster):
- Knative Serving/Eventing platform
- CRDs and controllers
- Cluster-level RBAC *(often managed by cloud provider)*
- Network policies and storage classes *(may be pre-configured in managed K8s)*

## Files to Modify

### Primary Taskfiles (add namespace parameters)
- `infrastructure/cluster/knative/functions/Taskfile.yaml`
- `infrastructure/cluster/knative/functions/scripts/deploy-functions.bash`
- `infrastructure/cluster/knative/test/Taskfile.yaml`

### Namespace-Scoped Resource Templates
- `infrastructure/cluster/knative/eventing/broker.yaml` - Template with namespace variable
- Test function manifests - Add namespace specification
- ServiceAccounts and RBAC - Namespace-specific permissions

### Platform Manifests (already correct)
- All CRD and core platform manifests are cluster-scoped
- No changes needed for serving-core.yaml, eventing-core.yaml, etc.

## Expected Outcome

After implementing namespace support:
1. **Functions deploy to custom namespaces** 
2. **TypeScript tests pass** with proper namespace resolution
3. **Bash prototype validates** deployment in any namespace
4. **Foundation established** for multi-tenant architecture
5. **Tests serve as validation** for future namespace changes

## Implementation Priorities

### Critical Path (must be namespace-aware):
1. **Function deployment** - Functions must go to correct namespace
2. **Broker deployment** - Each namespace needs its own broker  
3. **SinkBindings** - Must point to broker in same namespace
4. **Service discovery** - URLs must include namespace

### Secondary (can remain cluster-scoped):
1. **Platform manifests** - CRDs, controllers stay cluster-level
2. **Network policies** - Can be applied cluster-wide initially *(often pre-configured in managed K8s)*
3. **Storage classes** - Shared across all namespaces *(typically provided by cloud provider)*

### Validation Strategy

**Quick Validation**: Check resource deployment
```bash
# After namespace deployment
kubectl get all -n infra-unit-sender-function
kubectl get brokers -n infra-unit-sender-function
```

**Integration Validation**: Test service discovery
```bash
# Update bash prototype to use new namespace
sed -i 's/default/infra-unit-sender-function/g' javascript/sender-function/test-sender-unit.bash
./javascript/sender-function/test-sender-unit.bash
```

**Full Validation**: Run TypeScript tests
```bash
docker exec knative-test-runner npm run test -- --testNamePattern="Basic Message Chaining"
```

## Next Steps for LLM Agent

### Phase 1: Foundation (Namespace Creation)

> **🚨 TDD CRITICAL: WRITE TESTS FIRST 🚨**  
> Before modifying ANY Taskfile, create tests that validate namespace creation and resource deployment.

**TDD Steps**:
1. **Create test case** that validates namespace exists: `kubectl get namespace infra-unit-sender-function`
2. **Add namespace creation** to Taskfiles with proper naming  
3. **Implement namespace parameterization** in deployment scripts
4. **Validate with test** that namespace is created correctly

**Test-First Approach**:
```bash
# 1. Test should fail initially (namespace doesn't exist)
kubectl get namespace infra-unit-sender-function
# Expected: Error - namespace not found

# 2. Implement namespace creation in Taskfile
# 3. Test should pass
kubectl get namespace infra-unit-sender-function  
# Expected: Namespace found
```

### Phase 2: Function Deployment

> **🚨 TDD CRITICAL: TEST FUNCTION DEPLOYMENT FIRST 🚨**  
> Modify the bash prototype to expect the new namespace BEFORE changing deployment code.

**TDD Steps**:
1. **Modify bash prototype** to test new namespace:
   ```bash
   # Change URL in javascript/sender-function/test-sender-unit.bash
   # From: http://sender-function.default.svc.cluster.local
   # To:   http://sender-function.infra-unit-sender-function.svc.cluster.local
   ```
2. **Run bash test** - should FAIL with DNS resolution error
3. **Update func deployment** to use namespace parameter
4. **Deploy to test namespace**
5. **Run bash test again** - should PASS with function responding
6. **Verify TypeScript tests** also pass

**Test-First Validation**:
```bash
# 1. Modified bash test should fail initially
./javascript/sender-function/test-sender-unit.bash
# Expected: DNS resolution failure

# 2. After implementing namespace deployment
./javascript/sender-function/test-sender-unit.bash  
# Expected: All tests pass with message chaining working
```

### Phase 3: Eventing Infrastructure  

> **🚨 TDD GUIDANCE: EVENTING TESTS NEED COORDINATION 🚨**  
> This phase requires BOTH functions AND eventing resources. Test incrementally.

**TDD Steps**:
1. **Create eventing validation test** - check broker exists in namespace
2. **Deploy broker per namespace** with proper configuration
3. **Test broker accessibility** before updating sinkbindings
4. **Update sinkbindings** to reference namespace-local broker
5. **Create end-to-end eventing test** (without testMode) to validate full pipeline

**Test-First Validation**:
```bash
# 1. Test broker deployment
kubectl get brokers -n infra-unit-sender-function
# Expected: broker exists and is ready

# 2. Test eventing pipeline (requires turning off testMode)
# Modify sender-function to send real events to broker
# Validate events reach receiver-function
```

### Phase 4: Integration Testing

> **🚨 TDD SUCCESS CRITERIA: ALL TESTS MUST PASS 🚨**  
> This phase validates that the entire namespace architecture works end-to-end.

**TDD Validation Checklist**:
1. **✅ Bash prototype passes** in new namespace
2. **✅ TypeScript tests pass** with namespace resolution  
3. **✅ Function deployment** works in custom namespaces
4. **✅ Eventing pipeline** works within namespace boundaries
5. **✅ Service discovery** resolves correctly across namespaces

**Final Integration Test Commands**:
```bash
# Ultimate validation - both should pass
./javascript/sender-function/test-sender-unit.bash
docker exec knative-test-runner npm run test -- --testNamePattern="Basic Message Chaining"

# Multi-namespace validation
task deploy NAMESPACE=team1-app1  
task deploy NAMESPACE=team2-app2
# Both should work without conflicts
```

## Success Metrics

**Technical Success**:
- Functions deploy to custom namespaces
- Service discovery works across namespaces
- TypeScript tests pass with proper namespace resolution
- Bash prototype validates deployment in any namespace

**Architectural Success**:
- Multiple teams can deploy simultaneously without conflicts
- Resource isolation prevents "noisy neighbor" issues  
- Platform components remain shared and efficient
- Clear separation between tenant resources and platform resources

## Test-Driven Development Summary

### TDD Cycle for Each Phase
```
1. Write/Modify Test (bash prototype or TypeScript)
2. Run Test - Should FAIL  
3. Implement Minimal Code to Make Test Pass
4. Run Test - Should PASS
5. Refactor if Needed
6. Repeat for Next Feature
```

### Validation Tools Summary
- **Bash Prototype**: Immediate feedback, easy to modify, validates networking and service discovery
- **TypeScript Tests**: Integration validation, CloudEvents SDK testing, containerized environment  
- **kubectl Commands**: Infrastructure validation, resource existence, namespace creation
- **Task Commands**: Deployment pipeline validation, end-to-end workflow testing

> **🚨 FINAL TDD REMINDER 🚨**  
> NEVER change deployment code without having a failing test first.  
> ALWAYS validate changes with BOTH bash prototype AND TypeScript tests.  
> The test framework is your safety net - use it religiously!

This architectural evolution enables true multi-tenancy while maintaining the bootstrap simplicity for platform components and providing a clear path from single-tenant development to production-ready multi-tenant deployment - all validated through comprehensive test-driven development.