# Gotime Git Workflow Example

## Scenario: Building a User Authentication Feature

Let's walk through a real example where you want to implement user authentication using multiple AI models to compare approaches.

### Step 1: Initialize Comparison Session

```bash
$ gotime compare --feature "user-auth" --models "gpt-4,claude,gemini" -n 3
[✓] Created session: 8d4e7f
[✓] Setting up 3 worktrees...
[✓] Created branches:
    - session/8d4e7f/gpt4
    - session/8d4e7f/claude  
    - session/8d4e7f/gemini
[✓] Launching tmux session...
```

### Step 2: During Development

Each AI agent works in its own worktree:

```bash
# Terminal 1 (GPT-4)
[8d4e7f/gpt4] ~/gotime_8d4e7f_gpt4 $ git log --oneline
a1b2c3d Implement JWT token generation
d4e5f6g Add password hashing with bcrypt
g7h8i9j Create user model and migrations
j1k2l3m Set up auth middleware

# Terminal 2 (Claude)
[8d4e7f/claude] ~/gotime_8d4e7f_claude $ git log --oneline
n4o5p6q Implement OAuth2 with Google/GitHub
q7r8s9t Add session-based authentication
t1u2v3w Create user schema with validation
w4x5y6z Add rate limiting middleware

# Terminal 3 (Gemini)
[8d4e7f/gemini] ~/gotime_8d4e7f_gemini $ git log --oneline
a7b8c9d Implement magic link authentication
d1e2f3g Add passwordless email flow
g4h5i6j Create minimalist user model
j7k8l9m Add CSRF protection
```

### Step 3: Session Termination

```bash
$ gotime end
[✓] Stopping all agents...
[✓] Analyzing branches...

╔═══════════════════════════════════════════════════════════╗
║                  User Auth Comparison                      ║
╠════════════╦═════════╦═══════════╦═══════════╦═══════════╣
║ Model      ║ Commits ║ LoC Added ║ Tests     ║ Approach  ║
╠════════════╬═════════╬═══════════╬═══════════╬═══════════╣
║ GPT-4      ║ 4       ║ 342       ║ 12/12 ✓   ║ JWT       ║
║ Claude     ║ 4       ║ 456       ║ 11/12 ⚠   ║ OAuth2    ║
║ Gemini     ║ 4       ║ 234       ║ 10/10 ✓   ║ Magic Link║
╚════════════╩═════════╩═══════════╩═══════════╩═══════════╝

Performance Benchmarks:
- GPT-4 (JWT):        2.3ms avg auth time
- Claude (OAuth2):    45ms avg auth time (external API)
- Gemini (Magic):     1.2ms avg auth time

Select action:
[1] Create PR from GPT-4 implementation
[2] Create PR from Claude implementation  
[3] Create PR from Gemini implementation
[4] Merge best parts from all three
[5] Create separate PRs for review
[6] View detailed diffs

Choice: 4
```

### Step 4: Intelligent Merge

```bash
Analyzing code for intelligent merge...

Suggested combination:
✓ User model from Claude (most comprehensive)
✓ JWT implementation from GPT-4 (fastest)
✓ Magic link as secondary auth from Gemini
✓ Rate limiting from Claude
✓ Test suite combination (all unique tests)

Preview merged changes? [Y/n]: Y

# Shows interactive diff viewer
```

### Step 5: PR Creation

The system creates a single PR with the merged result:

```markdown
PR #123: [user-auth] Implement multi-strategy authentication system

## Description
This PR implements a flexible authentication system combining the best 
approaches from parallel development sessions.

## Implementation Details
- Primary: JWT-based authentication (2.3ms avg response)
- Secondary: Magic link for passwordless flow
- Optional: OAuth2 integration ready
- Security: Rate limiting and CSRF protection

## Source Branches
- session/8d4e7f/gpt4 (4 commits)
- session/8d4e7f/claude (4 commits)
- session/8d4e7f/gemini (4 commits)

## Metrics
- Total tests: 28 (all passing)
- Code coverage: 94%
- Performance: 2.3ms average auth time
- Security score: A+ (includes rate limiting)

## AI Model Contributions
| Model  | Key Contribution           | Included |
|--------|---------------------------|----------|
| GPT-4  | JWT implementation        | ✓        |
| Claude | OAuth2, rate limiting     | Partial  |
| Gemini | Magic link, minimal model | ✓        |

## Files Changed
- `models/user.js` (Claude's comprehensive model)
- `auth/jwt.js` (GPT-4's implementation)
- `auth/magic-link.js` (Gemini's passwordless)
- `middleware/rate-limit.js` (Claude's security)
- `tests/auth.test.js` (Combined test suite)

Labels: feature/auth, ai-generated, comparison-merge, gotime
```

### Step 6: Cleanup

```bash
$ git branch -a | grep session/8d4e7f
# (empty - temporary branches are cleaned up)

$ git log --oneline
8d4e7f9 Merge: Implement multi-strategy authentication
```

## Alternative Workflow: Multiple Features

```bash
# Working on two features with 4 agents
$ gotime start -n 4 --features "search:2,cache:2" --model "gpt-4"

# Creates:
# session/9f3e2a/a1 -> search feature
# session/9f3e2a/a2 -> search feature  
# session/9f3e2a/a3 -> cache feature
# session/9f3e2a/a4 -> cache feature

# On termination:
Session Summary:
┌─────────────┬──────────┬─────────────┬────────┐
│ Feature     │ Agents   │ Total Commits│ Status │
├─────────────┼──────────┼─────────────┼────────┤
│ search      │ a1, a2   │ 8           │ Ready  │
│ cache       │ a3, a4   │ 6           │ Ready  │
└─────────────┴──────────┴─────────────┴────────┘

Creating PRs:
[✓] PR #124: [search] Implement full-text search
[✓] PR #125: [cache] Add Redis caching layer
```

## Git Commands Under the Hood

```bash
# What gotime does internally:

# 1. Create worktrees
git worktree add -b session/8d4e7f/gpt4 /tmp/gotime_8d4e7f_gpt4 main

# 2. Track metadata
echo '{"feature":"user-auth","model":"gpt-4"}' > .gotime/metadata.json

# 3. On merge
git checkout -b feature/user-auth
git cherry-pick a1b2c3d  # JWT from GPT-4
git cherry-pick t1u2v3w  # User model from Claude
git cherry-pick a7b8c9d  # Magic link from Gemini

# 4. Create PR
gh pr create --title "[user-auth] Implement authentication" \
  --body "$(cat pr-template.md)" \
  --label "gotime,feature/auth"

# 5. Cleanup
git worktree remove /tmp/gotime_8d4e7f_gpt4
git branch -D session/8d4e7f/gpt4
```

## Key Takeaways

1. **Branches are temporary workspaces** - Named by session, not feature
2. **Metadata tracks context** - Features, models, metrics stored separately
3. **PRs are the permanent artifact** - Rich descriptions with full context
4. **Flexible merge strategies** - Pick best, combine, or review separately
5. **Automatic cleanup** - No branch pollution in your repo

This workflow gives you maximum flexibility while keeping your git history clean and your PRs meaningful.
