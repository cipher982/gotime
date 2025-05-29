# Gotime MVP - Day 1 Implementation

## Goal
A minimal working version that:
- Spawns 2 terminal panes with isolated git worktrees
- Handles branch creation and PR submission
- No evaluation, scoring, or automated merging

## Core Features

### 1. Simple CLI Command
```bash
gotime start feature1 feature2
```

This will:
- Create 2 git worktrees
- Create 2 branches
- Open tmux with 2 panes
- Each pane starts in its own worktree

### 2. Basic Session Management
```bash
gotime end
```

This will:
- Show what each branch changed
- Ask if you want to create PRs
- Clean up worktrees
- Return to original terminal state

## Implementation Plan

### Step 1: Basic Shell Script (~2 hours)

Create `gotime.sh`:
```bash
#!/bin/bash

# gotime - Minimal MVP for parallel development

GOTIME_DIR="/tmp/gotime_sessions"
SESSION_FILE="$HOME/.gotime_session"

function start_session() {
    if [ $# -ne 2 ]; then
        echo "Usage: gotime start <feature1> <feature2>"
        exit 1
    fi
    
    FEATURE1=$1
    FEATURE2=$2
    SESSION_ID=$(date +%s | tail -c 5)
    
    # Create session directory
    mkdir -p "$GOTIME_DIR"
    
    # Get current branch
    BASE_BRANCH=$(git branch --show-current)
    
    # Create worktrees
    WORKTREE1="$GOTIME_DIR/session_${SESSION_ID}_${FEATURE1}"
    WORKTREE2="$GOTIME_DIR/session_${SESSION_ID}_${FEATURE2}"
    
    echo "Creating worktrees..."
    git worktree add -b "feature/$FEATURE1-$SESSION_ID" "$WORKTREE1" "$BASE_BRANCH"
    git worktree add -b "feature/$FEATURE2-$SESSION_ID" "$WORKTREE2" "$BASE_BRANCH"
    
    # Save session info
    cat > "$SESSION_FILE" << EOF
SESSION_ID=$SESSION_ID
FEATURE1=$FEATURE1
FEATURE2=$FEATURE2
WORKTREE1=$WORKTREE1
WORKTREE2=$WORKTREE2
BRANCH1=feature/$FEATURE1-$SESSION_ID
BRANCH2=feature/$FEATURE2-$SESSION_ID
BASE_BRANCH=$BASE_BRANCH
EOF
    
    # Launch tmux
    tmux new-session -d -s "gotime_$SESSION_ID" -c "$WORKTREE1"
    tmux split-window -h -c "$WORKTREE2"
    
    # Add pane titles
    tmux select-pane -t 0 -T "[$FEATURE1]"
    tmux select-pane -t 1 -T "[$FEATURE2]"
    
    # Attach to session
    tmux attach-session -t "gotime_$SESSION_ID"
}

function end_session() {
    if [ ! -f "$SESSION_FILE" ]; then
        echo "No active gotime session found"
        exit 1
    fi
    
    # Load session info
    source "$SESSION_FILE"
    
    echo "Ending gotime session $SESSION_ID..."
    echo
    
    # Show changes
    echo "=== Changes in $FEATURE1 ==="
    cd "$WORKTREE1"
    git log --oneline "$BASE_BRANCH".."$BRANCH1" 2>/dev/null || echo "No commits"
    echo
    
    echo "=== Changes in $FEATURE2 ==="
    cd "$WORKTREE2"
    git log --oneline "$BASE_BRANCH".."$BRANCH2" 2>/dev/null || echo "No commits"
    echo
    
    # Ask about PRs
    read -p "Create PR for $FEATURE1? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$WORKTREE1"
        git push origin "$BRANCH1"
        echo "Branch $BRANCH1 pushed. Create PR manually or use gh/hub CLI"
    fi
    
    read -p "Create PR for $FEATURE2? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$WORKTREE2"
        git push origin "$BRANCH2"
        echo "Branch $BRANCH2 pushed. Create PR manually or use gh/hub CLI"
    fi
    
    # Cleanup
    read -p "Remove worktrees? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git worktree remove "$WORKTREE1" --force
        git worktree remove "$WORKTREE2" --force
        rm -f "$SESSION_FILE"
        echo "Cleanup complete!"
    fi
}

# Main command handler
case "$1" in
    start)
        shift
        start_session "$@"
        ;;
    end)
        end_session
        ;;
    *)
        echo "Usage: gotime {start|end}"
        echo "  start <feature1> <feature2> - Start parallel development"
        echo "  end                         - End session and create PRs"
        exit 1
        ;;
esac
```

