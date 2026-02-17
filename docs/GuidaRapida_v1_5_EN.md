# GPG PORTABLE KIT — QUICK REFERENCE v1.5

> Concise operational reference. For the full guide: `Guida_Operativa_Kit_GPG_v1_5_EN.md`

---

## INITIAL SETUP (one-time)

### 1 — Generate your keys
```
run\Setup_keys.cmd
```
Enter: Name, Email, Comment (optional), Passphrase.  
Output: `public_key_<Name>.asc` in the kit root.

### 2 — Verify and trust the sender's key ⚠️ MANDATORY
```
run\Setup_Trust.cmd
```
Prerequisites in `trust/`:
- `publickey.asc` — sender's public key
- `fingerprint.txt` — expected fingerprint (40 hex chars, no spaces)

**What the script does:**
1. Imports `publickey.asc` into the keyring (`home/`)
2. Retrieves sender's email from the key via `--list-keys --with-colons`
3. Extracts the actual fingerprint via `--fingerprint --with-colons`
4. Compares with `fingerprint.txt` → aborts if they do not match
5. Asks for fingerprint via email for second-channel verification (optional)
6. Sets `ownertrust`: FULL (4) with single check, ULTIMATE (5) with dual check

**Resulting trust levels:**

| Scenario | Trust | Description |
|----------|-------|-------------|
| Kit file check only | `4` FULL | Kit fingerprint = imported key fingerprint |
| Dual verification (kit + email) | `5` ULTIMATE | Same as above + confirmation on independent channel |

### 3 — Send your public key to the sender
```
public_key_<Name>.asc  →  sender (email / PEC / portal)
```

---

## DAY-TO-DAY OPERATIONS

### Decrypt a file
```
drag & drop  →  run\decifra.cmd
```
Or double-click `decifra.cmd` and drag the `.gpg` file into the window.

Output in the same folder as the input file, without the `.gpg` extension.

**Relevant return codes:**

| RC | Result |
|----|--------|
| 0 | OK — decrypted + valid signature |
| 1 | OK with warning — trust not validated (run Setup_Trust) |
| 2 | Decrypted — signature unverifiable (sender key missing or AEAD not detected*) |
| 3 | FAIL — decryption failed |
| 4 | FAIL — wrong passphrase |
| 5 | FAIL — no matching private key |

*`verifica.cmd` detects both `:encrypted data packet:` and `:aead encrypted packet:`.

### Verify the signature
```
drag & drop  →  run\verifica.cmd
```

**Results:**

| Output | Condition |
|--------|-----------|
| `GOOD SIGNATURE (TRUST OK)` | `[GNUPG:] GOODSIG` + `TRUST_FULLY` or `TRUST_ULTIMATE` |
| `SIGNATURE OK but TRUST not verified` | `GOODSIG` without trust — run Setup_Trust |
| `BAD SIGNATURE` | `BADSIG` or `ERRSIG` — file compromised |
| `Public key missing` | `NO_PUBKEY` — run Setup_Trust |
| `UNKNOWN` | None of the above tokens — check the report |

Report saved in `reports\verify_report_<timestamp>.txt`.

---

## KIT STRUCTURE

```
KIT_GPG/
├── bin/       gpg.exe, gpg-agent.exe, pinentry-w32.exe, paperkey.exe + DLLs
├── home/      GNUPGHOME — keyring, trustdb, gpg.conf
├── trust/     publickey.asc + fingerprint.txt  (provided by sender)
├── run/       Setup_keys | Setup_Trust | decifra | verifica | diagnostica
├── docs/      Operational Guide + Quick Reference (IT + EN)
├── in/        drop zone for incoming .gpg files
├── out/       decryption output (optional)
├── reports/   automatic logs from all scripts
└── backups/   manual backups
```

**GNUPGHOME** = `<kit_root>\home` — set explicitly by every script via `--homedir`.

---

## ALGORITHM DETAILS

### Fingerprint extraction (Setup_Trust + diagnostica)
```batch
REM GPG colon format: fpr::::::::::<FINGERPRINT>:
set "TEMP_ROW=!ROW:::=:EMPTY:!"   ← neutralise consecutive ::
for /f "tokens=10 delims=:" %%F in ("!TEMP_ROW!") do set "VAL=%%F"
```

### Email extraction from uid (Setup_Trust)
```batch
REM uid format: uid:o::::timestamp::::Name <email>:
set "TEMP_ROW=!ULINE:::=:EMPTY:!"
for /f "tokens=10 delims=:" %%U in ("!TEMP_ROW!") do set "UID_FULL=%%U"
for /f "tokens=2 delims=<"  %%A in ("!UID_FULL!")  do (
  for /f "tokens=1 delims=>" %%B in ("%%A") do set "SENDER_MAIL=%%B"
)
```

### AEAD encryption detection (verifica.cmd)
```batch
findstr /C:":encrypted data packet:" "%TMP_PKT%" >nul && set "IS_ENCRYPTED=1"
findstr /C:":aead encrypted packet:"  "%TMP_PKT%" >nul && set "IS_ENCRYPTED=1"
```

---

## QUICK TROUBLESHOOTING

| Symptom | Cause | Fix |
|---------|-------|-----|
| `TRUST not confirmed` always | Setup_Trust not run | `run\Setup_Trust.cmd` |
| `UNKNOWN` + RC=2 on encrypted file | AEAD not detected (old `verifica`) | Update to `verifica.cmd` v1.6+ |
| Fingerprint mismatch | Key replaced / tampered | Contact sender out-of-band |
| `No secret key` | Sender used outdated public key | Resend updated `public_key_<Name>.asc` |
| `Bad passphrase` | Wrong passphrase | Retry; check CAPS LOCK and keyboard layout |
| Script closes immediately | Drag&drop on old `verifica` without `pause` | Update to v1.6+ |
| Path with `&` or accented chars | cmd cannot handle certain characters | Move kit to a simple path (e.g. `E:\KIT_GPG`) |

### Full diagnostics
```
run\diagnostica.cmd
```
Checks: folder structure, GPG version, private/public keys, gpg.conf, disk space. Report in `reports\diagnostica_<timestamp>.txt`.

---

## USEFUL GPG COMMANDS

```bash
# List private keys with fingerprint
gpg --homedir home --list-secret-keys --with-colons --fingerprint

# List public keys
gpg --homedir home --list-keys --keyid-format LONG

# Check set trust
gpg --homedir home --export-ownertrust

# Packet dump (debug encryption/signature)
gpg --homedir home --list-packets file.gpg

# Manual signature verification
gpg --homedir home --status-fd 1 --verify file.gpg

# Manual decrypt (output to stdout)
gpg --homedir home --decrypt file.gpg
```

---

*GPG Kit v1.5 — Quick Reference*
