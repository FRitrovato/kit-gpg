@echo off
REM ============================================================================
REM  verifica.cmd - Verifica firma file GPG - VERSIONE 1.6 (goto-safe)
REM
REM  - Supporta file sign+encrypt (.gpg) verificando la firma DURANTE il decrypt
REM    (output=NUL, nessuna scrittura in chiaro)
REM  - Supporta file firmati non cifrati (.asc / .gpg) con --verify
REM  - Esito colorato:
REM      GOOD (verde) / BAD (rosso) / NO_PUBKEY o TRUST non completo (giallo)
REM  - Evita blocchi (...) per ridurre errori "non atteso" di cmd.exe
REM ============================================================================

setlocal EnableExtensions EnableDelayedExpansion

REM --- BaseDir = cartella root del kit (.. rispetto a run\)
set "BASEDIR=%~dp0.."
for %%I in ("%BASEDIR%") do set "BASEDIR=%%~fI"

set "GPG_EXE=%BASEDIR%\bin\gpg.exe"
set "GNUPGHOME=%BASEDIR%\home"
set "TRUST_DIR=%BASEDIR%\trust"
set "REPORT_DIR=%BASEDIR%\reports"
set "PUBKEY=%TRUST_DIR%\publickey.asc"

REM --- ESC per colori ANSI
for /F %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

REM --- Timestamp locale-indipendente via PowerShell
for /f "usebackq delims=" %%T in (`powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd_HHmmss')"`) do set "TS=%%T"

REM --- Input file (drag&drop o prompt)
set "INPUT_FILE=%~1"
if not "%INPUT_FILE%"=="" goto GOT_INPUT

set /p "INPUT_FILE=Inserisci percorso file (.gpg/.asc): "
if "%INPUT_FILE%"=="" (
  echo [ERRORE] Nessun file fornito.
  exit /b 1
)

:GOT_INPUT
set "INPUT_FILE=%INPUT_FILE:"=%"
for %%F in ("%INPUT_FILE%") do (
  set "INPUT_FILE_FULL=%%~fF"
  set "INPUT_FILE_NAME=%%~nxF"
  set "INPUT_FILE_EXT=%%~xF"
)

REM --- Report file
if not exist "%REPORT_DIR%" mkdir "%REPORT_DIR%" >nul 2>&1
set "REPORT_FILE=%REPORT_DIR%\verify_report_%TS%.txt"

REM --- Temp files (sempre in %TEMP% per evitare permessi/AV su cartelle del kit)
set "TMP_STATUS=%TEMP%\verify_status_%TS%.tmp"
set "TMP_PKT=%TEMP%\verify_packets_%TS%.tmp"
REM --- Init RC (evita output vuoto)
set "RC_IMPORT="
set "RC=1"


