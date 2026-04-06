# Step 1: Tailscale 설치 및 설정

> **소요 시간:** 5~10분  
> **난이도:** 초급  
> **필요한 것:** Tailscale 계정 (무료), macOS / Linux / Windows 컴퓨터

---

## Tailscale이란?

[Tailscale](https://tailscale.com)은 **WireGuard** 기반의 메시(mesh) VPN입니다. 기존 VPN과 달리 중앙 서버를 거치지 않고 기기 간에 직접 암호화 터널을 만들어 줍니다.

```
┌─────────────────────────────────────────────────────────────┐
│                    Tailscale 네트워크 (Tailnet)                │
│                                                             │
│   ┌──────────┐     WireGuard 터널     ┌──────────────┐     │
│   │  노트북   │◄──────────────────────►│  개발 서버    │     │
│   │ (집)      │                        │ (사무실)      │     │
│   └──────────┘                        └──────────────┘     │
│        ▲                                     ▲              │
│        │            WireGuard 터널            │              │
│        │         ┌──────────────┐            │              │
│        └────────►│   스마트폰    │◄───────────┘              │
│                  │ (카페)        │                           │
│                  └──────────────┘                           │
└─────────────────────────────────────────────────────────────┘
```

핵심 특징을 정리하면 다음과 같습니다.

| 특징 | 설명 |
|------|------|
| **제로 설정** | 설치하고 로그인하면 끝입니다. 복잡한 네트워크 설정이 필요 없습니다. |
| **메시 VPN** | 기기끼리 직접 연결(peer-to-peer)하므로 속도가 빠릅니다. |
| **WireGuard 기반** | 현존하는 가장 빠르고 안전한 VPN 프로토콜을 사용합니다. |
| **NAT 통과** | 공유기(NAT) 뒤에 있어도 자동으로 연결됩니다. |
| **무료 플랜** | 개인 사용자는 기기 100대까지 무료입니다. |

## 원격 개발에 Tailscale을 쓰는 이유

개발 서버에 원격으로 접속하려면 보통 이런 작업이 필요합니다.

- 공유기에서 포트 포워딩 설정
- 공인 IP 주소 확인 (그리고 바뀔 때마다 갱신)
- 방화벽 규칙 설정
- Dynamic DNS 서비스 등록

**Tailscale을 쓰면 이 모든 것이 필요 없습니다.**

```
❌ 기존 방식:
   노트북 → 인터넷 → 공인 IP → 포트 포워딩 → 방화벽 → 개발 서버
   (설정할 것 많음, 보안 위험, IP 바뀌면 접속 불가)

✅ Tailscale 방식:
   노트북 → Tailscale → 개발 서버
   (설치 후 로그인만 하면 끝, 어디서든 접속 가능)
```

> **핵심 요약:** Tailscale을 쓰면 같은 네트워크에 있는 것처럼 어디서든 개발 서버에 접속할 수 있습니다. 포트 포워딩, 공인 IP, 복잡한 방화벽 규칙이 모두 필요 없어집니다.

---

## 설치

### macOS

macOS에는 세 가지 설치 방법이 있습니다. **원격 개발이 목적이라면 CLI(독립형) 설치를 강력히 권장합니다.**

#### macOS 변형 비교

| | App Store | 독립형(Standalone) | CLI (`tailscaled`) |
|---|---|---|---|
| **설치 방법** | Mac App Store | [tailscale.com](https://tailscale.com/download) | `brew install tailscale` |
| **GUI 트레이 아이콘** | O | O | X |
| **SSH 서버 (수신)** | X | **O** | **O** |
| **서브넷 라우팅** | X | O | O |
| **Exit 노드** | X | O | O |
| **자동 업데이트** | App Store 경유 | 자체 업데이트 | Homebrew 경유 |
| **권장 대상** | 일반 사용자 | **개발자 (GUI 필요 시)** | **개발자 (CLI 선호 시)** |

> **중요:** App Store 버전은 샌드박스 제한으로 **SSH 서버 기능을 지원하지 않습니다**. 이 가이드에서는 SSH 서버가 필수이므로, 반드시 **독립형** 또는 **CLI** 버전을 설치하세요.

#### 방법 1: 독립형 설치 (권장 -- GUI + SSH 모두 지원)

1. [tailscale.com/download/mac](https://tailscale.com/download/mac)에서 다운로드합니다.
2. `.zip` 파일을 풀고, `Tailscale.app`을 `/Applications`에 드래그합니다.
3. 앱을 실행하면 메뉴바에 Tailscale 아이콘이 나타납니다.

#### 방법 2: CLI 설치 (Homebrew)

```bash
# Homebrew로 설치
brew install tailscale

# 데몬 시작 (백그라운드 서비스로 등록)
sudo brew services start tailscale

# 로그인
tailscale up
```

#### 방법 3: App Store (SSH 서버 미지원 -- 비권장)

Mac App Store에서 "Tailscale"을 검색하여 설치합니다. 단, SSH 서버 기능이 없으므로 이 가이드의 다음 단계를 진행할 수 없습니다.

---

### Linux

한 줄로 설치할 수 있습니다.

```bash
# 공식 설치 스크립트 (Ubuntu, Debian, Fedora, CentOS, Arch 등 지원)
curl -fsSL https://tailscale.com/install.sh | sh
```

설치 후 서비스를 시작하고 로그인합니다.

```bash
# 서비스 시작
sudo systemctl enable --now tailscaled

# 로그인 (브라우저에서 인증 URL이 열립니다)
sudo tailscale up
```

> **배포판별 수동 설치:** 공식 설치 스크립트 대신 패키지 매니저를 직접 사용하고 싶다면 [공식 문서](https://tailscale.com/kb/1031/install-linux)를 참고하세요.

---

### Windows

1. [tailscale.com/download/windows](https://tailscale.com/download/windows)에서 설치 파일을 다운로드합니다.
2. 설치 마법사를 따라 진행합니다.
3. 시스템 트레이의 Tailscale 아이콘을 클릭하여 로그인합니다.

---

## 첫 로그인 및 인증

설치가 완료되면 Tailscale 계정으로 로그인합니다.

```bash
# CLI에서 로그인
tailscale up
```

실행하면 브라우저에서 인증 페이지가 열립니다. Google, Microsoft, GitHub 등의 계정으로 로그인할 수 있습니다.

```
To authenticate, visit:
    https://login.tailscale.com/a/1234567890ab
```

> **팁:** 헤드리스 서버(모니터가 없는 서버)에서는 위 URL을 복사하여 다른 기기의 브라우저에서 열면 됩니다.

인증이 완료되면 기기가 자동으로 **Tailnet**(Tailscale 네트워크)에 합류합니다.

---

## 연결 확인

### `tailscale status`

Tailnet에 연결된 모든 기기를 확인합니다.

```bash
tailscale status
```

예상 출력:

```
100.64.0.1    macbook-pro        user@gmail.com   macOS   -
100.64.0.2    dev-server         user@gmail.com   linux   -
100.64.0.3    iphone             user@gmail.com   iOS     -
```

각 기기에 `100.x.x.x` 형태의 Tailscale IP가 자동으로 할당된 것을 확인할 수 있습니다. 이 IP는 어디서든 사용할 수 있는 고정 주소입니다.

### `tailscale ip`

현재 기기의 Tailscale IP 주소를 확인합니다.

```bash
tailscale ip
```

예상 출력:

```
100.64.0.1
fd7a:115c:a1e0::1
```

첫 번째 줄이 IPv4, 두 번째 줄이 IPv6 주소입니다.

---

## MagicDNS -- IP 대신 이름으로 접속

Tailscale의 **MagicDNS** 기능을 사용하면 IP 주소를 외울 필요가 없습니다. 기기 이름(호스트네임)으로 바로 접속할 수 있습니다.

```bash
# IP 주소로 접속 (불편)
ssh user@100.64.0.2

# MagicDNS로 접속 (편리!)
ssh user@dev-server
```

MagicDNS는 기본적으로 활성화되어 있습니다. [관리 콘솔](https://login.tailscale.com/admin/dns)에서 확인하고 설정을 변경할 수 있습니다.

> **팁:** 호스트네임이 겹치는 경우 `dev-server.tailnet-name.ts.net`과 같은 전체 도메인(FQDN)을 사용할 수도 있습니다.

### MagicDNS 동작 확인

```bash
# ping으로 MagicDNS 확인
ping dev-server

# 예상 출력:
# PING dev-server.tailnet-name.ts.net (100.64.0.2): 56 data bytes
# 64 bytes from 100.64.0.2: icmp_seq=0 ttl=64 time=5.123 ms
```

---

## 문제 해결

| 증상 | 해결 방법 |
|------|-----------|
| `tailscale up` 실행 시 "permission denied" | `sudo tailscale up`으로 실행하세요. |
| 다른 기기가 `tailscale status`에 안 보임 | 두 기기 모두 같은 계정으로 로그인했는지 확인하세요. |
| MagicDNS가 작동하지 않음 | [관리 콘솔 > DNS](https://login.tailscale.com/admin/dns)에서 MagicDNS가 켜져 있는지 확인하세요. |
| 연결이 되었는데 속도가 느림 | `tailscale ping dev-server`로 직접 연결(DERP 중계가 아닌)인지 확인하세요. |

---

## 다음 단계

Tailscale이 설치되고 기기들이 같은 Tailnet에 연결되었습니다. 이제 Tailscale SSH를 설정하여 비밀번호와 SSH 키 없이 안전하게 접속하는 방법을 알아봅니다.

> **다음:** [Step 2: Tailscale SSH 설정](./02-ssh-configuration.md)
