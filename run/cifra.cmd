@echo off
REM ============================================================================
REM  cifra.cmd - Encrypt + Sign Wizard (drag&drop) - VERSIONE 2.0
REM
REM  Scopo: cifrare e firmare un file trascinato sopra questo script, salvando
REM         l'output nella cartella <RADICE_KIT>\out\ con estensione .gpg
REM         e producendo un report in: <RADICE_KIT>\reports\
REM
REM  Flusso:
REM   1. Verifica prerequisiti (gpg.exe, chiave privata)
REM   2. Selezione chiave firmataria (privata)
REM   3. Importazione chiavi pubbliche aggiuntive da trust\import\  [OPZIONALE]
REM   4. Selezione destinatari tra le chiavi pubbliche nel portachiavi
REM   5. Selezione file da cifrare (drag&drop o manuale)
REM   6. Riepilogo e conferma
REM   7. Cifratura + firma -> out\
REM ============================================================================

setlocal EnableExtensions EnableDelayedExpansion

chcp 65001 >nul

REM ============================================================================
REM 1) COLORI ANSI
REM ============================================================================
for /F %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "C_RST=%ESC%[0m"
set "C_RED=%ESC%[31m"
set "C_GRN=%ESC%[32m"
set "C_YEL=%ESC%[33m"
set "C_CYA=%ESC%[36m"
set "C_DIM=%ESC%[2m"

REM ============================================================================
REM 2) PERCORSI BASE
REM ============================================================================
set "BASEDIR=%~dp0.."
for %%I in ("%BASEDIR%") do set "BASEDIR=%%~fI"

set "BIN=%BASEDIR%\bin"
set "HOME=%BASEDIR%\home"
set "OUT_DIR=%BASEDIR%\out"
set "REPORT_DIR=%BASEDIR%\reports"
set "IMPORT_DIR=%BASEDIR%\trust\import"
set "GPG_EXE=%BIN%\gpg.exe"

REM ============================================================================
REM 3) REPORT + CARTELLE OUTPUT
REM ============================================================================
if not exist "%REPORT_DIR%" mkdir "%REPORT_DIR%"
if not exist "%OUT_DIR%"    mkdir "%OUT_DIR%"
if not exist "%IMPORT_DIR%" mkdir "%IMPORT_DIR%"

set "TS=%date%_%time%"
set "TS=%TS: =%"
set "TS=%TS:/=-%"
set "TS=%TS::=-%"
set "TS=%TS:,=-%"
set "TS=%TS:.=-%"
set "REPORT_FILE=%REPORT_DIR%\encrypt_report_%TS%.txt"

REM ============================================================================
REM 4) HEADER
REM ============================================================================
cls
echo.
echo %C_CYA%+===============================================================+%C_RST%
echo %C_CYA%^|    ENCRYPTION WIZARD - INVIO FILE SICURO              v2.0   ^|%C_RST%
echo %C_CYA%+===============================================================+%C_RST%
echo.

REM ============================================================================
REM 5) CHECK gpg.exe
REM ============================================================================
if not exist "%GPG_EXE%" (
    echo %C_RED%[ERRORE] gpg.exe non trovato in %BIN%%C_RST%
    echo [ERRORE] gpg.exe non trovato >> "%REPORT_FILE%"
    pause
    exit /b 1
)

REM ============================================================================
REM 6) SELEZIONE CHIAVE PRIVATA (FIRMATARIO)
REM ============================================================================
call :BUILD_SECRET_KEY_LIST

if "%SK_COUNT%"=="0" (
    echo %C_RED%[ERRORE] Nessuna chiave privata trovata nel portachiavi.%C_RST%
    echo.
    echo %C_YEL%[INFO] Esegui prima Setup_keys.cmd per generare la tua coppia di chiavi.%C_RST%
    echo.
    echo [ERRORE] Nessuna chiave privata. >> "%REPORT_FILE%"
    pause
    exit /b 1
)

if "%SK_COUNT%"=="1" (
    set "SENDER_FPR=!SK_FPR[1]!"
    set "SENDER_NAME=!SK_NAME[1]!"
    echo %C_GRN%[INFO] Chiave firmataria rilevata automaticamente:%C_RST%
    echo        !SENDER_NAME!
    echo        %C_DIM%!SENDER_FPR!%C_RST%
    echo.
    goto SIGNER_SELECTED
)

