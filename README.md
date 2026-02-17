# KIT GPG Portabile

**Sistema portabile per la ricezione e decifratura sicura di file cifrati con GPG.**  
Funziona da chiavetta USB su qualsiasi PC Windows, senza installazione.

---

## Cos'è

KIT GPG è un bundle autosufficiente che include:

- **GnuPG 2.x** (portable, con DLL e pinentry)
- **Script `.cmd`** per tutte le operazioni comuni (generazione chiavi, verifica, decifratura)
- **Documentazione** operativa e di riferimento tecnico

Il kit gestisce l'intero ciclo di vita di uno scambio sicuro: generazione chiavi, verifica della chiave del mittente, decifratura e controllo firma digitale.

---

## Struttura

```
KIT_GPG/
├── bin/           GnuPG + DLL + pinentry
├── home/          GNUPGHOME (keyring portabile)
├── trust/         Chiave pubblica e fingerprint del mittente
├── run/           Script operativi
├── docs/          Guide
├── in/            Drop zone file .gpg in ingresso
├── out/           Output decifratura
└── reports/       Log automatici
```

---

## Avvio rapido

### 1. Genera le tue chiavi
```
run\Setup_keys.cmd
```

### 2. Verifica la chiave del mittente *(obbligatorio prima del primo utilizzo)*
Copia `publickey.asc` e `fingerprint.txt` del mittente nella cartella `trust/`, poi:
```
run\Setup_Trust.cmd
```

### 3. Invia la tua chiave pubblica al mittente
```
public_key_<Nome>.asc   →   mittente
```

### 4. Decifra i file ricevuti
```
drag & drop   →   run\decifra.cmd
```

### 5. Verifica la firma digitale
```
drag & drop   →   run\verifica.cmd
```

---

## Script

| Script | Descrizione |
|--------|-------------|
| `run\Setup_keys.cmd` | Genera, esporta, elimina chiavi personali |
| `run\Setup_Trust.cmd` | Importa, verifica e dichiara fidata la chiave del mittente |
| `run\decifra.cmd` | Decifra file `.gpg` (drag & drop o prompt) |
| `run\verifica.cmd` | Verifica firma digitale — supporta AEAD (GPG 2.3+) |
| `run\diagnostica.cmd` | Diagnostica completa con report |

---

## Documentazione

| Documento | Destinatari |
|-----------|-------------|
| `docs\Guida_Operativa_Kit_GPG_v1_5.md` | Utenti non tecnici — guida completa passo-passo |
| `docs\GuidaRapida_v1_5.md` | Utenti tecnici — riferimento operativo e algoritmi |

---

## Requisiti

- Windows 10 / 11
- Nessuna installazione richiesta
- Nessuna connessione Internet necessaria

---

## Note tecniche

- **GNUPGHOME** è impostato esplicitamente da ogni script con `--homedir <root>\home`, garantendo isolamento completo dal keyring di sistema.
- `verifica.cmd` rileva sia il formato classico (`:encrypted data packet:`) che AEAD (`:aead encrypted packet:`), compatibile con GPG 2.3+.
- `Setup_Trust.cmd` ricava la mail del mittente dinamicamente dal keyring tramite il fingerprint, senza riferimenti hardcoded.
- Il trust viene impostato via `--import-ownertrust`: livello 4 (FULL) con verifica singola, livello 5 (ULTIMATE) con doppia verifica (file kit + canale email).

---

## Changelog

### v1.5
- `Setup_Trust.cmd`: rimossi riferimenti hardcoded alla mail del mittente; mail ora estratta dinamicamente dal keyring tramite fingerprint
- `verifica.cmd`: aggiunto rilevamento pacchetti AEAD — risolto bug UNKNOWN/RC=2 su file cifrati con GPG 2.3+
- `verifica.cmd`: aggiunta `pause` finale — risolto problema finestra che si chiudeva in drag&drop
- Guide: riscrittura completa v1.5 — guida operativa (non tecnici) e guida rapida (tecnici)
- `trust/`: inclusi `publickey.asc` e `fingerprint.txt` di test per verifica funzionamento

### v1.4
- Prima versione pubblica
