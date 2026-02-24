@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ==========================================================
REM  KIT_GPG - Setup Chiavi - VERSIONE 1.5
REM ==========================================================

REM ----------------------------------------------------------
REM COLORI 
REM ----------------------------------------------------------
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "[char]27"`) do set "ESC=%%A"
set "C_RST=%ESC%[0m"
set "C_RED=%ESC%[31m"
set "C_GRN=%ESC%[32m"
set "C_YEL=%ESC%[33m"
set "C_CYA=%ESC%[36m"
set "C_DIM=%ESC%[2m"

echo.
echo %C_CYA%==================================================%C_RST%
echo %C_CYA%  GPG Portable - Setup Chiavi (RESET)%C_RST%
echo %C_CYA%==================================================%C_RST%
echo.

REM ----------------------------------------------------------
REM PERCORSI
REM ----------------------------------------------------------
for %%I in ("%~dp0..") do set "BASE_DIR=%%~fI"
set "BIN=%BASE_DIR%\bin"
set "HOME=%BASE_DIR%\home"
set "REPORT_DIR=%BASE_DIR%\reports"
set "BACKUP_DIR=%BASE_DIR%\backups"

REM Timestamp locale-indipendente via PowerShell
for /f "usebackq delims=" %%T in (`powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd_HHmmss')"`) do set "TS=%%T"
set "REPORT_FILE=%REPORT_DIR%\setup_keys_%TS%.txt"

REM Crea cartella reports e inizializza il file di log
if not exist "%REPORT_DIR%" mkdir "%REPORT_DIR%" >nul 2>&1
(
  echo ==========================================================
  echo KIT GPG - SETUP KEYS REPORT
  echo ==========================================================
  echo Data/Ora: %date% %time%
  echo Utente: %USERNAME%
  echo ----------------------------------------------------------
) > "%REPORT_FILE%"

if not exist "%BIN%\gpg.exe" (
  echo %C_RED%[FATALE]%C_RST% gpg.exe non trovato.
  pause
  exit /b 1
)

REM ==========================================================
REM FLUSSO PRINCIPALE
REM ==========================================================
:RELOAD_LIST
call :BUILD_KEY_LIST

if "%KEY_COUNT%"=="0" (
  echo %C_YEL%[INFO]%C_RST% Nessuna chiave trovata. Avvio generazione.
  goto GEN_KEY
)

:SELECT_KEY
echo %C_CYA%================== SELEZIONE CHIAVE ==================%C_RST%
echo Trovate %KEY_COUNT% chiavi.
echo.

for /L %%I in (1,1,%KEY_COUNT%) do (
  REM Mostriamo solo il nome estratto salvato in K_NAME
  echo   [%C_GRN%%%I%C_RST%] !K_NAME[%%I]!
)

echo.

set /p SEL=Seleziona numero [1-%KEY_COUNT%] o [G] per generare:
if /i "%SEL%"=="G" goto GEN_KEY
set "FOUND_FPR=!K_FPR[%SEL%]!"
set "FOUND_NAME=!K_NAME[%SEL%]!"
REM set "FOUND_NAME_RAW=!K_RAW_UID[%SEL%]!"


:MENU_KEY
echo.
echo %C_CYA%================== MENU ==================%C_RST%
echo Chiave selezionata: %C_GRN%!FOUND_NAME!%C_RST%
echo Fingerprint: %C_DIM%!FOUND_FPR!%C_RST%
echo.
echo  [U] Usa questa chiave (export pubblica)
echo  [D] Cancella questa chiave
echo  [S] Cambia chiave
echo  [Q] Esci
echo.
set /p CHOICE=Scelta (U/D/S/Q):
if /i "%CHOICE%"=="U" goto EXPORT_PUB
if /i "%CHOICE%"=="D" goto DELETE_KEY
if /i "%CHOICE%"=="S" goto SELECT_KEY
if /i "%CHOICE%"=="Q" goto END
goto MENU_KEY

:GEN_KEY
echo %C_CYA%================== GENERAZIONE CHIAVE ==================%C_RST%
set /p REALNAME=Nome e Cognome:
set /p EMAIL=Email:
set /p COMMENT=Commento:

set "FOUND_NAME=%REALNAME%"

echo.
echo %C_YEL%[ATTENZIONE]%C_RST% Tra poco apparirà una finestra separata (Pinentry).
echo %C_WHT%Dovrai inserire una %C_GRN%Passphrase%C_RST% (una password robusta).
echo.
echo %C_CYA%CONSIGLI PER LA PASSPHRASE:%C_RST%
echo * Usa una frase lunga o una combinazione di parole (es: "IlGattoVerdeSaltaSulMuro!26").
echo * La Passphrase protegge la tua chiave privata: se qualcuno la ruba, 
echo   non potrà usarla senza questa password.
echo * %C_RED%IMPORTANTE:%C_RST% Non dimenticarla! Non esiste un tasto "Recupera Password".
echo.
echo %C_YEL%[ATTESA]%C_RST% Generazione in corso... Solo un momento prego
echo.

call :PREPARE_AGENT_PINENTRY 

REM Silenziamento totale di GPG per mostrare solo i nostri messaggi
"%BIN%\gpg.exe" --homedir "%HOME%" --status-fd 1 --batch --quick-generate-key "%REALNAME% (%COMMENT%) <%EMAIL%>" rsa3072 sign,encrypt 3y >nul 2>&1

