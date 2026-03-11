# GPG PORTABLE KIT — QUICK REFERENCE v2.1

> Concise operational reference. For the full guide: `QUICK_REFERENCE_v2_1_EN.md`

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

### Encrypt a file to send
```
drag & drop  →  run\cifra.cmd
```
Or double-click `cifra.cmd` and enter the file path when prompted.

**Workflow:**
1. Select signing key (your private key)
2. Import additional public keys from `trust\import\` (optional)
3. Select recipients from the keyring (toggle, multi-select supported)
4. Enter file path (or drag & drop)
5. Summary and confirmation → Pinentry for Passphrase
6. Output: `out\<filename>.gpg`

**Importing new public keys:**
- Copy the `.asc` files received from recipients into `trust\import\`
- On the next launch of `cifra.cmd`, the script will offer to import them
- After import, files are moved to `trust\import\imported\` automatically

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
| 2 | Decrypted — signature not verifiable (sender key absent or AEAD not detected) |
| 3 | FAIL — decryption failed |
| 4 | FAIL — wrong passphrase |
| 5 | FAIL — no matching private key |

### Verify signature
```
drag & drop  →  run\verifica.cmd
```

**Results:**

| Output | Condition |
|--------|-----------|
| `GOOD SIGNATURE (TRUST OK)` | `[GNUPG:] GOODSIG` + `TRUST_FULLY` or `TRUST_ULTIMATE` |
| `SIGNATURE OK but TRUST not verified` | `GOODSIG` without trust — run Setup_Trust |
| `BAD SIGNATURE` | `BADSIG` or `ERRSIG` — file compromised |
| `Public key absent` | `NO_PUBKEY` — run Setup_Trust |
| `UNKNOWN` | None of the above tokens — check the report |

Report saved in `reports\verify_report_<timestamp>.txt`.

---

## KIT STRUCTURE

```
KIT_GPG/
├── bin/           gpg.exe, gpg-agent.exe, pinentry-w32.exe, paperkey.exe + DLLs
├── home/          GNUPGHOME — keyring, trustdb, gpg.conf
├── trust/
│   ├── publickey.asc      main sender's public key
│   ├── fingerprint.txt    expected fingerprint (for Setup_Trust)
│   └── import/            drop zone for additional public keys
│       └── imported/      already-imported .asc files (archived automatically)
├── run/           Setup_keys | Setup_Trust | cifra | decifra | verifica | diagnostica
├── docs/          Operational Guide + Quick Reference
├── in/            drop zone for incoming .gpg files
├── out/           outgoing encrypted .gpg files
├── reports/       automatic logs from all scripts
└── backups/       manual backups
```

**GNUPGHOME** = `<kit_root>\home` — set explicitly by every script via `--homedir`.

---

## SCRIPT INTERNALS

### Fingerprint extraction (Setup_Trust + diagnostica)
```batch
REM GPG colon format: fpr::::::::::<FINGERPRINT>:
set "TEMP_ROW=!ROW:::=:EMPTY:!"   ← neutralises consecutive ::
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

### Encryption + signing (cifra.cmd)
```batch
REM --trust-model always: suppresses interactive prompts for keys without configured trust
REM Delayed variables are transferred to normal variables before the GPG call
set "GPG_SIGNER=!SENDER_FPR!"
set "GPG_RECIP=!RECIP_ARGS!"
"%GPG_EXE%" --homedir "%HOME%" --trust-model always ^
    --encrypt --sign --local-user "%GPG_SIGNER%" %GPG_RECIP% ^
    --output "%OUT_FILE%" "%GPG_INPUT%"
```

### AEAD detection (verifica.cmd)
```batch
findstr /C:":encrypted data packet:" "%TMP_PKT%" >nul && set "IS_ENCRYPTED=1"
findstr /C:":aead encrypted packet:"  "%TMP_PKT%" >nul && set "IS_ENCRYPTED=1"
```

---

## QUICK TROUBLESHOOTING

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| `TRUST not confirmed` always | Setup_Trust not run | `run\Setup_Trust.cmd` |
| `UNKNOWN` + RC=2 on encrypted file | AEAD not detected (old `verifica`) | Available from v2.0 |
| GUI fails to start (LetterSpacing) | `LetterSpacing` not supported by WPF | Fixed in v2.1 |
| Diagnostics timer error (null) | PowerShell timer variable scope | Fixed in v2.1 |
| Fingerprint mismatch | Key replaced / tampered | Contact sender out-of-band |
| `No secret key` | Sender used an outdated public key | Resend updated `public_key_<Name>.asc` |
| `Bad passphrase` | Wrong passphrase | Retry; check CAPS LOCK and keyboard layout |
| Import files re-proposed every run | (bug in earlier versions) | Available from v2.0 |
| Path with `&` or accents | cmd cannot handle certain characters | Move kit to a simple path (e.g. `E:\KIT_GPG`) |

### Full diagnostics
```
run\diagnostica.cmd
```
Checks: folder structure, GPG version, private/public keys, gpg.conf, disk space. Report in `reports\diagnostica_<timestamp>.txt`.

---

## USEFUL GPG COMMANDS

```bash
# List private keys with fingerprints
gpg --homedir home --list-secret-keys --with-colons --fingerprint

# List public keys
gpg --homedir home --list-keys --keyid-format LONG

# Check configured trust
gpg --homedir home --export-ownertrust

# Packet dump (debug encryption/signing)
gpg --homedir home --list-packets file.gpg

# Manual signature verification
gpg --homedir home --status-fd 1 --verify file.gpg

# Manual decryption (output to stdout)
gpg --homedir home --decrypt file.gpg

# Manual multi-recipient encryption
gpg --homedir home --trust-model always --encrypt --sign \
    --local-user <SIGNER_FPR> \
    --recipient <RECIP1_FPR> --recipient <RECIP2_FPR> \
    --output file.gpg original_file
```

---

*GPG Kit v2.1 — Quick Reference*
