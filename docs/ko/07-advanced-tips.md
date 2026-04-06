# 고급 팁 & 트릭

> **난이도:** 중급~상급  
> **사전 준비:** [Step 1~6](./01-tailscale-setup.md) 완료

이 문서는 Tailscale + SSH + tmux 환경을 한 단계 더 업그레이드하는 고급 기법을 다룹니다. 필요한 부분만 골라서 적용하세요.

---

## Tailscale 고급 기능

### 서브넷 라우팅 (Subnet Router)

Tailscale이 설치되지 않은 기기(사무실 NAS, 프린터 등)에도 접근할 수 있습니다. Tailnet의 한 노드를 "라우터"로 지정하면 그 노드가 속한 네트워크 전체에 접근 가능합니다.

```bash
# 서버에서 서브넷 라우팅 활성화
sudo tailscale set --advertise-routes=192.168.1.0/24

# 관리 콘솔에서 라우트 승인 필요
# https://login.tailscale.com/admin/machines → 해당 기기 → "Edit route settings"
```

```
┌─ Tailnet ───────────────────────────────────────────┐
│                                                     │
│  핸드폰 ──► 서브넷 라우터 ──► 사무실 NAS (192.168.1.5) │
│  (어디서든)   (Tailscale 설치)  (Tailscale 미설치)      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Exit 노드 (VPN 게이트웨이)

특정 노드를 통해 **모든** 인터넷 트래픽을 라우팅할 수 있습니다. 공공 와이파이에서 보안이 필요할 때 유용합니다.

```bash
# 서버를 exit 노드로 설정
sudo tailscale set --advertise-exit-node

# 클라이언트에서 exit 노드 사용
tailscale set --exit-node=dev-server
```

### ACL을 Git으로 관리 (GitOps)

ACL 설정을 Git 저장소에 저장하고 PR로 관리할 수 있습니다.

```bash
# 1. GitHub 저장소에 policy.hujson 파일 생성
# 2. Tailscale 관리 콘솔 → Settings → Policy file
# 3. "Use a git repository" 선택
# 4. 저장소 URL 연결
```

이렇게 하면 ACL 변경이 코드 리뷰를 거치게 되어 실수를 방지할 수 있습니다.

### 세션 레코딩

SSH 세션을 녹화하여 감사(audit) 로그로 활용할 수 있습니다. 팀 환경에서 보안 컴플라이언스에 유용합니다.

```jsonc
// ACL에 recorder 설정 추가
{
  "ssh": [
    {
      "action": "accept",
      "src": ["group:developers"],
      "dst": ["tag:production"],
      "users": ["ubuntu"],
      "recorder": ["tag:recorder"]
    }
  ]
}
```

---

## tmux 고급 기법

### 레이아웃 스크립팅

`dev-session.sh`처럼 프로젝트별 커스텀 레이아웃을 스크립트로 만들 수 있습니다.

```bash
#!/usr/bin/env bash
# fullstack-session.sh — 풀스택 개발 레이아웃
set -euo pipefail

SESSION="fullstack"

if tmux has-session -t "$SESSION" 2>/dev/null; then
    exec tmux attach-session -t "$SESSION"
fi

# Window 1: Claude Code
tmux new-session -d -s "$SESSION" -n "claude" -c ~/projects/my-app
tmux send-keys -t "$SESSION:claude" "claude" Enter

# Window 2: Frontend
tmux new-window -t "$SESSION" -n "frontend" -c ~/projects/my-app
tmux send-keys -t "$SESSION:frontend" "npm run dev" Enter

# Window 3: Backend
tmux new-window -t "$SESSION" -n "backend" -c ~/projects/my-app
tmux send-keys -t "$SESSION:backend" "npm run server" Enter

# Window 4: DB + Redis
tmux new-window -t "$SESSION" -n "infra" -c ~/projects/my-app
tmux split-window -t "$SESSION:infra" -h
tmux send-keys -t "$SESSION:infra.1" "docker compose up db" Enter
tmux send-keys -t "$SESSION:infra.2" "docker compose up redis" Enter

# Window 5: Tests (상하 분할)
tmux new-window -t "$SESSION" -n "test" -c ~/projects/my-app
tmux split-window -t "$SESSION:test" -v -p 50
tmux send-keys -t "$SESSION:test.1" "npm test -- --watch" Enter
tmux send-keys -t "$SESSION:test.2" "# integration tests here" Enter