### Step 2: Installation (~30 min)

```bash
# Make it executable
chmod +x gotime.sh

# Add to PATH
sudo ln -s $(pwd)/gotime.sh /usr/local/bin/gotime

# Or add alias
echo "alias gotime='$(pwd)/gotime.sh'" >> ~/.zshrc
```

### Step 3: Optional Enhancements (~1.5 hours)

#### A. Better PR Creation
If you have GitHub CLI installed:
```bash
# In end_session function, replace manual PR message with:
gh pr create --base "$BASE_BRANCH" --head "$BRANCH1" \
    --title "feat: $FEATURE1" \
    --body "Implemented $FEATURE1 feature"
```

#### B. Session Status
Add a status command:
```bash
function show_status() {
    if [ ! -f "$SESSION_FILE" ]; then
        echo "No active gotime session"
        exit 1
    fi
    
    source "$SESSION_FILE"
    echo "Active session: $SESSION_ID"
    echo "Feature 1: $FEATURE1 (branch: $BRANCH1)"
    echo "Feature 2: $FEATURE2 (branch: $BRANCH2)"
}
```

#### C. Custom Pane Commands
Start each pane with a custom command:
```bash
# In start_session, after creating panes:
tmux send-keys -t 0 "echo 'Working on $FEATURE1'" C-m
tmux send-keys -t 1 "echo 'Working on $FEATURE2'" C-m
```

## Usage Example

```bash
# Start working on two features
$ gotime start login-page payment-api

# Now in tmux with 2 panes
# Left pane: working on login-page in its own worktree
# Right pane: working on payment-api in its own worktree

# Work normally in each pane
# Use your favorite AI coding assistant
# Make commits as usual

# When done (detach from tmux with Ctrl-b d)
$ gotime end

=== Changes in login-page ===
a1b2c3d Add login form component
d4e5f6g Add authentication logic

=== Changes in payment-api ===
g7h8i9j Create payment endpoint
j1k2l3m Add Stripe integration

Create PR for login-page? [y/N] y
Branch feature/login-page-12345 pushed.

Create PR for payment-api? [y/N] y
Branch feature/payment-api-12345 pushed.

Remove worktrees? [y/N] y
Cleanup complete!
```

## What This MVP Gives You

1. **Parallel Development**: Work on 2 features simultaneously
2. **Isolated Environments**: Each feature has its own worktree
3. **Simple Branch Management**: Automatic branch creation with clear names
4. **Easy PR Creation**: Push branches and create PRs when ready
5. **Clean Workspace**: Automatic cleanup of worktrees

## What's Missing (Future Work)

- Multiple AI models (just use different commands in each pane)
- Evaluation/scoring (handle manually for now)
- Conflict resolution (git handles basic conflicts)
- More than 2 panes (hardcoded to 2 for simplicity)
- Session persistence (if terminal crashes, need to clean up manually)

## Next Steps After MVP

Once this is working, you can:
1. Add support for N features/panes
2. Add configuration file support
3. Integrate with specific AI tools
4. Add basic metrics collection
5. Build toward the full v0.1 spec

This MVP focuses on the core value: **parallel development with clean git management**. Everything else can be added incrementally!
