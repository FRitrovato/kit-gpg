# KIT GPG — GUIDA RAPIDA v1.5

> Riferimento operativo sintetico. Per la guida completa: `Guida_Operativa_Kit_GPG_v1_5.md`

---

## SETUP INIZIALE (una tantum)

### 1 — Genera le tue chiavi
```
run\Setup_keys.cmd
```
Inserisci: Nome, Email, Commento (opzionale), Passphrase.  
Output: `public_key_<Nome>.asc` nella root del kit.

### 2 — Verifica e dichiara fidata la chiave del mittente ⚠️ OBBLIGATORIO
```
run\Setup_Trust.cmd
```
Prerequisiti in `trust/`:
- `publickey.asc` — chiave pubblica del mittente
- `fingerprint.txt` — fingerprint atteso (40 hex, senza spazi)

**Cosa fa lo script:**
1. Importa `publickey.asc` nel keyring (`home/`)
2. Rileva la mail del mittente dalla chiave via `--list-keys --with-colons`
3. Estrae il fingerprint reale via `--fingerprint --with-colons`
4. Confronta con `fingerprint.txt` → blocca se non corrispondono
5. Chiede fingerprint via email per verifica su secondo canale (opzionale)
6. Imposta `ownertrust`: FULL (4) con singola verifica, ULTIMATE (5) con doppia

**Livelli di trust risultanti:**

| Scenario | Trust | Descrizione |
|----------|-------|-------------|
| Solo verifica file kit | `4` FULL | Fingerprint kit = fingerprint chiave importata |
| Doppia verifica (kit + email) | `5` ULTIMATE | Come sopra + conferma su canale indipendente |

### 3 — Invia la chiave pubblica al mittente
```
public_key_<Nome>.asc  →  mittente (email / PEC / portale)
```

---

## OPERATIVITÀ CORRENTE

### Decifrare un file
```
drag & drop  →  run\decifra.cmd
```
oppure doppio clic su `decifra.cmd` e trascina il `.gpg` nella finestra.

Output nella stessa cartella del file di input, senza estensione `.gpg`.

**RC rilevanti:**

| RC | Esito |
|----|-------|
| 0 | OK — decifrato + firma valida |
| 1 | OK con warning — trust non validato (esegui Setup_Trust) |
| 2 | Decifrato — firma non verificabile (chiave mittente assente o AEAD non rilevato*) |
| 3 | FAIL — decifrazione fallita |
| 4 | FAIL — passphrase errata |
| 5 | FAIL — nessuna chiave privata corrispondente |

*`verifica.cmd` rileva sia `:encrypted data packet:` che `:aead encrypted packet:`.

### Verificare la firma
```
drag & drop  →  run\verifica.cmd
```

**Esiti:**

| Output | Condizione |
|--------|------------|
| `GOOD SIGNATURE (TRUST OK)` | `[GNUPG:] GOODSIG` + `TRUST_FULLY` o `TRUST_ULTIMATE` |
| `SIGNATURE OK ma TRUST non verificato` | `GOODSIG` senza trust — esegui Setup_Trust |
| `BAD SIGNATURE` | `BADSIG` o `ERRSIG` — file compromesso |
| `Chiave pubblica assente` | `NO_PUBKEY` — esegui Setup_Trust |
| `UNKNOWN` | Nessuno dei token sopra — controlla il report |

Report salvato in `reports\verify_report_<timestamp>.txt`.

---

## STRUTTURA KIT

```
KIT_GPG/
├── bin/           gpg.exe, gpg-agent.exe, pinentry-w32.exe, paperkey.exe + DLL
├── home/          GNUPGHOME — keyring, trustdb, gpg.conf
├── trust/         publickey.asc + fingerprint.txt  (forniti dal mittente)
├── run/           Setup_keys | Setup_Trust | decifra | verifica | diagnostica
├── docs/          Guida Operativa + Guida Rapida
├── in/            drop zone file .gpg in ingresso
├── out/           output decifratura (opzionale)
├── reports/       log automatici di tutti gli script
└── backups/       backup manuali
```

**GNUPGHOME** = `<root_kit>\home` — impostato esplicitamente da ogni script con `--homedir`.

---

## DETTAGLIO ALGORITMI NEGLI SCRIPT

### Estrazione fingerprint (Setup_Trust + diagnostica)
```batch
REM Formato colon GPG: fpr::::::::::<FINGERPRINT>:
set "TEMP_ROW=!ROW:::=:EMPTY:!"   ← neutralizza :: consecutivi
for /f "tokens=10 delims=:" %%F in ("!TEMP_ROW!") do set "VAL=%%F"
```

### Estrazione mail da uid (Setup_Trust)
```batch
REM Formato uid: uid:o::::timestamp::::Nome <mail>:
set "TEMP_ROW=!ULINE:::=:EMPTY:!"
for /f "tokens=10 delims=:" %%U in ("!TEMP_ROW!") do set "UID_FULL=%%U"
for /f "tokens=2 delims=<"  %%A in ("!UID_FULL!")  do (
  for /f "tokens=1 delims=>" %%B in ("%%A") do set "SENDER_MAIL=%%B"
)
```

### Rilevamento cifratura AEAD (verifica.cmd)
```batch
findstr /C:":encrypted data packet:" "%TMP_PKT%" >nul && set "IS_ENCRYPTED=1"
findstr /C:":aead encrypted packet:"  "%TMP_PKT%" >nul && set "IS_ENCRYPTED=1"
```

---

## TROUBLESHOOTING RAPIDO

| Sintomo | Causa | Fix |
|---------|-------|-----|
| `TRUST not confirmed` sempre | Setup_Trust non eseguito | `run\Setup_Trust.cmd` |
| `UNKNOWN` + RC=2 su file cifrato | AEAD non rilevato (vecchia `verifica`) | Aggiorna `verifica.cmd` v1.6+ |
| Fingerprint non corrisponde | Chiave sostituita/manomessa | Contatta mittente fuori banda |
| `No secret key` | Mittente ha usato chiave pubblica obsoleta | Reinvia `public_key_<Nome>.asc` aggiornata |
| `Bad passphrase` | Passphrase errata | Riprova; controlla CAPS LOCK e layout tastiera |
| Script si chiude subito | Drag&drop su vecchia `verifica` senza `pause` | Aggiorna a v1.6+ |
| Percorso con `&` o accenti | cmd non gestisce certi caratteri | Sposta kit in percorso semplice (es. `E:\KIT_GPG`) |

### Diagnostica completa
```
run\diagnostica.cmd
```
Controlla: struttura cartelle, versione GPG, chiavi private/pubbliche, gpg.conf, spazio disco. Report in `reports\diagnostica_<timestamp>.txt`.

---

## RIFERIMENTI GPG UTILI

```bash
# Lista chiavi private con fingerprint
gpg --homedir home --list-secret-keys --with-colons --fingerprint

# Lista chiavi pubbliche
gpg --homedir home --list-keys --keyid-format LONG

# Controlla trust impostato
gpg --homedir home --export-ownertrust

# Packet dump (debug cifratura/firma)
gpg --homedir home --list-packets file.gpg

# Verifica manuale firma
gpg --homedir home --status-fd 1 --verify file.gpg

# Decrypt manuale (output su stdout)
gpg --homedir home --decrypt file.gpg
```

---

*KIT GPG v1.5 — Quick Reference*