:SELECT_SIGNER
echo %C_CYA%============== SELEZIONE CHIAVE FIRMATARIA (TUA) ==============%C_RST%
echo Trovate %SK_COUNT% chiavi private disponibili.
echo.
for /L %%I in (1,1,%SK_COUNT%) do (
    echo   [%C_GRN%%%I%C_RST%] !SK_NAME[%%I]!
    echo       %C_DIM%!SK_FPR[%%I]!%C_RST%
)
echo.
set /p "SSEL=Seleziona il numero della chiave con cui firmare [1-%SK_COUNT%]: "
set "SENDER_FPR=!SK_FPR[%SSEL%]!"
set "SENDER_NAME=!SK_NAME[%SSEL%]!"
if "!SENDER_FPR!"=="" (
    echo %C_RED%[ERRORE] Selezione non valida. Riprova.%C_RST%
    echo.
    goto SELECT_SIGNER
)

:SIGNER_SELECTED
echo.

REM ============================================================================
REM 7) IMPORTAZIONE CHIAVI PUBBLICHE DA trust\import\
REM    - La cartella trust\import\ e' la "zona di carico":
REM      l'utente vi copia i file .asc ricevuti dai destinatari.
REM    - Il programma mostra i file trovati, li importa nel portachiavi
REM      e li sposta in trust\import\imported\ per non reimportarli.
REM    - Se la cartella e' vuota si procede direttamente.
REM ============================================================================
echo %C_CYA%========== IMPORTAZIONE CHIAVI PUBBLICHE AGGIUNTIVE ==========%C_RST%
echo Cartella di carico: %C_DIM%%IMPORT_DIR%%C_RST%
echo.

REM Conta i file .asc e .gpg presenti
set "IMP_COUNT=0"
for %%F in ("%IMPORT_DIR%\*.asc" "%IMPORT_DIR%\*.gpg") do (
    if exist "%%F" (
        set /a IMP_COUNT+=1
        set "IMP_FILE[!IMP_COUNT!]=%%~fF"
        set "IMP_NAME[!IMP_COUNT!]=%%~nxF"
    )
)

if "%IMP_COUNT%"=="0" (
    echo %C_DIM%[INFO] Nessun file .asc trovato in trust\import\%C_RST%
    echo.
    echo Vuoi aggiungere ora la chiave pubblica di un nuovo destinatario?
    echo.
    echo   [A] Apri la cartella import in Esplora File
    echo   [N] No, prosegui senza importare
    echo.
    set /p "IMP_EMPTY_CHOICE=Scelta: "
    if /i "!IMP_EMPTY_CHOICE!"=="A" (
        echo.
        echo %C_YEL%[INFO] Apro la cartella. Copiaci i file .asc dei destinatari,%C_RST%
        echo       poi torna qui e premi un tasto per continuare.
        echo.
        start explorer "%IMPORT_DIR%"
        pause
        REM Ri-scansiona dopo che l'utente ha copiato i file
        set "IMP_COUNT=0"
        for %%F in ("%IMPORT_DIR%\*.asc" "%IMPORT_DIR%\*.gpg") do (
            if exist "%%F" (
                set /a IMP_COUNT+=1
                set "IMP_FILE[!IMP_COUNT!]=%%~fF"
                set "IMP_NAME[!IMP_COUNT!]=%%~nxF"
            )
        )
        if "!IMP_COUNT!"=="0" (
            echo %C_YEL%[INFO] Nessun file trovato. Si procede senza importazione.%C_RST%
            echo.
            goto IMPORT_DONE
        )
        echo %C_GRN%[INFO] Trovati !IMP_COUNT! file. Procedo con l'importazione.%C_RST%
        echo.
        goto IMPORT_PROCEED
    )
    goto IMPORT_DONE
)

