# Gotime Branch Setup - Quick Guide

## The New Workflow

Instead of pre-planning all features, you can now create worktrees on-demand:

1. **Open a new pane in Warp** (manually)
2. **Navigate to your repo**: `cd ~/git/zerg`
3. **Create a new worktree**: `gotime branch feature_name`

## Basic Usage (Manual CD)

```bash
# In your new pane
cd ~/git/zerg
gotime branch new-feature

# Output:
# ✅ Created worktree at /tmp/gotime_sessions/zerg_new-feature_12345
# ✅ Created branch feature/new-feature-12345
# 
# To switch to the new worktree, run:
#   cd /tmp/gotime_sessions/zerg_new-feature_12345

# Then manually run the cd command
cd /tmp/gotime_sessions/zerg_new-feature_12345
```

## Advanced Setup (Auto-CD)

To automatically change to the new worktree directory, add this function to your shell config (~/.zshrc or ~/.bashrc):

```bash
# Add to ~/.zshrc
gotime() { 
    if [[ $1 == 'branch' ]]; then 
        eval $(command gotime "$@" | tail -1)
    else 
        command gotime "$@"
    fi 
}
```

Then reload your shell config:
```bash
source ~/.zshrc
```

Now when you run `gotime branch feature_name`, it will automatically cd you into the new worktree!

## Full Example

```bash
# Terminal 1: Working on main feature
cd ~/git/zerg
# ... working on main branch ...

# Decide you want to work on something else
# Open new pane (Cmd+D in Warp)

# Terminal 2 (new pane):
cd ~/git/zerg
gotime branch experimental-feature

# You're now automatically in:
# /tmp/gotime_sessions/zerg_experimental-feature_12345
# On branch: feature/experimental-feature-12345
# Ready to work!
```

## Benefits

- **Flexible**: Create new parallel features anytime
- **Simple**: One command per new feature
- **Clean**: Each feature gets its own worktree and branch
- **Natural**: Fits your "open pane, start feature" workflow
