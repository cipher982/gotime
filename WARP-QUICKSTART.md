# Gotime with Warp Terminal - Quick Start

## What's New?

This version of gotime uses **Warp's native launch configurations** instead of tmux, giving you:
- 🖱️ Better mouse support and click-to-select
- 🎨 Native Warp UI with proper pane management
- ⚡ Faster pane switching with Warp's shortcuts
- 📋 Better copy/paste and autocomplete

## Installation

```bash
# Make executable
chmod +x gotime-warp.sh

# Create alias (recommended)
echo "alias gotime='$(pwd)/gotime-warp.sh'" >> ~/.zshrc
source ~/.zshrc
```

## Usage

### 1. Start a session (in any git repo)
```bash
gotime start login-ui payment-api
```

This will:
1. Create 2 git worktrees
2. Generate a Warp launch configuration
3. Open Warp with split panes automatically
4. Each pane starts in its own feature branch

### 2. Work in parallel
- Warp opens with 2 panes side by side
- Each pane shows the feature name and branch
- Use Warp's native pane switching (⌘+] or click)
- Run your AI assistants in each pane

### 3. Check status
```bash
gotime status
```

Shows active session details without interrupting your work.

### 4. End session
```bash
gotime end
```

This will:
- Show commits from each feature
- Offer to push branches for PRs
- Clean up worktrees and Warp config

## How It Works

1. **Creates a YAML config** in `~/.warp/launch_configurations/`
2. **Uses Warp URI scheme**: `warp://launch/config-file`
3. **Warp reads the config** and creates the exact layout
4. **Automatic cleanup** when session ends

## Example Workflow

```bash
# Terminal 1: Start gotime
$ gotime start user-profile search-feature
Creating worktrees...
Launching Warp with split panes...
✅ Gotime session started!

# Warp opens with 2 panes automatically

# Left pane shows:
🚀 Working on user-profile
Branch: feature/user-profile-45678

# Right pane shows:
🚀 Working on search-feature  
Branch: feature/search-feature-45678

# Work in each pane, make commits...

# Terminal 1: End session
$ gotime end
=== Changes in user-profile ===
a1b2c3d Add profile component
d4e5f6g Add avatar upload

=== Changes in search-feature ===
g7h8i9j Implement search algorithm

Create PR for user-profile? [y/N] y
```

## Warp-Specific Tips

1. **Pane Navigation**:
   - Click panes directly
   - Use ⌘+] and ⌘+[ to cycle
   - Drag pane borders to resize

2. **Warp Features Work Normally**:
   - Command palette (⌘+P)
   - AI command search
   - Blocks and workflows
   - Input/output selection

3. **Multiple Windows**:
   - Each gotime session opens in a new Warp tab
   - Can run multiple sessions (different repos)

## Fallback to tmux

If Warp isn't detected, gotime automatically falls back to tmux. This happens when:
- Running on Linux without Warp
- Running in SSH sessions
- Warp isn't installed

## Troubleshooting

### Warp doesn't open
- Check if Warp is installed
- Try opening manually: `open "warp://launch/$HOME/.warp/launch_configurations/gotime_XXXXX.yaml"`

### Config file issues
- Check config exists: `ls ~/.warp/launch_configurations/gotime_*`
- View config: `cat ~/.warp/launch_configurations/gotime_XXXXX.yaml`

### Clean up stuck sessions
```bash
# Remove all gotime worktrees
git worktree list | grep gotime | awk '{print $1}' | xargs -I {} git worktree remove {} --force

# Remove session file
rm ~/.gotime_session

# Remove Warp configs
rm ~/.warp/launch_configurations/gotime_*.yaml
```

## Next Steps

Once comfortable:
1. Modify the startup commands in the script
2. Try different layout orientations (vertical splits)
3. Add more panes for 3+ features
4. Integrate with your specific AI tools

The Warp integration makes parallel development feel native and modern!
