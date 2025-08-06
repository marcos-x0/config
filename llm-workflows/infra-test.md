# Knative Infrastructure Testing Implementation Guide

## Problem Statement

We need to create comprehensive infrastructure tests for a Knative eventing cluster to validate that:
1. CloudEvent message chaining works correctly through the broker
2. Infrastructure components (broker, triggers, channels) function properly  
3. The system will work when we migrate from InMemoryChannel to Kafka
4. Each component can be tested in isolation and end-to-end

## Current Working Solution (Bash Prototype)

We have a **proven working bash test** that validates sender-function message chaining:

### Working Test Script: `javascript/sender-function/test-sender-unit.bash`
```bash
#!/usr/bin/env bash
set -euo pipefail

# Unit test script for sender-function
# Tests message chaining and test mode functionality

echo "Starting sender-function unit tests..."

# Setup: Ensure curl pod exists
if ! kubectl get pod curl-test-pod >/dev/null 2>&1; then
  echo "Creating curl test pod..."
  kubectl run curl-test-pod --image=curlimages/curl --restart=Never --command -- sleep 3600 >/dev/null
  kubectl wait --for=condition=Ready pod/curl-test-pod --timeout=30s >/dev/null
else
  echo "Using existing curl test pod..."
fi

# Test 1: Basic message chaining
echo "Test 1: Basic message chaining"
START_TIME=$(date +%s)
if ! RESULT=$(kubectl exec curl-test-pod -- curl -X POST http://sender-function.default.svc.cluster.local \
  -H "Ce-Id: unit-test-1-$(date +%s)" \
  -H "Ce-Specversion: 1.0" \
  -H "Ce-Type: com.example.message" \
  -H "Ce-Source: unit-test" \
  -H "Content-Type: application/json" \
  -d '{"message": "start", "testMode": true}' \
  --connect-timeout 3 --max-time 5 --fail --silent 2>/dev/null); then
  echo "FAILED: Test 1 timed out or failed"
  exit 1
fi

# Validate response JSON with jq
EXPECTED_MESSAGE="start->sender"
if ! ACTUAL_MESSAGE=$(echo "$RESULT" | jq -r '.processedMessage // empty'); then
  echo "FAILED: Test 1 - Invalid JSON response"
  exit 1
fi

if [ "$ACTUAL_MESSAGE" = "$EXPECTED_MESSAGE" ]; then
  echo "PASSED: Test 1 - Message chaining works"
else
  echo "FAILED: Test 1 - Expected '$EXPECTED_MESSAGE', got '$ACTUAL_MESSAGE'"
  exit 1
fi

# Validate logs with inline timing
DURATION=$(($(date +%s) - START_TIME + 2))
LOG_MESSAGE=$(kubectl logs -l serving.knative.dev/service=sender-function -c user-container --since=${DURATION}s | \
     jq -r 'select(.msg and (.msg | contains("Test mode: skipping"))) | .msg' | head -n1)
if [ "$LOG_MESSAGE" != "Test mode: skipping K_SINK forwarding" ]; then
  echo "FAILED: Test 1 - Test mode not logged correctly"
  exit 1
fi

# [Additional tests 2, 3, 4 follow same pattern...]

echo ""
echo "All sender-function unit tests PASSED!"
echo "Message chaining works correctly"
echo "Test mode functions properly"
echo "Function responds immediately in test mode"
```

### Supporting Function Code: `javascript/sender-function/index.js`
```javascript
const { CloudEvent, HTTP } = require('cloudevents');
const fetch = require('node-fetch');

const handle = async (context, event) => {
  const message = event?.data?.message || 'Hello from sender!';
  const testMode = event?.data?.testMode || false;
  
  // Message chaining: append "->sender" to existing message
  const chainedMessage = message.includes('->') ? `${message}->sender` : `${message}->sender`;
  
  // Create a CloudEvent to send
  const outgoingEvent = new CloudEvent({
    type: 'com.example.message',
    source: 'sender-function',
    data: {
      message: chainedMessage,
      timestamp: new Date().toISOString(),
      sender: 'function-1',
      testMode: testMode
    }
  });
  
  context.log.info('Created event:', outgoingEvent);
  
  // Get the K_SINK URL from environment
  const sinkUrl = process.env.K_SINK;
  
  // Skip broker forwarding in test mode
  if (!testMode && sinkUrl) {
    context.log.info('Sending event to K_SINK:', sinkUrl);
    
    try {
      // Send the event to the sink using CloudEvents HTTP binding
      const message = HTTP.binary(outgoingEvent);
      
      const response = await fetch(sinkUrl, {
        method: 'POST',
        headers: message.headers,
        body: message.body
      });
      
      if (!response.ok) {
        context.log.error('Failed to send event to sink:', response.status, response.statusText);
        throw new Error(`Failed to send event: ${response.status} ${response.statusText}`);
      }
      
      context.log.info('Successfully sent event to sink');
    } catch (error) {
      context.log.error('Error sending event to sink:', error);
      throw error;
    }
  } else if (testMode) {
    context.log.info('Test mode: skipping K_SINK forwarding');
  } else {
    context.log.warn('K_SINK not configured, returning event to caller');
  }
  
  // Return success response
  return { 
    success: true, 
    message: testMode ? 'Test mode: Event processed without forwarding' : 'Event sent to broker',
    eventId: outgoingEvent.id,
    processedMessage: chainedMessage,
    testMode: testMode
  };
};

module.exports = { handle };
```

