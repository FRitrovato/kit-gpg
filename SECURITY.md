# Security Policy

## Versioni supportate

| Versione | Supportata |
|----------|-----------|
| 1.5      | ✅ Sì     |
| < 1.5    | ❌ No     |

---

## Segnalare una vulnerabilità

**Non aprire una Issue pubblica per vulnerabilità di sicurezza.**

Se hai trovato una vulnerabilità (es. bypass della verifica del fingerprint, esecuzione di codice arbitrario, leak di dati sensibili), segnalala in modo riservato tramite:

- **GitHub Private Vulnerability Reporting**: usa il pulsante "Report a vulnerability" nella tab **Security** di questo repository
- In alternativa, apri una Issue con titolo `[SECURITY] <descrizione vaga>` senza dettagli tecnici — ti contatteremo per discuterne in privato

---

## Cosa aspettarsi

- **Risposta iniziale**: entro 7 giorni
- **Valutazione**: entro 14 giorni
- **Fix e rilascio**: dipende dalla gravità; le vulnerabilità critiche hanno priorità assoluta
- **Credit**: il tuo nome verrà citato nel changelog se lo desideri

---

## Scope

Rientrano nello scope:

- Script `.cmd` nella cartella `run/`
- Logica di verifica fingerprint e trust in `Setup_Trust.cmd`
- Rilevamento cifratura/firma in `verifica.cmd`
- Qualsiasi comportamento che possa portare a decifrare o accettare file non autentici

Sono fuori scope:

- Vulnerabilità in GnuPG stesso (segnalarle a https://gnupg.org/contact.html)
- Vulnerabilità nel sistema operativo Windows
- Attacchi che richiedono accesso fisico alla chiavetta USB

---

## Note sulla sicurezza del progetto

Questo kit include binari GnuPG pre-compilati. Prima di usarli in ambienti di produzione critici, è consigliabile verificare i checksum dei binari rispetto alle release ufficiali di GnuPG (https://gnupg.org/download/).
