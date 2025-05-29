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
