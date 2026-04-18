# Run_Docker_Win11 — 대화 요약

## 프로젝트 개요
- **목표:** Windows 11에서 Docker Desktop **engine start 무한로딩** 현상 해결 자동화
- **Git 공개 여부:** 공개 (public)
- **생성일:** 2026-04-17

## 문제 상황
1. Win11 + Docker Desktop 최초 설치 시 engine start에서 무한로딩
2. `dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart` 실행 + 재부팅 → 한 번은 정상 동작
3. Docker Desktop 종료 후 재실행하면 다시 무한로딩 발생
4. 이 시점에는 **재부팅도 무효**
5. **해결 workaround:** `docker-stop.bat` 실행 → Docker Desktop 재실행 → 정상 동작

## 대화 이력

### 2026-04-17 — 프로젝트 초기 생성
- 프로젝트 폴더 `Run_Docker_Win11` 생성
- `Claude_dialog/` 및 `git_status.md` 초기화

### 2026-04-17 — GUI 리팩토링 (PowerShell)
- `docker-stop.bat` 로직을 PowerShell WinForms GUI로 재구성
- `docker-gui.ps1` + `Run-Docker-GUI.bat` (UAC 런처)
- 기존 `docker-stop.bat`는 CLI fallback으로 유지
- 작업 중 C 드라이브 포화(237/237GB) → 사용자 확보 후 재개

### 2026-04-17 — EXE 변환 (C#)
- 사용자 요청: bat 대신 EXE
- `src/DockerControl.cs` + `src/app.manifest` + `src/build.bat`
- 빌드: `csc.exe` (.NET Framework 4 내장, 외부 도구 불필요)
- 결과: `DockerControl.exe` (9KB) — 더블클릭 시 UAC 자동 프롬프트 후 GUI 실행

## 결정사항
- GUI 언어: **영문**
- 구조: Stop/Start 분리 (옵션 B), Restart 버튼 없음
- 최종 진입점: **`DockerControl.exe`** (더블클릭)
- 빌드 도구: **내장 csc.exe** (외부 의존성 없음)
- 매니페스트: `requireAdministrator` 내장 → 런처 .bat 불필요

### 2026-04-17 — GitHub 퍼블리시 + v1.0.0 릴리스 + 정리
- `git init` + 첫 커밋 → `gh repo create --public` 로 https://github.com/1704014498pen/Run_Docker_Win11 생성
- README.md 작성 후 커밋
- v1.0.0 릴리스 생성, `DockerControl.exe` (9,216 B, sha256 `e9b5da...`) 에셋 첨부
- cleanup 커밋: 구버전 `Run-Docker-GUI.bat`, `docker-gui.ps1`, `docker-stop.bat` 삭제
- git 글로벌 identity: `1704014498pen` / `1704014498pen@gmail.com`

## 미해결 이슈
- `DockerControl.exe` 실제 동작 테스트 필요 (사용자 검증)
- 무한로딩 근본 원인 조사 미완료
