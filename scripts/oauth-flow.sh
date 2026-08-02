#!/usr/bin/env bash
# Authorization Code + PKCE 플로우를 수동으로 밟아보는 스크립트.
# 4단계에서 React SPA가 자동으로 하게 될 일을 눈으로 관찰하는 용도.
set -euo pipefail

AUTH_SERVER="http://localhost:9000"
CLIENT_ID="webfront"
REDIRECT_URI="http://localhost:5173/callback"

# 1. PKCE 준비: code_verifier(랜덤 원본) → code_challenge(SHA256 해시)
code_verifier=$(LC_ALL=C tr -dc 'A-Za-z0-9._~-' </dev/urandom | head -c 64)
code_challenge=$(printf '%s' "$code_verifier" | openssl dgst -sha256 -binary | openssl base64 -A | tr '+/' '-_' | tr -d '=')

echo "== 1. 아래 URL을 브라우저에서 열고 로그인하세요 =="
echo
echo "${AUTH_SERVER}/oauth2/authorize?response_type=code&client_id=${CLIENT_ID}&scope=openid%20profile&redirect_uri=${REDIRECT_URI}&code_challenge=${code_challenge}&code_challenge_method=S256"
echo
echo "로그인 후 브라우저가 ${REDIRECT_URI}?code=... 로 이동합니다."
echo "(아직 SPA가 없어서 '연결할 수 없음' 페이지가 뜨는 게 정상 — 주소창의 code 값만 복사)"
echo
read -r -p "code 값 입력: " code

echo
echo "== 2. 인가 코드 + code_verifier 를 토큰으로 교환 =="
response=$(curl -s -X POST "${AUTH_SERVER}/oauth2/token" \
  -d "grant_type=authorization_code" \
  -d "code=${code}" \
  -d "redirect_uri=${REDIRECT_URI}" \
  -d "client_id=${CLIENT_ID}" \
  -d "code_verifier=${code_verifier}")
echo "$response" | python3 -m json.tool

echo
echo "== 3. 액세스 토큰(JWT) 페이로드 디코드 =="
access_token=$(echo "$response" | python3 -c 'import sys,json; print(json.load(sys.stdin)["access_token"])')
payload=$(echo "$access_token" | cut -d. -f2 | tr '_-' '/+')
# base64 패딩 보정
pad=$(( (4 - ${#payload} % 4) % 4 ))
printf '%s' "$payload$(printf '=%.0s' $(seq 1 $pad 2>/dev/null))" | base64 -d 2>/dev/null | python3 -m json.tool

echo
echo "== 4. refresh_token 으로 재발급 =="
refresh_token=$(echo "$response" | python3 -c 'import sys,json; print(json.load(sys.stdin)["refresh_token"])')
curl -s -X POST "${AUTH_SERVER}/oauth2/token" \
  -d "grant_type=refresh_token" \
  -d "refresh_token=${refresh_token}" \
  -d "client_id=${CLIENT_ID}" | python3 -m json.tool
