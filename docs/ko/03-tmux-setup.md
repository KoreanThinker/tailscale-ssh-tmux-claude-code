# Step 3: tmux 설치 및 설정

> **소요 시간:** 15~20분  
> **난이도:** 초급~중급  
> **사전 준비:** [Step 2: Tailscale SSH 설정](./02-ssh-configuration.md) 완료

---

## tmux란?

**tmux** (Terminal Multiplexer)는 하나의 터미널 안에서 여러 개의 터미널 세션을 만들고 관리하는 도구입니다.

원격 개발에서 tmux가 필수인 이유는 딱 하나입니다.

> **SSH 연결이 끊겨도 작업이 그대로 유지됩니다.**

카페에서 노트북으로 작업하다가 와이파이가 끊겨도, 핸드폰으로 다시 접속하면 **끊기기 직전 화면 그대로** 이어서 작업할 수 있습니다.

```
시나리오: SSH 연결 끊김

❌ tmux 없이:
   노트북에서 작업 중 → WiFi 끊김 → SSH 연결 종료
   → 실행 중이던 프로세스 종료 → 편집 중이던 내용 유실
   → 재접속 → 처음부터 다시 시작...

✅ tmux 사용:
   노트북에서 작업 중 → WiFi 끊김 → SSH 연결 종료
   → tmux 세션은 서버에서 계속 실행 중!
   → 재접속 → tmux attach → 모든 것이 그대로!
```

---

## 핵심 개념: 세션, 윈도우, 패인

tmux는 **세션(Session)**, **윈도우(Window)**, **패인(Pane)** 세 가지 계층으로 구성됩니다.

```
┌─ tmux 서버 ──────────────────────────────────────────────────┐
│                                                              │
│  ┌─ Session: "dev" ────────────────────────────────────────┐ │
│  │                                                          │ │
│  │  ┌─ Window 1: "claude" ──┐  ┌─ Window 2: "code" ─────┐ │ │
│  │  │                        │  │  ┌─ Pane 1 ──────────┐ │ │ │
│  │  │  ┌─ Pane 1 ────────┐  │  │  │  vim main.ts      │ │ │ │
│  │  │  │                  │  │  │  │                    │ │ │ │
│  │  │  │  claude          │  │  │  ├────────────────────┤ │ │ │
│  │  │  │                  │  │  │  │  Pane 2            │ │ │ │
│  │  │  └──────────────────┘  │  │  │  $ npm run dev     │ │ │ │
│  │  └────────────────────────┘  │  └────────────────────┘ │ │ │
│  │                               └────────────────────────┘ │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌─ Session: "work" ───────────────────────────────────────┐ │
│  │  ...                                                     │ │
│  └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

| 개념 | 설명 | 비유 |
|------|------|------|
| **세션 (Session)** | 독립적인 작업 공간. 프로젝트별로 하나씩 만듭니다. | 가상 데스크톱 |
| **윈도우 (Window)** | 세션 안의 탭. 작업 종류별로 나눕니다. | 브라우저 탭 |
| **패인 (Pane)** | 윈도우 안의 분할 영역. 화면을 나누어 사용합니다. | 에디터의 분할 창 |

---

## 설치

### macOS (Homebrew)

```bash
brew install tmux
```

### Linux

#### Ubuntu / Debian

```bash
sudo apt update && sudo apt install -y tmux
```

#### Fedora / RHEL

```bash
sudo dnf install -y tmux
```

#### Arch Linux

```bash
sudo pacman -S tmux
```

### 소스 빌드 (최신 버전이 필요한 경우)

```bash
# 의존성 설치 (Ubuntu/Debian)
sudo apt install -y build-essential libevent-dev ncurses-dev bison pkg-config

