# Contributing to GPG Portable Kit

Thank you for your interest in contributing to this project. This document explains how to do so in an orderly way.

---

## Reporting a bug

Open an **Issue** on GitHub with:

- **Clear title**: e.g. `verifica.cmd: UNKNOWN on AEAD file with GPG 2.4`
- **Kit version** (e.g. v1.5)
- **Operating system** (e.g. Windows 11 22H2)
- **GPG version**: output of `bin\gpg.exe --version`
- **Steps to reproduce** the problem
- **Expected behaviour** vs **actual behaviour**
- **Attached report** from the `reports/` folder (remove personal data before attaching)

---

## Proposing a change

1. **Open an Issue first** to discuss the change — avoid working on something that may not be accepted
2. **Fork** the repository
3. Create a descriptive branch: `fix/verifica-aead` or `feature/cifra-cmd`
4. Make your changes
5. Open a **Pull Request** with a clear description of what changes and why

---

## Guidelines for `.cmd` scripts

- Use `setlocal EnableExtensions EnableDelayedExpansion` at the top
- Always set `--homedir` explicitly (never rely on the system GNUPGHOME)
- Always handle `ERRORLEVEL` after every call to `gpg.exe`
- Use temporary files in `%TEMP%` with a unique name (`%RANDOM%`)
- Always delete temporary files before exiting
- Add `pause` before every `exit /b` visible to the user
- To extract fields from GPG `--with-colons` output, use the established pattern:
  ```batch
  set "TEMP_ROW=!ROW:::=:EMPTY:!"
  for /f "tokens=10 delims=:" %%F in ("!TEMP_ROW!") do set "VAL=%%F"
  ```

---

## Updating documentation

The guides are in `docs/`. If you modify a script, update the corresponding guide as well. The format is standard Markdown. Both Italian and English versions should be kept in sync.

---

## What we will not accept

- Changes that add external dependencies (the kit must remain completely offline)
- Changes that reduce security (e.g. automatic trust without fingerprint verification)
- Hardcoded references to specific email addresses, domains or organisations
