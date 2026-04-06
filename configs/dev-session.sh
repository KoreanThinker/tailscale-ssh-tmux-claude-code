#!/usr/bin/env bash
# =============================================================================
#  dev-session.sh — Tmux Development Session Launcher
#  Creates a pre-configured tmux workspace for remote development
#
#  Usage:
#    ./dev-session.sh              # Create/attach "dev" session
#    ./dev-session.sh my-project   # Create/attach "my-project" session
# =============================================================================
set -euo pipefail

SESSION_NAME="${1:-dev}"

# ---------------------------------------------------------------------------
#  Idempotency: attach to existing session if it already exists
# ---------------------------------------------------------------------------
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session '$SESSION_NAME' already exists. Attaching..."
    exec tmux attach-session -t "$SESSION_NAME"
fi

echo "Creating new tmux session: $SESSION_NAME"

# ---------------------------------------------------------------------------
#  Window 1: claude — Claude Code CLI
# ---------------------------------------------------------------------------
tmux new-session -d -s "$SESSION_NAME" -n "claude"
tmux send-keys -t "$SESSION_NAME:claude" "claude" Enter

# ---------------------------------------------------------------------------
#  Window 2: code — Editor (top 70%) + Terminal (bottom 30%)
# ---------------------------------------------------------------------------
tmux new-window -t "$SESSION_NAME" -n "code"
# The window starts as one pane (editor area)
tmux split-window -t "$SESSION_NAME:code" -v -p 30
# Focus back on the top pane (editor)
tmux select-pane -t "$SESSION_NAME:code.1"

# ---------------------------------------------------------------------------
#  Window 3: server — Server (left) + Logs (right)
# ---------------------------------------------------------------------------
tmux new-window -t "$SESSION_NAME" -n "server"
tmux split-window -t "$SESSION_NAME:server" -h -p 50
# Focus on the left pane (server)
tmux select-pane -t "$SESSION_NAME:server.1"

# ---------------------------------------------------------------------------
#  Window 4: git — Git operations (single pane)
# ---------------------------------------------------------------------------
tmux new-window -t "$SESSION_NAME" -n "git"

# ---------------------------------------------------------------------------
#  Final setup: select the first window and attach
# ---------------------------------------------------------------------------
tmux select-window -t "$SESSION_NAME:claude"
exec tmux attach-session -t "$SESSION_NAME"