# Window 6: Git
tmux new-window -t "$SESSION" -n "git" -c ~/projects/my-app

tmux select-window -t "$SESSION:claude"
exec tmux attach-session -t "$SESSION"
```

### tmuxinator (더 체계적인 레이아웃 관리)

YAML 파일로 레이아웃을 정의하는 도구입니다.

```bash
# 설치
gem install tmuxinator

# 프로젝트 설정 생성
tmuxinator new my-project
```

```yaml
# ~/.tmuxinator/my-project.yml
name: my-project
root: ~/projects/my-project

windows:
  - claude:
      panes:
        - claude
  - code:
      layout: main-vertical
      panes:
        - vim .
        - # terminal
  - server:
      layout: even-horizontal
      panes:
        - npm run dev
        - npm run server
  - git:
      panes:
        - git status
```

```bash
# 실행
tmuxinator start my-project

# 종료
tmuxinator stop my-project
```

### 커스텀 키 바인딩 추가

자주 쓰는 작업을 단축키로 등록할 수 있습니다.

```bash
# ~/.tmux.conf에 추가

# prefix + g → lazygit 실행 (새 윈도우)
bind g new-window -n "lazygit" "lazygit"

# prefix + T → htop 실행 (새 윈도우)
bind T new-window -n "htop" "htop"

# prefix + C → Claude Code 실행 (새 윈도우)
bind C new-window -n "claude" "claude"

# prefix + / → 현재 패인을 팝업으로 명령 실행
bind / display-popup -E "fzf"
```

### 중첩 tmux 세션 (Nested Sessions)

로컬 tmux 안에서 원격 tmux에 접속하는 경우, prefix 키가 충돌합니다.

**해결책: 원격 세션은 다른 prefix 사용**

```bash
# 로컬 .tmux.conf: prefix = Ctrl-a (기본)
# 원격 .tmux.conf에 추가:
set -g prefix C-b    # 원격에서는 Ctrl-b 사용
```

또는 **F12로 로컬/원격 전환**하는 방법:

```bash
# 로컬 .tmux.conf에 추가
# F12: 로컬 prefix 비활성화 → 모든 키가 원격 tmux로 전달
bind -T root F12 \
    set prefix None \;\
    set key-table off \;\
    set status-style "bg=#ff0000" \;\
    if -F '#{pane_in_mode}' 'send-keys -X cancel' \;\
    refresh-client -S

# F12 다시: 로컬 prefix 복원
bind -T off F12 \
    set -u prefix \;\
    set -u key-table \;\
    set -u status-style \;\
    refresh-client -S
```

> **상태 바가 빨간색으로 바뀌면** 현재 원격 모드라는 뜻입니다. F12를 다시 누르면 로컬 모드로 돌아갑니다.

---

## SSH 고급 기법

### 에이전트 포워딩 (Agent Forwarding)

로컬 SSH 키를 원격 서버에서 사용할 수 있습니다. 원격 서버에서 GitHub에 push할 때 유용합니다.

```bash
# 접속 시 에이전트 포워딩 활성화
ssh -A user@dev-server

# 또는 ~/.ssh/config에 설정
Host dev
    HostName dev-server
    ForwardAgent yes
```

```bash
# 원격 서버에서 확인
ssh-add -l
# → 로컬 키가 표시되면 성공
```

> **보안 주의:** 에이전트 포워딩은 신뢰할 수 있는 서버에서만 사용하세요. 서버가 탈취되면 로컬 SSH 키가 악용될 수 있습니다.

### 포트 포워딩 (SSH 터널)

원격 서버의 서비스를 로컬에서 접근할 수 있습니다.

```bash
# 로컬 포트 포워딩: 로컬 3000 → 원격 서버의 3000
ssh -L 3000:localhost:3000 user@dev-server

# 원격의 개발 서버를 로컬 브라우저에서 확인 가능
# http://localhost:3000
```

```bash
# ~/.ssh/config에 설정 (매번 명령어 입력 불필요)
Host dev
    HostName dev-server
    LocalForward 3000 localhost:3000
    LocalForward 5432 localhost:5432
    LocalForward 8080 localhost:8080
