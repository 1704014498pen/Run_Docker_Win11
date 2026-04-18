# Run_Docker_Win11 — Todo

## 진행 중
- [ ] `DockerControl.exe` 실제 테스트 (STOP → START 사이클 검증)

## 예정
- [ ] `first-install.bat` — 최초 설치 후 VirtualMachinePlatform 활성화 안내
- [ ] 무한로딩 근본 원인 조사 (WSL2 상태, Hyper-V, vmcompute 서비스 등)
- [ ] README.md에 증상/해결 순서 문서화
- [ ] GitHub public 저장소 생성 + git_status.md 업데이트
- [ ] (옵션) EXE 아이콘 / 시스템 트레이 지원

## 완료
- [x] 프로젝트 폴더 구조 생성 (2026-04-17)
- [x] 문제 상황 정리 (summary.md) (2026-04-17)
- [x] `docker-gui.ps1` — WinForms GUI (PowerShell) (2026-04-17) — *이후 삭제*
- [x] `Run-Docker-GUI.bat` — UAC 자동상승 런처 (2026-04-17) — *이후 삭제*
- [x] 기존 `docker-stop.bat` 로직을 PowerShell로 리팩토링 (2026-04-17) — *이후 삭제*
- [x] **C#/WinForms로 EXE 컴파일** (`DockerControl.exe`, csc.exe 사용) (2026-04-17)
- [x] 매니페스트로 requireAdministrator 내장 (2026-04-17)
- [x] GitHub public 저장소 생성 + 첫 커밋 + 푸시 (2026-04-17)
- [x] README.md 작성 (2026-04-17)
- [x] v1.0.0 릴리스 + EXE 에셋 첨부 (2026-04-17)
- [x] 구버전 bat/ps1 3개 정리 (2026-04-17)