**Key Insights from Working Bash Solution:**
1. **Persistent curl pod**: Avoid pod creation overhead, get clean JSON responses
2. **Inline timing**: `START_TIME=$(date +%s)` then `--since=${DURATION}s` for precise log isolation
3. **Direct string comparisons**: Use jq parsing, avoid grep for reliable validation
4. **Test mode**: `testMode: true` bypasses broker forwarding for isolated testing
5. **Message chaining**: Tests transformation "start" → "start->sender"

## Why Migrate to TypeScript Container Testing

### Current Limitations:
- **Bash verbosity**: CloudEvent headers require many curl parameters
- **Limited testing scope**: Only tests direct function calls, not full eventing pipeline
- **No broker testing**: Missing validation of sender→broker→receiver flow
- **Future Kafka migration**: Need tests that validate channel swapping works

### Target Architecture:
- **TypeScript + Vitest**: Type-safe testing with native CloudEvents library
- **Container-based**: Test runner deployed as Kubernetes pod/job
- **Multi-stage build**: Optimize npm install layer caching with UBI8/nodejs-20
- **Infrastructure validation**: Test the cluster itself, not just user functions

## Technical Stack Decisions

### TypeScript Testing Stack:
- **cloudevents**: Official SDK with built-in TypeScript types (no @types needed)
- **Vitest**: Native TypeScript support, no configuration required
- **UBI8/nodejs-20**: Base image for consistency with function deployments

### Container Strategy:
```dockerfile
# Multi-stage Containerfile
FROM registry.access.redhat.com/ubi8/nodejs-20 AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM registry.access.redhat.com/ubi8/nodejs-20 AS test
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
CMD ["npm", "run", "test"]
```

## Namespace Collision Avoidance Strategy

### Pattern: `infra-(test_type)-(function-name)`

**ENV Values:**
- `infra-unit-test`: Infrastructure component unit tests
- `infra-e2e-test`: Full eventing pipeline end-to-end tests

**Namespace Examples:**
- `ENV=infra-unit-test` + `sender-function` → `infra-unit-test-sender-function`
- `ENV=infra-e2e-test` + `eventing-pipeline` → `infra-e2e-test-eventing-pipeline`

**Benefits:**
- Parallel testing across functions
- Clear infrastructure vs userland distinction  
- Zero namespace collisions
- Scalable to new test types

## Current Project Structure

```
infrastructure/cluster/knative/
├── eventing/
│   ├── Taskfile.yaml
│   └── broker.yaml
├── functions/
│   ├── Taskfile.yaml
│   └── scripts/deploy-functions.bash  # Contains workaround logic to reuse
└── test/                              # TARGET: Create this directory
    ├── Containerfile                  # Multi-stage build
    ├── package.json                   # TypeScript + Vitest + cloudevents
    ├── vitest.config.ts              # Test configuration
    └── src/
        └── eventing.spec.ts          # Infrastructure tests
```

## Current TODO List

### High Priority (Infrastructure Setup):
1. **Create knative/test directory structure** (IN PROGRESS)
2. **Set up package.json** with TypeScript, Vitest, cloudevents dependencies
3. **Create multi-stage Containerfile** using UBI8/nodejs-20 base image
4. **Design ENV-based namespace pattern** for collision-free testing
5. **Analyze deploy-functions.bash** workaround logic for adaptation

### Medium Priority (Testing Implementation):
6. **Create TypeScript test files** (.spec.ts) for eventing pipeline validation
7. **Implement CloudEvent sending/receiving** logic in TypeScript tests
8. **Test deployment** to test namespace using ENV variable configuration
9. **Validate test container communication** with sender/receiver functions

### Low Priority (Integration):
10. **Create task integration** for automated test execution

## Key Implementation Questions

### Critical Decisions Needed:
1. **deploy-functions.bash Workaround**: Which specific logic needs extraction?
2. **Test Execution Model**: Kubernetes Job vs long-running Pod?
3. **ENV Variable Mapping**: How should ENV values map to namespace creation?
4. **Registry Integration**: Use same local-dev-registry.orb.local:5000?

### Advanced Considerations:
- **Test Isolation**: How to ensure tests don't interfere with each other?
- **Resource Management**: Memory/CPU limits for test containers?
- **Test Reporting**: How to capture and surface test results?
- **Cleanup Strategy**: Automatic namespace cleanup after tests?
- **Broker Testing**: How to validate broker logs and event routing?
- **Kafka Migration Testing**: How to test channel swapping scenarios?

## Success Criteria

### Phase 1: Basic Infrastructure Testing
- [ ] TypeScript tests can deploy to namespaced environments
- [ ] CloudEvent message chaining works end-to-end
- [ ] Broker routing validates correctly
- [ ] Test results are captured and reportable

### Phase 2: Full Pipeline Validation  
- [ ] InMemoryChannel → Kafka migration testing
- [ ] Parallel function testing across namespaces
- [ ] Comprehensive eventing component validation
- [ ] Integration with existing task-based deployment

## Next Immediate Steps

1. **Start with Task 1**: Create the directory structure in `infrastructure/cluster/knative/test/`
2. **Analyze deploy-functions.bash**: Extract the workaround logic for reuse
3. **Initialize package.json**: Set up TypeScript + Vitest + cloudevents dependencies
4. **Create basic Containerfile**: Multi-stage build with UBI8/nodejs-20
5. **Port bash test logic**: Convert proven patterns to TypeScript + CloudEvents SDK

The bash prototype proves the testing approach works. Now we need to scale it to comprehensive infrastructure validation using modern TypeScript tooling while maintaining the proven patterns (persistent pods, inline timing, direct comparisons).