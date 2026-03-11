@echo off
REM  KIT_GPG.cmd  —  Avvia l'interfaccia grafica del Kit GPG
REM  Doppio clic su questo file per aprire la GUI
REM  Versione 2.1

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

REM Rileva percorso kit
for %%I in ("%~dp0.") do set "BASEDIR=%%~fI"
set "PS_SCRIPT=%BASEDIR%\run\KIT_GPG_GUI.ps1"

REM Verifica che lo script esista
if not exist "%PS_SCRIPT%" (
    echo [ERRORE] KIT_GPG_GUI.ps1 non trovato in run\
    echo Verifica che il kit sia integro.
    pause
    exit /b 1
)

REM Avvia PowerShell con ExecutionPolicy Bypass (non modifica policy di sistema)
"%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

endlocal
