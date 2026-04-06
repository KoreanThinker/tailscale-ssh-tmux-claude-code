# Tailscale + SSH + tmux + Claude Code

### Claude Code 에이전트 8개를 동시에 돌리세요 — 핸드폰에서도.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![EN](https://img.shields.io/badge/lang-English-blue)](README.md)
[![KO](https://img.shields.io/badge/lang-한국어-red)](#)

---

## 아이디어

강력한 개발 머신 한 대. tmux 패인에서 **Claude Code 에이전트 8개**가 동시에 돌아갑니다 — 하나는 테스트 작성, 하나는 리팩토링, 하나는 새 기능, 하나는 버그 수정. Tailscale 암호화 메시 VPN을 통해 노트북, 핸드폰, 태블릿 어디서든 접속.

쉬지 않는 시니어 개발자 8명의 팀장이 되는 겁니다.

> 서버에서 에이전트 8개를 시작. 노트북에서 SSH 접속. 연결 끊기. 핸드폰에서 다시 접속. **8개 에이전트 전부 그 자리에서 계속 돌아가고 있습니다.**

## 빠른 시작

```bash
# 서버에서
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
tailscale set --ssh
npm install -g @anthropic-ai/claude-code

# 클라이언트 — https://tailscale.com/download 에서 Tailscale 다운로드

# SSH 접속 (키 필요 없음!) 후 에이전트 8개 실행
ssh user@your-server
tmux new -s agents
# 8개 패인으로 분할: Ctrl-a + | 와 Ctrl-a + - 반복, 또는:
./configs/dev-session.sh 8

# 각 패인에서: `claude` 입력 후 작업 배정
# 패인 전환: Alt + 방향키  |  확대: Ctrl-a + z
# 분리: Ctrl-a + d  |  재접속: tmux a -t agents
```

## 전체 가이드

| 단계 | 주제 | EN | KO |
|------|------|----|----|
| 1 | Tailscale 설치 | [English](docs/en/01-tailscale-setup.md) | [한국어](docs/ko/01-tailscale-setup.md) |
| 2 | Tailscale SSH | [English](docs/en/02-ssh-configuration.md) | [한국어](docs/ko/02-ssh-configuration.md) |
| 3 | tmux 설치 | [English](docs/en/03-tmux-setup.md) | [한국어](docs/ko/03-tmux-setup.md) |
| 4 | tmux 워크플로우 | [English](docs/en/04-tmux-workflow.md) | [한국어](docs/ko/04-tmux-workflow.md) |
| 5 | 모바일 접속 | [English](docs/en/05-mobile-access.md) | [한국어](docs/ko/05-mobile-access.md) |
| 6 | 에이전트 8개 동시 실행 | [English](docs/en/06-claude-code-setup.md) | [한국어](docs/ko/06-claude-code-setup.md) |
| 7 | 고급 팁 | [English](docs/en/07-advanced-tips.md) | [한국어](docs/ko/07-advanced-tips.md) |

## 왜 이 스택?

| 도구 | 하는 일 |
|------|---------|
| **Tailscale** | 암호화 메시 VPN. 포트 포워딩 없이, 공인 IP 없이. 무료. |
| **Tailscale SSH** | SSH 키 대체. 자동 키 관리 + SSO. |
| **tmux** | 한 세션에 8개 터미널 패인. 연결 끊겨도 유지. |
| **Claude Code** | AI 코딩 에이전트. 헤드리스 원격 세션에 최적. |
| **Termius** | 모바일 SSH 클라이언트. 핸드폰에서 에이전트 관리. |

## 설정 파일

- [`configs/.tmux.conf`](configs/.tmux.conf) — 프로덕션급 tmux 설정
- [`configs/dev-session.sh`](configs/dev-session.sh) — N개 Claude Code 패인 실행 (기본: 8)

## 라이선스

[MIT](LICENSE)
