# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| 1.5     | ✅ Yes    |
| < 1.5   | ❌ No     |

---

## Reporting a vulnerability

**Do not open a public Issue for security vulnerabilities.**

If you have found a vulnerability (e.g. fingerprint verification bypass, arbitrary code execution, sensitive data leak), please report it privately via:

- **GitHub Private Vulnerability Reporting**: use the "Report a vulnerability" button in the **Security** tab of this repository
- Alternatively, open an Issue titled `[SECURITY] <vague description>` without technical details — we will contact you to discuss it privately

---

## What to expect

- **Initial response**: within 7 days
- **Assessment**: within 14 days
- **Fix and release**: depends on severity; critical vulnerabilities have absolute priority
- **Credit**: your name will be mentioned in the changelog if you wish

---

## Scope

In scope:

- `.cmd` scripts in the `run/` folder
- Fingerprint and trust verification logic in `Setup_Trust.cmd`
- Encryption/signature detection in `verifica.cmd`
- Any behaviour that could lead to decrypting or accepting non-authentic files

Out of scope:

- Vulnerabilities in GnuPG itself (report to https://gnupg.org/contact.html)
- Windows operating system vulnerabilities
- Attacks requiring physical access to the USB drive

---

## Security notes

This kit includes pre-compiled GnuPG binaries. Before using them in critical production environments, it is advisable to verify the binaries' checksums against official GnuPG releases (https://gnupg.org/download/).
