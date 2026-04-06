# Step 6: Running 8 Claude Code Agents in Parallel

> **Goal:** Launch 8 independent Claude Code agents in tmux panes and manage them like a team of senior developers -- each one tackling a different task simultaneously.

**Prerequisites:** [Step 5: Access from Your Phone](./05-mobile-access.md) completed, Claude Code CLI installed.

---

## The Concept

Claude Code is a terminal process. One terminal, one agent. But there is nothing stopping you from running eight of them at once.

tmux gives you the ability to tile multiple terminal panes inside a single window. Combine that with Claude Code, and you get **8 AI senior developers working in parallel** -- each one reading your codebase, writing code, running tests, and fixing bugs independently.

You become the engineering manager. Your job is to:

1. **Assign tasks** -- give each agent a clear, scoped objective
2. **Monitor progress** -- zoom into panes to check status
3. **Review and merge** -- inspect each agent's output before committing

This is not theoretical. It works today, right now, with the tmux configuration from this guide.

```
┌──────────────────┬──────────────────┬──────────────────┬──────────────────┐
│   Agent 1        │   Agent 2        │   Agent 3        │   Agent 4        │
│   Unit tests     │   DB refactor    │   New endpoint   │   Bug fix #42    │
│                  │                  │                  │                  │
├──────────────────┼──────────────────┼──────────────────┼──────────────────┤
│   Agent 5        │   Agent 6        │   Agent 7        │   Agent 8        │
│   API docs       │   DB migration   │   PR review      │   Query optimize │
│                  │                  │                  │                  │
└──────────────────┴──────────────────┴──────────────────┴──────────────────┘
```

Each pane is a fully independent Claude Code session with its own context, conversation history, and working directory. They do not interfere with each other.

---

## Prerequisites

Before you start, make sure you have:

- **Claude Code CLI** installed and authenticated on your remote machine
- **tmux** configured per [Step 3: tmux Setup](./03-tmux-setup.md) of this guide
- **A project** you want to work on (the agents need a codebase)

### Install Claude Code (if not done yet)

```bash
# Install Node.js via nvm (requires Node.js 18+)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc
nvm install --lts

# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Authenticate (one-time)
claude
```

---

## The dev-session.sh Script

The [`dev-session.sh`](../../configs/dev-session.sh) script is the launcher. It creates a tmux session with N panes arranged in a tiled grid -- one pane per agent.

### Usage

```bash
# Default: 8 panes
./configs/dev-session.sh

# Custom count
./configs/dev-session.sh 4     # 4 panes (smaller project, fewer tasks)
./configs/dev-session.sh 8     # 8 panes (the sweet spot)
./configs/dev-session.sh 12    # 12 panes (large project, many independent tasks)
```

### What it does

1. Creates a tmux session named `agents`
2. Splits the window into N panes
3. Applies a **tiled layout** so all panes are evenly sized
4. Prints a pane number label in each one (`Pane 1/8`, `Pane 2/8`, etc.)
5. Selects pane 1 and attaches you to the session

### Idempotency

If the `agents` session already exists, the script simply reattaches to it. You will not accidentally create duplicate sessions.

```bash
# First run: creates session with 8 panes
./configs/dev-session.sh 8

# Second run: reattaches to existing session
./configs/dev-session.sh 8
# → "Session 'agents' already exists. Attaching..."
```

### The tiled layout

tmux's `tiled` layout distributes panes as evenly as possible. For 8 panes, you get a clean 4x2 grid. For 4 panes, a 2x2 grid. For 12, a 4x3 grid. The layout auto-adjusts when you resize your terminal window.

---

## Workflow: Assigning Tasks to Agents

Once the session is running, you have 8 empty shells waiting. Here is the workflow.

### Step 1: Navigate to each pane and launch Claude Code

Use the keybindings from [Step 3: tmux Setup](./03-tmux-setup.md):

| Action | Keybinding | Notes |
|---|---|---|
| Move between panes | `Alt + Arrow` | No prefix needed -- instant switching |
| Zoom into a pane | `Ctrl-a + z` | Full screen. Press again to return to grid |
| Resize a pane | `Ctrl-a + Ctrl+Arrow` | 5-cell increments |

In each pane, navigate to the project and launch Claude Code:

```bash
cd ~/projects/my-app
claude
```

> **Tip:** If you are using git worktrees (recommended -- see below), each pane should `cd` into a different worktree.

### Step 2: Give each agent a task

Here is an example of how you might distribute 8 tasks across 8 agents:

| Pane | Task |
|---|---|
| 1 | "Write unit tests for the auth module" |
| 2 | "Refactor the database layer to use connection pooling" |
| 3 | "Build the new /api/v2/users endpoint" |
| 4 | "Fix bug #42 in the payment processing flow" |
| 5 | "Write API documentation for all public endpoints" |
| 6 | "Create the database migration for the v2 schema" |
| 7 | "Review the changes in PR #128 and suggest improvements" |
| 8 | "Profile and optimize the slow database queries" |

