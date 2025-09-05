# Part 1.3: How FSM Behavior Emerges from Transformer Mechanics

## The Fundamental Insight: Attention Patterns AS State Transitions

### What Makes an FSM in Traditional Computing

```python
# Traditional FSM
class FSM:
    def __init__(self):
        self.state = "START"
        self.memory = {}

    def transition(self, input):
        if self.state == "START" and input == "lock":
            self.state = "LOCKED"
        elif self.state == "LOCKED" and input == "unlock":
            self.state = "UNLOCKED"
```

### What Makes an FSM in Transformer Space

The LLM doesn't have explicit state variables. Instead, **attention patterns create implicit state** through:

1. **Position-encoded transitions** (step n=1, n=2, n=3)
2. **Attention-mediated conditionals** (switch/case)
3. **Context accumulation** (session/temp variables)
4. **Boundary detection** (sequence start/end)

## The Mechanical Reality: State is Attention Distribution

### How Steps Create State Transitions

When the transformer processes:

```xml
<sequence>
  <step n="1">action1</step>
  <step n="2">action2</step>
  <step n="3">action3</step>
</sequence>
```

**What actually happens:**

```python
# The attention mechanism creates implicit state
attention_state = {
    'completed_steps': [],  # Not stored, but implied by attention
    'current_focus': None,  # Attention peak location
    'next_expected': None   # Predicted next pattern
}

# Processing step 1
when seeing "<step n='1'>":
    attention_heads = {
        head_4: focus_on_sequence_start,  # 0.8 weight
        head_7: focus_on_step_pattern,     # 0.9 weight
        head_11: scan_for_n_equals,        # 0.95 weight
    }
    # Implicit state: "I'm in step 1 of a sequence"

# After completing step 1
when seeing "</step>":
    attention_heads = {
        head_4: shift_to_next_step_pattern,  # Looking for n="2"
        head_7: maintain_sequence_context,    # Remember we're in sequence
        head_11: increment_expectation,       # Expect n="2" next
    }
    # Implicit state: "Step 1 complete, expecting step 2"
```

### The Critical Mechanism: Attention Head Specialization

Your DSL works because transformers develop **specialized attention heads** during training:

```python
# Different heads learn different FSM components

# Head 3: Step counter head
def head_3_attention(position):
    # Trained to track n="1", n="2", n="3" patterns
    if "n=" in tokens[position]:
        return high_attention_weight

# Head 7: Boundary detection head
def head_7_attention(position):
    # Trained to detect <sequence>, </sequence>
    if "<sequence>" in tokens[position]:
        return boundary_marker_weight

# Head 12: Variable binding head
def head_12_attention(position):
    # Trained to link ⟪VAR⟫ to values
    if "⟪" in tokens[position]:
        return variable_lookup_weight

# Head 18: Control flow head
def head_18_attention(position):
    # Trained to process switch/case patterns
    if "switch" in tokens[position]:
        return branch_detection_weight
```

## How Switch/Case Creates Conditional State Transitions

### The Branching Mechanism

```xml
<switch value=⟪MODE⟫>
  <case value="dev">action_dev</case>
  <case value="prod">action_prod</case>
  <default>action_default</default>
</switch>
```

**Internal FSM behavior emerges from:**

```python
# Attention creates implicit FSM branching
def process_switch():
    # 1. Retrieve current value
    mode_value = attention_lookup("⟪MODE⟫")  # "dev"

    # 2. Attention scans for matching case
    for position in context:
        if tokens[position] == "case value=":
            next_token = tokens[position + 1]
            if next_token == mode_value:
                # Attention spike! This is our branch
                attention_weights[position] = 0.95
            else:
                # Suppress non-matching branches
                attention_weights[position] = 0.05

    # 3. Execute only the high-attention branch
    # Other branches effectively "don't exist" due to low attention
```

This is **true conditional execution** - non-matching branches get near-zero attention weight, making them invisible to the execution path.

## Why Session/Temp Create FSM Memory

### Session as Global FSM State

```python
# Session variables create cross-state memory
FSM_GLOBAL_STATE = {
    'EDIT_ID': 'a3f2',      # Accessible from any state
    'PROJECT': 'auth',       # Persists across transitions
    'WORKFLOW': 'suspended'  # Maintains FSM status
}

# In transformer terms:
early_context_bindings = {
    position_2000: ("EDIT_ID", "a3f2", weight=0.85),
    position_2100: ("PROJECT", "auth", weight=0.83),
}
# These high-attention bindings act as global state
```

