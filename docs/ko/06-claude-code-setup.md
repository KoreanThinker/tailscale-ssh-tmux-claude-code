# Step 6: Claude Code 에이전트 8개 동시 실행

> **소요 시간:** 15~20분  
> **난이도:** 중급  
> **사전 준비:** [Step 1~5](./01-tailscale-setup.md) 완료, Claude Code CLI 설치 완료, Anthropic API 키 또는 Claude Max 구독

---

## 콘셉트: 왜 여러 Claude Code를 동시에 실행하나?

Claude Code 하나로도 강력하지만, **여러 개를 동시에 실행하면 생산성이 완전히 달라집니다.**

각 Claude Code 인스턴스는 독립적인 터미널 프로세스입니다. 서로의 존재를 모르고, 각자 다른 작업을 수행합니다. tmux 패인을 활용하면 하나의 터미널 화면에서 **8개 이상의 Claude Code 에이전트를 병렬로 실행**할 수 있습니다.

이것이 의미하는 바는 명확합니다. **시니어 개발자 8명으로 구성된 팀의 팀장이 되는 것입니다.**

```
┌─────────────────────────────────────────────────────────────────┐
│                        tmux 세션 "agents"                        │
│                                                                  │
│  ┌──────────────────┬──────────────────┬──────────────────┐      │
│  │  Pane 1          │  Pane 2          │  Pane 3          │      │
│  │  유닛 테스트 작성  │  DB 리팩토링      │  API 엔드포인트   │      │
│  │  claude           │  claude           │  claude           │      │
│  ├──────────────────┼──────────────────┼──────────────────┤      │
│  │  Pane 4          │  Pane 5          │  Pane 6          │      │
│  │  버그 수정         │  문서 작성        │  DB 마이그레이션  │      │
│  │  claude           │  claude           │  claude           │      │
│  ├──────────────────┼──────────────────┼──────────────────┤      │
│  │  Pane 7          │  Pane 8          │                  │      │
│  │  코드 리뷰         │  쿼리 최적화      │   (확장 가능)     │      │
│  │  claude           │  claude           │                  │      │
│  └──────────────────┴──────────────────┴──────────────────┘      │
│                                                                  │
│  Alt+방향키: 패인 전환  │  Ctrl-a z: 패인 확대/축소                  │
└─────────────────────────────────────────────────────────────────┘
```

한 에이전트가 테스트를 작성하는 동안, 다른 에이전트는 버그를 수정하고, 또 다른 에이전트는 문서를 작성합니다. 모든 작업이 **동시에** 진행됩니다.

---

## 사전 요구 사항

시작하기 전에 두 가지가 준비되어 있어야 합니다.

### 1. Claude Code CLI 설치

```bash
# Node.js 18+ 필요
npm install -g @anthropic-ai/claude-code

# 설치 확인
claude --version
```

처음 실행 시 인증이 필요합니다.

```bash
claude
# 화면의 안내에 따라 Anthropic 계정으로 로그인합니다.
# 헤드리스 서버의 경우 터미널에 표시되는 URL을 다른 기기의 브라우저에서 열면 됩니다.
```

### 2. 본 가이드의 tmux 설정 완료

[Step 3: tmux 설정](./03-tmux-setup.md)과 [Step 4: tmux 워크플로우](./04-tmux-workflow.md)가 완료되어 있어야 합니다. 특히 다음 키바인딩이 설정되어 있어야 합니다.

| 키바인딩 | 동작 | 설정 위치 |
|---------|------|----------|
| `Alt + 방향키` | 패인 전환 (prefix 불필요) | `.tmux.conf` |
| `Ctrl-a + z` | 패인 확대/축소 (줌 토글) | tmux 기본 기능 |
| `Ctrl-a + d` | 세션 분리 (detach) | tmux 기본 기능 |

---

## dev-session.sh 스크립트

이 가이드의 [`configs/dev-session.sh`](../../configs/dev-session.sh) 스크립트가 모든 것을 자동화합니다. 숫자 하나만 넘기면 해당 개수만큼의 Claude Code 패인이 타일 레이아웃으로 생성됩니다.