:IMPORT_PROCEED
echo %C_YEL%Trovati %IMP_COUNT% file da importare:%C_RST%
echo.
for /L %%I in (1,1,%IMP_COUNT%) do (
    echo   [%%I] !IMP_NAME[%%I]!
)
echo.
echo   [T] Importa tutti
echo   [S] Scegli quali importare
echo   [N] Salta - non importare nulla
echo.
set /p "IMP_CHOICE=Scelta: "

if /i "!IMP_CHOICE!"=="N" goto IMPORT_DONE
if /i "!IMP_CHOICE!"=="T" goto IMPORT_ALL
if /i "!IMP_CHOICE!"=="S" goto IMPORT_SELECT_LOOP
echo %C_RED%[ERRORE] Scelta non valida.%C_RST%
goto IMPORT_PROCEED

REM --- Loop goto-safe per importare tutti i file ---
:IMPORT_ALL
set "IMP_IDX=1"
set "IMP_AFTER_ONE=ALL_NEXT"
:IMPORT_ALL_LOOP
if !IMP_IDX! GTR !IMP_COUNT! goto IMPORT_DONE
set "IMP_CUR_FILE=!IMP_FILE[%IMP_IDX%]!"
set "IMP_CUR_NAME=!IMP_NAME[%IMP_IDX%]!"
set /a IMP_IDX+=1
goto IMPORT_DO_ONE

:IMPORT_ALL_NEXT
goto IMPORT_ALL_LOOP

REM --- Loop goto-safe per importare un file alla volta ---
:IMPORT_SELECT_LOOP
echo.
echo %C_CYA%Seleziona i file da importare (uno alla volta):%C_RST%
echo.
for /L %%I in (1,1,%IMP_COUNT%) do (
    echo   [%%I] !IMP_NAME[%%I]!
)
echo   [F] Fine selezione
echo.
set /p "IMP_SEL=Numero file da importare (o F per terminare): "
if /i "!IMP_SEL!"=="F" goto IMPORT_DONE
set "IMP_CUR_FILE=!IMP_FILE[%IMP_SEL%]!"
set "IMP_CUR_NAME=!IMP_NAME[%IMP_SEL%]!"
if "!IMP_CUR_FILE!"=="" (
    echo %C_RED%[ERRORE] Selezione non valida.%C_RST%
    goto IMPORT_SELECT_LOOP
)
REM Dopo import torna al menu di selezione singola
set "IMP_AFTER_ONE=SELECT"
goto IMPORT_DO_ONE

REM --- Blocco comune di importazione (inline, senza call) ---
REM     IMP_CUR_FILE = percorso file, IMP_CUR_NAME = nome file
REM     IMP_AFTER_ONE = "ALL_NEXT" o "SELECT" (destinazione post-import)
:IMPORT_DO_ONE
set "IMPORTED_DIR=%IMPORT_DIR%\imported"
if not exist "%IMPORTED_DIR%" mkdir "%IMPORTED_DIR%"

echo %C_CYA%[INFO] Importo: !IMP_CUR_NAME!%C_RST%
echo [IMPORT] !IMP_CUR_NAME! >> "%REPORT_FILE%"

"%GPG_EXE%" --homedir "%HOME%" --import "!IMP_CUR_FILE!" >> "%REPORT_FILE%" 2>&1
set "IMP_RC=!ERRORLEVEL!"

