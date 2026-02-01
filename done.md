# Done - PR Merge and Issue Close

PR을 머지하고 관련 이슈를 클로즈합니다.

## 워크플로우

1. **현재 브랜치 확인**: 브랜치명에서 이슈 번호 추출
2. **PR 상태 확인**: 현재 브랜치의 PR 확인
3. **PR 머지**: squash merge 수행
4. **로컬 정리**: main으로 이동, pull, 브랜치 삭제

## 실행 단계

### Step 1: 현재 상태 확인
```bash
git branch --show-current
gh pr status
```

브랜치명에서 이슈 번호 추출:
- `feat/#123-add-login` → `123`
- `fix/#124-fix-bug` → `124`

### Step 2: PR 확인 및 머지
```bash
gh pr view --json number,state,mergeable
gh pr merge --squash --delete-branch
```

PR 머지 옵션:
- `--squash`: 커밋을 하나로 합침
- `--delete-branch`: 머지 후 원격 브랜치 삭제

### Step 3: 이슈 클로즈 (PR에서 자동으로 안 닫힌 경우)
```bash
gh issue close {issue_number}
```

### Step 4: 로컬 정리
```bash
git checkout main
git pull origin main
git branch -d {branch_name}
```

## 지침

1. PR이 없으면 실행하지 않음
2. PR이 머지 가능한 상태인지 확인 (리뷰 승인, CI 통과 등)
3. 머지 충돌이 있으면 먼저 해결 필요
4. PR 본문에 `Closes #123` 형식이 있으면 이슈는 자동으로 클로즈됨
5. 자동 클로즈가 안 된 경우에만 수동으로 이슈 클로즈
