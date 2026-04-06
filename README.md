# Tailscale + SSH + tmux + Claude Code

### Run 8 Claude Code agents in parallel from anywhere — even your phone.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![EN](https://img.shields.io/badge/lang-English-blue)](#)
[![KO](https://img.shields.io/badge/lang-한국어-red)](README.ko.md)

---

## The Idea

One powerful dev machine. **Eight Claude Code agents** running simultaneously in tmux panes — one writing tests, one refactoring, one building features, one fixing bugs. All accessible from your laptop, phone, or tablet through Tailscale's encrypted mesh VPN.

You become the engineering manager of 8 AI senior developers that never sleep.

> Start 8 agents on your server. SSH in from your laptop. Disconnect. SSH in from your phone. **All 8 agents are still running, exactly where you left them.**

## Quick Start

```bash
# On your SERVER
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
tailscale set --ssh
npm install -g @anthropic-ai/claude-code

# On your CLIENT — download Tailscale from https://tailscale.com/download

# SSH in (no keys needed!) and launch 8 agents
ssh user@your-server
tmux new -s agents
# Split into 8 panes: Ctrl-a + | and Ctrl-a + - repeatedly, or:
./configs/dev-session.sh 8

# Each pane: type `claude` and assign a task
# Switch panes: Alt + Arrow  |  Zoom: Ctrl-a + z
# Detach: Ctrl-a + d  |  Reattach: tmux a -t agents
```

## Full Guide

| Step | Topic | EN | KO |
|------|-------|----|----|
| 1 | Tailscale Setup | [English](docs/en/01-tailscale-setup.md) | [한국어](docs/ko/01-tailscale-setup.md) |
| 2 | Tailscale SSH | [English](docs/en/02-ssh-configuration.md) | [한국어](docs/ko/02-ssh-configuration.md) |
| 3 | tmux Setup | [English](docs/en/03-tmux-setup.md) | [한국어](docs/ko/03-tmux-setup.md) |
| 4 | tmux Workflow | [English](docs/en/04-tmux-workflow.md) | [한국어](docs/ko/04-tmux-workflow.md) |
| 5 | Mobile Access | [English](docs/en/05-mobile-access.md) | [한국어](docs/ko/05-mobile-access.md) |
| 6 | 8 Agents in Parallel | [English](docs/en/06-claude-code-setup.md) | [한국어](docs/ko/06-claude-code-setup.md) |
| 7 | Advanced Tips | [English](docs/en/07-advanced-tips.md) | [한국어](docs/ko/07-advanced-tips.md) |

## Why This Stack?

| Tool | What it does |
|------|-------------|
| **Tailscale** | Encrypted mesh VPN. No port forwarding, no public IP. Free. |
| **Tailscale SSH** | Replaces SSH keys. Automatic key management + SSO. |
| **tmux** | 8 terminal panes in one session. Survives disconnects. |
| **Claude Code** | AI coding agent. Perfect for headless remote sessions. |
| **Termius** | Mobile SSH client. Manage agents from your phone. |

## Configs

- [`configs/.tmux.conf`](configs/.tmux.conf) — Production-grade tmux config
- [`configs/dev-session.sh`](configs/dev-session.sh) — Launch N Claude Code panes (default: 8)

## License

[MIT](LICENSE)