if "!IMP_RC!"=="0" goto IMPORT_DO_ONE_OK
echo %C_YEL%  [WARN] RC importazione: !IMP_RC! (chiave gia' presente o avvisi).%C_RST%
echo   [WARN] RC importazione: !IMP_RC! >> "%REPORT_FILE%"
echo.
goto IMPORT_DO_ONE_MOVE

:IMPORT_DO_ONE_OK
echo %C_GRN%  [OK] Importata con successo.%C_RST%
echo   [OK] Importata con successo. >> "%REPORT_FILE%"
echo.

:IMPORT_DO_ONE_MOVE
REM Sposta il file SEMPRE (anche se gia' importata) per non riproporla
move /y "!IMP_CUR_FILE!" "%IMPORTED_DIR%\!IMP_CUR_NAME!" >nul 2>&1
echo   [INFO] File spostato in trust\import\imported\ >> "%REPORT_FILE%"

:IMPORT_DO_ONE_END
if "!IMP_AFTER_ONE!"=="SELECT" goto IMPORT_SELECT_LOOP
goto IMPORT_ALL_NEXT

:IMPORT_DONE
echo.

REM ============================================================================
REM 8) SELEZIONE CHIAVE/I PUBBLICA/HE (DESTINATARI)
REM ============================================================================
call :BUILD_PUBLIC_KEY_LIST

if "%PK_COUNT%"=="0" (
    echo %C_RED%[ERRORE] Nessuna chiave pubblica trovata nel portachiavi.%C_RST%
    echo.
    echo %C_YEL%[INFO] Copia i file .asc dei destinatari in:%C_RST%
    echo         %IMPORT_DIR%
    echo %C_YEL%[INFO] Poi riesegui cifra.cmd per importarle.%C_RST%
    echo.
    echo [ERRORE] Nessuna chiave pubblica nel portachiavi. >> "%REPORT_FILE%"
    pause
    exit /b 1
)

set "RECIP_COUNT=0"
set "RECIP_ARGS="

:SELECT_RECIP_MENU
cls
echo.
echo %C_CYA%+===============================================================+%C_RST%
echo %C_CYA%^|    ENCRYPTION WIZARD - INVIO FILE SICURO              v2.0   ^|%C_RST%
echo %C_CYA%+===============================================================+%C_RST%
echo.
echo %C_CYA%================ SELEZIONE DESTINATARI =================%C_RST%
echo Chiavi pubbliche disponibili nel portachiavi:
echo.
for /L %%I in (1,1,%PK_COUNT%) do (
    set "MARKER=   "
    for /L %%J in (1,1,%RECIP_COUNT%) do (
        if "!RECIP_FPR[%%J]!"=="!PK_FPR[%%I]!" set "MARKER=%C_GRN%[*]"
    )
    echo   !MARKER! [%%I]%C_RST% !PK_NAME[%%I]!
    echo         %C_DIM%!PK_FPR[%%I]!%C_RST%
)
echo.
if %RECIP_COUNT% GTR 0 (
    echo %C_GRN%Destinatari selezionati: %RECIP_COUNT%%C_RST%
    for /L %%J in (1,1,%RECIP_COUNT%) do (
        echo   %C_GRN%  + !RECIP_NAME[%%J]!%C_RST%
    )
    echo.
)
echo   Digita un numero per aggiungere/togliere un destinatario.
if %RECIP_COUNT% GTR 0 (
    echo   [C] Conferma e continua   [Q] Annulla
) else (
    echo   [Q] Annulla
)
echo.
set /p "RSEL=Scelta: "

if /i "!RSEL!"=="Q" (
    echo.
    echo %C_YEL%[INFO] Operazione annullata.%C_RST%
    echo [INFO] Operazione annullata. >> "%REPORT_FILE%"
    pause
    exit /b 0
)
if /i "!RSEL!"=="C" (
    if %RECIP_COUNT% EQU 0 (
        echo %C_RED%[ERRORE] Seleziona almeno un destinatario.%C_RST%
        goto SELECT_RECIP_MENU
    )
    goto RECIP_SELECTED
)

REM Verifica numero valido
set "RSEL_FPR=!PK_FPR[%RSEL%]!"
set "RSEL_NAME=!PK_NAME[%RSEL%]!"
if "!RSEL_FPR!"=="" goto SELECT_RECIP_MENU

REM Toggle: aggiunge o rimuove dalla lista destinatari
set "ALREADY=0"
set "RECIP_COUNT_NEW=0"
set "RECIP_ARGS_NEW="
for /L %%J in (1,1,%RECIP_COUNT%) do (
    if "!RECIP_FPR[%%J]!"=="!RSEL_FPR!" (
        set "ALREADY=1"
    ) else (
        set /a RECIP_COUNT_NEW+=1
        set "RECIP_FPR[!RECIP_COUNT_NEW!]=!RECIP_FPR[%%J]!"
        set "RECIP_NAME[!RECIP_COUNT_NEW!]=!RECIP_NAME[%%J]!"
        set "RECIP_ARGS_NEW=!RECIP_ARGS_NEW! --recipient !RECIP_FPR[%%J]!"
    )
)

if "!ALREADY!"=="1" (
    set "RECIP_COUNT=!RECIP_COUNT_NEW!"
    set "RECIP_ARGS=!RECIP_ARGS_NEW!"
) else (
    set /a RECIP_COUNT+=1
    set "RECIP_FPR[!RECIP_COUNT!]=!RSEL_FPR!"
    set "RECIP_NAME[!RECIP_COUNT!]=!RSEL_NAME!"
    set "RECIP_ARGS=!RECIP_ARGS! --recipient !RSEL_FPR!"
)
goto SELECT_RECIP_MENU

:RECIP_SELECTED
echo.

REM ============================================================================
REM 9) FILE DA CIFRARE (drag&drop o prompt)
REM ============================================================================
set "INPUT_FILE=%~1"

