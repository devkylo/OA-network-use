@echo off

REM 방화벽 규칙을 변경하기 전에 사용자가 로컬 관리자 그룹의 구성원인지 확인
net session >nul 2>&1
if %errorLevel% == 0 (
  goto :start
) else (
  echo "관리자 권한으로 실행하십시오."
  pause
  exit /b 1
)

:start
REM 사용자 입력 받기
setlocal EnableDelayedExpansion
set /p choice="1. OA망 제외 IP 차단 or 2. OA망 제외 IP 차단 해제 : "

REM 선택에 따라 방화벽, IPsec 규칙 추가 또는 삭제
if "%choice%"=="1" (
  echo 방화벽 정책 설정 중...
  
  REM OS 방화벽 전체 IP 차단 및 150망 제외
  netsh advfirewall firewall add rule name="OA망 제외 IP 차단" dir=out action=block remoteip="OA망 대역 입력" enable=yes
  
  echo 방화벽 정책 설정 완료!
  echo 　　　　　
  echo IPsec 정책 설정 중...

  REM IPsec 전체 IP 차단
  netsh ipsec static add filterlist name=Internet_Block

  netsh ipsec static add filter filterlist=Internet_Block srcaddr=me dstaddr=any protocol=any srcport=0 dstport=0

  netsh ipsec static add filteraction name=Block action=block

  netsh ipsec static add policy name=Internet_Block_Policy assign=yes

  netsh ipsec static add rule name=Internet_Block_Policy_rule policy=Internet_Block_Policy filterlist=Internet_Block filteraction=Block

  REM IPsec 150망 허용
  netsh ipsec static add filterlist name=Internet_Spec_Permit

  netsh ipsec static add filter filterlist=Internet_Spec_Permit srcaddr=me dstaddr=OA망 대역 입력 dstmask=8 protocol=any srcport=0 dstport=0

  netsh ipsec static add filteraction name=Permit action=permit

  netsh ipsec static add rule name=Internet_Permit_Policy_rule policy=Internet_Block_Policy filterlist=Internet_Spec_Permit filteraction=Permit
  
  echo IPsec 정책 설정 완료...
  echo 문의 : SO관제팀
) else if "%choice%"=="2" (
  echo 방화벽 정책 설정 삭제 중...
  netsh advfirewall firewall delete rule name="OA망 제외 IP 차단"
  echo 방화벽 정책 삭제 완료!
  echo 　　　　　
  echo IPsec 정책 설정 삭제 중...
  netsh ipsec static delete policy name=Internet_Block_Policy
  echo IPsec 정책 삭제 완료!
  echo 문의 : SO관제팀
) else (
  echo "잘못된 입력입니다."
  pause
  timeout /t 3
  exit /b 1
)

REM 스크립트 3초 후 종료
timeout /t 3
exit /b 0
