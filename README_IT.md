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

## Conformità normativa

Questo kit è uno **strumento tecnico** e non è soggetto direttamente alle normative di cybersicurezza. Tuttavia, le organizzazioni che lo adottano per proteggere lo scambio di dati sensibili possono fare riferimento ai seguenti quadri normativi per valutarne la coerenza con i propri obblighi di compliance.

### NIS2 — D.Lgs. 138/2024 (recepimento Direttiva UE 2022/2555)

In vigore dal 16 ottobre 2024, il decreto impone ai soggetti essenziali e importanti l'adozione di misure tecniche e organizzative tra cui, esplicitamente, **"politiche e procedure relative all'uso della crittografia e, ove opportuno, della cifratura"** (art. 24).

Il kit supporta questo requisito perché:
- Implementa cifratura asimmetrica OpenPGP con chiavi RSA 3072 bit (standard raccomandato)
- Garantisce autenticazione tramite firma digitale su ogni file scambiato
- Produce log e report verificabili per ogni operazione (audit trail)
- Impone la verifica esplicita del fingerprint prima di dichiarare fidata una chiave (catena di fiducia documentata)

> ⚠️ Il kit è un componente tecnico. La conformità NIS2 richiede anche misure organizzative, governance e notifica degli incidenti che esulano dall'ambito di questo strumento.

### GDPR — Regolamento UE 2016/679

L'art. 32 del GDPR richiede misure tecniche adeguate a garantire la sicurezza del trattamento, inclusa la cifratura dei dati personali.

Il kit supporta questo requisito perché:
- I file contenenti dati personali vengono trasmessi esclusivamente in forma cifrata
- Le chiavi private non lasciano mai il dispositivo del destinatario
- Nessun dato transita su server di terze parti (funzionamento completamente offline)
- La firma digitale garantisce integrità e autenticità del dato ricevuto (art. 5 GDPR — principio di integrità)

### ACN — Linee Guida Funzioni Crittografiche

L'ACN promuove l'uso della crittografia come strumento di cybersicurezza, favorendone l'impiego lungo l'intero ciclo di vita dei sistemi ICT, in conformità ai principi della sicurezza e della tutela della privacy.

Il CVCN (Centro di Valutazione e Certificazione Nazionale) richiede esplicitamente chiavi PGP di tipo RSA + RSA (2048, 3072 o 4096 bit) o ECC per lo scambio di documenti nei procedimenti ufficiali.

Il kit utilizza **RSA 3072 bit** per la generazione delle chiavi, in linea con questi requisiti. La validità delle chiavi è impostata a **3 anni**, coerente con le raccomandazioni ACN.

### Riepilogo

| Requisito normativo | Riferimento | Supportato dal kit |
|---------------------|-------------|-------------------|
| Uso della crittografia | NIS2 art. 24 / D.Lgs. 138/2024 | ✅ OpenPGP RSA 3072 |
| Cifratura dati personali | GDPR art. 32 | ✅ Cifratura asimmetrica |
| Integrità e autenticità | GDPR art. 5 | ✅ Firma digitale obbligatoria |
| Verifica catena di fiducia | ACN Linee Guida Crittografia | ✅ Verifica fingerprint su doppio canale |
| Chiavi RSA 2048/3072/4096 | ACN / CVCN | ✅ RSA 3072 (default) |
| Audit trail | NIS2 art. 24 | ✅ Report automatici in `reports/` |
| Funzionamento offline | Best practice sicurezza | ✅ Nessuna dipendenza da rete |

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
- `Setup_Trust.cmd`: algoritmo di estrazione mail allineato a quello di `Setup_keys.cmd` (sostituzione `:::=:EMPTY:`, token 10)
- `verifica.cmd`: aggiunto rilevamento pacchetti AEAD — risolto bug UNKNOWN/RC=2 su file cifrati con GPG 2.3+
- `verifica.cmd`: aggiunta `pause` finale — risolto problema finestra che si chiudeva in drag&drop
- Guide: riscrittura completa v1.5 — guida operativa (non tecnici) e guida rapida (tecnici)
- `trust/`: inclusi `publickey.asc` e `fingerprint.txt` di test per verifica funzionamento

### v1.4
- Prima versione pubblica