if not "%INPUT_FILE%"=="" goto GOT_INPUT

echo %C_YEL%[INFO] Nessun file trascinato.%C_RST%
echo       Trascina un file su cifra.cmd oppure inserisci il percorso manualmente.
echo.
set /p "INPUT_FILE=Percorso file da cifrare: "
if "%INPUT_FILE%"=="" (
    echo %C_RED%[ERRORE] Nessun file specificato.%C_RST%
    pause
    exit /b 1
)

:GOT_INPUT
set "INPUT_FILE=%INPUT_FILE:"=%"

if not exist "%INPUT_FILE%" (
    echo %C_RED%[ERRORE] File non trovato: %INPUT_FILE%%C_RST%
    echo [ERRORE] File non trovato: %INPUT_FILE% >> "%REPORT_FILE%"
    pause
    exit /b 1
)

for %%F in ("%INPUT_FILE%") do (
    set "INPUT_FILE_FULL=%%~fF"
    set "INPUT_FILE_NAME=%%~nxF"
    set "INPUT_FILE_NAME_ONLY=%%~nF"
)

REM ============================================================================
REM 10) RIEPILOGO E CONFERMA
REM ============================================================================
echo %C_CYA%+===============================================================+%C_RST%
echo %C_CYA%^| RIEPILOGO OPERAZIONE                                          ^|%C_RST%
echo %C_CYA%+===============================================================+%C_RST%
echo.
echo   File da cifrare : %C_GRN%%INPUT_FILE_NAME%%C_RST%
echo   Firmatario      : %C_GRN%!SENDER_NAME!%C_RST%
echo   Destinatari     :
for /L %%J in (1,1,%RECIP_COUNT%) do (
    echo     %C_GRN%+ !RECIP_NAME[%%J]!%C_RST%
)
echo   Output in       : %C_CYA%%OUT_DIR%%C_RST%
echo.

set /p "CONFIRM=Procedere con la cifratura? (S/N): "
if /i not "%CONFIRM%"=="S" (
    echo.
    echo %C_YEL%[INFO] Operazione annullata dall'utente.%C_RST%
    echo [INFO] Operazione annullata. >> "%REPORT_FILE%"
    pause
    exit /b 0
)

REM ============================================================================
REM 11) HEADER REPORT
REM ============================================================================
(
    echo ============================================================
    echo ENCRYPTION WIZARD - REPORT OPERAZIONE
    echo ============================================================
    echo Data/Ora: %date% %time%
    echo Utente: %USERNAME%
    echo Percorso Kit: %BASEDIR%
    echo GNUPGHOME: %HOME%
    echo File input: %INPUT_FILE_FULL%
    echo Firmatario: !SENDER_NAME! [!SENDER_FPR!]
) > "%REPORT_FILE%"
for /L %%J in (1,1,%RECIP_COUNT%) do (
    echo Destinatario %%J: !RECIP_NAME[%%J]! [!RECIP_FPR[%%J]!] >> "%REPORT_FILE%"
)
echo ------------------------------------------------------------ >> "%REPORT_FILE%"

REM ============================================================================
REM 12) PINENTRY
REM ============================================================================
call :PREPARE_AGENT_PINENTRY

