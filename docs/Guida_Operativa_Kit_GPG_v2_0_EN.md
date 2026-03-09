# GPG PORTABLE KIT
**Version 2.0**  
**Operational Guide**  
*Secure system for encrypting, sending and receiving sensitive and confidential data*

---

## TABLE OF CONTENTS

1. [Introduction to the GPG Kit](#1-introduction-to-the-gpg-kit)
2. [Kit Contents](#2-kit-contents)
3. [Initial Setup: Generating Your Keys](#3-initial-setup-generating-your-keys)
4. [Mandatory Setup: Verifying a Received Key](#4-mandatory-setup-verifying-a-received-key)
5. [Sending Your Public Key](#5-sending-your-public-key)
6. [Encrypting and Sending a File](#6-encrypting-and-sending-a-file)
7. [Receiving and Decrypting Files](#7-receiving-and-decrypting-files)
8. [Digital Signature Verification](#8-digital-signature-verification)
9. [Managing Multiple Keys](#9-managing-multiple-keys)
10. [Secure USB Drive Management](#10-secure-usb-drive-management)
11. [Troubleshooting](#11-troubleshooting)
12. [FAQ — Frequently Asked Questions](#12-faq--frequently-asked-questions)
13. [Appendix: Glossary](#appendix-glossary)

---

## 1. INTRODUCTION TO THE GPG KIT

### 1.1 What is the GPG Kit

The GPG Kit is a portable, self-contained system for encrypting, sending and receiving sensitive data securely. It is designed to run directly from a USB drive, with no need to install anything on the computer.

### 1.2 How it works — a simple analogy

Think of a mailbox with two keys:

- **The public key** is like the mail slot: anyone can insert a message (encrypt a file for you), but only you can open the box.
- **The private key** is the key to the lock: only you have it, and only with it can you read the received messages (decrypt the files).

> ⚠️ **IMPORTANT**  
> The private key never leaves the USB drive. Encrypted files can only be decrypted by whoever holds that key. If you lose it, you lose access to the data.

### 1.3 The secure exchange process — end to end

```
[YOU]                                       [COUNTERPART]
  |                                              |
  |-- 1. Generate your key pair                  |
  |        (Setup_keys.cmd)                      |
  |                                              |
  |-- 2. Exchange public keys ----------------->|
  |        (via email / PEC / portal)       <----|
  |                                              |
  |-- 3. Verify the received key                 |
  |        (Setup_Trust.cmd) ← MANDATORY        |
  |                                              |
  |-- 4. Encrypt and send a file -------------->|
  |        (cifra.cmd)                           |
  |                                              |
  |<-- 5. Receive an encrypted file -------------|
  |        (extension .gpg)                      |
  |                                              |
  |-- 6. Decrypt and verify the signature        |
  |        (decifra.cmd + verifica.cmd)          |
```

---

## 2. KIT CONTENTS

### 2.1 Folder structure

```
KIT_GPG/
├── run/                        ← Scripts to run
│   ├── Setup_keys.cmd          ← Generate and manage your keys
│   ├── Setup_Trust.cmd         ← Verify and trust a received public key
│   ├── cifra.cmd               ← Encrypt and sign files to send
│   ├── decifra.cmd             ← Decrypt received files
│   ├── verifica.cmd            ← Verify digital signatures
│   └── diagnostica.cmd         ← Diagnostics and troubleshooting
│
├── trust/                      ← Received public keys
│   ├── publickey.asc           ← Main counterpart's public key
│   ├── fingerprint.txt         ← Key fingerprint (for Setup_Trust verification)
│   └── import/                 ← Drop zone for additional public keys
│       └── imported/           ← Already-imported .asc files (auto-archived)
│
├── home/                       ← GPG keyring — DO NOT touch, DO NOT share
├── in/                         ← Recommended folder for incoming .gpg files
├── out/                        ← Outgoing encrypted files (produced by cifra.cmd)
├── docs/                       ← This guide and the quick reference
├── reports/                    ← Automatic logs from all scripts
└── public_key_*.asc            ← Your public keys (to send to counterparts)
```

### 2.2 Available scripts

| Script | Function | When to use |
|--------|----------|-------------|
| **Setup_keys.cmd** | Generate and manage your personal keys | Initial setup, new keys, export |
| **Setup_Trust.cmd** | Verify and declare a received public key trusted | Before encrypting for a new recipient / before decrypting |
| **cifra.cmd** | Encrypt and sign files to send to one or more recipients | Every time you need to send an encrypted file |
| **decifra.cmd** | Decrypt received `.gpg` files | Every time you receive an encrypted file |
| **verifica.cmd** | Verify the digital signature of a file | To check authenticity and integrity |
| **diagnostica.cmd** | System diagnostics | When something goes wrong |

---

## 3. INITIAL SETUP: GENERATING YOUR KEYS

> This step is performed **once only**, unless you need to create a new key in the future.

### 3.1 Copy the Kit to the USB drive

1. Insert a USB drive into the computer
2. Extract the contents of the received ZIP file
3. Copy the entire `KIT_GPG` folder to the USB drive
4. Verify all files have been copied correctly

### 3.2 Generate your first key

1. Open the `run` folder on the USB drive
2. Double-click **`Setup_keys.cmd`**
3. If you have no keys yet, the script will start the generation process automatically

The script will ask for:

- **Full Name** — enter your full name (e.g. `Pico de Paperis`)
- **Email** — your email address
- **Comment** — optional, useful to distinguish different keys (e.g. `Work`)
- **Passphrase** — a strong password to protect your private key

> ⚠️ **CHOOSING YOUR PASSPHRASE**  
> The passphrase is the only protection for your private key. It must be:
> - At least 12 characters long, with letters, numbers and symbols
> - Easy for you to remember, impossible for others to guess
> - **Written down OFFLINE** (on paper, not a digital file) and kept in a safe place
> - **NOT recoverable**: if you forget it, the key becomes unusable

### 3.3 What happens at the end

The script saves the private key in the keyring (`home/`) and generates the file `public_key_Pico_de_Paperis.asc` in the kit root, ready to send to counterparts.

---

## 4. MANDATORY SETUP: VERIFYING A RECEIVED KEY

> ⚠️ **THIS STEP IS MANDATORY**  
> Without it, GPG does not trust the received key and signature verification will always fail, even if the file is authentic.

### 4.1 What it is and why it is necessary

When you receive a counterpart's public key, you must:
1. **Verify** that it is authentic (that it actually comes from that person, not a third party)
2. **Declare** to GPG that you trust that key

### 4.2 What you need

| File/Data | Where to find it | Purpose |
|-----------|-----------------|---------|
| `publickey.asc` | Kit's `trust/` folder | The counterpart's public key |
| `fingerprint.txt` | Kit's `trust/` folder | The unique fingerprint of the key |
| Fingerprint via email/PEC | In the received communication | Independent channel verification (optional but recommended) |

### 4.3 Run Setup_Trust.cmd

1. Copy `publickey.asc` and `fingerprint.txt` into the `trust/` folder
2. Double-click **`run\Setup_Trust.cmd`**
3. The script imports the key, verifies its fingerprint, and asks for confirmation

### 4.4 Trust levels

| Scenario | Trust | Description |
|----------|-------|-------------|
| Kit file check only | **4 — FULL** | Kit fingerprint matches the imported key |
| Dual verification (kit + email) | **5 — ULTIMATE** | Same as above + confirmed on an independent channel |

### 4.5 What to do if fingerprints do NOT match

> ❌ **CRITICAL ERROR: fingerprint does NOT match. Possible key tampering.**

Do not proceed. Contact the counterpart via a different channel (phone, separate PEC) to report the anomaly.

---

## 5. SENDING YOUR PUBLIC KEY

After generating your keys, send your **public** key to counterparts. Only then will they be able to encrypt files addressed to you.

The file to send is in the kit root:
```
public_key_Pico_de_Paperis.asc
```

> ✅ The public key can be shared freely. Only the **private key** must remain secret on the USB drive.

Also communicate your fingerprint (visible from `diagnostica.cmd`) so the counterpart can verify they received the correct key.

---

## 6. ENCRYPTING AND SENDING A FILE

### 6.1 Starting cifra.cmd

- **Drag & drop**: drag the file to encrypt onto `run\cifra.cmd`
- **Double-click**: open `cifra.cmd` and enter the file path when prompted

### 6.2 Step-by-step guided workflow

#### Step 1 — Select signing key

The script detects private keys available in the keyring:
- If you have **only one**, it is selected automatically
- If you have **more than one**, a numbered selection menu appears

#### Step 2 — Import additional public keys

If `.asc` files are present in the `trust\import\` folder, the script proposes them:

```
========== IMPORT ADDITIONAL PUBLIC KEYS ==========
Found 2 files to import:
  [1] Archimede Pitagorico.asc
  [2] Anacleto Mitraglia.asc

  [T] Import all
  [S] Choose which ones to import
  [N] Skip - do not import anything
```

With `[S]` you can select files one at a time; `[F]` to finish the selection.

After import, files are automatically moved to `trust\import\imported\` and will never be proposed again.

> **How to add a new public key:**
> 1. Receive the `.asc` file from the counterpart
> 2. Copy it into `trust\import\`
> 3. Restart `cifra.cmd` — the script will import and archive it

If the folder is empty, the script offers to open it directly in File Explorer.

#### Step 3 — Select recipients

All public keys in the keyring are displayed. You can select **one or more recipients** with a toggle system:

```
================ SELECT RECIPIENTS =================

  [*] [1] Mittente
        A893C524F394623C8B9CF6F14AE4DCB5D131BBB3
      [2] Archimede Pitagorico
        2EDB07F9BE7316BF5E67D9507D05DEF5017E6CD7
      [3] Anacleto Mitraglia
        0584C99D6E00BF0A77E30EB2B97A8580D0035D4F

Selected recipients: 1
    + Mittente

  Enter a number to add/remove a recipient.
  [C] Confirm and continue   [Q] Cancel
```

- Enter a number to **add** a recipient (the `[*]` marker appears)
- Enter the same number again to **remove** them
- `[C]` to confirm the selection

#### Step 4 — File to encrypt

If you did not drag the file onto the script, enter the path manually:
```
File path to encrypt: C:\Users\mario\Desktop\document.pdf
```

#### Step 5 — Summary and confirmation

```
+===============================================================+
| OPERATION SUMMARY                                             |
+===============================================================+

  File to encrypt : document.pdf
  Signer          : Pico de Paperis
  Recipients      :
    + Mittente
    + Archimede Pitagorico
  Output in       : E:\KIT_GPG\out

Proceed with encryption? (Y/N):
```

#### Step 6 — Encryption and signing

```
+===============================================================+
| ENCRYPTION IN PROGRESS                                        |
+===============================================================+

[INFO] Selected recipients' keys have been verified.
[INFO] The file will be encrypted for all indicated recipients.

[WAITING] Enter your Passphrase in the Pinentry window that will appear.
```

The Pinentry window will appear: enter the passphrase for your private key. If correct, the encrypted file will be saved in `out\document.pdf.gpg`.

### 6.3 Sending the encrypted file

The `.gpg` file produced in `out\` can be sent freely via email, PEC or portal. Its contents are readable **only by the selected recipients**.

---

## 7. RECEIVING AND DECRYPTING FILES

### 7.1 Receiving the encrypted file

1. You will receive the `.gpg` file via email, PEC or portal
2. Save it on the USB drive (recommended in the `in/` folder)
3. Avoid saving it on the computer's hard drive

### 7.2 Decrypt with Drag & Drop (recommended method)

1. Open the `run` folder on the USB drive
2. Drag the `.gpg` file onto **`decifra.cmd`**
3. Enter the passphrase in the Pinentry window
4. The decrypted file will appear in the same folder as the `.gpg` file

### 7.3 Decrypt by double-clicking

1. Double-click `decifra.cmd`
2. When prompted, drag the `.gpg` file into the window or enter the path
3. Enter the passphrase

### 7.4 Where to find the decrypted file

The decrypted file is saved in the same folder as the `.gpg` file, with the same name but without the `.gpg` extension:

```
confidential_document.pdf.gpg   →   confidential_document.pdf
```

### 7.5 Interpreting the result

| Result displayed | Meaning |
|-----------------|---------|
| `[OK] File decrypted successfully` | All good, valid signature |
| `[OK] File decrypted with WARNINGS` | Decrypted, but trust not validated — run Setup_Trust.cmd |
| `Decryption failed - Bad passphrase` | Wrong passphrase, try again |
| `Decryption failed - No secret key` | Sender used a different public key from your current one |

---

## 8. DIGITAL SIGNATURE VERIFICATION

The digital signature guarantees that the file genuinely comes from the declared sender and has not been altered.

### 8.1 How to verify

1. Open the `run` folder
2. Drag the `.gpg` file onto **`verifica.cmd`**
3. The script verifies the signature automatically
4. A detailed report is saved in `reports\`

> To obtain a full verification (GOOD SIGNATURE), you must have run **Setup_Trust.cmd** beforehand.

### 8.2 Interpreting the results

| Result | Meaning | Action |
|--------|---------|--------|
| ✅ **GOOD SIGNATURE (TRUST OK)** | Valid signature, trusted key | Proceed |
| 🟡 **SIGNATURE OK but TRUST not verified** | Technically valid, key not declared trusted | Run Setup_Trust.cmd |
| ❌ **BAD SIGNATURE** | File altered or signature not authentic | Do not open the file, contact sender |
| ⚠️ **Public key absent** | Sender key not imported | Run Setup_Trust.cmd |

---

## 9. MANAGING MULTIPLE KEYS

### 9.1 Why have multiple keys

- Separate different contexts (work, projects, entities)
- Keep old keys to decrypt historical files
- Have a key for each role or organisation

### 9.2 Managing keys with Setup_keys.cmd

When you run `Setup_keys.cmd` with existing keys, a selection menu appears. After selecting a key, you can:

- **[U]** — Export the public key (to send to new counterparts)
- **[D]** — Delete the key (irreversible operation)
- **[S]** — Change the selected key
- **[Q]** — Exit

### 9.3 Encrypting for multiple recipients

`cifra.cmd` natively supports multi-recipient encryption (see section 6). The encrypted file will be decryptable by **each** of the selected recipients.

---

## 10. SECURE USB DRIVE MANAGEMENT

### 10.1 Core rules

✅ **DO:**
- Store the USB drive in a safe place (safe, locked drawer)
- Create a backup on a second USB drive
- Update the backup after every key change
- Write down passphrases offline

❌ **DO NOT:**
- Copy the `home/` folder to the computer's hard drive
- Share the private key or passphrase
- Leave the USB drive unattended

### 10.2 Creating a backup

1. Use a second USB drive
2. Copy the entire `KIT_GPG` folder to the second drive
3. Verify all files are present
4. Store the backup in a physically separate location from the original

> ⚠️ Without a backup, losing the USB drive means permanently losing all keys and the ability to decrypt previously received files.

---

## 11. TROUBLESHOOTING

### 11.1 Diagnostics as first step

In case of problems, first run `run\diagnostica.cmd`: it checks the kit structure, present keys, GPG configuration and generates a complete report in `reports\`.

### 11.2 Common issues

| Problem | Likely cause | Solution |
|---------|-------------|----------|
| `decryption failed: No secret key` | Sender used a different public key | Resend the correct public key to the sender |
| `decryption failed: Bad passphrase` | Wrong passphrase | Retry; check CAPS LOCK and keyboard layout |
| Signature verification: TRUST not verified | Setup_Trust.cmd not run | Run Setup_Trust.cmd (section 4) |
| Signature verification: key absent | Sender key not imported | Run Setup_Trust.cmd (section 4) |
| Import files re-proposed every launch | Files not moved to `imported\` | Update to GPG Kit v2.0 |
| Script closes immediately on start | Path with special characters (`&`, accents) | Move kit to a simple path (e.g. `E:\KIT_GPG`) |
| GPG asks confirmation for each recipient | Trust not configured (older versions) | Update to GPG Kit v2.0 — resolved with `--trust-model always` |

### 11.3 Forgotten passphrase

> ⚠️ There is no recovery. If you have forgotten the passphrase, that key is unusable.

Solution: generate a new key with `Setup_keys.cmd`, send it to counterparts and ask them to re-encrypt important files.

### 11.4 Full reset

1. Decrypt all files still accessible
2. Delete the `home/` folder from the USB drive
3. Delete all `public_key_*.asc` files from the kit root
4. Run `Setup_keys.cmd` again
5. Send the new public keys to counterparts

---

## 12. FAQ — FREQUENTLY ASKED QUESTIONS

**Q: Can I use the kit on multiple computers?**  
A: Yes. The kit is completely portable: no installation required on any Windows PC.

**Q: Do I need to repeat Setup_Trust.cmd every time?**  
A: No. Run it once for each received key. Repeat it only if the counterpart renews their public key.

**Q: Can I encrypt a file for multiple recipients at once?**  
A: Yes. `cifra.cmd` supports multiple recipient selection with a toggle system. The encrypted file will be decryptable by each of the selected recipients.

**Q: Does GPG ask for confirmation before encrypting for a key?**  
A: This does not happen in GPG Kit v2.0. The script uses `--trust-model always` to avoid interactive prompts for keys consciously selected by the user.

**Q: What happens if the USB drive is damaged?**  
A: If you have a backup, use that. If not, you must redo the full setup with new keys.

**Q: Can the recipient read files after encrypting them?**  
A: Only if the file was also encrypted for their own key. In `cifra.cmd`, the signing key (you) is not automatically added as a recipient: if you want to be able to re-open the file, select yourself as a recipient too.

**Q: Is Internet required?**  
A: No. The kit works completely offline.

**Q: Can I share the private key in exceptional circumstances?**  
A: Never. There is no exceptional circumstance that justifies sharing the private key.

**Q: How do I know which key to use for decryption?**  
A: GPG recognises it automatically and asks for the passphrase of the correct key.

**Q: How often should I make backups?**  
A: After every key generation or deletion, and every time you receive important files.

---

## APPENDIX: GLOSSARY

**Public key** — Can be shared freely. Used by counterparts to encrypt files addressed to you.

**Private key** — Must remain absolutely secret on the USB drive. Used by you to decrypt received files and to sign sent files.

**Fingerprint** — Unique digital identifier of a GPG key: a 40-character hexadecimal string. Used to verify that two copies of the same key are identical.

**Passphrase** — Password protecting the private key. Without it the key cannot be used.

**Trust** — Explicit declaration that a public key genuinely belongs to the indicated person. GPG does not automatically trust any key until it is declared trusted via Setup_Trust.cmd.

**Digital signature** — Cryptographic mechanism guaranteeing authenticity (who created the file) and integrity (the file has not been modified).

**.gpg file** — File encrypted with GPG. May contain both the encrypted data and the digital signature.

**.asc file** — Text format (ASCII armor) used to export and share GPG keys.

**AEAD** — Advanced Encryption with Associated Data: modern encryption mode used by GPG 2.3+.

**trust-model always** — GPG option instructing it to trust all selected keys without interactive confirmation. Used in `cifra.cmd` because the user has already consciously chosen recipients from the list.

**GPG (GNU Privacy Guard)** — Open source software implementing the OpenPGP standard for encryption and digital signing.

---

*GPG Kit Version 2.0*  
*For technical support, contact your internal reference person*
