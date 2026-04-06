#!/usr/bin/env bash
# =============================================================================
#  dev-session.sh — Launch N Claude Code agents in tmux panes
#
#  Usage:
#    ./dev-session.sh          # 8 Claude Code panes (default)
#    ./dev-session.sh 4        # 4 Claude Code panes
#    ./dev-session.sh 12       # 12 Claude Code panes
#
#  Each pane starts a shell ready for `claude`. The layout is auto-tiled.
#  Detach with Ctrl-a + d. Reattach with: tmux a -t agents
# =============================================================================
set -euo pipefail

NUM_PANES="${1:-8}"
SESSION_NAME="agents"

# ---------------------------------------------------------------------------
#  Idempotency: attach to existing session if it already exists
# ---------------------------------------------------------------------------
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session '$SESSION_NAME' already exists. Attaching..."
    exec tmux attach-session -t "$SESSION_NAME"
fi

echo "Creating tmux session '$SESSION_NAME' with $NUM_PANES Claude Code panes..."

# ---------------------------------------------------------------------------
#  Create the session with the first pane
# ---------------------------------------------------------------------------
tmux new-session -d -s "$SESSION_NAME" -n "agents"

# ---------------------------------------------------------------------------
#  Create remaining panes (N-1 splits)
# ---------------------------------------------------------------------------
for ((i = 2; i <= NUM_PANES; i++)); do
    tmux split-window -t "$SESSION_NAME:agents"
    # Re-tile after each split to keep things balanced
    tmux select-layout -t "$SESSION_NAME:agents" tiled
done

# ---------------------------------------------------------------------------
#  Final tiled layout
# ---------------------------------------------------------------------------
tmux select-layout -t "$SESSION_NAME:agents" tiled

# ---------------------------------------------------------------------------
#  Print instructions in each pane
# ---------------------------------------------------------------------------
for ((i = 1; i <= NUM_PANES; i++)); do
    tmux send-keys -t "$SESSION_NAME:agents.$i" \
        "echo '── Pane $i/$NUM_PANES ── Type: claude'" Enter
done

# ---------------------------------------------------------------------------
#  Select first pane and attach
# ---------------------------------------------------------------------------
tmux select-pane -t "$SESSION_NAME:agents.1"
exec tmux attach-session -t "$SESSION_NAME"
