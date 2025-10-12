#!/bin/bash

# 8시간을 초 단위로 설정 (8 * 60 * 60 = 28800초)
CACHE_TIMEOUT=28800
DEFAULT_REMOTE="origin" # 대부분의 Git 저장소에서 기본 원격 이름은 origin입니다.

# =======================================================
# 📌 추가된 부분: 현재 시스템 정보 자동 감지 및 Git 설정
# =======================================================

# 1. 시스템 사용자 이름과 호스트 이름 가져오기
CURRENT_USER=$(whoami) # 현재 시스템 사용자 이름 (예: wsl)
CURRENT_HOST=$(hostname) # 현재 시스템 호스트 이름 (예: wsl)

# 2. Git 설정 변수 정의
GIT_USER_NAME="$CURRENT_USER"
# 이메일은 '사용자@호스트' 형식으로 생성 (예: wsl@wsl)
GIT_USER_EMAIL="${CURRENT_USER}@${CURRENT_HOST}" 

echo "--- Git 사용자 정보 자동 설정 시작 ---"
# 3. Git 전역 설정 갱신
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

echo "✅ Git Global User 설정 완료:"
echo "   - Name: $GIT_USER_NAME"
echo "   - Email: $GIT_USER_EMAIL"

# =======================================================
# 📌 기존 자격 증명 캐시 및 로그인 로직
# =======================================================

echo ""
echo "--- Git 자격 증명 캐시 설정 시작 ---"

# 1. 자격 증명 도우미를 'cache' 모드로 설정 및 만료 시간 적용
git config --global credential.helper "cache --timeout=$CACHE_TIMEOUT"

echo "✅ Git 자격 증명 캐시가 $CACHE_TIMEOUT초 (8시간) 동안 유지되도록 설정되었습니다."
echo "✅ 캐시 적용을 위해 원격 저장소에 접속을 시도합니다."

# 2. git fetch를 실행하여 사용자에게 로그인(인증) 정보를 요청하도록 유도
echo ""
echo "--- 📌 로그인 정보 입력 필요 ---"
echo "Git에서 사용자 이름과 비밀번호/PAT (개인 액세스 토큰)을 요청하면 입력해주세요."
echo "이 정보는 8시간 동안 저장됩니다."

# 현재 디렉토리에서 git fetch 실행 (로그인 유도)
git fetch $DEFAULT_REMOTE

# $?는 마지막 명령어의 종료 상태를 저장합니다.
if [ $? -eq 0 ]; then
    echo ""
    echo "--- Git 인증 및 설정 완료 ---"
    echo "🎉 로그인 정보가 성공적으로 저장되었으며, 커밋을 위한 사용자 정보도 설정되었습니다."
else
    echo ""
    echo "--- ❌ Git 인증 실패 ---"
    echo "인증에 실패했거나 원격 저장소에 접근할 수 없습니다. 사용자 이름 및 토큰을 확인해주세요."
fi
