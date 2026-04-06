# Tailscale + SSH + tmux + Claude Code

### Run 8 Claude Code agents in parallel from anywhere — even your phone.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![EN](https://img.shields.io/badge/lang-English-blue)](#)
[![KO](https://img.shields.io/badge/lang-한국어-red)](README.ko.md)

---

**[English Guide](guide/en.md)** | **[한국어 가이드](guide/ko.md)**

## What is this?

A step-by-step visual guide to set up a remote development environment where you can run **8 Claude Code AI agents simultaneously** in tmux panes — and access them from your laptop, phone, or tablet.

No developer experience required. Every step has a screenshot.

## The Stack

| Tool | What it does |
|------|-------------|
| [Tailscale](https://tailscale.com) | Encrypted mesh VPN — connects your devices. Free. |
| SSH | Secure terminal connection to your dev machine. |
| [tmux](https://github.com/tmux/tmux) | Runs 8 terminal panes that survive disconnects. |
| [Claude Code](https://claude.ai/code) | AI coding agent that runs in the terminal. |
| [Termius](https://termius.com) | Mobile SSH client — manage agents from your phone. |

## Guides

- **[English Guide with Screenshots](guide/en.md)**
- **[한국어 가이드 (스크린샷 포함)](guide/ko.md)**

## Configs

- [`configs/.tmux.conf`](configs/.tmux.conf) — tmux config
- [`configs/dev-session.sh`](configs/dev-session.sh) — Launch 8 Claude Code panes

## License

[MIT](LICENSE)
