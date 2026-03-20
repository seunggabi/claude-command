# macOS System Optimize

macOS 시스템의 리소스 사용량을 분석하고, 불필요한 파일과 서비스를 정리하여 성능을 최적화한다.

## 핵심 원칙

- **안전 우선**: `rm -rf` 절대 사용 금지. 캐시 매니저의 purge/clean 명령을 우선 사용하고, 그 외에는 `/tmp/`로 이동하는 방식 사용.
- **보안 SW 미변경**: 회사 보안 소프트웨어(Fortinet, AhnLab, Jiran, PNPSecure, Wizvera 등)는 절대 중지하지 않는다.
- **병렬 실행**: 독립적인 점검/정리 작업은 반드시 병렬 에이전트로 수행하여 시간을 절약한다.
- **Before/After 보고**: 모든 작업에 대해 이전/이후 용량을 측정하여 결과를 정량적으로 보고한다.

## Workflow

### Phase 1: 시스템 상태 진단 (직접 수행)

먼저 현재 시스템 상태를 빠르게 파악한다. 아래 명령들을 **병렬로** 실행:

```bash
# CPU/메모리 요약
top -l 1 -n 0 | head -12

# 디스크 사용량
df -h / /System/Volumes/Data

# 총 RAM 및 VM 통계
sysctl hw.memsize | awk '{print "Total RAM: " $2/1024/1024/1024 " GB"}'
vm_stat | head -10

# 메모리 상위 프로세스 (macOS 형식)
ps -eo pid,rss,comm -r | head -20

# CPU 상위 프로세스
ps -eo pid,pcpu,comm -r | sort -k2 -nr | head -20

# 캐시 디렉토리 크기
du -sh ~/Library/Caches/*/ 2>/dev/null | sort -hr | head -15

# 로그인 항목
osascript -e 'tell application "System Events" to get the name of every login item'

# LaunchAgents
ls ~/Library/LaunchAgents/ 2>/dev/null
ls /Library/LaunchAgents/ 2>/dev/null
ls /Library/LaunchDaemons/ 2>/dev/null

# 실행중인 비-Apple 서비스
launchctl list | grep -v "com.apple" | grep -v "^\-" | head -30
```

진단 결과를 사용자에게 테이블 형태로 요약 보고한다:
- CPU: idle %, Load Avg
- 메모리: 총량, 사용량, compressor 크기
- 디스크: 총량, 사용량, 여유 공간
- 리소스 상위 프로세스 TOP 5
- 주요 캐시 크기

### Phase 2: 병렬 에이전트 팀 구성

5개의 에이전트를 **동시에** 백그라운드로 실행한다:

#### Team 1: cache-cleaner (캐시 및 임시파일 정리)

수행 작업:
- `pip cache purge`
- `HOMEBREW_NO_AUTO_UPDATE=1 brew cleanup`
- `npm cache clean --force`
- `~/Library/Logs` 내 30일 이상 오래된 로그 파일을 `/tmp/`로 이동
- 브라우저 캐시 정리 (Whale, Chrome 등 - `/tmp/`로 이동)
- JetBrains 캐시 중 안전한 항목(backup, download, temp) 정리
- 각 작업의 이전/이후 용량 측정

주의사항:
- `rm -rf` 사용 금지, `/tmp/` 이동 방식 사용
- 캐시 매니저가 제공하는 purge/clean 명령 우선 사용
- IDE별 핵심 캐시(인덱스 등)는 유지

#### Team 2: brew-updater (Homebrew 업데이트)

수행 작업:
- `HOMEBREW_NO_AUTO_UPDATE=1 brew outdated` 로 목록 확인
- `HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade` 실행
- `HOMEBREW_NO_AUTO_UPDATE=1 brew autoremove` 실행
- `HOMEBREW_NO_AUTO_UPDATE=1 brew doctor` 로 문제 진단
- 발견된 문제 가능한 범위 내 수정

주의사항:
- 항상 `HOMEBREW_NO_AUTO_UPDATE=1` 환경변수 사용 (brew update가 homebrew-core 클론을 시도하며 매우 느려지는 것 방지)
- lock 충돌 시 `pkill -f "brew upgrade"` 후 재시도
- 메이저 버전 변경이 필요한 패키지는 목록만 보고

#### Team 3: service-optimizer (서비스 최적화)

수행 작업:
- `brew services list` 로 상태 확인
- 개발용 서비스(Kafka, Redis, Elasticsearch 등) 중 상시 불필요한 것 중지
- `brew services stop <service>` 로 중지 (plist도 제거되어 재부팅 후에도 안 올라옴)
- FortiClient 등 비정상 CPU 사용 확인
- 실행중이지 않은 서비스 상태 확인 (Nginx, Docker 등)

주의사항:
- 보안 소프트웨어(Fortinet, AhnLab, Jiran, PNPSecure, Wizvera, CrossEx 등) 절대 미변경
- MySQL 등 사용자가 유지를 원할 수 있는 DB는 기본 유지
- `brew services stop`은 LaunchAgent plist를 제거하므로 재부팅 후에도 안전