### 기본 사용법

```bash
# 실행 권한 부여 (최초 1회)
chmod +x ./configs/dev-session.sh

# 8개 패인 생성 (기본값)
./configs/dev-session.sh

# 4개 패인 생성 (소규모 작업)
./configs/dev-session.sh 4

# 12개 패인 생성 (대규모 작업)
./configs/dev-session.sh 12
```

### 스크립트가 하는 일

1. `agents`라는 이름의 tmux 세션을 생성합니다.
2. 지정한 개수만큼 패인을 분할합니다.
3. 매 분할마다 `tiled` 레이아웃을 적용하여 모든 패인의 크기가 균등하게 유지됩니다.
4. 각 패인에 번호를 표시합니다 (`── Pane 1/8 ── Type: claude`).
5. 첫 번째 패인을 선택한 상태로 세션에 접속합니다.

> **멱등성:** 이미 `agents` 세션이 존재하면 새로 만들지 않고 기존 세션에 재접속합니다. 안심하고 반복 실행할 수 있습니다.

### 타일 레이아웃

tmux의 `tiled` 레이아웃은 모든 패인을 격자 형태로 균등하게 배치합니다.

```
4개 패인:                     8개 패인:
┌──────────┬──────────┐      ┌──────┬──────┬──────┐
│  Pane 1  │  Pane 2  │      │  1   │  2   │  3   │
│          │          │      ├──────┼──────┼──────┤
├──────────┼──────────┤      │  4   │  5   │  6   │
│  Pane 3  │  Pane 4  │      ├──────┼──────┼──────┤
│          │          │      │  7   │  8   │      │
└──────────┴──────────┘      └──────┴──────┴──────┘
```

터미널 창이 클수록 각 패인에 더 많은 내용이 표시됩니다. 모니터가 크다면 12개 이상의 패인도 충분히 실용적입니다.

---

## 워크플로우: 작업 배정

스크립트를 실행하면 8개의 빈 패인이 준비됩니다. 이제 각 패인에 접속하여 Claude Code를 실행하고 작업을 지시하면 됩니다.

### 패인 이동과 확대

```bash
# 패인 전환 (prefix 불필요 — 가장 자주 쓰는 키)
Alt + ←    # 왼쪽 패인으로
Alt + →    # 오른쪽 패인으로
Alt + ↑    # 위쪽 패인으로
Alt + ↓    # 아래쪽 패인으로

# 패인 확대 (전체화면으로 키워서 출력 확인)
Ctrl-a + z   # 현재 패인을 전체화면으로 확대
Ctrl-a + z   # 다시 누르면 원래 타일 레이아웃으로 복원
```

> **팁:** `Ctrl-a + z`(줌 토글)는 가장 중요한 키바인딩입니다. 타일 레이아웃에서는 각 패인이 작게 보이므로, 특정 에이전트의 진행 상황을 자세히 확인할 때 반드시 활용하세요.

### 각 패인에서 Claude Code 실행

패인으로 이동한 뒤 `claude`를 입력하면 에이전트가 시작됩니다. 프로젝트 디렉토리에서 실행하면 해당 프로젝트의 컨텍스트를 자동으로 인식합니다.

```bash
# 각 패인에서 실행
cd ~/projects/my-app
claude
```

### 8개 패인 작업 배정 예시

실제로 하나의 프로젝트에서 8개의 에이전트에게 동시에 작업을 배정하는 예시입니다.

| 패인 | 작업 지시 | 카테고리 |
|-----|---------|---------|
| **1** | "auth 모듈 유닛 테스트 작성해줘" | 테스트 |
| **2** | "데이터베이스 레이어를 커넥션 풀링으로 리팩토링해줘" | 리팩토링 |
| **3** | "새로운 /api/v2/users 엔드포인트 만들어줘" | 기능 개발 |
| **4** | "결제 처리 플로우의 버그 #42 수정해줘" | 버그 수정 |
| **5** | "공개 API 엔드포인트 전체 문서 작성해줘" | 문서화 |
| **6** | "v2 스키마용 데이터베이스 마이그레이션 만들어줘" | DB |
| **7** | "PR #128 변경사항 리뷰하고 개선 사항 제안해줘" | 코드 리뷰 |
| **8** | "느린 데이터베이스 쿼리 프로파일링하고 최적화해줘" | 성능 최적화 |