```

> **Tailscale 사용 시:** Tailscale IP로 직접 접근 가능하므로 (`http://100.64.0.2:3000`) 포트 포워딩이 불필요한 경우가 많습니다. 다만 `localhost`에서만 바인딩하는 서비스에는 여전히 포트 포워딩이 필요합니다.

### ProxyJump (Jump Host)

중간 서버를 거쳐 최종 서버에 접속합니다.

```bash
# 한 줄 명령
ssh -J user@jump-server user@target-server

# ~/.ssh/config
Host target
    HostName target-server
    ProxyJump jump-server
    User ubuntu
```

> **Tailscale을 쓰면 ProxyJump가 거의 필요 없습니다.** 모든 기기가 같은 Tailnet에 있으면 직접 접속하면 됩니다.

---

## 성능 최적화

### 레이턴시 줄이기

```bash
# SSH 연결 멀티플렉싱 (ControlMaster)
# ~/.ssh/config에 추가
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600    # 10분간 연결 유지
```

```bash
# 소켓 디렉토리 생성
mkdir -p ~/.ssh/sockets
```

이렇게 하면 같은 서버에 대한 후속 SSH 연결이 기존 연결을 재사용하여 즉시 연결됩니다.

### 느린 연결 최적화

모바일 데이터나 해외에서 접속할 때 느릴 수 있습니다.

```bash
# SSH 압축 활성화
ssh -C user@dev-server

# ~/.ssh/config
Host dev
    HostName dev-server
    Compression yes
```

tmux에서도 화면 갱신을 최적화할 수 있습니다.

```bash
# ~/.tmux.conf에 추가
# 상태 바 갱신 주기를 늘림 (기본 5초 → 느린 연결에서는 15초)
set -g status-interval 15

# 패인 리드로우 최적화
set -g remain-on-exit off
```

### Mosh 사용 (극단적으로 불안정한 연결)

Mosh(Mobile Shell)는 UDP 기반으로 동작하여 연결이 잠시 끊겨도 자동으로 복구합니다.

```bash
# 서버에 mosh 설치
sudo apt install mosh    # Ubuntu/Debian

# 접속 (SSH 대신)
mosh user@dev-server

# mosh + tmux 조합
mosh user@dev-server -- tmux attach -t dev
```

> **Tailscale + Mosh:** Tailscale IP를 사용하면 됩니다. `mosh user@100.64.0.2`

---

## 자동화

### SSH 로그인 시 tmux 자동 시작

SSH로 접속하면 자동으로 tmux 세션에 접속하도록 설정합니다.

```bash
# ~/.bashrc 또는 ~/.zshrc 맨 아래에 추가
if [[ -n "$SSH_CONNECTION" ]] && [[ -z "$TMUX" ]]; then
    # 기존 세션이 있으면 접속, 없으면 새로 생성
    tmux attach-session -t dev 2>/dev/null || tmux new-session -s dev
fi
```

더 세련된 버전 (dev-session.sh 활용):

```bash
# ~/.bashrc 또는 ~/.zshrc
if [[ -n "$SSH_CONNECTION" ]] && [[ -z "$TMUX" ]]; then
    if [[ -x "$HOME/dev-session.sh" ]]; then
        exec ~/dev-session.sh
    else
        tmux attach-session -t dev 2>/dev/null || tmux new-session -s dev
    fi
fi
```

> **주의:** `exec`를 사용하면 셸이 tmux로 대체되므로, tmux를 종료하면 SSH 연결도 끊깁니다. tmux 없이 셸을 쓰고 싶다면 `exec` 대신 그냥 호출하세요.

### 하루 시작 스크립트

매일 아침 실행하는 루틴을 자동화합니다.

```bash
#!/usr/bin/env bash
# morning.sh — 하루 시작 루틴
set -euo pipefail

echo "=== Good morning! Setting up your dev environment... ==="

# Git pull (모든 프로젝트)
for dir in ~/projects/*/; do
    if [[ -d "$dir/.git" ]]; then
        echo "Pulling $dir..."
        git -C "$dir" pull --rebase 2>/dev/null || true
    fi
done

# Docker 서비스 시작
docker compose -f ~/projects/infra/docker-compose.yml up -d 2>/dev/null || true

# dev-session 시작
exec ~/dev-session.sh
```

