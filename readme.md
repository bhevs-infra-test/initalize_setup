## BHEVS Infra

### Directory Information
#### Git
- login.sh: infra repository를 사용하기 위한 login

#### jenkins
- ansible: 대상 서버 설정용 ansible playbook
  - 폴더: 설치 패키지는 폴더로 모듈화
  - .vault_pass_secret: ansible vault 비밀번호 파일
  - ansible.cfg: ansible 설정 파일
  - ansible_check.sh: ansible 적용 전 점검용 스크립트
  - hosts.ini: ansible 대상 서버 정보
  - playbook.yml: ansible playbook 파일
  - 
- nopasswd: ansible에서 sudo 명령어를 비밀번호 없이 사용하기 위한 설정 파일
  - nopasswd.env: 설정 정보
  - nopasswd_init.sh: 설정

#### wsl
local-pc에서 wsl 개인화 설정용도
- server_init.sh: 패키지 설치
- ssh_config.env: ssh key 설정 정보
- wsl_init.sh: ssh 설정


### Convention
1 Action 1 Commit

### Message Roles
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅, 세미콜론 누락, 코드 변경이 없는 경우
design: CSS, HTML 등 변경
refactor: 코드 리팩토링
test: 테스트 코드, 리팩토링 테스트 코드 추가
chore: 빌드 업무 수정, 패키지 매니저 수정
rename: 파일 혹은 폴더 명 변경만 진행된 경우
remove: 파일 혹은 폴더 삭제 작업만 진행된 경우
perf: 성능 개선
ci: CI 관련 설정 파일 수정
build: 빌드 관련 파일 수정
revert: 이전 커밋 되돌리기
WIP: 작업 진행 중

### Commit Message Examples
```text
feat: 회원가입 기능 추가
fix: 로그인 버그 수정
docs: README.md 파일 수정
style: 코드 포맷팅 적용
design: 메인 페이지 레이아웃 변경
refactor: 중복 코드 제거
test: 회원가입 테스트 코드 추가
chore: 패키지 업데이트
rename: user.js 파일명을 member.js로 변경
remove: 사용하지 않는 이미지 파일 삭제
perf: 이미지 로딩 속도 개선
ci: GitHub Actions 워크플로우 수정
build: Webpack 설정 파일 수정
revert: 이전 커밋으로 되돌리기
WIP: 회원가입 기능 작업 중
```