REM ============================================================================
REM  HEADER
REM ============================================================================
cls
echo.
echo +===============================================================+
echo ^|    SIGNATURE VERIFICATION WIZARD v1.6                        ^|
echo +===============================================================+
echo.
echo %ESC%[32m[INFO] Percorso Kit: %BASEDIR%%ESC%[0m
echo %ESC%[32m[INFO] Portachiavi:  %GNUPGHOME%%ESC%[0m
echo %ESC%[32m[INFO] File input:   %INPUT_FILE_NAME%%ESC%[0m
echo %ESC%[32m[INFO] Report:       %REPORT_FILE%%ESC%[0m
echo.

REM --- Log header report
(
  echo ===============================================================
  echo SIGNATURE VERIFICATION REPORT
  echo Timestamp: %date% %time%
  echo File: %INPUT_FILE_FULL%
  echo ===============================================================
) > "%REPORT_FILE%"

REM ============================================================================
REM  GUARDIA ESTENSIONE (goto-safe)
REM ============================================================================
if /I "%INPUT_FILE_EXT%"==".gpg" goto EXT_OK
if /I "%INPUT_FILE_EXT%"==".asc" goto EXT_OK

echo %ESC%[33m[WARN] Estensione non supportata: %INPUT_FILE_EXT% (solo .gpg/.asc)%ESC%[0m
echo [WARN] Estensione non supportata: %INPUT_FILE_EXT%>>"%REPORT_FILE%"
del /q "%TMP_STATUS%" >nul 2>&1
del /q "%TMP_PKT%" >nul 2>&1
exit /b 2

:EXT_OK

REM ============================================================================
REM  CHECK PRESENZA gpg.exe
REM ============================================================================
if not exist "%GPG_EXE%" (
  echo %ESC%[31m[ERRORE] gpg.exe non trovato: %GPG_EXE%%ESC%[0m
  echo [ERRORE] gpg.exe non trovato: %GPG_EXE%>>"%REPORT_FILE%"
  del /q "%TMP_STATUS%" >nul 2>&1
  del /q "%TMP_PKT%" >nul 2>&1
  pause
  exit /b 1
)

REM ============================================================================
REM  IMPORT CHIAVE PUBBLICA (opzionale)
REM ============================================================================
echo %ESC%[36m[INFO] Import chiave pubblica per verifica...%ESC%[0m
echo [INFO] Import chiave pubblica (se presente): %PUBKEY%>>"%REPORT_FILE%"

if exist "%PUBKEY%" goto DO_IMPORT
echo %ESC%[33m[WARN] Chiave pubblica non trovata: %PUBKEY%%ESC%[0m
echo [WARN] Chiave pubblica non trovata: %PUBKEY%>>"%REPORT_FILE%"
goto IMPORT_DONE

:DO_IMPORT
"%GPG_EXE%" --homedir "%GNUPGHOME%" --import "%PUBKEY%" >> "%REPORT_FILE%" 2>&1
set "RC_IMPORT=%ERRORLEVEL%"
echo [INFO] RC import: !RC_IMPORT!>>"%REPORT_FILE%"
REM --- console
if defined RC_IMPORT echo %ESC%[36m[INFO] RC import: !RC_IMPORT!%ESC%[0m
if "%RC_IMPORT%"=="0" (
  echo %ESC%[32m[OK] Chiave pubblica importata%ESC%[0m
) else (
  echo %ESC%[33m[WARN] Import chiave: RC=%RC_IMPORT%%ESC%[0m
)
:IMPORT_DONE
echo.>>"%REPORT_FILE%"

REM ============================================================================
REM  RILEVA SE CIFRATO (NO pipe)
REM ============================================================================
set "IS_ENCRYPTED=0"
"%GPG_EXE%" --homedir "%GNUPGHOME%" --list-packets "%INPUT_FILE_FULL%" > "%TMP_PKT%" 2>&1
findstr /C:":encrypted data packet:" "%TMP_PKT%" >nul && set "IS_ENCRYPTED=1"
findstr /C:":aead encrypted packet:"  "%TMP_PKT%" >nul && set "IS_ENCRYPTED=1"

echo [INFO] IS_ENCRYPTED=%IS_ENCRYPTED%>>"%REPORT_FILE%"
echo [INFO] Packet dump (estratto):>>"%REPORT_FILE%"
type "%TMP_PKT%" >> "%REPORT_FILE%"
echo.>>"%REPORT_FILE%"

REM ============================================================================
REM  VERIFICA FIRMA
REM ============================================================================
echo %ESC%[36m+===============================================================+%ESC%[0m
echo %ESC%[36m^| Verifica firma in corso...                                    ^|%ESC%[0m
echo %ESC%[36m+===============================================================+%ESC%[0m
echo.

if "%IS_ENCRYPTED%"=="1" goto DO_DECRYPT_CHECK
goto DO_VERIFY_CHECK

:DO_DECRYPT_CHECK
echo [INFO] Modalita: sign+encrypt -> decrypt output=NUL (verifica durante decrypt)>>"%REPORT_FILE%"
"%GPG_EXE%" --homedir "%GNUPGHOME%" --status-fd 1 --output NUL --decrypt "%INPUT_FILE_FULL%" > "%TMP_STATUS%" 2>&1
set "RC=%ERRORLEVEL%"
goto PARSE_STATUS

:DO_VERIFY_CHECK
echo [INFO] Modalita: verify (file non cifrato)>>"%REPORT_FILE%"
"%GPG_EXE%" --homedir "%GNUPGHOME%" --status-fd 1 --verify "%INPUT_FILE_FULL%" > "%TMP_STATUS%" 2>&1
set "RC=%ERRORLEVEL%"
goto PARSE_STATUS

:PARSE_STATUS
echo [INFO] RC verifica: !RC!>>"%REPORT_FILE%"
REM --- console
if defined RC echo %ESC%[36m[INFO] RC verifica: !RC!%ESC%[0m
echo [INFO] Output GPG (status-fd):>>"%REPORT_FILE%"
type "%TMP_STATUS%" >> "%REPORT_FILE%"
echo.>>"%REPORT_FILE%"

set "SIG_GOOD=0"
set "SIG_BAD=0"
set "SIG_NO_PUBKEY=0"
set "TRUST_OK=0"

findstr /C:"[GNUPG:] GOODSIG" "%TMP_STATUS%" >nul && set "SIG_GOOD=1"
findstr /C:"[GNUPG:] BADSIG"  "%TMP_STATUS%" >nul && set "SIG_BAD=1"
findstr /C:"[GNUPG:] ERRSIG"  "%TMP_STATUS%" >nul && set "SIG_BAD=1"
findstr /C:"[GNUPG:] NO_PUBKEY" "%TMP_STATUS%" >nul && set "SIG_NO_PUBKEY=1"

findstr /C:"[GNUPG:] TRUST_FULLY" "%TMP_STATUS%" >nul && set "TRUST_OK=1"
findstr /C:"[GNUPG:] TRUST_ULTIMATE" "%TMP_STATUS%" >nul && set "TRUST_OK=1"

REM ============================================================================
REM  ESITO COLORATO (goto-safe)
REM ============================================================================
if "%SIG_BAD%"=="1" goto OUT_BAD
if "%SIG_NO_PUBKEY%"=="1" goto OUT_NOKEY
if "%SIG_GOOD%"=="1" goto OUT_GOOD
goto OUT_UNKNOWN

:OUT_BAD
echo %ESC%[31m+===============================================================+%ESC%[0m
echo %ESC%[31m^| ESITO: BAD SIGNATURE (firma NON valida)                        ^|%ESC%[0m
echo %ESC%[31m+===============================================================+%ESC%[0m
echo [ESITO] BAD SIGNATURE>>"%REPORT_FILE%"
goto SUMMARY

:OUT_NOKEY
echo %ESC%[33m+===============================================================+%ESC%[0m
echo %ESC%[33m^| ESITO: IMPOSSIBILE VERIFICARE (chiave pubblica assente)        ^|%ESC%[0m
echo %ESC%[33m+===============================================================+%ESC%[0m
echo [ESITO] NO_PUBKEY>>"%REPORT_FILE%"
goto SUMMARY

:OUT_GOOD
if "%TRUST_OK%"=="1" goto OUT_GOOD_TRUST
goto OUT_GOOD_NOTRUST

:OUT_GOOD_TRUST
echo %ESC%[32m+===============================================================+%ESC%[0m
echo %ESC%[32m^| ESITO: GOOD SIGNATURE (firma valida)                           ^|%ESC%[0m
echo %ESC%[32m+===============================================================+%ESC%[0m
echo [ESITO] GOOD SIGNATURE (TRUST OK)>>"%REPORT_FILE%"
goto SUMMARY

:OUT_GOOD_NOTRUST
echo %ESC%[33m+===============================================================+%ESC%[0m
echo %ESC%[33m^| ESITO: SIGNATURE OK ma TRUST non verificato                    ^|%ESC%[0m
echo %ESC%[33m+===============================================================+%ESC%[0m
echo [ESITO] GOOD SIGNATURE (TRUST NOT CONFIRMED)>>"%REPORT_FILE%"
goto SUMMARY

:OUT_UNKNOWN
echo %ESC%[33m+===============================================================+%ESC%[0m
echo %ESC%[33m^| ESITO: VERIFICA FALLITA / NON RICONOSCIUTA                     ^|%ESC%[0m
echo %ESC%[33m+===============================================================+%ESC%[0m
echo [ESITO] UNKNOWN>>"%REPORT_FILE%"
goto SUMMARY

:SUMMARY
echo.
echo Return Code GPG: !RC!
echo Return Code GPG: !RC!>>"%REPORT_FILE%"

REM --- Pulizia tmp (best effort)
del /q "%TMP_STATUS%" >nul 2>&1
del /q "%TMP_PKT%" >nul 2>&1

echo.
pause
exit /b %RC%