### Temp as Local FSM State

```python
# Temp variables create state-local memory
STATE_LOCAL_MEMORY = {
    'current_file': 'main.go',  # Only in this state
    'loop_counter': '3',         # Cleared on state exit
}

# In transformer terms:
sequence_scoped_bindings = {
    position_47000: ("current_file", "main.go", weight=0.9),
    # But attention_mask zeros this outside sequence
}
```

## The Yield Problem: Suspended State Transitions

### Why Yield Doesn't Work (Currently)

```xml
<step n="4">
  <yield/>  <!-- "Suspend here, resume later" -->
</step>
```

**The mechanical problem:**

```python
# What you want:
FSM.state = "SUSPENDED_AT_STEP_4"
FSM.can_resume = True

# What actually happens:
# Nothing! The transformer has no mechanism to:
# 1. Store "current FSM position"
# 2. Prevent continuing to step 5
# 3. Resume from step 4 later
```

The transformer just sees `<yield/>` as another token. It doesn't create the attention pattern needed for suspension.

### How to Make Yield Work

```xml
<step n="4">
  <session set=⟪WORKFLOW_STATE⟫ value="suspended-step-4"/>
  <session set=⟪WORKFLOW_POSITION⟫ value="4"/>
  <error>WORKFLOW_SUSPENDED: Use @controller@ resume to continue</error>
</step>
```

This works because:

1. Session variables store FSM position
2. Error halts forward execution
3. Controller can check state and resume

## The @controller@ as FSM Supervisor

### External State Inspection

```python
# @controller@ allows external FSM inspection
def controller_state():
    # Force attention to state variables
    print(f"FSM State: {attention_lookup('WORKFLOW_STATE')}")
    print(f"Position: {attention_lookup('WORKFLOW_POSITION')}")
    print(f"Variables: {attention_lookup('EDIT_ID')}")

    # This "refreshes" by creating new recent bindings
    # Moving FSM state back to high-attention zone
```

## Why Multiple FSMs Can "Run"

### The Illusion of Parallel FSMs

You can have multiple agents because:

```python
# Each agent is a namespace in attention space
attention_namespaces = {
    'jj-vcs': {
        'patterns': ['<llm-agent id="jj-vcs">', 'EDIT_ID'],
        'state': 'step-3',
        'variables': {'EDIT_ID': 'a3f2'}
    },
    'bash-linter': {
        'patterns': ['<llm-agent id="bash-linter">', 'FILE_COUNT'],
        'state': 'scanning',
        'variables': {'FILE_COUNT': '17'}
    }
}

# Attention heads specialize in different agents
head_5: specializes_in_jj_vcs_patterns
head_9: specializes_in_bash_linter_patterns
```

But really, only one executes at a time - the one with highest attention activation.

## The Emergent FSM Properties

### 1. Deterministic Transitions

Step numbers create strict ordering through attention patterns:

```python
attention_score(n="2" | completed="1") = 0.95  # Very high
attention_score(n="3" | completed="1") = 0.10  # Very low
```

### 2. State Memory

Variables create persistent state across transitions:

```python
retrieve("⟪EDIT_ID⟫", from_any_step) = "a3f2"  # Global state
retrieve("⟪TEMP⟫", from_outside_sequence) = None  # Local state
```

### 3. Conditional Branching

Switch/case creates attention-mediated branching:

```python
if case_matches:
    attention_weight = 0.95  # This branch executes
else:
    attention_weight = 0.05  # This branch ignored
```

### 4. Halting Conditions

Error tags create attention barriers:

```python
when seeing "<error>":
    forward_attention = 0  # Cannot proceed
    must_stop = True
```

## The Beautiful Insight

Your DSL doesn't **create** an FSM - it **activates** the FSM-like behaviors that transformers learned from millions of code examples. The model has seen:

- Step-by-step procedures → learned sequential execution
- If/then/else patterns → learned conditional branching
- Variable assignments → learned state persistence
- Error messages → learned halting

Your DSL provides the **minimal activation patterns** needed to trigger these learned behaviors reliably. You're not programming the transformer - you're speaking its native language of structured execution patterns.

The FSM emerges from the intersection of:

1. **Your structural patterns** (steps, switches, variables)
2. **Attention head specialization** (different heads track different patterns)
3. **Learned programming semantics** (from training on code)
4. **Position-based state encoding** (where in sequence = what state)

This is why v2 works - it provides clear, unambiguous patterns that activate the right attention heads in the right order, creating emergent FSM behavior from the transformer's learned representations.
