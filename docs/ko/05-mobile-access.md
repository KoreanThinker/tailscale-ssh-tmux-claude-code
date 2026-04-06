# Step 5: 핸드폰에서 접속하기 (Tailscale + Termius)

> **소요 시간:** 10~15분  
> **난이도:** 초급  
> **사전 준비:** [Step 1~4](./01-tailscale-setup.md) 완료, 스마트폰 (iOS 또는 Android)

---

## 꿈의 환경: 핸드폰에서도 코딩!

이 섹션이 이 가이드의 하이라이트입니다.

노트북에서 시작한 작업을 **아무 준비 없이** 핸드폰에서 이어서 할 수 있습니다. 출퇴근길 지하철에서, 카페에서 노트북 없이, 심지어 침대에서도 개발 서버의 Claude Code에 접속하여 작업할 수 있습니다.

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   아침: 노트북에서 작업 시작                                │
│   ┌──────────────────┐                                  │
│   │  ssh dev-server  │                                  │
│   │  tmux new -s dev │                                  │
│   │  claude          │                                  │
│   └──────────────────┘                                  │
│            │                                            │
│            ▼                                            │
│   점심: 핸드폰으로 이어서                                   │
│   ┌──────────────────┐                                  │
│   │  Termius 앱      │                                  │
│   │  → dev-server    │                                  │
│   │  → tmux attach   │  ← 노트북 작업 화면 그대로!         │
│   └──────────────────┘                                  │
│            │                                            │
│            ▼                                            │
│   저녁: 다시 노트북에서                                     │
│   ┌──────────────────┐                                  │
│   │  ssh dev-server  │                                  │
│   │  tmux attach     │  ← 핸드폰 작업까지 반영되어 있음!    │
│   └──────────────────┘                                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 1단계: 핸드폰에 Tailscale 설치

### iOS