# 소스 다운로드 및 빌드
TMUX_VERSION=3.5a
wget https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
tar xzf tmux-${TMUX_VERSION}.tar.gz
cd tmux-${TMUX_VERSION}
./configure && make
sudo make install
```

### 설치 확인

```bash
tmux -V
# 예상 출력: tmux 3.5a
```

---

## 설정 파일 (.tmux.conf)

이 가이드에서 제공하는 [`configs/.tmux.conf`](../../configs/.tmux.conf)를 사용합니다. 원격 개발과 Claude Code 워크플로우에 최적화된 설정입니다.

```bash
# 설정 파일 복사
cp configs/.tmux.conf ~/.tmux.conf
```

각 섹션을 살펴보겠습니다.

### Prefix 키 변경

```bash
# Ctrl-b (기본) → Ctrl-a 로 변경
unbind C-b
set -g prefix C-a
bind C-a send-prefix
```

`Ctrl-a`는 키보드 홈 로우에 가까워서 `Ctrl-b`보다 훨씬 누르기 쉽습니다. tmux의 모든 단축키는 **prefix 키를 먼저 누른 후** 해당 키를 누르는 방식입니다.

> **예시:** 새 윈도우를 만드려면 `Ctrl-a`를 누르고, 손을 떼고, `c`를 누릅니다.  
> 이 문서에서는 이것을 `prefix + c`로 표기합니다.

### 일반 설정

```bash
# 설정 리로드 단축키 (prefix + r)
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# ESC 지연 제거 (Vim/Neovim 사용자에게 매우 중요)
set -sg escape-time 0

# 스크롤백 버퍼 확대 (기본 2000줄 → 50000줄)
set -g history-limit 50000
```

| 설정 | 값 | 이유 |
|------|-----|------|
| `escape-time 0` | 0ms | ESC 키 지연을 제거하여 Vim이 즉각 반응합니다. |
| `history-limit 50000` | 50,000줄 | 긴 빌드 로그나 테스트 출력을 스크롤해서 볼 수 있습니다. |
| `focus-events on` | on | Vim의 `autoread` 등이 제대로 동작합니다. |

### 윈도우/패인 분할

```bash
# 직관적인 분할 단축키
bind | split-window -h -c "#{pane_current_path}"   # | → 좌우 분할
bind - split-window -v -c "#{pane_current_path}"   # - → 상하 분할
```

`-c "#{pane_current_path}"`는 분할 시 현재 디렉토리를 유지합니다. 이 옵션이 없으면 새 패인이 홈 디렉토리에서 열립니다.

```
prefix + |  → 좌우 분할         prefix + -  → 상하 분할

┌──────────┐                  ┌──────────────────────┐
│          │          │          │                      │
│  기존     │  새 패인 │          │     기존              │
│          │          │          │                      │
│          │          │          ├──────────────────────┤
│          │          │          │     새 패인            │
│          │          │          │                      │
└──────────┘                  └──────────────────────┘
```

### 패인 이동 (Alt + 방향키)

```bash
# prefix 없이 Alt + 방향키로 패인 이동
bind -n M-Left  select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up    select-pane -U
bind -n M-Down  select-pane -D
```

`-n` 옵션은 prefix 없이 바로 동작하는 키를 뜻합니다. 패인 간 이동이 매우 빠릅니다.

### 마우스 지원

```bash
set -g mouse on
```

마우스를 활성화하면 다음 작업을 마우스로 할 수 있습니다.

- 패인 클릭으로 포커스 이동
- 패인 경계를 드래그해서 크기 조정
- 스크롤 휠로 스크롤백 탐색
- 텍스트 드래그 선택

### 복사 모드 (Vi 스타일)

```bash
setw -g mode-keys vi

bind v copy-mode                                        # prefix + v → 복사 모드 진입
bind -T copy-mode-vi v   send-keys -X begin-selection   # v → 선택 시작
bind -T copy-mode-vi y   send-keys -X copy-selection-and-cancel  # y → 복사
```

### 상태 바 (Catppuccin Mocha 테마)

설정 파일에 포함된 상태 바는 [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) 색상 팔레트를 사용합니다.

```
┌─────────────────────────────────────────────────────────────┐
│  ◆ dev │ 1:claude  2:code  3:server  4:git │  dev-server  15:30 │
└─────────────────────────────────────────────────────────────┘
 ↑ 세션명          ↑ 윈도우 목록                ↑ 호스트명   ↑ 시간
```

---

## TPM (Tmux Plugin Manager) 설치

TPM은 tmux 플러그인을 관리하는 도구입니다.

```bash
# TPM 설치
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

설치 후 tmux를 실행하고 플러그인을 설치합니다.

```bash
# tmux 시작 (또는 이미 실행 중이면 설정 리로드)
tmux

# tmux 안에서 플러그인 설치
# prefix + I  (Shift + i)
```

> **TPM 단축키:**
> | 단축키 | 동작 |
> |--------|------|
> | `prefix + I` | 플러그인 설치 |
> | `prefix + U` | 플러그인 업데이트 |
> | `prefix + Alt + u` | 사용하지 않는 플러그인 제거 |

