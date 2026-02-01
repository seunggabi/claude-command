# Claude Commands

Claude Code에서 사용하는 커스텀 커맨드 모음입니다.

## 설치

프로젝트의 `.claude/commands/` 디렉토리에 원하는 커맨드 파일을 복사하세요.

```bash
mkdir -p .claude/commands
cp commit-push-pr.md .claude/commands/
cp done.md .claude/commands/
```

## 커맨드 목록

### `/commit-push-pr`

자동으로 이슈 생성, 브랜치 생성, 커밋, 푸시, PR 생성을 수행합니다.

**워크플로우:**
1. 현재 브랜치 확인 (main인지)
2. 변경사항 분석 후 타입 결정 (feat/fix/refactor/chore)
3. GitHub 이슈 생성
4. 브랜치 생성: `{type}/#{issue_number}-{alias}`
5. 커밋: `(#{issue_number}) {type}: {description}`
6. 푸시 및 PR 생성

### `/done`

PR을 머지하고 관련 이슈를 클로즈합니다.

**워크플로우:**
1. 현재 브랜치에서 이슈 번호 추출
2. PR squash merge
3. 이슈 클로즈 (자동으로 안 닫힌 경우)
4. main으로 이동, pull, 로컬 브랜치 삭제

## 컨벤션

### 브랜치 명명 규칙
```
{type}/#{issue_number}-{alias}
```
- `feat/#123-add-login`
- `fix/#124-fix-auth-bug`
- `refactor/#125-cleanup-code`
- `chore/#126-update-deps`

### 커밋 메시지 형식
```
(#{issue_number}) {type}: {description}
```
- `(#123) feat: 로그인 기능 추가`
- `(#124) fix: 인증 버그 수정`

### PR 제목 형식
```
(#{issue_number}) {type}: {description}
```

## 참고
- [Semantic Commit Messages](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716)
- [Branch Naming Convention](https://gist.github.com/seunggabi/87f8c722d35cd07deb3f649d45a31082)
