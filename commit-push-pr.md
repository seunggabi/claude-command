# Commit, Push, and Create PR

자동으로 이슈 생성, 브랜치 생성, 커밋, 푸시, PR 생성을 수행합니다.

## 워크플로우

1. **현재 브랜치 확인**: main 브랜치인지 확인
2. **변경사항 분석**: git diff로 변경 내용 파악
3. **이슈 생성**: GitHub에 이슈 등록 (main 브랜치일 경우)
4. **브랜치 생성**: `{type}/#{issue_number}-{alias}` 형식
5. **커밋**: `(#{issue_number}) {type}: {description}` 형식
6. **푸시 & PR 생성**

## 실행 단계

### Step 1: 현재 상태 확인
```bash
git status
git branch --show-current
git diff --staged --stat
git diff --stat
```

### Step 2: 변경사항 분석 후 타입 결정
변경사항을 분석하여 적절한 타입을 선택:
- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `refactor`: 코드 리팩토링 (기능 변경 없음)
- `chore`: 유지보수, 설정 변경, 의존성 업데이트

### Step 3: main 브랜치일 경우 이슈 생성
```bash
gh issue create --title "{이슈 제목}" --body "{변경사항 요약}"
```

### Step 4: 브랜치 생성
```bash
git checkout -b {type}/#{issue_number}-{alias}
```

브랜치 명명 규칙:
- `feat/#123-add-login`
- `fix/#124-fix-auth-bug`
- `refactor/#125-cleanup-code`
- `chore/#126-update-deps`

### Step 5: 커밋
```bash
git add -A
git commit -m "(#{issue_number}) {type}: {description}"
```

커밋 메시지 형식:
- `(#123) feat: 로그인 기능 추가`
- `(#124) fix: 인증 버그 수정`
- `(#125) refactor: 코드 정리`

### Step 6: 푸시 및 PR 생성
```bash
git push -u origin {branch_name}
gh pr create --title "(#{issue_number}) {type}: {PR 제목}" --body "Closes #{issue_number}

## 변경사항
{변경사항 요약}
"
```

PR 제목 형식:
- `(#123) feat: 로그인 기능 추가`
- `(#124) fix: 인증 버그 수정`

## 지침

1. 변경사항이 없으면 실행하지 않음
2. 이슈 제목과 PR 제목은 간결하게 작성
3. alias는 변경사항을 나타내는 짧은 영문 별칭 (kebab-case)
4. 커밋 메시지는 한글로 작성
5. main 브랜치가 아닌 경우 이슈 생성 단계 건너뛰고 현재 브랜치에서 커밋/푸시/PR 진행