REM ============================================================================
REM 13) CIFRATURA + FIRMA
REM ============================================================================
echo.
echo %C_CYA%+===============================================================+%C_RST%
echo %C_CYA%^| CIFRATURA IN CORSO                                            ^|%C_RST%
echo %C_CYA%+===============================================================+%C_RST%
echo.
echo %C_GRN%[INFO]%C_RST% Le chiavi dei destinatari selezionati sono state verificate.
echo %C_GRN%[INFO]%C_RST% Il file verra' cifrato per tutti i destinatari indicati.
echo.
echo %C_YEL%[ATTESA] Inserisci la Passphrase nella finestra Pinentry che apparira'.%C_RST%
echo.

set "OUT_FILE=%OUT_DIR%\%INPUT_FILE_NAME_ONLY%.gpg"

REM Trasferisce variabili delayed in variabili normali per garantire
REM la corretta espansione nella riga di comando GPG multi-token
set "GPG_SIGNER=!SENDER_FPR!"
set "GPG_RECIP=!RECIP_ARGS!"
set "GPG_INPUT=!INPUT_FILE_FULL!"

"%GPG_EXE%" --homedir "%HOME%" --trust-model always --encrypt --sign --local-user "%GPG_SIGNER%" %GPG_RECIP% --output "%OUT_FILE%" "%GPG_INPUT%" >> "%REPORT_FILE%" 2>&1

set "RC=%ERRORLEVEL%"
echo [INFO] RC gpg: %RC% >> "%REPORT_FILE%"
echo ------------------------------------------------------------ >> "%REPORT_FILE%"

REM ============================================================================
REM 14) ESITO
REM ============================================================================
if "%RC%"=="0" goto :ESITO_OK

echo %C_RED%+===============================================================+%C_RST%
echo %C_RED%^| ESITO: CIFRATURA FALLITA (RC=%RC%)                             ^|%C_RST%
echo %C_RED%+===============================================================+%C_RST%
echo.
echo %C_YEL%Cause possibili:%C_RST%
echo   * Passphrase errata o annullata
echo   * Chiave destinatario senza trust configurato (esegui Setup_Trust.cmd)
echo   * Permessi insufficienti sulla cartella out\
echo.
echo %C_YEL%[INFO] Consulta il report: %REPORT_FILE%%C_RST%
echo.
echo [ESITO] CIFRATURA FALLITA (RC=%RC%) >> "%REPORT_FILE%"
goto :FINE

:ESITO_OK
set "OUT_SIZE=0"
if exist "%OUT_FILE%" for %%A in ("%OUT_FILE%") do set "OUT_SIZE=%%~zA"

echo %C_GRN%+===============================================================+%C_RST%
echo %C_GRN%^| ESITO: FILE CIFRATO E FIRMATO CON SUCCESSO!                   ^|%C_RST%
echo %C_GRN%+===============================================================+%C_RST%
echo.
echo   File output : %C_GRN%%OUT_FILE%%C_RST%
echo   Dimensione  : %OUT_SIZE% bytes
echo.
echo %C_YEL%[INFO] Invia il file .gpg ai destinatari tramite canale sicuro.%C_RST%
echo.
echo [ESITO] CIFRATURA OK >> "%REPORT_FILE%"
echo File output: %OUT_FILE% >> "%REPORT_FILE%"
echo Dimensione: %OUT_SIZE% bytes >> "%REPORT_FILE%"

:FINE
echo ============================================================ >> "%REPORT_FILE%"
echo Fine operazione. RC=%RC% >> "%REPORT_FILE%"
echo %C_CYA%[INFO] Report: %REPORT_FILE%%C_RST%
echo.
pause
endlocal
exit /b %RC%


REM ============================================================================
REM SUBROUTINE: BUILD_SECRET_KEY_LIST
REM Lista chiavi PRIVATE disponibili per la firma
REM ============================================================================
:BUILD_SECRET_KEY_LIST
set "SK_COUNT=0"
set "TMP_LIST=%TEMP%\gpg_sec_%RANDOM%.txt"
"%GPG_EXE%" --homedir "%HOME%" --list-secret-keys --with-colons --fingerprint > "%TMP_LIST%" 2>nul

