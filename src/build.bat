@echo off
setlocal
set CSC=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe
set OUT=%~dp0..\DockerControl.exe

"%CSC%" /nologo /target:winexe /out:"%OUT%" /win32manifest:"%~dp0app.manifest" /reference:System.Windows.Forms.dll /reference:System.Drawing.dll "%~dp0DockerControl.cs"

if %errorlevel% neq 0 (
    echo Build FAILED.
    pause
    exit /b 1
)
echo Build OK: %OUT%
endlocal
