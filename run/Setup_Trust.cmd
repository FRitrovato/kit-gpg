@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ==========================================================
REM  KIT_GPG - Setup Trust Chiave Mittente (Versione Semplificata)
REM ==========================================================

REM Colori ANSI
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "[char]27"`) do set "ESC=%%A"
set "C_RST=%ESC%[0m"
set "C_RED=%ESC%[31m"
set "C_GRN=%ESC%[32m"
set "C_YEL=%ESC%[33m"
set "C_CYA=%ESC%[36m"

cls
echo.
echo %C_CYA%============================================================%C_RST%
echo %C_CYA%         SETUP TRUST - CHIAVE PUBBLICA MITTENTE%C_RST%
echo %C_CYA%============================================================%C_RST%
echo.

REM Percorsi
for %%I in ("%~dp0..") do set "BASE_DIR=%%~fI"
set "BIN=%BASE_DIR%\bin"
set "HOME=%BASE_DIR%\home"
set "TRUST_DIR=%BASE_DIR%\trust"
set "PUBKEY=%TRUST_DIR%\publickey.asc"
set "FINGERPRINT_FILE=%TRUST_DIR%\fingerprint.txt"
set "REPORT_DIR=%BASE_DIR%\reports"

REM Crea cartella reports
if not exist "%REPORT_DIR%" mkdir "%REPORT_DIR%" >nul 2>&1

REM Crea nome file report
set "TIMESTAMP=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "REPORT_FILE=%REPORT_DIR%\setup_trust_%TIMESTAMP%.txt"

REM Leggi fingerprint dal file (OBBLIGATORIO)
set "EXPECTED_FPR="
if not exist "%FINGERPRINT_FILE%" goto :ERROR_NO_FINGERPRINT
for /f "usebackq delims=" %%F in ("%FINGERPRINT_FILE%") do (
  set "LINE=%%F"
  REM Rimuovi spazi e prendi solo caratteri esadecimali
  set "CLEAN=!LINE: =!"
  if not "!CLEAN!"=="" if "!EXPECTED_FPR!"=="" set "EXPECTED_FPR=!CLEAN!"
)
if "!EXPECTED_FPR!"=="" goto :ERROR_EMPTY_FINGERPRINT

REM Variabili
set "TRUST_LEVEL=4"
set "TRUST_LABEL=FULL"
set "MANUAL_CHECK_OK=0"

REM Controlli preliminari
if not exist "%BIN%\gpg.exe" goto :ERROR_NO_GPG
if not exist "%PUBKEY%" goto :ERROR_NO_KEY
goto :START

:ERROR_NO_GPG
echo %C_RED%ERRORE:%C_RST% gpg.exe non trovato
pause
exit /b 1

:ERROR_NO_KEY
echo %C_RED%ERRORE:%C_RST% Chiave pubblica non trovata
echo.
echo File atteso: %PUBKEY%
pause
exit /b 1

:ERROR_NO_FINGERPRINT
echo %C_RED%ERRORE:%C_RST% File fingerprint non trovato
echo.
echo File atteso: %FINGERPRINT_FILE%
echo.
echo Il file fingerprint.txt deve contenere il fingerprint
echo della chiave pubblica MITTENTE per verificarne l'autenticita.
pause
exit /b 1

:ERROR_EMPTY_FINGERPRINT
echo %C_RED%ERRORE:%C_RST% File fingerprint vuoto
echo.
echo Il file %FINGERPRINT_FILE% esiste ma e' vuoto.
echo Deve contenere il fingerprint della chiave pubblica MITTENTE.
pause
exit /b 1

:START
echo Importo chiave pubblica mittente...
"%BIN%\gpg.exe" --homedir "%HOME%" --quiet --import "%PUBKEY%" >nul 2>&1
if errorlevel 1 goto :ERROR_IMPORT
echo %C_GRN%OK%C_RST%
echo.

REM Ricava la mail dalla chiave appena importata tramite il fingerprint atteso
set "SENDER_MAIL="
set "TMP_UID_FILE=%TEMP%\gpg_uid_%RANDOM%.txt"
"%BIN%\gpg.exe" --homedir "%HOME%" --list-keys --with-colons "%EXPECTED_FPR%" > "%TMP_UID_FILE%" 2>nul
for /f "usebackq delims=" %%U in ("%TMP_UID_FILE%") do (
  set "UROW=%%U"
  if "!UROW:~0,4!"=="uid:" if "!SENDER_MAIL!"=="" call :EXTRACT_MAIL "%%U"
)
del /q "%TMP_UID_FILE%" 2>nul
if "!SENDER_MAIL!"=="" (
  echo %C_RED%ERRORE:%C_RST% Impossibile ricavare la mail dalla chiave importata.
  pause
  exit /b 1
)
echo Mittente rilevato: %C_CYA%!SENDER_MAIL!%C_RST%
echo.

REM Estrai fingerprint
set "TMP_FPR_FILE=%TEMP%\gpg_fpr_%RANDOM%.txt"
"%BIN%\gpg.exe" --homedir "%HOME%" --fingerprint --with-colons "!SENDER_MAIL!" > "%TMP_FPR_FILE%" 2>nul

set "ACTUAL_FPR="
set "FOUND_PRIMARY_FPR=0"
for /f "usebackq delims=" %%L in ("%TMP_FPR_FILE%") do (
  set "ROW=%%L"
  if "!ROW:~0,4!"=="fpr:" if "!FOUND_PRIMARY_FPR!"=="0" call :EXTRACT_FPR "%%L"
)
del /q "%TMP_FPR_FILE%" 2>nul
goto :CONTINUE_AFTER_FPR

:EXTRACT_FPR
set "LINE=%~1"
set "TEMP_ROW=!LINE:::=:EMPTY:!"
set "TEMP_ROW=!TEMP_ROW:::=:EMPTY:!"
for /f "tokens=10 delims=:" %%F in ("!TEMP_ROW!") do set "VAL=%%F"
if "!VAL!"=="EMPTY" goto :EOF
if "!VAL!"=="" goto :EOF
set "ACTUAL_FPR=!VAL!"
set "FOUND_PRIMARY_FPR=1"
goto :EOF

:EXTRACT_MAIL
REM Stesso algoritmo di BUILD_KEY_LIST in Setup_keys.cmd
REM Sostituzione dei doppi punti per isolare i campi (come Setup_keys)
set "ULINE=%~1"
set "TEMP_ROW=!ULINE:::=:EMPTY:!"
set "TEMP_ROW=!TEMP_ROW:::=:EMPTY:!"
REM Campo 10 = "Nome Cognome <mail@dominio>"
for /f "tokens=10 delims=:" %%U in ("!TEMP_ROW!") do (
  set "UID_FULL=%%U"
  if not "!UID_FULL!"=="EMPTY" (
    REM Isola la parte dopo < e prima di >
    for /f "tokens=2 delims=<" %%A in ("!UID_FULL!") do (
      for /f "tokens=1 delims=>" %%B in ("%%A") do (
        set "SENDER_MAIL=%%B"
      )
    )
  )
)
goto :EOF

:CONTINUE_AFTER_FPR
echo Verifico fingerprint...
if "!ACTUAL_FPR!"=="%EXPECTED_FPR%" goto :FPR_OK

REM Caso 1: Fingerprint errato
echo %C_RED%ERRORE CRITICO:%C_RST% Il fingerprint NON corrisponde!
echo.
echo   Atteso:  %EXPECTED_FPR%
echo   Trovato: !ACTUAL_FPR!
echo.
echo %C_RED%Possibile manomissione della chiave. INTERROMPO.%C_RST%
pause
exit /b 2

:FPR_OK
echo %C_GRN%OK%C_RST% - Fingerprint verificato dal file KIT
echo.

REM Verifica aggiuntiva via email
echo %C_CYA%Verifica aggiuntiva (opzionale):%C_RST%
echo.
echo Per la massima sicurezza, inserisci il fingerprint
echo ricevuto via EMAIL (oppure premi INVIO per saltare):
echo.
echo Fingerprint: %C_GRN%!ACTUAL_FPR!%C_RST%
echo.
set /p "MANUAL_FPR=Inserisci fingerprint da email: "

if "!MANUAL_FPR!"=="" goto :SKIP_EMAIL_CHECK

REM Verifica email
set "MANUAL_UPPER=!MANUAL_FPR: =!"
set "EXPECTED_UPPER=!EXPECTED_FPR: =!"

if /I "!MANUAL_UPPER!"=="!EXPECTED_UPPER!" goto :EMAIL_OK

REM Email non corrisponde
echo.
echo %C_RED%ATTENZIONE:%C_RST% Il fingerprint inserito NON corrisponde!
echo.
set /p "CONTINUE=Continuare comunque? (S/N): "
if /I "!CONTINUE!"=="S" goto :SKIP_EMAIL_CHECK
echo.
echo Procedura annullata.
pause
exit /b 3

:EMAIL_OK
REM Caso 3: Doppia verifica OK
echo.
echo %C_GRN%ECCELLENTE!%C_RST% Fingerprint verificato tramite 2 canali indipendenti
echo %C_GRN%Trust impostato a livello 5 (ULTIMATE)%C_RST%
set "TRUST_LEVEL=5"
set "TRUST_LABEL=ULTIMATE"
set "MANUAL_CHECK_OK=1"
goto :PROCEED

:SKIP_EMAIL_CHECK
REM Caso 2: Solo verifica KIT
echo.
echo %C_YEL%Verifica singola (solo file KIT)%C_RST%
echo %C_YEL%Trust impostato a livello 4 (FULL)%C_RST%

:PROCEED
echo.
echo Configuro trust...

REM Firma locale (silenzioso, ignora errori)
"%BIN%\gpg.exe" --homedir "%HOME%" --batch --yes --quiet --lsign-key "%EXPECTED_FPR%" >nul 2>&1

REM Imposta trust
set "OWNERTRUST_FILE=%TEMP%\ownertrust_%RANDOM%.txt"
echo %EXPECTED_FPR%:!TRUST_LEVEL!:> "%OWNERTRUST_FILE%"
"%BIN%\gpg.exe" --homedir "%HOME%" --import-ownertrust < "%OWNERTRUST_FILE%" >nul 2>&1
set "TRUST_RC=%ERRORLEVEL%"
del /q "%OWNERTRUST_FILE%" 2>nul

if %TRUST_RC% neq 0 goto :ERROR_TRUST

REM Verifica che il trust sia stato effettivamente impostato
"%BIN%\gpg.exe" --homedir "%HOME%" --export-ownertrust 2>nul | findstr /C:"%EXPECTED_FPR%" >nul
if errorlevel 1 goto :ERROR_TRUST

echo %C_GRN%OK%C_RST%
echo.

REM Verifica finale
echo Stato finale:
echo.
"%BIN%\gpg.exe" --homedir "%HOME%" --fingerprint "!SENDER_MAIL!" 2>nul | findstr /C:"pub" /C:"uid"
echo.

REM Salva report (con retry se il file Ã¨ bloccato)
if not "%REPORT_FILE%"=="" (
  REM Prova a creare il report
  (
    echo =============================================================
    echo SETUP TRUST Chiave Pubblica Mittente - REPORT
    echo =============================================================
    echo Data: %date% %time%
    echo Utente: %USERNAME%
    echo.
    echo Fingerprint atteso: %EXPECTED_FPR%
    echo Fingerprint trovato: !ACTUAL_FPR!
    echo Verifica doppio canale: !MANUAL_CHECK_OK!
    echo Trust finale: !TRUST_LABEL! (livello !TRUST_LEVEL!)
    echo.
  ) > "%REPORT_FILE%" 2>nul
  
  REM Aggiungi output GPG solo se il file Ã¨ stato creato
  if exist "%REPORT_FILE%" (
    "%BIN%\gpg.exe" --homedir "%HOME%" --fingerprint "!SENDER_MAIL!" >> "%REPORT_FILE%" 2>&1
    echo ============================================================= >> "%REPORT_FILE%" 2>nul
  )
)

echo %C_GRN%============================================================%C_RST%
echo %C_GRN%              PROCEDURA COMPLETATA%C_RST%
echo %C_GRN%============================================================%C_RST%
echo.
if "!MANUAL_CHECK_OK!"=="1" (
  echo %C_GRN%[SICUREZZA MASSIMA]%C_RST% Doppia verifica OK
) else (
  echo %C_YEL%[NOTA]%C_RST% Per sicurezza massima, verifica anche via email
)
echo.
if exist "%REPORT_FILE%" (
  echo Report salvato: %C_CYA%%REPORT_FILE%%C_RST%
  echo.
)
pause
endlocal
exit /b 0

:ERROR_IMPORT
echo %C_RED%ERRORE%C_RST% durante l'importazione
pause
exit /b 1

:ERROR_TRUST
echo %C_RED%ERRORE%C_RST% durante l'impostazione trust
pause
exit /b 1