Each agent receives your instruction and starts working independently. They read the codebase, make changes, run commands, and report back -- all in their own pane.

### Step 3: Monitor progress

While the agents work, you can:

- **Glance at the grid** to see high-level status (who is still working, who is waiting for input)
- **Zoom into a pane** (`Ctrl-a + z`) to read detailed output, review code diffs, or answer follow-up questions
- **Zoom back out** (`Ctrl-a + z` again) to return to the grid view
- **Scroll up** in a pane (`Ctrl-a + [`, then arrow keys or Page Up) to see earlier output

### Step 4: Review and merge

When an agent finishes its task, zoom in, review its changes, and decide whether to commit. Do not blindly merge -- you are the manager, and every change should pass your review.

---

## Best Practices

### Use git worktrees for isolation

This is the single most important practice. If all 8 agents work on the same directory, they will step on each other's changes and create merge conflicts.

**Git worktrees** give each agent its own independent copy of the repository, all sharing the same `.git` directory. Changes in one worktree do not affect others.

See the [Git Worktree Pattern](#git-worktree-pattern) section below for setup instructions.

### Keep one pane as a command center (optional)

Instead of 8 agents, use 7 agents + 1 regular shell. The shell pane is your command center for:

- Running `git status` across worktrees
- Monitoring system resources (`htop`, `btop`)
- Running the dev server or watching logs
- Coordinating merges

```bash
# Launch 8 panes but only run claude in 7 of them
# Keep pane 8 as your shell
./configs/dev-session.sh 8
# In panes 1-7: type `claude`
# In pane 8: use as regular terminal
```

### Check progress by zooming periodically

Develop a rhythm: every 5-10 minutes, cycle through panes with `Alt + Arrow` to check who needs attention. Agents sometimes ask clarifying questions and wait for your input.

### Merge results carefully

After all agents finish:

1. Zoom into each pane and review the changes
2. In your command center pane, merge each worktree's branch into main one at a time
3. Run tests after each merge to catch conflicts early
4. Resolve any issues before merging the next branch

### Name your session meaningfully

```bash
# Instead of the default "agents" name, create project-specific sessions
tmux new-session -s my-project-agents -n agents
```

Or modify the `SESSION_NAME` variable in `dev-session.sh`:

```bash
SESSION_NAME="my-project"
```

---

## Git Worktree Pattern

This is the recommended setup for running multiple agents without conflicts.

### Directory structure

```
~/projects/my-app/              # Main repo (main branch)
~/projects/my-app-wt-1/         # Worktree for agent 1
~/projects/my-app-wt-2/         # Worktree for agent 2
~/projects/my-app-wt-3/         # Worktree for agent 3
~/projects/my-app-wt-4/         # Worktree for agent 4
~/projects/my-app-wt-5/         # Worktree for agent 5
~/projects/my-app-wt-6/         # Worktree for agent 6
~/projects/my-app-wt-7/         # Worktree for agent 7
~/projects/my-app-wt-8/         # Worktree for agent 8 (or command center)
```

### Setup commands

```bash
cd ~/projects/my-app

# Create worktrees with descriptive branch names
git worktree add ../my-app-wt-1 -b agent/auth-tests
git worktree add ../my-app-wt-2 -b agent/db-refactor
git worktree add ../my-app-wt-3 -b agent/api-v2-users
git worktree add ../my-app-wt-4 -b agent/fix-payment-bug
git worktree add ../my-app-wt-5 -b agent/api-docs
git worktree add ../my-app-wt-6 -b agent/db-migration
git worktree add ../my-app-wt-7 -b agent/pr-review
git worktree add ../my-app-wt-8 -b agent/query-optimization
```

### In each tmux pane

After launching `dev-session.sh 8`, go to each pane and point it to the right worktree:

```bash
# Pane 1
cd ~/projects/my-app-wt-1
claude

# Pane 2
cd ~/projects/my-app-wt-2
claude

# ... and so on for each pane
```

### Verify worktrees

```bash
git worktree list
# ~/projects/my-app           abcd123 [main]
# ~/projects/my-app-wt-1      abcd123 [agent/auth-tests]
# ~/projects/my-app-wt-2      abcd123 [agent/db-refactor]
# ...
```

### Cleanup after merging

```bash
cd ~/projects/my-app

# Remove worktrees when done
git worktree remove ../my-app-wt-1
git worktree remove ../my-app-wt-2
# ... repeat for all

# Prune any stale references
git worktree prune

# Delete merged branches
git branch -d agent/auth-tests agent/db-refactor agent/api-v2-users
```

---

## Scaling: 4 vs 8 vs 12+ Panes

### When to use 4 panes

- Smaller projects with fewer independent tasks
- Limited screen real estate (laptop screen)
- You want to read each agent's output comfortably without zooming

### When to use 8 panes (recommended)

- Medium to large projects with many independent modules
- You have a large monitor or are working over SSH (terminal can be any size)
- The sweet spot between parallelism and manageability

### When to use 12+ panes

- Very large codebases with many independent subsystems
- Sprint-planning scenarios where you want to knock out a dozen tasks at once
- You are comfortable managing many agents and have a systematic workflow

### Resource considerations

| Resource | Impact | Notes |
|---|---|---|
| **CPU** | Low | Claude Code itself is lightweight -- it sends requests to the API and applies changes locally |
| **Memory** | Low-moderate | Each Claude Code process uses ~100-200 MB. 8 agents = ~1-1.5 GB |
| **Network** | Moderate | Each agent makes API calls to Anthropic. 8 agents means 8x the API traffic |
| **API rate limits** | Main bottleneck | Check your Anthropic plan's rate limits. If you hit limits, reduce the number of concurrent agents |
| **Disk I/O** | Low-moderate | Agents read/write files and run commands. SSDs handle this easily |

> **Warning:** If you are on an Anthropic plan with strict rate limits, 8 concurrent agents can exhaust your quota quickly. Monitor your usage and adjust the number of agents accordingly.

---

## The Full Lifecycle

Here is the complete flow from start to finish:

### 1. Plan your tasks

Before launching agents, decide what work needs to be done. Write down 4-8 independent tasks that do not depend on each other.

### 2. Create worktrees

```bash
cd ~/projects/my-app
for i in $(seq 1 8); do
    git worktree add ../my-app-wt-$i -b agent/task-$i
done
```

### 3. Launch the agent grid

```bash
./configs/dev-session.sh 8
```

### 4. Assign tasks

Cycle through each pane (`Alt + Arrow`), `cd` into the corresponding worktree, launch `claude`, and give it the task.

### 5. Monitor

Check progress periodically. Answer questions when agents ask. Zoom in with `Ctrl-a + z` to review detailed output.

### 6. Review

When agents finish, review each one's changes carefully. Run tests. Read diffs.

### 7. Merge

From your main repo (or command center pane), merge each branch:

```bash
cd ~/projects/my-app
git merge agent/auth-tests
git merge agent/db-refactor
# ... resolve conflicts if any, run tests between merges
```

### 8. Cleanup

```bash
# Remove all worktrees
for i in $(seq 1 8); do
    git worktree remove ../my-app-wt-$i
done
git worktree prune

# Kill the tmux session
tmux kill-session -t agents
```

Your main repo is clean, all work is merged, and you just accomplished in one session what would normally take a team a full day.

---

## Security

All of this runs over Tailscale, which means:

### Everything is encrypted

```
Your device → [SSH encryption] → [WireGuard encryption (Tailscale)] → Dev machine
                                                                        ↓
                                                                   8 Claude Code agents
                                                                   reading/writing code
```

Two layers of encryption protect every keystroke and every line of code.

### No exposed ports

Your dev machine has zero ports open to the public internet. Tailscale SSH operates entirely within the WireGuard tunnel. Attackers cannot discover your machine, let alone connect to it. See [Step 1: Tailscale Setup](./01-tailscale-setup.md) for details.

### Code stays on the server

When you work remotely over SSH, your code never transfers to your local device. You send keystrokes; you receive terminal output. This is critical for proprietary codebases -- the source code never leaves the secure server.

### API keys stay on the server

Your Anthropic API key (or Claude Pro/Max session) is configured on the remote machine only. It never appears on your laptop, phone, or any client device. Even if your client device is compromised, your API credentials are safe.

### Perfect for proprietary work

This setup is ideal for working with sensitive codebases:

- Code is isolated on a server behind Tailscale
- No cloud IDE, no code syncing, no third-party access
- SSH + WireGuard encryption in transit
- Full disk encryption at rest (configure on your server)
- 8 agents working on your code, all contained within your infrastructure

---

## Summary

At this point, you have:

- [x] Claude Code installed on your remote dev machine
- [x] The `dev-session.sh` script for launching N agents in a tmux grid
- [x] A workflow for assigning, monitoring, and reviewing parallel agent work
- [x] Git worktree patterns for safe multi-agent development
- [x] An understanding of scaling and resource considerations
- [x] All traffic encrypted via Tailscale -- code and keys never leave the server

The complete stack:

```
Tailscale (networking) → SSH (access) → tmux (8 panes) → 8x Claude Code (parallel development)
```

You are no longer a solo developer with an AI assistant. You are an engineering manager with a team of 8 AI senior developers, accessible from any device, anywhere in the world.

**Next:** [Advanced Tips & Tricks](./07-advanced-tips.md) -- power-user configurations, automation, and optimization.
