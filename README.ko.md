# Tailscale + SSH + tmux + Claude Code

### Claude Code 에이전트 8개를 동시에 돌리세요 — 핸드폰에서도.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![EN](https://img.shields.io/badge/lang-English-blue)](README.md)
[![KO](https://img.shields.io/badge/lang-한국어-red)](#)

---

**[English Guide](guide/en.md)** | **[한국어 가이드](guide/ko.md)**

## 이게 뭔가요?

원격 개발 환경을 세팅하는 **스크린샷 기반 비주얼 가이드**입니다. tmux 패인에서 **Claude Code AI 에이전트 8개를 동시에 실행**하고, 노트북/핸드폰/태블릿 어디서든 접속할 수 있습니다.

개발 경험이 없어도 됩니다. 모든 단계에 스크린샷이 있습니다.

## 스택

| 도구 | 하는 일 |
|------|---------|
| [Tailscale](https://tailscale.com) | 암호화 메시 VPN — 디바이스를 연결합니다. 무료. |
| SSH | 개발 머신에 안전하게 접속합니다. |
| [tmux](https://github.com/tmux/tmux) | 연결 끊겨도 유지되는 8개 터미널 패인. |
| [Claude Code](https://claude.ai/code) | 터미널에서 실행되는 AI 코딩 에이전트. |
| [Termius](https://termius.com) | 모바일 SSH — 핸드폰에서 에이전트 관리. |

## 가이드

- **[English Guide with Screenshots](guide/en.md)**
- **[한국어 가이드 (스크린샷 포함)](guide/ko.md)**

## 설정 파일

- [`configs/.tmux.conf`](configs/.tmux.conf) — tmux 설정
- [`configs/dev-session.sh`](configs/dev-session.sh) — Claude Code 8개 패인 실행

## 라이선스

[MIT](LICENSE)
