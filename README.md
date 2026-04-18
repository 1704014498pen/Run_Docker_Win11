# Run_Docker_Win11

Windows 11에서 **Docker Desktop engine start 무한로딩** 현상을 원클릭으로 해결하는 GUI 도구.

## 문제

Windows 11 + Docker Desktop 환경에서 자주 발생하는 증상:

1. Docker Desktop을 종료했다가 재실행하면 **"engine starting..." 상태로 무한 로딩**
2. 재부팅해도 해결 안 됨
3. Docker 관련 프로세스를 강제 종료하고 `wsl --shutdown` 후 재실행하면 정상 동작

이 반복 작업을 버튼 두 개로 끝내기 위한 도구.

## 사용법

1. [Releases](../../releases) 또는 레포에서 `DockerControl.exe` 다운로드
2. 더블클릭 → UAC 프롬프트 수락
3. GUI에서:
   - **STOP Docker** — Docker 프로세스 전체 kill + `wsl --shutdown`
   - **START Docker** — Docker Desktop 재실행
   - 상태 라벨이 2초마다 RUNNING/STOPPED 자동 갱신

## 내부 동작

`STOP` 클릭 시 다음 프로세스를 순서대로 종료:

- `Docker Desktop`
- `com.docker.backend`
- `com.docker.build`
- `docker-agent`
- `docker-sandbox`
- `com.docker.cli`

이후 `wsl --shutdown`으로 WSL2 백엔드까지 정리.

## 빌드 (소스에서)

외부 의존성 없음. Windows 내장 `csc.exe`만 사용.

```cmd
cd src
build.bat
```

결과: 상위 폴더에 `DockerControl.exe` 생성 (~9 KB).

요구사항:
- Windows 10/11
- .NET Framework 4.x (Windows 기본 포함)

## 파일 구조

```
Run_Docker_Win11/
├── DockerControl.exe        # 메인 실행 파일 (관리자 권한 매니페스트 내장)
└── src/
    ├── DockerControl.cs     # C# WinForms 소스
    ├── app.manifest         # requireAdministrator
    └── build.bat            # csc.exe 빌드 스크립트
```

## 라이선스

MIT
