# Gotime Branching Strategy

## Core Principles

1. **Branch names are ephemeral** - They exist only during the session
2. **PRs are permanent** - They carry the semantic meaning
3. **Features are metadata** - Specified at runtime, not hardcoded

## Implementation

### 1. Session Initialization with Feature Context

```bash
# Start session with feature specification
gotime start -n 4 --feature "user-auth" --models "gpt-4,claude,gemini,local"

# Or multiple features
gotime start -n 4 --features "user-auth:2,payment-api:2"
```

### 2. Branch Naming Convention

```
{session_type}/{session_id}/{agent_id}
```

Examples:
- `session/7c3a1b/a1`
- `experiment/7c3a1b/a1`
- `feature/7c3a1b/a1`

### 3. Agent Metadata File

Each worktree contains `.gotime/metadata.json`:

```json
{
  "session_id": "7c3a1b",
  "agent_id": "a1",
  "feature": "user-auth",
  "model": "gpt-4",
  "started_at": "2025-05-29T14:30:00Z",
  "parent_branch": "main"
}
```

### 4. PR Creation Strategy

When session ends, PRs are created with rich metadata:

```markdown
Title: [user-auth] Implement authentication flow
Labels: feature/user-auth, model/gpt-4, session/7c3a1b
Description:
- Agent: a1 (GPT-4)
- Session: 7c3a1b
- Feature: user-auth
- Commits: 4
- Files changed: 12
```

## Multi-Model Feature Testing

### Scenario: Same Feature, Different Models

```bash
# Launch comparative session
gotime compare --feature "optimize-search" --models "gpt-4,claude,gemini" -n 3
```

This creates:
```
compare/8d4e7f/gpt4
compare/8d4e7f/claude
compare/8d4e7f/gemini
```

### Termination Flow for Comparisons

```
┌─────────────────────────────────────────────────┐
│         Feature: optimize-search                 │
├─────────────┬──────────┬────────────┬──────────┤
│ Model       │ Commits  │ Tests Pass │ Score    │
├─────────────┼──────────┼────────────┼──────────┤
│ GPT-4       │ 5        │ 12/12      │ 95%      │
│ Claude      │ 7        │ 11/12      │ 88%      │
│ Gemini      │ 4        │ 12/12      │ 92%      │
└─────────────┴──────────┴────────────┴──────────┘

Actions:
[1] Create PR from best performer (GPT-4)
[2] Create combined PR (merge all approaches)
[3] Create separate PRs for review
[4] Run additional analysis
```

### Intelligent Merging

```python
def merge_comparison_branches(session):
    results = analyze_branches(session.branches)
    
    if results.has_conflicts():
        # Show side-by-side diff
        return interactive_merge_tool(results)
    
    if results.all_pass_tests():
        # Combine best parts
        return cherry_pick_best_commits(results)
    
    # Default: use best performer
    return results.best_performer()
```

## Advanced Workflows

### 1. Iterative Refinement
```bash
# Round 1: Generate initial implementations
gotime start --feature "api-endpoint" --models "gpt-4,claude" -n 2

# Round 2: Review and improve
gotime iterate --from-session "7c3a1b" --reviewer "gemini" -n 1
```

### 2. Feature Decomposition
```bash
# Break complex feature into sub-tasks
gotime decompose --feature "payment-system" \
  --subtasks "api-client:1,webhook-handler:1,database-schema:1" \
  --models "gpt-4"
```

### 3. A/B Testing Branches
```bash
# Create variants for production testing
gotime variants --feature "checkout-flow" \
  --strategies "aggressive-caching,lazy-loading,precompute" \
  -n 3
```

## Configuration File

`.gotime/config.yml`:
```yaml
branching:
  strategy: "session-based"
  prefix: "session"
  include_timestamp: false
  
pr_creation:
  auto_create: true
  template: "detailed"
  labels:
    - "gotime"
    - "${feature}"
    - "${model}"
  
comparison:
  metrics:
    - test_coverage
    - performance_benchmarks
    - code_quality_score
  auto_select: "highest_score"
  require_human_review: true
```

## Best Practices

1. **Don't overthink branch names** - They're temporary
2. **Rich PR descriptions** - This is where documentation lives
3. **Use labels extensively** - For filtering and tracking
4. **Automate comparison** - Let metrics guide decisions
5. **Keep session data** - For future analysis

## Example Session Lifecycle

```bash
# Start
$ gotime start --feature "cache-layer" --compare --models "all" -n 4
Created session: 9f3e2a
Launching 4 agents with different models...

# During development
[9f3e2a/a1] $ git commit -m "Add Redis cache implementation"
[9f3e2a/a2] $ git commit -m "Add in-memory cache with LRU"
[9f3e2a/a3] $ git commit -m "Add distributed cache with Hazelcast"
[9f3e2a/a4] $ git commit -m "Add hybrid cache solution"

# End session
$ gotime end
Analyzing 4 implementations of 'cache-layer'...

Performance Results:
- a1 (GPT-4/Redis): 2.3ms avg latency
- a2 (Claude/Memory): 0.8ms avg latency  ← Best
- a3 (Gemini/Hazelcast): 3.1ms avg latency
- a4 (Local/Hybrid): 1.2ms avg latency

Create PR from best performer? [Y/n]
