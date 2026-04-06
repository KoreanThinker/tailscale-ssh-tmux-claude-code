# 세팅 가이드: Tailscale + SSH + tmux + Claude Code

Claude Code 에이전트 8개를 동시에 돌리세요 — 핸드폰에서도.

---

## Step 1: Tailscale 가입하기

[tailscale.com](https://tailscale.com)에 접속해서 **"Get started - it's free!"** 버튼을 클릭하세요.

![Tailscale 홈페이지](images/01-tailscale-home.png)

Google, Microsoft, GitHub, Apple 중 하나로 가입하세요. 카드 등록 없이 무료입니다.

![Tailscale 가입](images/02-tailscale-signup.png)

---

## Step 2: 서버에 Tailscale 설치하기

[tailscale.com/download](https://tailscale.com/download)에서 플랫폼을 선택하세요.

![Tailscale 다운로드](images/03-tailscale-download.png)

**Linux 서버**라면 — 이 명령어 하나만 붙여넣으세요:

![Tailscale Linux 설치](images/05-tailscale-download-linux.png)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

그 다음 Tailscale을 시작하고 SSH를 켜세요:

```bash
sudo tailscale up
tailscale set --ssh
```

끝입니다. 이제 다른 모든 디바이스에서 이 서버에 접속할 수 있습니다.

---

## Step 3: 노트북/핸드폰에 Tailscale 설치하기

접속할 모든 디바이스에 Tailscale을 설치하세요:

- **Mac/Windows**: [tailscale.com/download](https://tailscale.com/download)
- **iPhone/iPad**: App Store → "Tailscale" 검색
- **Android**: Google Play → "Tailscale" 검색

![Tailscale iOS 다운로드](images/04-tailscale-download-ios.png)

Step 1에서 사용한 **같은 계정**으로 로그인하세요. 모든 디바이스가 자동으로 서로를 인식합니다.

---

## Step 4: 서버에 SSH 접속하기

노트북에서 터미널을 열고 입력하세요:

```bash
ssh 사용자이름@서버이름
```

> SSH 키가 필요 없습니다! Tailscale이 인증을 자동으로 처리합니다.

![Tailscale SSH 문서](images/06-tailscale-ssh-docs.png)

---

## Step 5: tmux와 Claude Code 설치하기

서버에서 tmux와 Claude Code를 설치하세요:

```bash
# tmux 설치
sudo apt install tmux          # Ubuntu/Debian
brew install tmux              # macOS

# Claude Code 설치
npm install -g @anthropic-ai/claude-code
```

포함된 tmux 설정을 복사하세요:

```bash
cp configs/.tmux.conf ~/.tmux.conf
```

---

## Step 6: Claude Code 에이전트 8개 실행하기

여기가 핵심입니다. 포함된 스크립트를 실행하세요:

```bash
./configs/dev-session.sh 8
```

**타일 레이아웃으로 8개 패인**이 있는 tmux 세션이 생성됩니다. 각 패인에서 Claude Code를 실행할 준비가 되어 있습니다.

각 패인에서 `claude`를 입력하고 작업을 지시하세요:

| 패인 | 작업 |
|------|------|
| 1 | "auth 모듈 테스트 작성해줘" |
| 2 | "데이터베이스 레이어 리팩토링해줘" |
| 3 | "새 /api/v2/users 엔드포인트 만들어줘" |
| 4 | "결제 버그 #42 수정해줘" |
| 5 | "API 문서 작성해줘" |
| 6 | "데이터베이스 마이그레이션 만들어줘" |
| 7 | "PR #128 리뷰해줘" |
| 8 | "느린 쿼리 최적화해줘" |

**핵심 단축키:**
- 패인 전환: `Alt + 방향키`
- 패인 확대 (전체화면): `Ctrl-a` 다음 `z`
- 분리 (에이전트 계속 실행): `Ctrl-a` 다음 `d`
- 나중에 재접속: `tmux a -t agents`

---

## Step 7: 핸드폰에서 접속하기

핸드폰에 **Termius**를 설치하세요 — 최고의 모바일 SSH 앱입니다.

![Termius](images/07-termius-home.png)

1. App Store 또는 Google Play에서 [Termius](https://termius.com) 다운로드
2. 새 호스트 추가 → 서버의 Tailscale 호스트네임 입력
3. 접속 → `tmux a -t agents` 입력
4. 8개 에이전트가 핸드폰에서 바로 보입니다!

**모바일 팁:**
- `Ctrl-a` → `z`로 패인 확대 — 전체화면이 되어 읽기 훨씬 편합니다
- 가로 모드가 tmux에 더 좋습니다
- Termius 키보드 단축키 바를 활용하세요

---

## 워크플로우

1. 서버에서 **에이전트 시작**
2. 각 패인에 **작업 배정**
3. **진행 상황 확인** — 패인 전환하면서 체크
4. 언제든 **연결 끊기** — 노트북 닫기, 외출하기
5. 아무 디바이스에서 **재접속** — 핸드폰, 태블릿, 다른 노트북
6. **8개 에이전트 전부 그대로**, 정확히 그 자리에서 계속 실행 중

끝입니다. 이제 세계 어디서든 AI 개발자 8명을 관리할 수 있습니다.

---

## 설정 파일

- [`.tmux.conf`](../configs/.tmux.conf) — 프로덕션급 tmux 설정
- [`dev-session.sh`](../configs/dev-session.sh) — Claude Code N개 패인 실행 스크립트

## 링크

- [Tailscale](https://tailscale.com) — 무료 메시 VPN
- [Tailscale SSH 문서](https://tailscale.com/docs/features/tailscale-ssh) — 키 없는 SSH
- [Claude Code](https://claude.ai/code) — AI 코딩 에이전트
- [Termius](https://termius.com) — 모바일 SSH 클라이언트
- [tmux 치트시트](https://tmuxcheatsheet.com) — 단축키 참조