---

## 모니터링: tmux 상태 바에 시스템 정보

### CPU & 메모리 사용량

```bash
# ~/.tmux.conf — 상태 바 오른쪽에 시스템 정보 추가
set -g status-right-length 120
set -g status-right "#[fg=#fab387]CPU: #(top -l 1 | grep 'CPU usage' | awk '{print $3}')#[default] | #[fg=#a6e3a1]MEM: #(memory_pressure | head -1 | awk '{print $4}')#[default] | #[fg=#cdd6f4]#H#[default] | #[fg=#89b4fa,bold]%H:%M#[default] "
```

> **Linux 서버용:**
> ```bash
> set -g status-right "#[fg=#fab387]CPU: #(awk '/cpu /{printf \"%.0f%%\", ($2+$4)*100/($2+$4+$5)}' /proc/stat)#[default] | #[fg=#a6e3a1]MEM: #(free -h | awk '/Mem/{print $3\"/\"$2}')#[default] | #[fg=#cdd6f4]#H#[default] | #[fg=#89b4fa,bold]%H:%M#[default] "
> ```

### Git 브랜치 표시

```bash
# 현재 패인의 디렉토리에서 git 브랜치 표시
set -g status-right "#[fg=#cba6f7]#(cd #{pane_current_path}; git branch --show-current 2>/dev/null || echo '-')#[default] | #[fg=#cdd6f4]#H#[default] | #[fg=#89b4fa,bold]%H:%M#[default] "
```

### Tailscale 상태 표시

```bash
# Tailscale 연결 상태를 상태 바에 표시
set -g status-left "#[bg=#89b4fa,fg=#1e1e2e,bold]  #S #[bg=#1e1e2e,fg=#89b4fa] #[fg=#a6e3a1]TS:#(tailscale status --self --json 2>/dev/null | python3 -c 'import sys,json; d=json.load(sys.stdin); print(\"ON\" if d.get(\"Online\") else \"OFF\")' 2>/dev/null || echo '?') "
```

---

## 보안 체크리스트

환경 구축 후 아래 항목을 점검하세요.

- [ ] **Tailscale 2FA/MFA 활성화** — 계정 탈취 방지
- [ ] **기존 SSH 포트(22) 비활성화** — 공격 표면 축소
- [ ] **ACL 최소 권한 설정** — 필요한 접근만 허용
- [ ] **기기 키 만료 설정** — 분실 기기 자동 차단
- [ ] **tmux 스크롤백 민감 정보 주의** — 토큰, 비밀번호가 기록에 남을 수 있음
- [ ] **SSH 에이전트 포워딩은 신뢰할 수 있는 서버에서만** 사용
- [ ] **정기적으로 `tailscale status` 확인** — 알 수 없는 기기 확인

---

## 유용한 별칭 (Aliases)

`.bashrc` 또는 `.zshrc`에 추가하면 편리합니다.

```bash
# tmux 별칭
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias tn='tmux new-session -s'
alias tk='tmux kill-session -t'
alias ds='~/dev-session.sh'

# Tailscale 별칭
alias ts='tailscale status'
alias tsi='tailscale ip'
alias tsp='tailscale ping'

# 개발 서버 접속
alias dev='ssh dev-server'
```

---

## 마무리

이것으로 Tailscale + SSH + tmux를 활용한 원격 개발 환경 구축 가이드를 마칩니다. 이 환경의 핵심 가치를 다시 한번 정리합니다.

| 도구 | 해결하는 문제 |
|------|-------------|
| **Tailscale** | 어디서든, 어떤 네트워크에서든 내 서버에 접속 |
| **Tailscale SSH** | SSH 키 관리 부담 제거, 중앙 접근 제어 |
| **tmux** | 연결 끊김에 대한 완벽한 보호, 작업 맥락 보존 |
| **Claude Code** | AI 페어 프로그래머가 항상 대기 중 |
| **모바일 접속** | 아무 기기에서나 작업 이어가기 |

```
어디서든, 어떤 기기에서든, 끊김 없이 개발한다.
That's the dream. 그리고 이제 현실입니다.
```

---

> **처음부터 다시 보기:** [Step 1: Tailscale 설치 및 설정](./01-tailscale-setup.md)
