@echo off
REM ============================================================================
REM  diagnostica.cmd - Diagnostica sistema KIT GPG - VERSIONE 1.0
REM  
REM  Funzionalita':
REM  - Verifica presenza e versione binari GPG
REM  - Lista chiavi private e pubbliche
REM  - Controlla configurazione
REM  - Verifica spazio disco e integrita' cartelle
REM  - Genera report diagnostico completo
REM ============================================================================

setlocal EnableExtensions EnableDelayedExpansion

REM Imposta code page UTF-8
chcp 65001 >nul

REM Ottieni carattere ESC per colori ANSI
for /F %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

cls
echo.
echo %ESC%[36m============================================================%ESC%[0m
echo %ESC%[36m   KIT GPG - DIAGNOSTICA SISTEMA v1.0%ESC%[0m
echo %ESC%[36m============================================================%ESC%[0m
echo.

REM ============================================================================
REM 1) CALCOLO PERCORSI
REM ============================================================================
set "BASEDIR=%~dp0.."
for %%I in ("%BASEDIR%") do set "BASEDIR=%%~fI"

set "BIN=%BASEDIR%\bin"
set "HOME=%BASEDIR%\home"
set "TRUST=%BASEDIR%\trust"
set "DOCS=%BASEDIR%\docs"
set "RUN=%BASEDIR%\run"
set "IN=%BASEDIR%\in"
set "OUT=%BASEDIR%\out"
set "REPORTS=%BASEDIR%\reports"
set "BACKUPS=%BASEDIR%\backups"

echo %ESC%[32m[INFO] Percorso base kit: %BASEDIR%%ESC%[0m
echo.

REM ============================================================================
REM 2) REPORT FILE
REM ============================================================================
set "REPORT_DIR=%BASEDIR%\reports"
if not exist "%REPORT_DIR%" mkdir "%REPORT_DIR%"

REM Timestamp safe
for /f "usebackq delims=" %%T in (`powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd_HHmmss')"`) do set "TS=%%T"
set "REPORT_FILE=%REPORT_DIR%\diagnostica_%TS%.txt"

echo ============================================================ > "%REPORT_FILE%"
echo KIT GPG - REPORT DIAGNOSTICA >> "%REPORT_FILE%"
echo ============================================================ >> "%REPORT_FILE%"
echo Data/Ora: %date% %time% >> "%REPORT_FILE%"
echo Sistema: %COMPUTERNAME% >> "%REPORT_FILE%"
echo Utente: %USERNAME% >> "%REPORT_FILE%"
echo OS: >> "%REPORT_FILE%"
ver >> "%REPORT_FILE%"
echo ------------------------------------------------------------ >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"

REM ============================================================================
REM 3) CONTROLLO VERSIONE WINDOWS
REM ============================================================================
echo %ESC%[36m[1/9] Sistema Operativo%ESC%[0m
echo ============================================================ >> "%REPORT_FILE%"
echo SISTEMA OPERATIVO >> "%REPORT_FILE%"
echo ============================================================ >> "%REPORT_FILE%"

ver | findstr /i "10\. 11\." >nul
if errorlevel 1 (
    echo %ESC%[33m  [WARN] Sistema non Windows 10/11 - funzionalita' limitate possibili%ESC%[0m
    echo [WARN] Sistema non Windows 10/11 >> "%REPORT_FILE%"
) else (
    echo %ESC%[32m  [OK] Windows 10/11 rilevato%ESC%[0m
    echo [OK] Windows 10/11 >> "%REPORT_FILE%"
)
echo. >> "%REPORT_FILE%"
echo.

REM ============================================================================
REM 4) CONTROLLO STRUTTURA CARTELLE
REM ============================================================================
echo %ESC%[36m[2/9] Struttura cartelle%ESC%[0m
echo ============================================================ >> "%REPORT_FILE%"
echo STRUTTURA CARTELLE >> "%REPORT_FILE%"
echo ============================================================ >> "%REPORT_FILE%"

set "FOLDER_OK=0"
set "FOLDER_MISSING=0"

for %%D in (bin home trust docs run in out reports backups) do (
    if exist "%BASEDIR%\%%D" (
        echo %ESC%[32m  [OK] Cartella %%D esistente%ESC%[0m
        echo [OK] %%D >> "%REPORT_FILE%"
        set /a FOLDER_OK+=1
    ) else (
        echo %ESC%[31m  [MISS] Cartella %%D MANCANTE%ESC%[0m
        echo [MISS] %%D >> "%REPORT_FILE%"
        set /a FOLDER_MISSING+=1
    )
)
echo. >> "%REPORT_FILE%"
echo   Totale: %FOLDER_OK% OK, %FOLDER_MISSING% mancanti
echo.

REM ============================================================================
REM 5) CONTROLLO BINARI GPG
REM ============================================================================
echo %ESC%[36m[3/9] Binari GPG%ESC%[0m
echo ============================================================ >> "%REPORT_FILE%"
echo BINARI GPG >> "%REPORT_FILE%"
echo ============================================================ >> "%REPORT_FILE%"

if exist "%BIN%\gpg.exe" (
    echo %ESC%[32m  [OK] gpg.exe trovato%ESC%[0m
    echo [OK] gpg.exe trovato >> "%REPORT_FILE%"
    
    REM Versione GPG - Corretto per gestire percorsi con spazi e caratteri speciali
    echo( >> "%REPORT_FILE%"
    echo Versione GPG: >> "%REPORT_FILE%"
    "%BIN%\gpg.exe" --version >> "%REPORT_FILE%" 2>&1
    
    for /f "tokens=3" %%V in ('^""%BIN%\gpg.exe" --version ^| findstr /C:"gpg (GnuPG)"^"') do (
        echo   Versione rilevata: %ESC%[32m%%V%ESC%[0m
    )
) else (
    echo %ESC%[31m  [ERRORE] gpg.exe NON trovato in %BIN%%ESC%[0m
    echo [ERRORE] gpg.exe non trovato >> "%REPORT_FILE%"
)
echo(
echo( >> "%REPORT_FILE%"

REM Altri binari importanti
for %%B in (gpg-agent.exe pinentry-w32.exe pinentry.exe paperkey.exe) do (
    if exist "%BIN%\%%B" (
        echo %ESC%[32m  [OK] %%B%ESC%[0m
        echo [OK] %%B >> "%REPORT_FILE%"
    ) else (
        echo %ESC%[33m  [WARN] %%B non trovato%ESC%[0m
        echo [WARN] %%B non trovato >> "%REPORT_FILE%"
    )
)
echo. >> "%REPORT_FILE%"
echo.


REM ============================================================================
REM 6) CHIAVI PRIVATE
REM ============================================================================
echo %ESC%[36m[4/9] Chiavi private (segrete)%ESC%[0m
echo ============================================================ >> "%REPORT_FILE%"
echo CHIAVI PRIVATE (SEGRETE) >> "%REPORT_FILE%"
echo ============================================================ >> "%REPORT_FILE%"
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
REM exit /b 0
echo Trovate %KEY_COUNT% chiavi.
echo.

for /L %%I in (1,1,%KEY_COUNT%) do (
  REM Mostriamo solo il nome estratto salvato in K_NAME
  echo   [%C_GRN%%%I%C_RST%] !K_NAME[%%I]!
    echo   [%C_GRN%%%I%C_RST%] !K_NAME[%%I]! >> "%REPORT_FILE%"
)
echo(

REM ============================================================================
REM 7) CHIAVI PUBBLICHE
REM ============================================================================
echo %ESC%[36m[5/9] Chiavi pubbliche importate%ESC%[0m
echo ============================================================ >> "%REPORT_FILE%"
echo CHIAVI PUBBLICHE IMPORTATE >> "%REPORT_FILE%"
echo ============================================================ >> "%REPORT_FILE%"

if not exist "%BIN%\gpg.exe" goto :PUB_GPG_MISSING

"%BIN%\gpg.exe" --homedir "%HOME%" --list-keys --keyid-format LONG >> "%REPORT_FILE%" 2>&1

set "TMP_PUB=%TEMP%\gpg_pub_%RANDOM%.txt"
set "TMP_CNT=%TEMP%\gpg_pub_cnt_%RANDOM%.txt"
set "PUBKEY_COUNT=0"

"%BIN%\gpg.exe" --homedir "%HOME%" --list-keys --with-colons --fingerprint > "%TMP_PUB%" 2>nul

REM Conta righe pub: senza FOR/DO: scrive il numero su file e poi lo legge
cmd /c "findstr /b /c:pub: "%TMP_PUB%" ^| find /c /v "" > "%TMP_CNT%"" 2>nul
set /p PUBKEY_COUNT=<"%TMP_CNT%"

if "%PUBKEY_COUNT%"=="0" goto :PUB_NONE

echo %ESC%[32m  [OK] Trovate %PUBKEY_COUNT% chiave/i pubblica/he%ESC%[0m
echo.
echo Dettaglio chiavi:
"%BIN%\gpg.exe" --homedir "%HOME%" --list-keys --keyid-format LONG

REM (5) Verifica: chiave importata nel keyring?

:PUB_Key_NOT_IN_KEYRING
REM Non a' nel keyring: controlla se il file in trust esiste
if exist "%TRUST%\publickey.asc" goto :PUB_FILE_OK

echo.
echo %ESC%[33m  [WARN] Chiave non importata e file trust\publickey.asc NON trovato%ESC%[0m
goto :PUB_CLEANUP

:PUB_FILE_OK
echo.
echo %ESC%[33m  [WARN] Chiave non importata (ma presente in trust\publickey.asc)%ESC%[0m
echo %ESC%[33m        Import: gpg --homedir "%HOME%" --import "%KIT_ROOT%\trust\publickey.asc"%ESC%[0m
goto :PUB_CLEANUP

:PUB_NONE
echo %ESC%[33m  [WARN] Nessuna chiave pubblica importata%ESC%[0m
goto :PUB_CLEANUP

:PUB_GPG_MISSING
echo %ESC%[31m  [ERRORE] Impossibile verificare (gpg.exe mancante)%ESC%[0m
goto :PUB_END

:PUB_CLEANUP
del /q "%TMP_PUB%" 2>nul
del /q "%TMP_CNT%" 2>nul

:PUB_END
echo. >> "%REPORT_FILE%"
echo.

REM ============================================================================
REM 8) CONFIGURAZIONE GPG
REM ============================================================================
echo %ESC%[36m[6/9] Configurazione GPG%ESC%[0m
echo ============================================================ >> "%REPORT_FILE%"
echo CONFIGURAZIONE GPG >> "%REPORT_FILE%"
echo ============================================================ >> "%REPORT_FILE%"

if exist "%HOME%\gpg.conf" (
    echo %ESC%[32m  [OK] gpg.conf trovato%ESC%[0m
    echo [OK] gpg.conf presente >> "%REPORT_FILE%"
    echo. >> "%REPORT_FILE%"
    echo Contenuto gpg.conf: >> "%REPORT_FILE%"
    type "%HOME%\gpg.conf" >> "%REPORT_FILE%"
) else (
    echo %ESC%[33m  [WARN] gpg.conf non trovato - verra' usata config di default%ESC%[0m
    echo [WARN] gpg.conf non trovato >> "%REPORT_FILE%"
)
echo. >> "%REPORT_FILE%"
if exist "%HOME%\gpg-agent.conf" (
    echo %ESC%[32m  [OK] gpg-agent.conf trovato%ESC%[0m
    echo [OK] gpg-agent.conf presente >> "%REPORT_FILE%"
) else (
    echo %ESC%[33m  [INFO] gpg-agent.conf non presente %ESC%[0m
    echo [INFO] gpg-agent.conf non presente >> "%REPORT_FILE%"
)
echo( >> "%REPORT_FILE%"
echo(
REM ============================================================================
REM 9) CHIAVE PUBBLICA 
REM ============================================================================
echo %ESC%[36m[7/9] Chiave pubblica  (trust/)%ESC%[0m
echo ============================================================ >> "%REPORT_FILE%"
echo CHIAVE PUBBLICA  >> "%REPORT_FILE%"
echo ============================================================ >> "%REPORT_FILE%"

if exist "%TRUST%\publickey.asc" (
    echo %ESC%[32m  [OK] publickey.asc trovato%ESC%[0m
    echo [OK] publickey.asc presente >> "%REPORT_FILE%"
    
    if exist "%TRUST%\fingerprint.txt" (
        echo %ESC%[32m  [OK] fingerprint.txt trovato%ESC%[0m
        set /p CHIAVE_FPR=<"%TRUST%\fingerprint.txt"
        echo   Fingerprint: %ESC%[36m!CHIAVE_FPR!%ESC%[0m
        echo [OK] Fingerprint: !CHIAVE_FPR! >> "%REPORT_FILE%"
    ) else (
        echo %ESC%[33m  [WARN] fingerprint.txt non trovato%ESC%[0m
        echo [WARN] fingerprint.txt non trovato >> "%REPORT_FILE%"
    )
) else (
    echo %ESC%[31m  [ERRORE] publickey.asc MANCANTE%ESC%[0m
    echo [ERRORE] publickey.asc mancante >> "%REPORT_FILE%"
    echo   La chiave pubblica del mittente e' necessaria per cifrare/verificare
)
echo. >> "%REPORT_FILE%"
echo.

REM ============================================================================
REM 10) SPAZIO DISCO
REM ============================================================================
echo %ESC%[36m[8/9] Spazio disco%ESC%[0m
echo ============================================================ >> "%REPORT_FILE%"
echo SPAZIO DISCO >> "%REPORT_FILE%"
echo ============================================================ >> "%REPORT_FILE%"

echo Dimensioni cartelle: >> "%REPORT_FILE%"
for %%D in (bin home trust docs run reports backups) do (
    if exist "%BASEDIR%\%%D" (
        for /f "tokens=3" %%S in ('dir "%BASEDIR%\%%D" /s /-c 2^>nul ^| findstr /C:"File"') do (
            echo   %%D: %%S bytes
            echo %%D: %%S bytes >> "%REPORT_FILE%"
        )
    )
)
echo. >> "%REPORT_FILE%"

REM Spazio libero drive
for %%D in ("%BASEDIR%") do set "DRIVE=%%~dD"
for /f "tokens=3" %%F in ('dir "%DRIVE%\" ^| findstr /C:"byte disponibili"') do (
    echo   Spazio libero %DRIVE%: %%F bytes
    echo Spazio libero %DRIVE%: %%F bytes >> "%REPORT_FILE%"
)
echo. >> "%REPORT_FILE%"
echo.

REM ============================================================================
REM 11) SCRIPT DISPONIBILI
REM ============================================================================
echo %ESC%[36m[9/9] Script disponibili%ESC%[0m
echo ============================================================ >> "%REPORT_FILE%"
echo SCRIPT DISPONIBILI >> "%REPORT_FILE%"
echo ============================================================ >> "%REPORT_FILE%"

for %%S in (Setup_keys.cmd decifra.cmd cifra.cmd verifica.cmd diagnostica.cmd) do (
    if exist "%RUN%\%%S" (
        echo %ESC%[32m  [OK] %%S%ESC%[0m
        echo [OK] %%S >> "%REPORT_FILE%"
    ) else (
        echo %ESC%[33m  [MISS] %%S%ESC%[0m
        echo [MISS] %%S >> "%REPORT_FILE%"
    )
)
echo. >> "%REPORT_FILE%"
echo.

REM ============================================================================
REM 12) RIEPILOGO E RACCOMANDAZIONI
REM ============================================================================
echo.
echo %ESC%[36m============================================================%ESC%[0m
echo %ESC%[36m   RIEPILOGO DIAGNOSTICA%ESC%[0m
echo %ESC%[36m============================================================%ESC%[0m
echo.

echo ============================================================ >> "%REPORT_FILE%"
echo RIEPILOGO E RACCOMANDAZIONI >> "%REPORT_FILE%"
echo ============================================================ >> "%REPORT_FILE%"

set "ISSUES=0"

if not exist "%BIN%\gpg.exe" (
    echo %ESC%[31m ! CRITICO: gpg.exe mancante%ESC%[0m
    echo [CRITICO] gpg.exe mancante >> "%REPORT_FILE%"
    set /a ISSUES+=1
)

if not exist "%TRUST%\publickey.asc" (
    echo %ESC%[31m ! CRITICO: Chiave pubblica  mancante%ESC%[0m
    echo [CRITICO] Chiave pubblica  mancante >> "%REPORT_FILE%"
    set /a ISSUES+=1
)

if !KEY_COUNT! EQU 0 (
    echo %ESC%[33m ! WARN: Nessuna chiave privata - esegui Setup_keys.cmd%ESC%[0m
    echo [WARN] Nessuna chiave privata >> "%REPORT_FILE%"
    set /a ISSUES+=1
)

if !ISSUES! EQU 0 (
    echo %ESC%[32m STATO: Tutto OK - Il kit a' pronto all'uso%ESC%[0m
    echo [OK] Kit pronto all'uso >> "%REPORT_FILE%"
) else (
    echo %ESC%[33m STATO: %ISSUES% problema/i rilevato/i%ESC%[0m
    echo [WARN] %ISSUES% problemi rilevati >> "%REPORT_FILE%"
)

echo.
echo Report completo salvato in:
echo %REPORT_FILE%
echo.

echo ============================================================ >> "%REPORT_FILE%"
echo Fine diagnostica >> "%REPORT_FILE%"
echo ============================================================ >> "%REPORT_FILE%"

echo %ESC%[36m============================================================%ESC%[0m
echo.

set "OPEN_REPORT="
set /p OPEN_REPORT=Vuoi aprire il report completo? (S/N): 
if /i "%OPEN_REPORT%"=="S" notepad "%REPORT_FILE%"

pause
endlocal