8개 에이전트가 동시에 작업하므로, 혼자 순차적으로 진행하는 것보다 **몇 배 더 빠르게** 프로젝트가 진행됩니다.

> **경고:** 여러 에이전트가 **같은 파일**을 동시에 수정하면 충돌이 발생합니다. 각 에이전트의 작업 범위가 서로 겹치지 않도록 배정하세요. 이 문제를 구조적으로 해결하는 방법은 아래 [Git Worktree 패턴](#git-worktree-패턴)을 참고하세요.

---

## 모범 사례

### 1. Git worktree로 충돌 방지

가장 중요한 모범 사례입니다. 각 에이전트가 **독립된 작업 디렉토리**에서 작업하도록 git worktree를 사용하세요. 같은 파일을 동시에 수정하는 충돌을 원천 차단할 수 있습니다. 자세한 방법은 아래 [Git Worktree 패턴](#git-worktree-패턴)에서 설명합니다.

### 2. 커맨드 센터 패인 활용 (선택)

8개 패인 중 하나를 Claude Code 대신 일반 셸로 유지하여 **커맨드 센터**로 활용할 수 있습니다. 테스트 실행, git 상태 확인, 로그 모니터링 등 전체 상황을 파악하는 용도입니다.

```bash
# Pane 8을 커맨드 센터로 활용
./configs/dev-session.sh 8

# Pane 1~7: claude 실행 후 작업 배정
# Pane 8: 일반 셸로 유지

# 커맨드 센터에서 자주 사용하는 명령어:
git status                    # 전체 변경 사항 확인
git worktree list             # 각 worktree 상태 확인
npm test                      # 테스트 실행
tail -f logs/app.log          # 로그 모니터링
```

### 3. 주기적으로 진행 상황 확인

에이전트에게 작업을 배정한 뒤 방치하지 마세요. 주기적으로 각 패인을 **확대(`Ctrl-a + z`)**하여 진행 상황을 확인하세요.

```
순회 패턴:
  Alt+→ → Ctrl-a z (확대) → 상태 확인 → Ctrl-a z (축소) → Alt+→ → 반복
```

### 4. 머지 전 변경사항 신중하게 리뷰

AI 에이전트의 코드를 맹신하지 마세요. 각 에이전트의 작업이 완료되면 반드시 변경사항을 직접 리뷰한 뒤 머지하세요. 테스트 통과 여부, 코드 품질, 의도한 동작 여부를 모두 확인해야 합니다.

```bash
# 각 worktree에서 변경사항 확인
cd ~/projects/my-app-auth-tests
git diff
npm test

# 문제 없으면 메인 브랜치에 머지
git checkout main
git merge feat/auth-tests
```

---

## Git Worktree 패턴

여러 에이전트가 동시에 같은 저장소에서 작업할 때, **git worktree**는 필수입니다. 각 에이전트에게 독립된 작업 디렉토리를 제공하여 파일 충돌을 원천 차단합니다.

### 권장 디렉토리 구조

```
~/projects/
├── my-app/                    # 메인 worktree (main 브랜치)
├── my-app-auth-tests/         # Pane 1: 테스트 작성
├── my-app-db-refactor/        # Pane 2: DB 리팩토링
├── my-app-api-v2/             # Pane 3: 새 API 엔드포인트
├── my-app-bugfix-42/          # Pane 4: 버그 수정
├── my-app-docs/               # Pane 5: 문서 작성
├── my-app-migration/          # Pane 6: DB 마이그레이션
├── my-app-review/             # Pane 7: 코드 리뷰
└── my-app-perf/               # Pane 8: 성능 최적화
```

### Worktree 생성 명령어

```bash
# 메인 저장소에서 실행
cd ~/projects/my-app

# 각 작업별 worktree 생성
git worktree add ../my-app-auth-tests   -b feat/auth-tests
git worktree add ../my-app-db-refactor  -b feat/db-refactor
git worktree add ../my-app-api-v2       -b feat/api-v2
git worktree add ../my-app-bugfix-42    -b fix/bugfix-42
git worktree add ../my-app-docs         -b docs/api-docs
git worktree add ../my-app-migration    -b feat/db-migration
git worktree add ../my-app-review       -b chore/review-128
git worktree add ../my-app-perf         -b perf/query-optimization
```

### 각 패인에서 해당 worktree로 이동 후 Claude Code 실행

```bash
# Pane 1에서
cd ~/projects/my-app-auth-tests
claude
# → "auth 모듈 유닛 테스트 작성해줘"

# Pane 2에서
cd ~/projects/my-app-db-refactor
claude
# → "데이터베이스 레이어를 커넥션 풀링으로 리팩토링해줘"

# ... 나머지 패인도 동일한 패턴
```

### Worktree 관리

```bash
# 모든 worktree 목록 확인
git worktree list

# 작업 완료 후 worktree 제거
git worktree remove ../my-app-auth-tests

# 삭제된 worktree 정리
git worktree prune
```

> **팁:** 각 worktree는 독립적인 브랜치이므로, 작업이 완료되면 PR을 만들어 메인 브랜치에 머지하는 일반적인 git 워크플로우를 따르면 됩니다.

---

## 스케일링: 패인 개수 가이드

패인 개수는 작업의 성격과 사용 가능한 리소스에 따라 조절하세요.

### 4개 패인 — 집중 작업

```bash
./configs/dev-session.sh 4
```

- 소규모 프로젝트나 밀접하게 관련된 작업들에 적합합니다.
- 각 패인이 충분히 커서 출력을 확대하지 않고도 확인할 수 있습니다.
- 리소스 사용량이 적습니다.

### 8개 패인 — 권장 기본값

```bash
./configs/dev-session.sh 8
```

- 대부분의 프로젝트에서 최적의 균형점입니다.
- 다양한 카테고리의 작업을 동시에 진행할 수 있습니다.
- 27인치 이상의 모니터에서 쾌적하게 사용 가능합니다.

### 12개 이상 패인 — 대규모 작업

```bash
./configs/dev-session.sh 12
```

- 대규모 리팩토링이나 마이그레이션 프로젝트에 적합합니다.
- 넓은 모니터(32인치+) 또는 다중 모니터 환경에서 권장합니다.
- 개별 패인이 상당히 작아지므로 `Ctrl-a + z` 줌 기능을 적극 활용해야 합니다.

### 리소스 고려사항

| 항목 | 설명 |
|-----|------|
| **CPU** | Claude Code 자체는 CPU를 거의 사용하지 않습니다. 하지만 에이전트가 실행하는 빌드, 테스트, 린트 명령어가 CPU를 사용합니다. 8개 에이전트가 동시에 `npm test`를 실행하면 부하가 클 수 있습니다. |
| **메모리** | 각 Claude Code 인스턴스는 메모리를 적게 사용합니다 (Node.js 프로세스 1개). 8개를 실행해도 수백 MB 수준입니다. |
| **API Rate Limit** | 가장 중요한 제약입니다. 각 Claude Code 인스턴스가 독립적으로 API를 호출하므로, 8개를 동시에 실행하면 API 호출량이 8배가 됩니다. Claude Max 구독은 이를 감안하여 충분한 rate limit을 제공하지만, API 키 사용 시 비용을 주의하세요. |
| **디스크** | git worktree 사용 시 각 worktree가 저장소의 작업 디렉토리를 복사합니다. `.git` 디렉토리는 공유되므로 큰 부담은 없지만, 대규모 저장소에서는 디스크 사용량을 확인하세요. |

> **경고:** API 키로 과금하는 경우, 8개 에이전트를 동시에 실행하면 비용이 빠르게 증가할 수 있습니다. Claude Max 구독을 사용하면 비용 걱정 없이 마음껏 실행할 수 있습니다.

---

## 전체 라이프사이클

하나의 개발 스프린트에서 8개 에이전트를 활용하는 전체 흐름입니다.

```
1. 세션 시작
   └─ ./configs/dev-session.sh 8

2. Worktree 생성
   └─ git worktree add ../my-app-{task} -b {branch}  (x8)

3. 에이전트 시작 & 작업 배정
   └─ 각 패인: cd worktree → claude → 작업 지시

4. 모니터링
   └─ Alt+방향키로 패인 순회
   └─ Ctrl-a z로 확대하여 상세 확인
   └─ 필요 시 추가 지시 또는 방향 수정

5. 리뷰
   └─ 각 에이전트의 작업 완료 확인
   └─ git diff로 변경사항 검토
   └─ 테스트 실행 (npm test, etc.)

6. 머지
   └─ PR 생성 또는 직접 머지
   └─ 충돌 해결 (있는 경우)

7. 정리
   └─ git worktree remove ../my-app-{task}  (x8)
   └─ git worktree prune
   └─ tmux kill-session -t agents  (또는 Ctrl-a d로 detach 후 나중에 재사용)
```

> **팁:** 세션을 종료하지 않고 `Ctrl-a + d`로 detach하면, 나중에 `tmux attach -t agents`로 재접속할 수 있습니다. 에이전트가 아직 작업 중이었다면 결과가 그대로 남아 있습니다. Tailscale + tmux의 핵심 강점입니다.

---

## 보안

여러 Claude Code 에이전트를 원격 서버에서 실행해도 보안은 철저하게 유지됩니다.

### Tailscale로 전 트래픽 암호화

```
Phone/Laptop → [SSH 암호화] → [WireGuard 암호화 (Tailscale)] → 개발 서버
```

모든 통신이 이중으로 암호화됩니다. SSH 프로토콜 암호화 위에 Tailscale의 WireGuard 터널이 추가됩니다. 공개 인터넷에 노출되는 포트가 없으므로, 공격자가 서버를 발견하는 것조차 불가능합니다.

### API 키 노출 없음

Claude Code의 인증 정보는 서버에만 저장됩니다. SSH 터미널을 통해 전달되는 것은 키 입력과 텍스트 출력뿐입니다. API 키가 네트워크를 통해 전송되는 일은 없습니다.

### 코드는 서버에만 존재

원격으로 Claude Code를 사용할 때, 코드는 서버를 떠나지 않습니다. 여러분의 기기에는 터미널 출력(텍스트)만 전달됩니다. 민감한 코드베이스를 다루는 경우에 특히 중요한 장점입니다.

```
인증 체인:
  Identity Provider (Google/GitHub 등)
    → Tailscale 인증
      → Tailscale SSH 인증서
        → tmux 세션
          → Claude Code (x8)
```

모든 단계가 인증되고 암호화됩니다.

---

## 문제 해결

| 증상 | 해결 방법 |
|------|-----------|
| `claude: command not found` | 설치 확인: `npm list -g @anthropic-ai/claude-code` 또는 재설치 |
| 인증 실패 | `claude logout` 후 `claude` 실행하여 재인증 |
| 패인이 너무 작아서 내용이 안 보임 | `Ctrl-a + z`로 해당 패인을 전체화면으로 확대 |
| tmux 안에서 색상이 안 나옴 | `.tmux.conf`에 `set -g default-terminal "tmux-256color"` 확인 ([Step 3](./03-tmux-setup.md) 참고) |
| 여러 에이전트가 같은 파일 수정으로 충돌 | git worktree로 각 에이전트에게 독립된 작업 디렉토리 제공 |
| API rate limit 초과 | 동시 실행 에이전트 수를 줄이거나 Claude Max 구독 사용 |
| 이전 대화를 이어가고 싶음 | `claude --resume`으로 마지막 대화를 이어갈 수 있습니다 |

---

## 다음 단계

이제 8개의 Claude Code 에이전트를 동시에 운용하는 방법을 익혔습니다. 개발 생산성이 완전히 다른 차원으로 올라갈 것입니다. 마지막으로 이 환경을 더욱 강력하게 만들어주는 고급 팁과 트릭을 알아봅니다.

> **다음:** [고급 팁 & 트릭](./07-advanced-tips.md)
