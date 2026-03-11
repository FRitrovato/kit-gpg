@echo off
REM  avvia_GUI.cmd  —  Launcher per l'interfaccia grafica KIT GPG v2.1
REM  Avvia KIT_GPG_GUI.ps1 con ExecutionPolicy Bypass (nessuna modifica al sistema)

setlocal

REM Cerca PowerShell (prima pwsh/PowerShell 7, poi powershell.exe classico)
set "PS_EXE="
where pwsh.exe >nul 2>&1 && set "PS_EXE=pwsh.exe"
if not defined PS_EXE (
    where powershell.exe >nul 2>&1 && set "PS_EXE=powershell.exe"
)

if not defined PS_EXE (
    echo [ERRORE] PowerShell non trovato nel PATH.
    echo Il kit richiede Windows PowerShell 5.1 o superiore.
    pause
    exit /b 1
)

set "SCRIPT=%~dp0KIT_GPG_GUI.ps1"

if not exist "%SCRIPT%" (
    echo [ERRORE] KIT_GPG_GUI.ps1 non trovato in:
    echo %SCRIPT%
    pause
    exit /b 1
)

"%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"

endlocal