---

## 필수 플러그인

설정 파일에 포함된 4개의 플러그인을 설명합니다.

### tmux-sensible

```bash
set -g @plugin 'tmux-plugins/tmux-sensible'
```

tmux의 합리적인 기본 설정을 적용합니다. UTF-8 지원, 상태 바 갱신 주기 등을 자동으로 최적화합니다.

### tmux-yank

```bash
set -g @plugin 'tmux-plugins/tmux-yank'
```

tmux에서 복사한 텍스트를 **시스템 클립보드**에 자동으로 복사합니다. SSH로 원격 접속한 상태에서도 텍스트를 복사하여 로컬에서 붙여넣을 수 있습니다.

### tmux-resurrect

```bash
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'
```

tmux 세션 전체(윈도우 레이아웃, 패인 배치, 실행 중인 프로그램)를 **파일로 저장**하고 복원합니다.

| 단축키 | 동작 |
|--------|------|
| `prefix + Ctrl-s` | 현재 세션 저장 |
| `prefix + Ctrl-r` | 마지막 저장 시점으로 복원 |

### tmux-continuum

```bash
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'
```

tmux-resurrect를 **자동으로** 실행합니다.

- 15분마다 자동 저장
- tmux 서버 시작 시 자동 복원

> **resurrect + continuum 조합 효과:** 서버가 재부팅되어도 tmux를 시작하면 마지막 상태가 자동으로 복원됩니다. 세션, 윈도우, 패인 레이아웃이 모두 살아납니다.

---

## 첫 tmux 세션 실습

설치와 설정이 끝났으면 직접 사용해 봅니다.

### 1. 새 세션 만들기

```bash
# "dev"라는 이름의 세션 생성
tmux new-session -s dev
```

### 2. 패인 분할하기

```
# 좌우로 분할
prefix + |

# 상하로 분할
prefix + -
```

### 3. 패인 간 이동

```
# Alt + 방향키로 이동 (prefix 불필요)
Alt + Left   → 왼쪽 패인
Alt + Right  → 오른쪽 패인
Alt + Up     → 위 패인
Alt + Down   → 아래 패인
```

### 4. 새 윈도우 만들기

```
prefix + c    → 새 윈도우
prefix + ,    → 윈도우 이름 변경
```

### 5. 세션 분리 (Detach)

```
prefix + d    → 세션에서 빠져나오기 (세션은 백그라운드에서 계속 실행)
```

### 6. 세션 재접속 (Attach)

```bash
# 마지막 세션에 재접속
tmux attach

# 특정 세션에 재접속
tmux attach -t dev
```

### 7. 핵심 체험: 끊김 → 복구

실제로 SSH 연결 끊김과 복구를 체험해 보세요.

```bash
# 1. 서버에 SSH 접속
ssh user@dev-server

# 2. tmux 세션 시작
tmux new -s test

# 3. 뭔가 실행 (예: 카운터)
while true; do date; sleep 1; done

# 4. 터미널을 강제로 닫기 (X 버튼 클릭)

# 5. 다시 SSH 접속
ssh user@dev-server

# 6. tmux 재접속
tmux attach -t test

# 7. 카운터가 계속 돌고 있는 것을 확인!
```

---

## 문제 해결

| 증상 | 해결 방법 |
|------|-----------|
| "no server running" | tmux 서버가 실행 중이 아닙니다. `tmux`로 새 세션을 시작하세요. |
| 색상이 이상하게 보임 | 터미널 에뮬레이터가 256색/True Color를 지원하는지 확인하세요. |
| 마우스가 안 됨 | `set -g mouse on`이 설정에 있는지 확인하세요. |
| 플러그인이 설치 안 됨 | `~/.tmux/plugins/tpm` 디렉토리가 있는지 확인하고, `prefix + I`를 눌러 설치하세요. |
| prefix 키가 안 먹힘 | `.tmux.conf`를 올바른 위치(`~/.tmux.conf`)에 복사했는지 확인하세요. |

---

## 다음 단계

tmux의 기본 설치와 설정이 완료되었습니다. 다음 단계에서는 패인과 윈도우를 능숙하게 다루는 워크플로우를 배웁니다.

> **다음:** [Step 4: tmux 패인 & 워크플로우 마스터](./04-tmux-workflow.md)