if not errorlevel 1 (
  echo %C_GRN%[OK]%C_RST% La chiave e' stata creata e firmata con successo.
  echo [OK] Chiave generata per: %REALNAME% ^<%EMAIL%^> >> "%REPORT_FILE%"

  call :BUILD_KEY_LIST
  
  REM Recupero sicuro del fingerprint post-generazione
  call set "FOUND_FPR=%%K_FPR[!KEY_COUNT!]%%"
  call set "FOUND_NAME=%%K_NAME[!KEY_COUNT!]%%"

  goto EXPORT_PUB
) else (
  echo %C_RED%[ERRORE]%C_RST% Si e' verificato un problema durante la generazione.
)
pause
goto END

:EXPORT_PUB
echo.
echo %C_CYA%================== EXPORT ==================%C_RST%
echo.
REM Se FOUND_NAME non è definita (chiave esistente), usiamo un nome generico basato sul fingerprint
if "%FOUND_NAME%"=="" set "FOUND_NAME=key_!FOUND_FPR:~-8!"

set "SAFE_NAME=!FOUND_NAME: =_!"
set "PUBKEY_FILE=%BASE_DIR%\public_key_!SAFE_NAME!.asc"
REM set "SAFE_NAME=%FOUND_NAME: =_%"
REM set "PUBKEY_FILE=%BASE_DIR%\public_key_%SAFE_NAME%.asc"

echo %C_CYA%[INFO]%C_RST% Export in corso: %PUBKEY_FILE%
"%BIN%\gpg.exe" --homedir "%HOME%" --armor --export "%FOUND_FPR%" > "%PUBKEY_FILE%"

if exist "%PUBKEY_FILE%" (
    echo.
    echo %C_GRN%[OK] ESPORTAZIONE RIUSCITA!%C_RST%
    echo.
    echo Invia questo file: %C_GRN%%PUBKEY_FILE%%C_RST%
    echo.
    echo [OK] Chiave pubblica esportata: %PUBKEY_FILE% >> "%REPORT_FILE%"
) else (
    echo %C_RED%[ERRORE]%C_RST% Export fallito.
    echo [ERRORE] Export chiave pubblica fallito per FPR: !FOUND_FPR! >> "%REPORT_FILE%"
)
pause
goto END

:DELETE_KEY
set /p CONF=Confermi cancellazione? (S/N):
if /i not "%CONF%"=="S" goto MENU_KEY
"%BIN%\gpg.exe" --homedir "%HOME%" --batch --yes --delete-secret-and-public-key "%FOUND_FPR%"
if errorlevel 1 (
  echo %C_RED%[ERRORE]%C_RST% Cancellazione chiave fallita.
  echo [ERRORE] Cancellazione chiave fallita - FPR: %FOUND_FPR% >> "%REPORT_FILE%"
) else (
  echo %C_GRN%[OK]%C_RST% Chiave cancellata.
  echo [OK] Chiave cancellata - FPR: %FOUND_FPR% >> "%REPORT_FILE%"
)
goto RELOAD_LIST

:BUILD_KEY_LIST
set "KEY_COUNT=0"
set "TMP_LIST=%TEMP%\gpg_list_%RANDOM%.txt"
REM Generiamo la lista grezza con i due punti
"%BIN%\gpg.exe" --homedir "%HOME%" --list-secret-keys --with-colons --fingerprint > "%TMP_LIST%" 2>nul

set "I=0"
for /f "usebackq delims=" %%L in ("%TMP_LIST%") do (
    set "ROW=%%L"
    
    REM --- GESTIONE FINGERPRINT (Riga fpr:) ---
    if "!ROW:~0,4!"=="fpr:" (
        set /a I+=1
        set "K_RAW_FPR[!I!]=!ROW!"
        
        REM Sostituzione dei doppi punti per isolare i campi in MS-DOS
        set "TEMP_ROW=!ROW:::=:EMPTY:!"
        set "TEMP_ROW=!TEMP_ROW:::=:EMPTY:!"
        
        REM Estraiamo il campo 10 (il Fingerprint pulito)
        for /f "tokens=10 delims=:" %%F in ("!TEMP_ROW!") do (
            set "VAL=%%F"
            if "!VAL!"=="EMPTY" (
                set "K_FPR[!I!]="
            ) else (
                set "K_FPR[!I!]=%%F"
                REM echo %C_DIM%[DEBUG] Chiave !I!: FPR trovato %%F%C_RST%
            )
        )
    )
    
    REM --- GESTIONE NOME UTENTE (Riga uid:) ---
    if "!ROW:~0,4!"=="uid:" (
        set "K_RAW_UID[!I!]=!ROW!"
        
        REM Sostituzione dei doppi punti per isolare i campi
        set "TEMP_ROW=!ROW:::=:EMPTY:!"
        set "TEMP_ROW=!TEMP_ROW:::=:EMPTY:!"
        
        REM Estraiamo il campo 10 (Nome Cognome <email>)
        for /f "tokens=10 delims=:" %%U in ("!TEMP_ROW!") do (
            set "UID_FULL=%%U"
            if not "!UID_FULL!"=="EMPTY" (
                REM Estraiamo solo la parte del nome (prima di < o ()
                for /f "tokens=1 delims=(<" %%A in ("!UID_FULL!") do (
                    set "NAME_PART=%%A"
                    REM Rimuoviamo l'eventuale spazio finale
                    if "!NAME_PART:~-1!"==" " set "NAME_PART=!NAME_PART:~0,-1!"
                    set "K_NAME[!I!]=!NAME_PART!"
                    REM echo %C_DIM%[DEBUG] Chiave !I!: Nome estratto "!NAME_PART!"%C_RST%
                )
            )
        )
    )
)
set "KEY_COUNT=%I%"
del /q "%TMP_LIST%" 2>nul
exit /b 0

:PREPARE_AGENT_PINENTRY
echo pinentry-program "%BIN%\pinentry-w32.exe" > "%HOME%\gpg-agent.conf"
taskkill /F /IM gpg-agent.exe >nul 2>&1
exit /b 0

:END
endlocal