set "I=0"
for /f "usebackq delims=" %%L in ("%TMP_LIST%") do (
    set "ROW=%%L"
    if "!ROW:~0,4!"=="fpr:" (
        set /a I+=1
        set "TEMP_ROW=!ROW:::=:EMPTY:!"
        set "TEMP_ROW=!TEMP_ROW:::=:EMPTY:!"
        for /f "tokens=10 delims=:" %%F in ("!TEMP_ROW!") do (
            set "VAL=%%F"
            if "!VAL!"=="EMPTY" (set "SK_FPR[!I!]=") else (set "SK_FPR[!I!]=%%F")
        )
    )
    if "!ROW:~0,4!"=="uid:" (
        set "TEMP_ROW=!ROW:::=:EMPTY:!"
        set "TEMP_ROW=!TEMP_ROW:::=:EMPTY:!"
        for /f "tokens=10 delims=:" %%U in ("!TEMP_ROW!") do (
            set "UID_FULL=%%U"
            if not "!UID_FULL!"=="EMPTY" (
                for /f "tokens=1 delims=(<" %%A in ("!UID_FULL!") do (
                    set "NAME_PART=%%A"
                    if "!NAME_PART:~-1!"==" " set "NAME_PART=!NAME_PART:~0,-1!"
                    if "!SK_NAME[%I%]!"=="" set "SK_NAME[!I!]=!NAME_PART!"
                )
            )
        )
    )
)
set "SK_COUNT=%I%"
del /q "%TMP_LIST%" 2>nul
exit /b 0

REM ============================================================================
REM SUBROUTINE: BUILD_PUBLIC_KEY_LIST
REM Lista chiavi PUBBLICHE importate nel portachiavi (destinatari)
REM ============================================================================
:BUILD_PUBLIC_KEY_LIST
set "PK_COUNT=0"
set "TMP_LIST=%TEMP%\gpg_pub_%RANDOM%.txt"
"%GPG_EXE%" --homedir "%HOME%" --list-keys --with-colons --fingerprint > "%TMP_LIST%" 2>nul

set "I=0"
set "LAST_IS_PUB=0"
for /f "usebackq delims=" %%L in ("%TMP_LIST%") do (
    set "ROW=%%L"
    if "!ROW:~0,4!"=="pub:" set "LAST_IS_PUB=1"
    if "!ROW:~0,4!"=="fpr:" if "!LAST_IS_PUB!"=="1" (
        set /a I+=1
        set "LAST_IS_PUB=0"
        set "TEMP_ROW=!ROW:::=:EMPTY:!"
        set "TEMP_ROW=!TEMP_ROW:::=:EMPTY:!"
        for /f "tokens=10 delims=:" %%F in ("!TEMP_ROW!") do (
            set "VAL=%%F"
            if "!VAL!"=="EMPTY" (set "PK_FPR[!I!]=") else (set "PK_FPR[!I!]=%%F")
        )
    )
    if "!ROW:~0,4!"=="uid:" (
        if "!PK_NAME[%I%]!"=="" (
            set "TEMP_ROW=!ROW:::=:EMPTY:!"
            set "TEMP_ROW=!TEMP_ROW:::=:EMPTY:!"
            for /f "tokens=10 delims=:" %%U in ("!TEMP_ROW!") do (
                set "UID_FULL=%%U"
                if not "!UID_FULL!"=="EMPTY" (
                    for /f "tokens=1 delims=(<" %%A in ("!UID_FULL!") do (
                        set "NAME_PART=%%A"
                        if "!NAME_PART:~-1!"==" " set "NAME_PART=!NAME_PART:~0,-1!"
                        set "PK_NAME[!I!]=!NAME_PART!"
                    )
                )
            )
        )
    )
)
set "PK_COUNT=%I%"
del /q "%TMP_LIST%" 2>nul
exit /b 0

REM ============================================================================
REM SUBROUTINE: PREPARE_AGENT_PINENTRY
REM ============================================================================
:PREPARE_AGENT_PINENTRY
echo pinentry-program "%BIN%\pinentry-w32.exe" > "%HOME%\gpg-agent.conf"
taskkill /F /IM gpg-agent.exe >nul 2>&1
exit /b 0
