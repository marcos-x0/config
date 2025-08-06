# Knative Infrastructure Testing Setup Progress

## Project Overview

This document tracks the progress of creating a comprehensive TypeScript-based testing framework for Knative infrastructure validation. The primary goal is to test the Knative cluster setup itself (not userland code) and prepare for InMemory→Kafka channel migration.

## What We Have Accomplished

### ✅ Foundation Setup
- **Container Infrastructure**: Built working test container (`knative-test:local`) with UBI8/nodejs-20
- **Environment Configuration**: Fixed environment variable loading through proper direnv integration
  - Moved infrastructure variables to `infrastructure/.env.local` (proper domain separation)
  - Fixed root `.envrc` to load infrastructure environment files
  - Environment variables now properly cascade: root → infrastructure → test
- **Build Validation**: Created `build-container` task that validates environment variables are available in container
- **Test Functions**: Created sender-function and receiver-function as test infrastructure (not userland code)

### ✅ Test Architecture Design
- **Directory Structure**: Designed comprehensive test organization:
  - `utils/` - Shared test utilities (cloudevents, kubernetes, environment)
  - `fixtures/` - Test data and expected responses
  - `eventing/` - Knative eventing component tests (brokers, channels, triggers, etc.)
  - `unit/` - Individual function behavior tests
  - `integration/` - Function-to-infrastructure communication tests  
  - `e2e/` - End-to-end pipeline validation tests
- **Migration Strategy**: Tests designed to validate InMemory→Kafka channel migration
- **LLM Agent Continuity**: All files include detailed documentation for future LLM agents

### ✅ Environment Variables Validated
Required variables now properly loaded and validated:
- `ENV_PREFIX=infra`
- `DEFAULT_TEST_TYPE` (has default value) 
- `ORBSTACK_DOMAIN=k8s.orb.local`
- `REGISTRY_HOST=local-dev-registry.orb.local`
- `NODE_ENV=test`

Namespace pattern: `${ENV_PREFIX}-${TEST_TYPE}-${FUNCTION_NAME}` (e.g., `infra-unit-sender-function`)

## Current Phase: 1.2 - Test Skeleton Creation (IN PROGRESS)

**Status**: Creating complete test skeleton with placeholder files

**What's Being Done**: 
- Creating all directory structure and placeholder test files
- Each file includes comprehensive documentation for future LLM agents
- **ALL TESTS ARE `it.skip()` PLACEHOLDERS** - No actual test implementation in Phase 1.2
- Each `it.skip("description")` contains detailed comments with "based on current knowledge" disclaimers
- Focus on meaningful test names that reflect Knative components being tested

**Reference Implementation**: Working bash prototype exists at `./javascript/sender-function/test-sender-unit.bash`
- This bash test is proven to work and validates message chaining and test mode
- TypeScript tests should port this logic using CloudEvents SDK instead of curl
- Current `sender-function/spec/sender-function.spec.ts` will be deleted (not moved) as it has actual implementation

**Current Step**: Need to think deeply about sender/receiver function roles and create properly named test files that reflect what aspects of Knative setup are being validated.

**Phase 1.2 Implementation Rules**:
- Every test is `it.skip("meaningful description")`
- Every skip comment includes "Based on current knowledge..." disclaimer
- Every skip comment provides specific implementation guidance for future LLM agents
- No actual test code - only comprehensive documentation and planning

**Remaining Phase 1.2 Tasks**:
1. Analyze sender/receiver function capabilities and create appropriately named test files
2. Complete all placeholder files with detailed LLM agent documentation
3. Update vitest.config.ts for new test structure
4. Create comprehensive README.md

## Upcoming Phases

### Phase 2: Infrastructure Validation
**Goal**: Validate Knative eventing components are operational
**Tasks**:
- Implement environment validation tests (foundation)
- Create broker operational tests
- Validate trigger configuration and routing
- Test channel behavior (critical for migration)
- Verify function deployment and health

### Phase 3: Integration Testing (Port Bash Prototype)
**Goal**: Convert proven bash test logic to TypeScript
**Reference**: `javascript/sender-function/test-sender-unit.bash` (known working prototype)
**Tasks**:
- Port curl-based testing to CloudEvents SDK
- Implement sender→broker communication tests
- Create broker→receiver delivery tests
- Validate message chaining and transformation

### Phase 4: End-to-End Pipeline Validation
**Goal**: Test complete eventing pipeline
**Tasks**:
- Complete message flow testing (external→broker→sender→broker→receiver)
- Error handling and failure scenarios
- Performance baseline measurement
- Message transformation chain validation

### Phase 5: Migration Readiness Testing
**Goal**: Prepare for InMemory→Kafka channel migration
**Critical Tests**:
- Channel interface abstraction validation
- Delivery guarantee differences documentation
- Performance characteristic comparison
- Consumer group behavior (Kafka-specific)
- Event ordering and persistence testing

## Key Technical Decisions Made

1. **Test Organization**: Tests organized by what Knative component is being tested, not by function name
2. **Environment Domain Separation**: Infrastructure variables belong in `infrastructure/.env.local`
3. **Container Strategy**: Use explicit environment variable passing with `docker run -e` flags
4. **Namespace Isolation**: Pattern `infra-spec-{function-name}` for collision-free testing
5. **LLM Continuity**: Every file documented for future LLM agent understanding

## Migration-Critical Components

The following tests are essential for validating InMemory→Kafka migration:
- **Channel behavior tests**: Event delivery, ordering, persistence differences
- **Broker interface tests**: Ensure consistent API regardless of channel implementation
- **Performance baselines**: Measure before/after migration performance
- **Delivery guarantee tests**: Document differences in reliability/persistence

## Next LLM Agent Instructions

1. **Immediate Task**: Complete Phase 1.2 by analyzing sender/receiver function roles and creating meaningfully named test files
2. **Think Deeply About**: What aspects of Knative setup do sender/receiver functions help us test? Name tests accordingly.
3. **Remember**: Functions are test infrastructure, not userland code - tests validate Knative eventing components
4. **Follow**: All placeholder files need comprehensive LLM agent documentation with implementation guidance

## Context for Future Work

This testing framework validates the Knative cluster setup itself. The sender and receiver functions are infrastructure helpers that enable testing of:
- Event routing through brokers
- Message transformation pipelines  
- Channel delivery behavior
- Trigger filtering and routing
- Complete eventing pipeline functionality

The ultimate goal is confident migration from InMemoryChannel to KafkaChannel with identical behavior validation.