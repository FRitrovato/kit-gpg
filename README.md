# KIT GPG Portabile

**Sistema portabile per la cifratura, l'invio e la ricezione sicura di file con GPG.**  
Funziona da chiavetta USB su qualsiasi PC Windows, senza installazione.

---

## Cos'è

KIT GPG è un bundle autosufficiente che include:

- **GnuPG 2.x** (portable, con DLL e pinentry)
- **Script `.cmd`** per tutte le operazioni comuni (generazione chiavi, cifratura, verifica, decifratura)
- **Documentazione** operativa e di riferimento tecnico

Il kit gestisce l'intero ciclo di vita di uno scambio sicuro: generazione chiavi, verifica delle chiavi ricevute, cifratura multi-destinatario, decifratura e controllo firma digitale.

---

## Struttura

```
KIT_GPG/
├── bin/           GnuPG + DLL + pinentry
├── home/          GNUPGHOME (keyring portabile)
├── trust/
│   ├── publickey.asc      chiave pubblica mittente principale
│   ├── fingerprint.txt    fingerprint atteso (per Setup_Trust)
│   └── import/            zona di carico chiavi pubbliche aggiuntive
│       └── imported/      file .asc già importati (archiviati automaticamente)
├── run/           Script operativi
├── docs/          Guide
├── in/            Drop zone file .gpg in ingresso
├── out/           File cifrati in uscita
└── reports/       Log automatici
```

---

## Avvio rapido

### 1. Genera le tue chiavi
```
run\Setup_keys.cmd
```

### 2. Verifica la chiave ricevuta *(obbligatorio prima del primo utilizzo)*
Copia `publickey.asc` e `fingerprint.txt` nella cartella `trust/`, poi:
```
run\Setup_Trust.cmd
```

### 3. Invia la tua chiave pubblica
```
public_key_<Nome>.asc   →   controparte
```

### 4. Cifra e invia un file
```
drag & drop   →   run\cifra.cmd
```

### 5. Decifra i file ricevuti
```
drag & drop   →   run\decifra.cmd
```

### 6. Verifica la firma digitale
```
drag & drop   →   run\verifica.cmd
```

---

## Script

| Script | Descrizione |
|--------|-------------|
| `run\Setup_keys.cmd` | Genera, esporta, elimina chiavi personali |
| `run\Setup_Trust.cmd` | Importa, verifica e dichiara fidata una chiave pubblica |
| `run\cifra.cmd` | Cifra e firma file — wizard guidato con selezione destinatari multipli |
| `run\decifra.cmd` | Decifra file `.gpg` (drag & drop o prompt) |
| `run\verifica.cmd` | Verifica firma digitale — supporta AEAD (GPG 2.3+) |
| `run\diagnostica.cmd` | Diagnostica completa con report |

---

## Documentazione

| Documento | Destinatari |
|-----------|-------------|
| `docs\Guida_Operativa_Kit_GPG_v2_0.md` | Utenti — guida completa passo-passo (IT) |
| `docs\Guida_Operativa_Kit_GPG_v2_0_EN.md` | Users — full step-by-step guide (EN) |
| `docs\GuidaRapida_v2_0.md` | Tecnici — riferimento operativo e algoritmi (IT) |
| `docs\GuidaRapida_v2_0_EN.md` | Technical users — operational reference (EN) |

---

## Requisiti

- Windows 10 / 11
- Nessuna installazione richiesta
- Nessuna connessione Internet necessaria

---

## Note tecniche

- **GNUPGHOME** è impostato esplicitamente da ogni script con `--homedir <root>\home`, garantendo isolamento completo dal keyring di sistema.
- `cifra.cmd` supporta cifratura multi-destinatario con menu toggle interattivo. Usa `--trust-model always` per evitare richieste interattive di conferma su chiavi selezionate consapevolmente dall'utente.
- `cifra.cmd` gestisce l'importazione di chiavi pubbliche aggiuntive da `trust\import\`: i file vengono spostati in `imported\` dopo l'importazione e non vengono mai riproposti.
- `verifica.cmd` rileva sia il formato classico (`:encrypted data packet:`) che AEAD (`:aead encrypted packet:`), compatibile con GPG 2.3+.
- `Setup_Trust.cmd` ricava la mail del mittente dinamicamente dal keyring tramite fingerprint, senza riferimenti hardcoded.
- Il trust viene impostato via `--import-ownertrust`: livello 4 (FULL) con verifica singola, livello 5 (ULTIMATE) con doppia verifica (file kit + canale email).
- Tutti gli script CMD seguono lo stile **goto-safe**: nessuna label dentro blocchi `if (...)` o `for (...)`, garantendo compatibilità e stabilità su tutte le versioni di Windows CMD.

---

## Changelog

### v2.0
- `cifra.cmd`: nuovo script — Encryption Wizard con selezione multi-destinatario (toggle interattivo), importazione chiavi pubbliche da `trust\import\` con archiviazione automatica in `imported\`, selezione chiave firmataria, riepilogo e conferma prima della cifratura
- `cifra.cmd`: aggiunto `--trust-model always` — eliminata richiesta interattiva di conferma su chiavi senza trust configurato
- `cifra.cmd`: fix bug delayed expansion (`!RECIP_COUNT!` invece di `%RECIP_COUNT%`) — risolto nome destinatario vuoto dopo selezione
- `cifra.cmd`: fix bug label-in-block — riscrittura goto-safe di tutto il flusso di importazione; eliminato `call :IMPORT_ONE_KEY` dentro `for /L`
- `cifra.cmd`: fix importazione sempre riproposta — file spostati in `imported\` indipendentemente dal RC di GPG
- `cifra.cmd`: fix variabili GPG — `!SENDER_FPR!` e `!RECIP_ARGS!` trasferiti in variabili normali prima della chiamata GPG
- `diagnostica.cmd`: aggiornato a v2.0
- `verifica.cmd`: aggiornato a v2.0
- `Setup_Trust.cmd`: aggiornato a v2.0
- Guide: riscrittura completa v2.0 — guida operativa e guida rapida in italiano e inglese

### v1.6
- `verifica.cmd`: aggiunto rilevamento pacchetti AEAD — risolto bug UNKNOWN/RC=2 su file cifrati con GPG 2.3+
- `verifica.cmd`: riscrittura goto-safe completa
- `decifra.cmd`: rimosso riferimento hardcoded `sogei_publickey.asc`, allineato a `trust\publickey.asc`

### v1.5
- `Setup_Trust.cmd`: rimossi riferimenti hardcoded alla mail del mittente; mail ora estratta dinamicamente dal keyring tramite fingerprint
- `Setup_Trust.cmd`: algoritmo di estrazione mail allineato a quello di `Setup_keys.cmd`
- `verifica.cmd`: aggiunta `pause` finale — risolto problema finestra che si chiudeva in drag&drop
- Guide: riscrittura completa — guida operativa e guida rapida

### v1.4
- Prima versione pubblica
