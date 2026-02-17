# GPG Portable Kit

**Portable system for secure reception and decryption of GPG-encrypted files.**  
Runs from a USB drive on any Windows PC, no installation required.

---

## What it is

GPG Portable Kit is a self-contained bundle that includes:

- **GnuPG 2.x** (portable, with DLLs and pinentry)
- **`.cmd` scripts** for all common operations (key generation, verification, decryption)
- **Documentation** for both end users and technical staff

The kit manages the full lifecycle of a secure file exchange: key generation, sender key verification, decryption and digital signature validation.

---

## Structure

```
KIT_GPG/
├── bin/           GnuPG + DLLs + pinentry
├── home/          GNUPGHOME (portable keyring)
├── trust/         Sender's public key and fingerprint
├── run/           Operational scripts
├── docs/          Documentation
├── in/            Drop zone for incoming .gpg files
├── out/           Decryption output
└── reports/       Automatic logs
```

---

## Quick Start

### 1. Generate your keys
```
run\Setup_keys.cmd
```

### 2. Verify the sender's key *(mandatory before first use)*
Copy the sender's `publickey.asc` and `fingerprint.txt` into the `trust/` folder, then:
```
run\Setup_Trust.cmd
```

### 3. Send your public key to the sender
```
public_key_<Name>.asc   →   sender
```

### 4. Decrypt received files
```
drag & drop   →   run\decifra.cmd
```

### 5. Verify the digital signature
```
drag & drop   →   run\verifica.cmd
```

---

## Scripts

| Script | Description |
|--------|-------------|
| `run\Setup_keys.cmd` | Generate, export and delete personal keys |
| `run\Setup_Trust.cmd` | Import, verify and declare the sender's key trusted |
| `run\decifra.cmd` | Decrypt `.gpg` files (drag & drop or prompt) |
| `run\verifica.cmd` | Verify digital signature — supports AEAD (GPG 2.3+) |
| `run\diagnostica.cmd` | Full diagnostics with report |

---

## Documentation

| Document | Audience |
|----------|----------|
| `docs\Guida_Operativa_Kit_GPG_v1_5.md` | Non-technical users — complete step-by-step guide (Italian) |
| `docs\Guida_Operativa_Kit_GPG_v1_5_EN.md` | Non-technical users — complete step-by-step guide (English) |
| `docs\GuidaRapida_v1_5.md` | Technical users — operational reference and algorithms (Italian) |
| `docs\GuidaRapida_v1_5_EN.md` | Technical users — operational reference and algorithms (English) |

---

## Requirements

- Windows 10 / 11
- No installation required
- No Internet connection needed

---

## Regulatory Compliance

This kit is a **technical tool** and is not directly subject to cybersecurity regulations. However, organisations that adopt it to protect sensitive data exchanges can reference the following frameworks when assessing its alignment with their own compliance obligations.

### NIS2 — D.Lgs. 138/2024 (transposition of EU Directive 2022/2555)

In force since 16 October 2024, the decree requires essential and important entities to adopt technical and organisational measures including, explicitly, **"policies and procedures relating to the use of cryptography and, where appropriate, encryption"** (art. 24).

The kit supports this requirement by:
- Implementing OpenPGP asymmetric encryption with RSA 3072-bit keys (recommended standard)
- Ensuring authentication via digital signature on every exchanged file
- Producing verifiable logs and reports for every operation (audit trail)
- Enforcing explicit fingerprint verification before declaring a key trusted (documented chain of trust)

> ⚠️ The kit is a technical component. NIS2 compliance also requires organisational measures, governance and incident notification, which are outside the scope of this tool.

### GDPR — EU Regulation 2016/679

Art. 32 GDPR requires appropriate technical measures to ensure security of processing, including encryption of personal data.

The kit supports this requirement by:
- Transmitting personal data files exclusively in encrypted form
- Keeping private keys on the recipient's device at all times
- Operating completely offline — no data passes through third-party servers
- Using digital signatures to guarantee integrity and authenticity (art. 5 GDPR — integrity principle)

### ACN — Cryptographic Functions Guidelines

Italy's National Cybersecurity Agency (ACN) promotes the use of cryptography throughout the ICT lifecycle. The CVCN (National Evaluation and Certification Centre) explicitly requires PGP keys of type RSA + RSA (2048, 3072 or 4096 bits) for official document exchanges.

The kit uses **RSA 3072 bits** by default, in line with these requirements. Key validity is set to **3 years**, consistent with ACN recommendations.

### Summary

| Regulatory requirement | Reference | Supported by kit |
|------------------------|-----------|-----------------|
| Use of cryptography | NIS2 art. 24 / D.Lgs. 138/2024 | ✅ OpenPGP RSA 3072 |
| Personal data encryption | GDPR art. 32 | ✅ Asymmetric encryption |
| Integrity and authenticity | GDPR art. 5 | ✅ Mandatory digital signature |
| Chain of trust verification | ACN Cryptographic Guidelines | ✅ Dual-channel fingerprint verification |
| RSA 2048/3072/4096 keys | ACN / CVCN | ✅ RSA 3072 (default) |
| Audit trail | NIS2 art. 24 | ✅ Automatic reports in `reports/` |
| Offline operation | Security best practices | ✅ No network dependency |

---

## Technical Notes

- **GNUPGHOME** is set explicitly by every script via `--homedir <root>\home`, ensuring complete isolation from the system keyring.
- `verifica.cmd` detects both classic format (`:encrypted data packet:`) and AEAD (`:aead encrypted packet:`), compatible with GPG 2.3+.
- `Setup_Trust.cmd` retrieves the sender's email dynamically from the keyring via fingerprint — no hardcoded values.
- Trust is set via `--import-ownertrust`: level 4 (FULL) with single verification, level 5 (ULTIMATE) with dual verification (kit file + email channel).

---

## Changelog

### v1.5
- `Setup_Trust.cmd`: removed hardcoded sender email; mail now extracted dynamically from keyring via fingerprint
- `Setup_Trust.cmd`: mail extraction algorithm aligned with `Setup_keys.cmd` (`:::=:EMPTY:` substitution, token 10)
- `verifica.cmd`: added AEAD packet detection — fixed UNKNOWN/RC=2 bug on files encrypted with GPG 2.3+
- `verifica.cmd`: added final `pause` — fixed window closing immediately on drag & drop
- `decifra.cmd`: removed hardcoded `sogei_publickey.asc` reference, aligned to `trust\publickey.asc`
- Documentation: full rewrite v1.5 — operational guide (non-technical) and quick reference (technical), both IT and EN
- `trust/`: included test `publickey.asc` and `fingerprint.txt` for functional verification

### v1.4
- Initial public release
