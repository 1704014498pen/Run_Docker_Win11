@echo off
REM --- UAC 자동 상승 ---
>nul 2>&1 net session
if %errorlevel% neq 0 (
    echo Requesting admin...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo Stopping Docker Desktop and backend processes...
taskkill /IM "Docker Desktop.exe" /F 2>nul
taskkill /IM "com.docker.backend.exe" /F 2>nul
taskkill /IM "com.docker.build.exe" /F 2>nul
taskkill /IM "docker-agent.exe" /F 2>nul
taskkill /IM "docker-sandbox.exe" /F 2>nul
taskkill /IM "com.docker.cli.exe" /F 2>nul

echo Shutting down WSL...
wsl --shutdown

echo.
echo Done. Docker Desktop is stopped.
echo Start Docker Desktop from the Start menu when ready.
pause