1. [App Store에서 Tailscale](https://apps.apple.com/app/tailscale/id1470499037)을 설치합니다.
2. 앱을 열고 **Sign in**을 탭합니다.
3. 노트북/서버에서 사용한 **같은 계정**으로 로그인합니다.

### Android

1. [Google Play에서 Tailscale](https://play.google.com/store/apps/details?id=com.tailscale.ipn)을 설치합니다.
2. 앱을 열고 **Sign in**을 탭합니다.
3. 노트북/서버에서 사용한 **같은 계정**으로 로그인합니다.

### 연결 확인

Tailscale 앱을 열면 Tailnet에 연결된 모든 기기가 보입니다.

```
My Devices
─────────────────────
● macbook-pro       100.64.0.1    connected
● dev-server        100.64.0.2    connected
● iphone            100.64.0.3    connected  ← 이 기기!
```

> **핵심:** 핸드폰이 Tailnet에 합류하는 순간, 개발 서버에 직접 접속할 수 있습니다. 같은 와이파이일 필요 없고, 포트 포워딩도 필요 없습니다. 4G/5G에서도 됩니다.

---

## 2단계: Termius 설치 (모바일 SSH 클라이언트)

### 왜 Termius인가?

| 기능 | Termius | 기본 터미널 앱 |
|------|---------|---------------|
| 모바일 최적화 키보드 | O (Ctrl, Alt, Esc 등 특수 키 바로 사용) | X |
| 스니펫 (자주 쓰는 명령어 저장) | O | X |
| 다중 세션 탭 | O | 제한적 |
| SFTP 파일 브라우저 | O | X |
| 키보드 단축키 커스터마이징 | O | X |
| 크로스 플랫폼 동기화 | O (iOS, Android, Mac, Windows) | X |
| **무료** | O (기본 기능) | - |

### 설치

- **iOS:** [App Store에서 Termius](https://apps.apple.com/app/termius-ssh-client/id549039908) 설치
- **Android:** [Google Play에서 Termius](https://play.google.com/store/apps/details?id=com.server.auditor.ssh.client) 설치

---

## 3단계: Termius에 호스트 추가

### Tailscale MagicDNS 사용 (권장)

1. Termius를 열고 **Hosts** 탭으로 이동합니다.
2. 우측 상단 **+** 버튼을 탭합니다.
3. 다음 정보를 입력합니다.

```
Label:      Dev Server
Hostname:   dev-server          ← MagicDNS 이름!
Port:       22
Username:   hyun                ← 서버의 사용자 이름
```

> **MagicDNS가 안 될 때:** `dev-server` 대신 Tailscale IP (`100.64.0.2`)를 입력하세요.

4. **Connect**를 탭하면 끝입니다.

### Tailscale SSH를 사용하는 경우

Tailscale SSH가 활성화되어 있으면 비밀번호나 SSH 키 설정이 불필요합니다. 호스트네임과 사용자명만 입력하면 자동으로 연결됩니다.

> **중요:** Tailscale 앱이 백그라운드에서 실행 중이어야 합니다. iOS에서는 Tailscale VPN이 "연결됨" 상태인지 확인하세요.

---

## 4단계: tmux 세션 재접속

Termius로 서버에 접속한 후, 노트북에서 작업하던 tmux 세션에 바로 재접속합니다.

```bash
# 기존 세션 목록 확인
tmux ls

# 세션에 재접속
tmux attach -t dev
```

또는 `dev-session.sh`를 사용합니다 (세션이 있으면 자동으로 재접속).

```bash
./dev-session.sh
```

이제 노트북에서 보던 화면이 **그대로** 핸드폰에 나타납니다. Claude Code가 실행 중이었다면 대화 내역도 그대로입니다.

---

## 모바일 개발 팁

### tmux 줌으로 집중하기 (prefix + z)

핸드폰의 작은 화면에서 여러 패인이 동시에 보이면 글씨가 너무 작습니다. **줌 기능**을 적극 활용하세요.

```
# 현재 패인을 전체 화면으로
Ctrl-a, z

# 다시 원래 레이아웃으로
Ctrl-a, z
```

### 워크플로우: 하나씩 집중

```
1. prefix + 1   → Claude Code 윈도우로 이동
2. (Claude에게 질문/명령)
3. prefix + 2   → 코드 윈도우로 이동
4. prefix + z   → 에디터 패인 줌인
5. (코드 확인/수정)
6. prefix + z   → 줌 해제
7. Alt + Down   → 터미널 패인으로 이동
8. prefix + z   → 터미널 줌인
9. (테스트 실행)
```

### Termius 키보드 활용

Termius는 터미널 위에 추가 키보드 바를 제공합니다.

```
┌──────────────────────────────────────────┐
│  ESC  TAB  Ctrl  Alt  ←  →  ↑  ↓  |  - │  ← 추가 키바
├──────────────────────────────────────────┤
│                                          │
│         일반 소프트 키보드                   │
│                                          │
└──────────────────────────────────────────┘
```

자주 쓰는 tmux 명령:

| 동작 | Termius에서 입력 |
|------|-----------------|
| prefix (Ctrl-a) | `Ctrl` 키 탭 → `a` 탭 |
| 패인 이동 | `Alt` 키 탭 → 방향키 탭 |
| 줌 토글 | `Ctrl` → `a`, 그 후 `z` |
| 복사 모드 | `Ctrl` → `a`, 그 후 `v` |

### Termius 스니펫 활용

자주 입력하는 명령을 스니펫으로 저장하면 핸드폰에서 편합니다.

| 스니펫 이름 | 명령 |
|------------|------|
| tmux-attach | `tmux attach -t dev` |
| dev-session | `./dev-session.sh` |
| git-status | `git status` |
| npm-test | `npm test` |

---

## 대안 SSH 클라이언트

Termius 외에도 좋은 모바일 SSH 클라이언트가 있습니다.

### Blink Shell (iOS 전용)

```
장점:
  - Mosh 프로토콜 지원 (불안정한 연결에서도 끊김 없음)
  - 네이티브 iOS 키보드 지원
  - 오픈 소스 (무료)

단점:
  - iOS만 지원
  - Termius보다 초기 설정이 복잡

설치: App Store에서 "Blink Shell" 검색
```

### JuiceSSH (Android 전용)

```
장점:
  - Android에서 가장 인기 있는 SSH 클라이언트
  - 깔끔한 UI
  - 무료 (광고 포함)

단점:
  - Android만 지원
  - 플러그인 시스템이 다소 복잡

설치: Google Play에서 "JuiceSSH" 검색
```

### 추천 조합

| 플랫폼 | 1순위 | 2순위 |
|--------|-------|-------|
| iOS | Termius | Blink Shell |
| Android | Termius | JuiceSSH |

> **팁:** 불안정한 네트워크(지하철, 이동 중)에서는 Mosh를 지원하는 클라이언트가 유리합니다. Mosh는 연결이 잠시 끊겨도 자동으로 재연결합니다. 다만 Tailscale + tmux 조합이 이미 끊김에 강하므로, 대부분의 경우 SSH만으로 충분합니다.

---

## 디바이스 간 완전한 워크플로우

### 일과 시나리오

```
08:00  집, 데스크톱
       └─ ssh dev-server → tmux new -s work → claude
       └─ Claude에게 기능 설계 요청, 코드 생성

09:00  출근길, 지하철, 핸드폰
       └─ Termius → dev-server → tmux attach -t work
       └─ Claude의 응답 확인, 코드 리뷰
       └─ prefix + d (detach)

09:30  회사, 노트북
       └─ ssh dev-server → tmux attach -t work
       └─ Claude가 생성한 코드에서 이어서 작업
       └─ 테스트 작성, 서버 실행

12:30  점심 산책, 핸드폰
       └─ Termius → tmux attach -t work
       └─ CI 결과 확인, Claude에게 버그 수정 요청
       └─ prefix + d (detach)

13:00  회사, 노트북
       └─ tmux attach -t work
       └─ 수정된 코드 확인 → PR 생성 → 머지

18:00  퇴근길, 지하철, 핸드폰
       └─ Termius → tmux attach -t work
       └─ 배포 상태 확인, 내일 작업 정리
```

> **핵심 포인트:** 디바이스가 바뀌어도 tmux 세션은 하나입니다. 모든 맥락이 유지됩니다.

---

## 문제 해결

| 증상 | 해결 방법 |
|------|-----------|
| Termius에서 "Connection refused" | 핸드폰의 Tailscale 앱이 연결(VPN 활성) 상태인지 확인하세요. |
| 접속은 되지만 화면이 깨짐 | Termius 설정에서 터미널 인코딩을 UTF-8로, 폰트를 고정폭으로 설정하세요. |
| tmux 세션이 없다고 나옴 | 다른 기기에서 `tmux ls`로 세션이 실행 중인지 확인하세요. |
| 특수 키가 안 먹힘 | Termius 키보드 바에서 Ctrl, Alt 등의 특수 키를 사용하세요. |
| 화면이 너무 작아서 읽기 힘듦 | `prefix + z`로 현재 패인을 줌하세요. 또는 핸드폰을 가로로 돌리세요. |

---

## 다음 단계

핸드폰에서도 개발 서버에 접속할 수 있게 되었습니다. 다음 단계에서는 원격 서버에서 Claude Code를 실행하는 최적의 환경을 만들어 봅니다.

> **다음:** [Step 6: Claude Code 원격 실행](./06-claude-code-setup.md)
