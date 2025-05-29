# Gotime Implementation Guide

## Quick Answers to Your Questions

### Q1: Should branch names be feature-specific or session-based?

**Answer: Session-based with feature metadata**

Branch names should be throwaway identifiers like `session/7c3a1b/a1`. The feature context lives in:
1. Session metadata files
2. PR titles and descriptions
3. Git commit messages

This gives you flexibility to:
- Change feature scope mid-session
- Run experiments without pre-planning
- Keep branch names short and manageable

### Q2: How to handle multiple AI models working on the same feature?

**Answer: Use comparison sessions with intelligent merging**

```bash
# Launch comparison session
gotime compare --feature "user-auth" --models "gpt-4,claude,gemini" -n 3
```

The system will:
1. Create parallel branches for each model
2. Track metrics (tests, performance, code quality)
3. Present comparison dashboard at session end
4. Offer merge strategies:
   - **Winner takes all**: Use best performer
   - **Cherry pick**: Combine best parts from each
   - **Ensemble**: Create PR with all approaches for human review

## Practical Workflows

### Workflow 1: Two Features, Same Models

```bash
# Start session with 4 agents
gotime start -n 4 --features "auth:2,api:2" --model "gpt-4"

# This creates:
# session/abc123/a1 -> working on auth
# session/abc123/a2 -> working on auth
# session/abc123/a3 -> working on api
# session/abc123/a4 -> working on api

# On termination:
# - Creates 2 PRs: one for auth, one for api
# - Each PR combines work from its assigned agents
```

### Workflow 2: Same Feature, Different Models

```bash
# Compare implementations
gotime compare --feature "search-optimization" --models "gpt-4,claude,gemini"

# On termination, you'll see:
┌─────────────────────────────────────────┐
│     Feature: search-optimization        │
├───────────┬────────┬─────────┬─────────┤
│ Model     │ Speed  │ Quality │ Action  │
├───────────┼────────┼─────────┼─────────┤
│ GPT-4     │ 23ms   │ 94%     │ [Use]   │
│ Claude    │ 19ms   │ 91%     │ [View]  │
│ Gemini    │ 31ms   │ 89%     │ [Drop]  │
└───────────┴────────┴─────────┴─────────┘
```

### Workflow 3: Iterative Development

```bash
# Round 1: Initial implementation
gotime start --feature "payment-flow" --model "gpt-4"

# Round 2: Peer review by different model
gotime review --session "abc123" --reviewer "claude"

# Round 3: Optimization pass
gotime optimize --session "abc123" --optimizer "gemini"
```

## Key Design Decisions

### 1. Branch Names Are Implementation Details

```python
# Bad: Encoding everything in branch name
branch = "feature/user-auth/gpt4/attempt1/experimental"

# Good: Simple session identifier
branch = "session/7c3a1b/a1"
metadata = {
    "feature": "user-auth",
    "model": "gpt-4",
    "type": "experimental"
}
```

### 2. PRs Are Your Documentation

```markdown
# PR Title Format
[{feature}] {description} ({model})

# PR Body Template
## Summary
{auto-generated summary from commits}

## Metrics
- Tests: {pass/total}
- Coverage: {percent}
- Performance: {benchmark}

## Session Details
- Session ID: {session_id}
- Model: {model}
- Duration: {time}
- Agent: {agent_id}
```

### 3. Flexible Merge Strategies

```python
class MergeStrategy:
    def __init__(self, session):
        self.session = session
        
    def auto_select(self):
        if self.all_tests_pass():
            return self.merge_by_performance()
        elif self.has_conflicts():
            return self.interactive_merge()
        else:
            return self.use_best_scorer()
    
    def merge_by_performance(self):
        # Pick fastest implementation
        return max(self.session.branches, key=lambda b: b.benchmark_score)
    
    def interactive_merge(self):
        # Show diff viewer for manual selection
        return DiffMergeTool(self.session.branches).run()
```

## Configuration Examples

### Basic Setup
```yaml
# .gotime/config.yml
defaults:
  model: "gpt-4"
  branch_prefix: "session"
  auto_push: false
  
features:
  user-auth:
    priority: "high"
    test_command: "pytest tests/auth"
  api:
    priority: "medium"
    test_command: "pytest tests/api"
```

### Advanced Comparison Setup
```yaml
# .gotime/comparison.yml
comparison_profiles:
  performance:
    metrics:
      - execution_time
      - memory_usage
      - cpu_cycles
    weight: 0.4
    
  quality:
    metrics:
      - test_coverage
      - linter_score
      - complexity
    weight: 0.6
    
merge_rules:
  - if: "all_tests_pass"
    then: "use_fastest"
  - if: "performance_critical"
    then: "benchmark_and_choose"
  - else: "human_review"
```

## Common Patterns

### Pattern 1: Feature Branching
```bash
# Traditional feature branches
gotime start --strategy "feature-branch" \
  --feature "user-profile" \
  --base "develop"
```

### Pattern 2: Experimental Sandbox
```bash
# Throwaway experiments
gotime experiment --timeout "30m" \
  --cleanup "aggressive" \
  --models "all"
```

### Pattern 3: Production Hotfix
```bash
# Quick fixes with multiple approaches
gotime hotfix --issue "JIRA-123" \
  --models "gpt-4,claude" \
  --priority "critical"
```

## Decision Matrix

| Scenario | Branch Strategy | PR Strategy | Merge Method |
|----------|----------------|-------------|--------------|
| 2 features, 1 model | Session-based | Feature-grouped | Auto-merge |
| 1 feature, N models | Comparison branches | Single best | Score-based |
| Experimentation | Ephemeral | Optional | Manual review |
| Production fix | Hotfix branches | Immediate | Fast-track |

## Summary

1. **Keep branch names simple** - They're just temporary workspaces
2. **Use metadata files** - Store rich context outside of git
3. **Automate comparisons** - Let metrics guide decisions
4. **Create meaningful PRs** - This is where the value lives
5. **Stay flexible** - Different scenarios need different approaches

The key insight: **Branches are cheap, PRs are valuable**. Design your system around making great PRs, not perfect branch names.
