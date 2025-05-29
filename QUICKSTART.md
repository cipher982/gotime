# Gotime MVP - Quick Start Guide

## Prerequisites
- **Must be inside a Git repository** - gotime uses git worktrees
- tmux installed (`brew install tmux` on macOS)
- Basic familiarity with tmux (Ctrl-b is the prefix key)

## Git Repository Requirement

Gotime **must** be run from within a git repository because it:
- Creates git worktrees (isolated copies of your repo)
- Creates feature branches
- Manages git commits and pushes

If you try to run it outside a git repo, you'll see:
```
Error: Not in a git repository!
Please run gotime from within a git repository.
```

## Installation (30 seconds)

```bash
# Option 1: Add to PATH (recommended)
sudo ln -s $(pwd)/gotime.sh /usr/local/bin/gotime

# Option 2: Create alias
echo "alias gotime='$(pwd)/gotime.sh'" >> ~/.zshrc
source ~/.zshrc
```

## Basic Usage

### 1. Start a session
```bash
gotime start login-ui payment-api
```

This will:
- Create 2 git worktrees in `/tmp/gotime_sessions/`
- Create branches: `feature/login-ui-XXXXX` and `feature/payment-api-XXXXX`
- Open tmux with 2 panes side by side
- Each pane is in its own isolated git worktree

### 2. Work in parallel
- Left pane: Work on login-ui feature
- Right pane: Work on payment-api feature
- Use any AI coding assistant in each pane
- Make commits normally with `git add` and `git commit`

### 3. End session
```bash
# First, detach from tmux: Ctrl-b then d
gotime end
```

This will:
- Show commits made in each branch
- Ask if you want to push branches (for PR creation)
- Offer to clean up the worktrees

## Tmux Basics

- **Switch panes**: `Ctrl-b` then arrow keys
- **Detach session**: `Ctrl-b` then `d`
- **Scroll mode**: `Ctrl-b` then `[` (exit with `q`)
- **Kill pane**: `Ctrl-b` then `x`

## Example Workflow

```bash
# 1. Start working on two features
$ gotime start user-profile search-feature

# 2. In left pane (user-profile)
$ echo "Working on user profile"
$ git add .
$ git commit -m "Add user profile component"

# 3. Switch to right pane (Ctrl-b →)
$ echo "Working on search"
$ git add .
$ git commit -m "Implement search algorithm"

# 4. Detach when done (Ctrl-b d)

# 5. End session and create PRs
$ gotime end
```

## Tips

1. **Feature names**: Use short, descriptive names without spaces
2. **Commits**: Make regular commits in each pane
3. **AI assistants**: Run your AI tool (Cursor, Cline, etc.) in each pane independently
4. **Multiple sessions**: Only one session at a time is supported in this MVP

## Troubleshooting

### "No active gotime session found"
- You may have already ended the session
- Check if session file exists: `ls ~/.gotime_session`

### Tmux session already exists
- Kill existing session: `tmux kill-session -t gotime_XXXXX`
- List sessions: `tmux ls`

### Worktree errors
- List worktrees: `git worktree list`
- Remove stuck worktree: `git worktree remove /tmp/gotime_sessions/... --force`

### Can't push branches
- Make sure you have commits: `git log --oneline`
- Check remote: `git remote -v`
- Manual push: `git push origin feature/name-XXXXX`

## What's Next?

Once comfortable with this MVP:
1. Try working on 2 related features that share code
2. Use different AI models in each pane
3. Time how much faster you can develop in parallel

Ready to build the full version? Check out `gotime-v0.1-spec.md`!
