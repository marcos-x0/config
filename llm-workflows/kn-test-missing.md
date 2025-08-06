# Knative Infrastructure Testing - Missing Components Guide

## CRITICAL UPDATE: Incomplete Unit Test Coverage in Phase 1.2

### Context for LLM Agent
The previous LLM agent was creating test skeleton files in `infrastructure/cluster/knative/test/` and ran out of context mid-process. This document identifies the missing test files that MUST be created to complete Phase 1.2.

### Timestamp Analysis
Looking at the unit test creation timeline:
```
11:32:39 - http-to-function-routing.spec.ts (4.2 KB)
11:33:13 - function-environment-integration.spec.ts (4.6 KB)
11:33:48 - function-to-broker-communication.spec.ts (5.4 KB)
11:34:35 - cloudevent-processing.spec.ts (5.9 KB)
11:35:11 - message-transformation.spec.ts (5.6 KB)
[CONTEXT LOST - Agent stopped here]
```

### Current Unit Test Coverage

#### ✅ What Has Been Created:
1. **HTTP Routing** - How Knative Serving routes requests to functions
2. **Environment Variables** - K_SINK injection and environment setup
3. **Function→Broker** - Sending events from functions to broker
4. **CloudEvent Processing** - Parsing and creating CloudEvents
5. **Message Transformation** - Business logic for message chaining

#### ❌ What Is Missing:
The agent tested only HALF of the eventing flow. Critical components remain untested.

## Missing Unit Tests (MUST CREATE)

### 1. `unit/broker-to-function-delivery.spec.ts` (HIGHEST PRIORITY)
**Why This Is Critical**: This is the SECOND HALF of the eventing flow!
- Current tests: Function → Broker ✅
- Missing tests: Broker → Function ❌

**What This Test Must Cover**:
```typescript
describe('Knative Broker to Function Delivery', () => {
  it.skip('should deliver CloudEvents from broker to functions via triggers')
  it.skip('should include correct CloudEvent headers in broker-delivered events')
  it.skip('should receive HTTP 200/202 acknowledgment from functions')
  it.skip('should handle function unavailability gracefully')
  it.skip('should respect trigger subscriber configuration')
})
```

**Key Testing Points**:
- Broker makes HTTP POST to function endpoints
- CloudEvent headers preserved during delivery
- Function acknowledgment handling
- Delivery failure scenarios

### 2. `unit/trigger-filtering-logic.spec.ts` (CRITICAL)
**Why This Is Critical**: Triggers determine WHERE events go. Wrong filtering = wrong routing.

**What This Test Must Cover**:
```typescript
describe('Knative Trigger Filtering Logic', () => {
  it.skip('should filter events based on CloudEvent type attribute')
  it.skip('should route events only to triggers with matching filters')
  it.skip('should support multiple triggers filtering same event type')
  it.skip('should not deliver events to non-matching triggers')
  it.skip('should handle complex filter attributes beyond type')
})
```

**Key Testing Points**:
- Filter attribute matching (type: com.example.message)
- Multiple triggers with different filters
- Events reach only intended functions
- Filter precedence and specificity

### 3. `unit/event-delivery-retry.spec.ts` (RECOMMENDED)
**Why This Is Critical**: Reliability mechanisms differ between InMemory and Kafka channels.

**What This Test Must Cover**:
```typescript
describe('Knative Event Delivery Retry Behavior', () => {
  it.skip('should retry failed deliveries with exponential backoff')
  it.skip('should respect maximum retry limits')
  it.skip('should send to dead letter sink after max retries')
  it.skip('should handle transient vs permanent failures differently')
  it.skip('should preserve CloudEvent attributes during retries')
})
```

**Key Testing Points**:
- Retry attempt patterns
- Backoff timing
- Dead letter sink activation
- InMemory vs Kafka retry differences

### 4. `unit/event-ordering-guarantees.spec.ts` (MIGRATION-CRITICAL)
**Why This Is Critical**: MAJOR DIFFERENCE between InMemory and Kafka channels!
- InMemoryChannel: NO ordering guarantee
- KafkaChannel: Per-partition ordering guarantee

**What This Test Must Cover**:
```typescript
describe('Knative Event Ordering Guarantees', () => {
  it.skip('should document current ordering behavior with InMemoryChannel')
  it.skip('should test concurrent event delivery patterns')
  it.skip('should validate event sequence preservation (or lack thereof)')
  it.skip('should establish baseline for Kafka migration comparison')
  it.skip('should test ordering under various load conditions')
})
```

**Key Testing Points**:
- Current ordering behavior documentation
- Concurrent delivery patterns
- Baseline metrics for migration
- Order-sensitive scenarios

## Complete Event Flow Coverage

With these missing tests, the complete flow will be validated:

```
[External Event] 
    ↓
[Broker Ingress] ← Tested by existing broker tests
    ↓
[Channel Storage] ← Critical for InMemory→Kafka migration
    ↓
[Trigger Filtering] ← MISSING: trigger-filtering-logic.spec.ts
    ↓
[Delivery + Retry] ← MISSING: event-delivery-retry.spec.ts
    ↓
[Function Receipt] ← MISSING: broker-to-function-delivery.spec.ts
    ↓
[Function Processing] ← Tested by existing function tests
    ↓
[Function Response] ← Tested by message-transformation.spec.ts
    ↓
[Back to Broker] ← Tested by function-to-broker-communication.spec.ts
```

## Phase 1.2 Completion Requirements

### Immediate Tasks:
1. **Create missing unit tests** (minimum: broker-to-function-delivery.spec.ts)
2. **Follow established pattern**: 4-6 KB files with comprehensive documentation
3. **Use `it.skip()` placeholders** with detailed implementation guidance
4. **Include "Based on current knowledge..." disclaimers**

### Remaining Directory Structure:
```
unit/                          # Almost complete, add missing tests
├── [EXISTING 5 FILES]
├── broker-to-function-delivery.spec.ts      # MUST CREATE
├── trigger-filtering-logic.spec.ts          # MUST CREATE
├── event-delivery-retry.spec.ts             # RECOMMENDED
└── event-ordering-guarantees.spec.ts        # RECOMMENDED

eventing/                      # NOT STARTED
├── brokers.spec.ts
├── channels.spec.ts          # MIGRATION CRITICAL
├── triggers.spec.ts
├── sources-sinks.spec.ts
├── deployment.spec.ts
└── environment.spec.ts

integration/                   # NOT STARTED
└── [Plan integration test structure]

e2e/                          # NOT STARTED
└── [Plan e2e test structure]
```

## Implementation Guidelines

### File Size Pattern:
- Maintain 4-6 KB per file (established pattern)
- Include comprehensive JSDoc headers
- Provide detailed test descriptions
- Add implementation guidance comments

### Test Naming Convention:
- Descriptive test names that indicate WHAT is being tested
- Focus on Knative infrastructure components, not business logic
- Include migration considerations where relevant

### Priority Order:
1. Complete missing unit tests (especially broker→function delivery)
2. Create eventing/ directory tests
3. Design integration/ test structure
4. Plan e2e/ test scenarios
5. Update configuration files
6. Write comprehensive README.md

## Critical Understanding

The previous agent created excellent test skeletons but missed the complete eventing flow. The most critical missing piece is **broker-to-function delivery**, which represents the second half of the eventing pipeline. Without these tests, we cannot validate that events actually reach their intended destinations through the trigger mechanism.

**Start immediately with**: `unit/broker-to-function-delivery.spec.ts`

This completes the critical path: Event → Broker → Trigger → Function → Back to Broker