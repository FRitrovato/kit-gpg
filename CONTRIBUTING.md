# Come contribuire a KIT GPG

Grazie per l'interesse nel contribuire al progetto. Questo documento spiega come farlo in modo ordinato.

---

## Segnalare un bug

Apri una **Issue** su GitHub con:

- **Titolo chiaro**: es. `verifica.cmd: UNKNOWN su file AEAD con GPG 2.4`
- **Versione del kit** (es. v1.5)
- **Sistema operativo** (es. Windows 11 22H2)
- **Versione GPG**: output di `bin\gpg.exe --version`
- **Passi per riprodurre** il problema
- **Comportamento atteso** vs **comportamento ottenuto**
- **Report allegato** dalla cartella `reports/` (rimuovi dati personali prima di allegarlo)

---

## Proporre una modifica

1. **Apri prima una Issue** per discutere la modifica — evita di lavorare su qualcosa che potrebbe non essere accettato
2. **Fork** del repository
3. Crea un branch descrittivo: `fix/verifica-aead` o `feature/cifra-cmd`
4. Fai le modifiche
5. Apri una **Pull Request** con descrizione chiara di cosa cambia e perché

---

## Linee guida per gli script `.cmd`

- Usa `setlocal EnableExtensions EnableDelayedExpansion` in testa
- Imposta sempre `--homedir` esplicitamente (mai affidarsi al GNUPGHOME di sistema)
- Gestisci sempre `ERRORLEVEL` dopo ogni chiamata a `gpg.exe`
- Usa file temporanei in `%TEMP%` con nome univoco (`%RANDOM%`)
- Cancella sempre i file temporanei prima di uscire
- Aggiungi `pause` prima di ogni `exit /b` visibile all'utente
- Per estrarre campi dall'output `--with-colons` di GPG usa il pattern consolidato:
  ```batch
  set "TEMP_ROW=!ROW:::=:EMPTY:!"
  for /f "tokens=10 delims=:" %%F in ("!TEMP_ROW!") do set "VAL=%%F"
  ```

---

## Aggiornare la documentazione

Le guide sono in `docs/`. Se modifichi uno script, aggiorna anche la guida corrispondente. Il formato è Markdown standard.

---

## Cosa non accettiamo

- Modifiche che aggiungono dipendenze esterne (il kit deve restare completamente offline)
- Modifiche che riducono la sicurezza (es. trust automatico senza verifica fingerprint)
- Riferimenti hardcoded a indirizzi email, domini o organizzazioni specifiche