#### Team 4: disk-analyzer (디스크 공간 분석)

수행 작업:
- `du -sh ~/*` 홈 디렉토리 top 15
- `~/Library` 내 대용량 디렉토리 분석
- Docker 상태 확인 (`docker system df`)
- `node_modules` 목록 (삭제하지 않고 목록만)
- 큰 `.git` 디렉토리 확인
- Java hprof 크래시 덤프 등 불필요 대용량 파일 식별
- Xcode/Developer 캐시 확인

#### Team 5: system-health (시스템 건강 점검)

수행 작업:
- `softwareupdate -l` 로 macOS 소프트웨어 업데이트 확인 (설치하지 않고 목록만)
- `diskutil verifyVolume /` 디스크 볼륨 무결성 확인
- DNS 캐시 플러시: `sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder`
- 메모리 압축 해제: `sudo purge` (inactive 메모리 정리)
- `.DS_Store` 파일 목록 확인 (홈 디렉토리 1단계만)
- 휴지통 크기 확인: `du -sh ~/.Trash/ 2>/dev/null`
- Time Machine 로컬 스냅샷 확인: `tmutil listlocalsnapshots /`
- 시스템 무결성 보호(SIP) 상태 확인: `csrutil status`
- 스왑 사용량 확인: `sysctl vm.swapusage`
- 열린 파일 수 확인: `sysctl kern.maxfiles kern.maxfilesperproc`

주의사항:
- `softwareupdate --install`은 실행하지 않고 목록만 보고
- Time Machine 스냅샷은 삭제하지 않고 크기만 보고
- `sudo purge`는 안전한 명령이지만 일시적으로 시스템이 느려질 수 있음

### Phase 3: 결과 수집 및 추가 조치

에이전트 완료 후:

1. **Java hprof 파일 정리**: `~/java_error_in_*.hprof` 파일을 `/tmp/`로 이동 (JVM 크래시 덤프, 안전하게 삭제 가능)
2. **brew upgrade lock 충돌 처리**: 실패한 패키지가 있으면 stale 프로세스 kill 후 재시도
3. **brew cleanup 재실행**: 업그레이드 후 남은 구버전 정리
4. **휴지통 정리**: 휴지통이 크면 사용자에게 비우기 권장 (자동 삭제하지 않음)
5. **DNS 캐시 플러시 완료 확인**: 네트워크 응답 속도 개선
6. **macOS 업데이트 목록 보고**: 보안 업데이트가 있으면 강조하여 권장

### Phase 4: 종합 보고서

모든 작업 완료 후 아래 형식으로 최종 보고서를 작성:

```
## 최종 시스템 최적화 종합 보고서

### 1. 디스크 정리 결과
| 작업 | 절약 용량 |
|------|-----------|
| ... | ... |
| **총 디스크 절약** | **XXX GB** |

### 2. Homebrew 패키지 업데이트
- 업그레이드 완료: N개
- 미완료 (수동 필요): ...
- brew doctor 결과: ...

### 3. 서비스 최적화
| 서비스 | 조치 |
|--------|------|
| ... | ... |

### 4. 시스템 상태 비교 (Before → After)
| 항목 | 이전 | 이후 |
|------|------|------|
| CPU idle | X% | Y% |
| Load Avg | X | Y |
| 디스크 여유 | X GB | Y GB |

### 5. 추가 권장사항 (수동 작업)
| 우선순위 | 항목 | 예상 효과 |
|----------|------|-----------|
| ... | ... | ... |
```

## 중요 패턴

### 안전한 삭제 방식
```bash
# 캐시 매니저 명령 우선
pip cache purge
npm cache clean --force
brew cleanup

# 매니저가 없는 경우 /tmp로 이동
mkdir -p /tmp$(pwd)
mv ./target /tmp$(pwd)/target

# 충돌 방지 (이미 존재하면 타임스탬프 추가)
mv ~/some/path /tmp/some/path_$(date +%Y%m%d_%H%M%S)
```

### brew 명령 패턴
```bash
# 항상 auto-update 비활성화
HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade
HOMEBREW_NO_AUTO_UPDATE=1 brew cleanup
HOMEBREW_NO_AUTO_UPDATE=1 brew outdated
HOMEBREW_NO_AUTO_UPDATE=1 brew doctor
```

### 서비스 영구 중지
```bash
# brew services stop은 plist를 제거하므로 재부팅 후에도 안전
brew services stop kafka

# 확인
ls ~/Library/LaunchAgents/homebrew.mxcl.kafka.plist  # should not exist
```

### 보안 소프트웨어 식별 패턴
다음 키워드가 포함된 서비스는 회사 보안정책일 가능성이 높으므로 절대 변경하지 않는다:
- fortinet, forticlient (VPN/보안)
- ahnlab, astx (안티바이러스)
- jiran, jkok (DLP/보안)
- pnpsecure, pcassist (보안)
- wizvera, delfino, veraport (공인인증)
- iniline, crossex (공인인증)
- nprotect (게임/보안)
- raon, touchen (공인인증)
