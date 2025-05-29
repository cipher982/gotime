#!/bin/bash

# gotime-warp - Parallel development with Warp terminal

GOTIME_DIR="/tmp/gotime_sessions"
SESSION_FILE="$HOME/.gotime_session"
WARP_CONFIG_DIR="$HOME/.warp/launch_configurations"

function check_terminal() {
    # Check if Warp is available
    if [[ "$TERM_PROGRAM" == "WarpTerminal" ]] || command -v warp &> /dev/null; then
        return 0
    else
        return 1
    fi
}

function start_session() {
    if [ $# -ne 2 ]; then
        echo "Usage: gotime start <feature1> <feature2>"
        exit 1
    fi
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository!"
        echo "Please run gotime from within a git repository."
        exit 1
    fi
    
    FEATURE1=$1
    FEATURE2=$2
    SESSION_ID=$(date +%s | tail -c 5)
    
    # Create session directory
    mkdir -p "$GOTIME_DIR"
    
    # Get current branch
    BASE_BRANCH=$(git branch --show-current)
    if [ -z "$BASE_BRANCH" ]; then
        # Detached HEAD state, use commit hash
        BASE_BRANCH=$(git rev-parse HEAD)
        echo "Warning: Detached HEAD state. Using commit $BASE_BRANCH as base."
    fi
    
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
    
    if check_terminal; then
        # Use Warp launch configuration
        launch_with_warp "$SESSION_ID" "$FEATURE1" "$FEATURE2" "$WORKTREE1" "$WORKTREE2"
    else
        # Fall back to tmux
        echo "Warp not detected, falling back to tmux..."
        launch_with_tmux "$SESSION_ID" "$WORKTREE1" "$WORKTREE2" "$FEATURE1" "$FEATURE2"
    fi
}

function launch_with_warp() {
    local SESSION_ID=$1
    local FEATURE1=$2
    local FEATURE2=$3
    local WORKTREE1=$4
    local WORKTREE2=$5
    
    # Create Warp launch configuration directory if it doesn't exist
    mkdir -p "$WARP_CONFIG_DIR"
    
    # Generate launch configuration filename
    CONFIG_FILENAME="gotime_${SESSION_ID}.yaml"
    CONFIG_FILE="$WARP_CONFIG_DIR/$CONFIG_FILENAME"
    
    # Create launch configuration with proper format
    cat > "$CONFIG_FILE" << EOF
name: gotime session ${SESSION_ID}
windows:
  - tabs:
      - title: gotime-${SESSION_ID}
        layout:
          split_direction: horizontal
          panes:
            - cwd: ${WORKTREE1}
              is_focused: true
              commands:
                - exec: echo "🚀 Working on ${FEATURE1}"
                - exec: echo "Branch: feature/${FEATURE1}-${SESSION_ID}"
                - exec: echo ""
                - exec: echo "Run your AI assistant or start coding!"
            - cwd: ${WORKTREE2}
              commands:
                - exec: echo "🚀 Working on ${FEATURE2}"
                - exec: echo "Branch: feature/${FEATURE2}-${SESSION_ID}"
                - exec: echo ""
                - exec: echo "Run your AI assistant or start coding!"
        color: blue
EOF
    
    # Save config file path to session
    echo "WARP_CONFIG=$CONFIG_FILE" >> "$SESSION_FILE"
    
    echo "Launching Warp with split panes..."
    echo "Config saved to: $CONFIG_FILE"
    
    # Open Warp with the launch configuration (just the filename!)
    echo "Opening: warp://launch/${CONFIG_FILENAME}"
    open "warp://launch/${CONFIG_FILENAME}"
    
    echo ""
    echo "✅ Gotime session started!"
    echo "📁 Feature 1: $FEATURE1 in $WORKTREE1"
    echo "📁 Feature 2: $FEATURE2 in $WORKTREE2"
    echo ""
    echo "When done, run: gotime end"
}

function launch_with_tmux() {
    local SESSION_ID=$1
    local WORKTREE1=$2
    local WORKTREE2=$3
    local FEATURE1=$4
    local FEATURE2=$5
    
    # Check for tmux
    if ! command -v tmux &> /dev/null; then
        echo "Error: Neither Warp nor tmux is available!"
        echo "Install tmux with: brew install tmux (macOS) or apt-get install tmux (Linux)"
        exit 1
    fi
    
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
        
        # Remove Warp config if it exists
        if [ ! -z "$WARP_CONFIG" ] && [ -f "$WARP_CONFIG" ]; then
            rm -f "$WARP_CONFIG"
            echo "Removed Warp launch configuration"
        fi
        
        rm -f "$SESSION_FILE"
        echo "Cleanup complete!"
    fi
}

function show_status() {
    if [ ! -f "$SESSION_FILE" ]; then
        echo "No active gotime session"
        exit 1
    fi
    
    source "$SESSION_FILE"
    echo "Active gotime session: $SESSION_ID"
    echo "Feature 1: $FEATURE1 (branch: $BRANCH1)"
    echo "Feature 2: $FEATURE2 (branch: $BRANCH2)"
    echo "Worktree 1: $WORKTREE1"
    echo "Worktree 2: $WORKTREE2"
    
    if [ ! -z "$WARP_CONFIG" ]; then
        echo "Warp config: $WARP_CONFIG"
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
    status)
        show_status
        ;;
    *)
        echo "Usage: gotime {start|end|status}"
        echo "  start <feature1> <feature2> - Start parallel development"
        echo "  end                         - End session and create PRs"
        echo "  status                      - Show active session info"
        exit 1
        ;;
esac
