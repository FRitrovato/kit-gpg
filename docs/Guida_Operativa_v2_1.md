# KIT GPG PORTABILE
**Versione 2.1**  
**Guida Operativa**  
*Sistema sicuro per la cifratura, l'invio e la ricezione di dati sensibili e riservati*

---

## INDICE

1. [Introduzione al Kit GPG](#1-introduzione-al-kit-gpg)
2. [Cosa contiene il Kit](#2-cosa-contiene-il-kit)
3. [Prima configurazione: generare le proprie chiavi](#3-prima-configurazione-generare-le-proprie-chiavi)
4. [Configurazione obbligatoria: verificare la chiave del mittente](#4-configurazione-obbligatoria-verificare-la-chiave-del-mittente)
5. [Invio della chiave pubblica](#5-invio-della-chiave-pubblica)
6. [Cifrare e inviare un file](#6-cifrare-e-inviare-un-file)
7. [Ricezione e decifratura dei file](#7-ricezione-e-decifratura-dei-file)
8. [Verifica firma digitale](#8-verifica-firma-digitale)
9. [Gestione chiavi multiple](#9-gestione-chiavi-multiple)
10. [Gestione sicura della chiavetta](#10-gestione-sicura-della-chiavetta)
11. [Risoluzione problemi](#11-risoluzione-problemi)
12. [FAQ - Domande frequenti](#12-faq---domande-frequenti)
13. [Appendice: Glossario termini tecnici](#appendice-glossario-termini-tecnici)

---

## 1. INTRODUZIONE AL KIT GPG

### 1.1 Cos'è il Kit GPG

Il Kit GPG è un sistema portabile e autosufficiente per cifrare, inviare e ricevere dati sensibili in modo sicuro. È progettato per funzionare direttamente da una chiavetta USB, senza bisogno di installare nulla sul computer.

### 1.2 Come funziona in sintesi

Immagina una cassetta della posta con due chiavi:

- **La chiave pubblica** è come la buca delle lettere: chiunque può inserirci un messaggio (cifrare un file per te), ma solo tu puoi aprire la cassetta.
- **La chiave privata** è la chiave della serratura: solo tu la possiedi e solo con essa puoi leggere i messaggi ricevuti (decifrare i file).

> ⚠️ **IMPORTANTE**  
> La chiave privata non lascia mai la chiavetta. I file cifrati possono essere decifrati solo da chi possiede quella chiave. Se la perdi, perdi l'accesso ai dati.

### 1.3 Il processo di scambio sicuro — dall'inizio alla fine

```
[TU]                                    [CONTROPARTE]
  |                                          |
  |-- 1. Generi la tua coppia di chiavi      |
  |        (Setup_keys.cmd)                  |
  |                                          |
  |-- 2. Scambiate le chiavi pubbliche ----->|
  |        (via email / PEC / portale)  <----|
  |                                          |
  |-- 3. Verifichi la chiave ricevuta        |
  |        (Setup_Trust.cmd) ← OBBLIGATORIO  |
  |                                          |
  |-- 4. Cifri e invii un file ------------->|
  |        (cifra.cmd)                       |
  |                                          |
  |<-- 5. Ricevi un file cifrato ------------|
  |        (estensione .gpg)                 |
  |                                          |
  |-- 6. Decifri e verifichi la firma        |
  |        (decifra.cmd + verifica.cmd)      |
```

---

## 2. COSA CONTIENE IL KIT

### 2.1 Struttura delle cartelle

```
KIT_GPG/
├── run/                        ← Script da eseguire
│   ├── Setup_keys.cmd          ← Genera e gestisce le tue chiavi
│   ├── Setup_Trust.cmd         ← Verifica e dichiara fidata una chiave pubblica
│   ├── cifra.cmd               ← Cifra e firma file da inviare
│   ├── decifra.cmd             ← Decifra i file ricevuti
│   ├── verifica.cmd            ← Verifica la firma digitale
│   └── diagnostica.cmd         ← Diagnostica e troubleshooting
│
├── trust/                      ← Chiavi pubbliche ricevute
│   ├── publickey.asc           ← Chiave pubblica mittente principale
│   ├── fingerprint.txt         ← Impronta digitale (per verifica Setup_Trust)
│   └── import/                 ← Zona di carico chiavi pubbliche aggiuntive
│       └── imported/           ← File .asc già importati (archiviati automaticamente)
│
├── home/                       ← Keyring GPG — NON toccare, NON condividere
├── in/                         ← Cartella consigliata per file cifrati in arrivo
├── out/                        ← File cifrati in uscita (prodotti da cifra.cmd)
├── docs/                       ← Questa guida e la guida rapida
├── reports/                    ← Report generati automaticamente dagli script
└── public_key_*.asc            ← Le tue chiavi pubbliche (da inviare alle controparti)
```

### 2.2 Script disponibili

| Script | Funzione | Quando usarlo |
|--------|----------|---------------|
| **Setup_keys.cmd** | Genera e gestisce le tue chiavi personali | Prima configurazione, nuove chiavi, export |
| **Setup_Trust.cmd** | Verifica e dichiara fidata una chiave pubblica ricevuta | Prima di cifrare per un nuovo destinatario / prima di decifrare |
| **cifra.cmd** | Cifra e firma file da inviare a uno o più destinatari | Ogni volta che devi inviare un file cifrato |
| **decifra.cmd** | Decifra file `.gpg` ricevuti | Ogni volta che ricevi un file cifrato |
| **verifica.cmd** | Verifica la firma digitale di un file | Per controllare autenticità e integrità |
| **diagnostica.cmd** | Diagnostica problemi | Quando qualcosa non funziona |

---

## 3. PRIMA CONFIGURAZIONE: GENERARE LE PROPRIE CHIAVI

> Questo passaggio va eseguito **una sola volta**, a meno che tu non debba creare una nuova chiave in futuro.

### 3.1 Copia il Kit sulla chiavetta USB

1. Inserisci una chiavetta USB nel computer
2. Estrai il contenuto del file ZIP ricevuto
3. Copia l'intera cartella `KIT_GPG` sulla chiavetta
4. Verifica che tutti i file siano stati copiati correttamente

### 3.2 Genera la tua prima chiave

1. Apri la cartella `run` sulla chiavetta
2. Fai doppio clic su **`Setup_keys.cmd`**
3. Se non hai ancora chiavi, lo script avvierà automaticamente la generazione

Lo script chiederà:

- **Nome e Cognome** — inserisci il tuo nome completo (es. `Pico de Paperis`)
- **Email** — il tuo indirizzo email
- **Commento** — opzionale, utile per distinguere chiavi diverse (es. `Lavoro`)
- **Passphrase** — una password forte per proteggere la chiave privata

> ⚠️ **SCELTA DELLA PASSPHRASE**  
> La passphrase è l'unica protezione della tua chiave privata. Deve essere:
> - Lunga almeno 12 caratteri, con lettere, numeri e simboli
> - Facile da ricordare per te, impossibile da indovinare per altri
> - **Annotata OFFLINE** (carta, non file digitale) e conservata in luogo sicuro
> - **NON recuperabile**: se la dimentichi, la chiave diventa inutilizzabile

### 3.3 Cosa succede al termine

Lo script salva la chiave privata nel keyring (`home/`) e genera il file `public_key_Pico_de_Paperis.asc` nella root del kit, pronto da inviare alle controparti.

---

## 4. CONFIGURAZIONE OBBLIGATORIA: VERIFICARE LA CHIAVE RICEVUTA

> ⚠️ **QUESTO PASSAGGIO È OBBLIGATORIO**  
> Senza di esso, GPG non si fida della chiave ricevuta e la verifica della firma fallirà sempre, anche se il file è autentico.

### 4.1 Cos'è e perché è necessario

Quando ricevi la chiave pubblica di una controparte, devi:
1. **Verificare** che sia autentica (che provenga davvero dal mittente, non da terzi)
2. **Dichiarare** a GPG che ti fidi di quella chiave

### 4.2 Cosa ti serve

| File/Dato | Dove si trova | Scopo |
|-----------|---------------|-------|
| `publickey.asc` | Cartella `trust/` del kit | La chiave pubblica della controparte |
| `fingerprint.txt` | Cartella `trust/` del kit | L'impronta digitale univoca della chiave |
| Fingerprint via email/PEC | Nella comunicazione ricevuta | Verifica su canale indipendente (opzionale ma consigliata) |

### 4.3 Esegui Setup_Trust.cmd

1. Copia `publickey.asc` e `fingerprint.txt` nella cartella `trust/`
2. Fai doppio clic su **`run\Setup_Trust.cmd`**
3. Lo script importa la chiave, ne verifica il fingerprint e chiede conferma

### 4.4 Livelli di trust

| Scenario | Trust | Descrizione |
|----------|-------|-------------|
| Solo verifica file kit | **4 — FULL** | Fingerprint nel kit corrisponde alla chiave importata |
| Doppia verifica (kit + email) | **5 — ULTIMATE** | Come sopra + conferma su canale indipendente |

### 4.5 Cosa fare se i fingerprint NON corrispondono

> ❌ **ERRORE CRITICO: il fingerprint NON corrisponde. Possibile manomissione della chiave.**

Non procedere. Contatta la controparte tramite un canale diverso (telefono, PEC separata) per segnalare l'anomalia.

---

## 5. INVIO DELLA CHIAVE PUBBLICA

Dopo aver generato le tue chiavi, invia la tua chiave **pubblica** alle controparti. Solo così potranno cifrare file destinati a te.

Il file da inviare si trova nella root del kit:
```
public_key_Pico_de_Paperis.asc
```

> ✅ La chiave pubblica può essere condivisa liberamente. Solo la chiave **privata** deve restare segreta sulla chiavetta.

Comunica anche il fingerprint (visibile da `diagnostica.cmd`) così la controparte può verificare di aver ricevuto la chiave giusta.

---

## 6. CIFRARE E INVIARE UN FILE

### 6.1 Avviare cifra.cmd

- **Drag & drop**: trascina il file da cifrare sopra `run\cifra.cmd`
- **Doppio clic**: apri `cifra.cmd` e inserisci il percorso del file quando richiesto

### 6.2 Flusso guidato passo per passo

#### Passo 1 — Selezione chiave firmataria

Lo script rileva le chiavi private disponibili nel portachiavi:
- Se ne hai **una sola**, viene selezionata automaticamente
- Se ne hai **più di una**, compare un menu di selezione numerato

#### Passo 2 — Importazione chiavi pubbliche aggiuntive

Se nella cartella `trust\import\` sono presenti file `.asc`, lo script li propone:

```
========== IMPORTAZIONE CHIAVI PUBBLICHE AGGIUNTIVE ==========
Trovati 2 file da importare:
  [1] Archimede Pitagorico.asc
  [2] Anacleto Mitraglia.asc

  [T] Importa tutti
  [S] Scegli quali importare
  [N] Salta - non importare nulla
```

Con `[S]` puoi selezionare i file uno alla volta; `[F]` per terminare la selezione.

Dopo l'importazione i file vengono spostati automaticamente in `trust\import\imported\` e non verranno mai riproposti.

> **Come aggiungere una nuova chiave pubblica:**
> 1. Ricevi il file `.asc` dalla controparte
> 2. Copialo in `trust\import\`
> 3. Riavvia `cifra.cmd` — lo script lo importerà e archivierà

Se la cartella è vuota, lo script offre di aprirla direttamente in Esplora File per facilitare l'inserimento.

#### Passo 3 — Selezione destinatari

Vengono mostrate tutte le chiavi pubbliche presenti nel portachiavi. Puoi selezionare **uno o più destinatari** con sistema toggle:

```
================ SELEZIONE DESTINATARI =================

  [*] [1] Mittente
        A893C524F394623C8B9CF6F14AE4DCB5D131BBB3
      [2] Archimede Pitagorico
        2EDB07F9BE7316BF5E67D9507D05DEF5017E6CD7
      [3] Anacleto Mitraglia
        0584C99D6E00BF0A77E30EB2B97A8580D0035D4F

Destinatari selezionati: 1
    + Mittente

  Digita un numero per aggiungere/togliere un destinatario.
  [C] Conferma e continua   [Q] Annulla
```

- Digita un numero per **aggiungere** un destinatario (appare il marcatore `[*]`)
- Digita lo stesso numero di nuovo per **rimuoverlo**
- `[C]` per confermare la selezione

#### Passo 4 — File da cifrare

Se non hai trascinato il file sullo script, inserisci il percorso manualmente:
```
Percorso file da cifrare: C:\Users\mario\Desktop\documento.pdf
```

#### Passo 5 — Riepilogo e conferma

```
+===============================================================+
| RIEPILOGO OPERAZIONE                                          |
+===============================================================+

  File da cifrare : documento.pdf
  Firmatario      : Pico de Paperis
  Destinatari     :
    + Mittente
    + Archimede Pitagorico
  Output in       : E:\KIT_GPG\out

Procedere con la cifratura? (S/N):
```

#### Passo 6 — Cifratura e firma

```
+===============================================================+
| CIFRATURA IN CORSO                                            |
+===============================================================+

[INFO] Le chiavi dei destinatari selezionati sono state verificate.
[INFO] Il file verra' cifrato per tutti i destinatari indicati.

[ATTESA] Inserisci la Passphrase nella finestra Pinentry che apparira'.
```

Apparirà la finestra Pinentry: inserisci la passphrase della tua chiave privata. Se la passphrase è corretta, il file cifrato verrà salvato in `out\documento.pdf.gpg`.

### 6.3 Inviare il file cifrato

Il file `.gpg` prodotto in `out\` può essere inviato liberamente via email, PEC o portale. Il suo contenuto è leggibile **solo dai destinatari selezionati**.

---

## 7. RICEZIONE E DECIFRATURA DEI FILE

### 7.1 Ricevere il file cifrato

1. Riceverai il file `.gpg` via email, PEC o portale
2. Salvalo sulla chiavetta USB (consigliato nella cartella `in/`)
3. Evita di salvarlo sul disco fisso del computer

### 7.2 Decifrare con Drag & Drop (metodo consigliato)

1. Apri la cartella `run` sulla chiavetta
2. Trascina il file `.gpg` sopra **`decifra.cmd`**
3. Inserisci la passphrase nella finestra Pinentry
4. Il file decifrato apparirà nella stessa cartella del file `.gpg`

### 7.3 Decifrare con doppio clic

1. Fai doppio clic su `decifra.cmd`
2. Quando richiesto, trascina il file `.gpg` nella finestra oppure inserisci il percorso
3. Inserisci la passphrase

### 7.4 Dove trovare il file decifrato

Il file decifrato viene salvato nella stessa cartella del `.gpg`, con lo stesso nome ma senza l'estensione `.gpg`:

```
documento_riservato.pdf.gpg   →   documento_riservato.pdf
```

### 7.5 Interpretare l'esito

| Esito visualizzato | Significato |
|--------------------|-------------|
| `[OK] File decifrato con successo` | Tutto OK, firma valida |
| `[OK] File decifrato con AVVISI` | Decifrato, ma trust non validato — esegui Setup_Trust.cmd |
| `Decifratura fallita - Bad passphrase` | Passphrase errata, riprova |
| `Decifratura fallita - No secret key` | Il mittente ha usato una chiave pubblica diversa dalla tua attuale |

---

## 8. VERIFICA FIRMA DIGITALE

La firma digitale garantisce che il file provenga davvero dal mittente dichiarato e non sia stato alterato.

### 8.1 Come verificare

1. Apri la cartella `run`
2. Trascina il file `.gpg` sopra **`verifica.cmd`**
3. Lo script verifica automaticamente la firma
4. Un report dettagliato viene salvato in `reports\`

> Per ottenere una verifica completa (GOOD SIGNATURE), è necessario aver eseguito **Setup_Trust.cmd** in precedenza.

### 8.2 Interpretare i risultati

| Esito | Significato | Azione |
|-------|-------------|--------|
| ✅ **GOOD SIGNATURE (TRUST OK)** | Firma valida, chiave fidata | Procedi |
| 🟡 **SIGNATURE OK ma TRUST non verificato** | Firma valida, chiave non dichiarata fidata | Esegui Setup_Trust.cmd |
| ❌ **BAD SIGNATURE** | File alterato o firma non autentica | Non aprire il file, contatta il mittente |
| ⚠️ **Chiave pubblica assente** | Chiave del mittente non importata | Esegui Setup_Trust.cmd |

---

## 9. GESTIONE CHIAVI MULTIPLE

### 9.1 Perché avere più chiavi

- Separare contesti diversi (lavoro, progetti, enti)
- Mantenere chiavi vecchie per decifrare file storici
- Avere una chiave per ogni ruolo o organizzazione

### 9.2 Gestire le chiavi con Setup_keys.cmd

Quando esegui `Setup_keys.cmd` con chiavi già presenti, vedrai un menu di selezione. Dopo aver selezionato una chiave, puoi:

- **[U]** — Esporta la chiave pubblica (per inviarla a nuove controparti)
- **[D]** — Elimina la chiave (operazione irreversibile)
- **[S]** — Cambia chiave selezionata
- **[Q]** — Esci

### 9.3 Eliminare una chiave

> ⚠️ **Operazione irreversibile.** Dopo l'eliminazione non sarà più possibile decifrare i file ricevuti con quella chiave.

### 9.4 Cifrare per più destinatari

`cifra.cmd` supporta nativamente la cifratura multi-destinatario (vedere sezione 6). Il file cifrato sarà decifrabile da **ognuno** dei destinatari selezionati.

---

## 10. GESTIONE SICURA DELLA CHIAVETTA

### 10.1 Regole fondamentali

✅ **FARE:**
- Conservare la chiavetta in luogo sicuro (cassaforte, cassetto chiuso a chiave)
- Creare un backup su una seconda chiavetta USB
- Aggiornare il backup dopo ogni modifica alle chiavi
- Annotare offline le passphrase

❌ **NON FARE:**
- Mai copiare la cartella `home/` sul disco fisso del computer
- Mai condividere la chiave privata o la passphrase
- Mai lasciare la chiavetta incustodita

### 10.2 Creare un backup

1. Usa una seconda chiavetta USB
2. Copia l'intera cartella `KIT_GPG` sulla seconda chiavetta
3. Verifica che tutti i file siano presenti
4. Conserva il backup in un luogo fisicamente separato dall'originale

> ⚠️ Senza backup, la perdita della chiavetta comporta la perdita definitiva di tutte le chiavi e l'impossibilità di decifrare i file già ricevuti.

---

## 11. RISOLUZIONE PROBLEMI

### 11.1 Diagnostica come primo passo

In caso di problemi, esegui prima `run\diagnostica.cmd`: verifica la struttura del kit, le chiavi presenti, la configurazione GPG e genera un report completo in `reports\`.

### 11.2 Problemi comuni

| Problema | Causa probabile | Soluzione |
|----------|----------------|-----------|
| `decryption failed: No secret key` | Mittente ha usato una chiave pubblica diversa | Reinvia la chiave pubblica corretta al mittente |
| `decryption failed: Bad passphrase` | Passphrase errata | Riprova; controlla CAPS LOCK e layout tastiera |
| Verifica firma: TRUST non verificato | Setup_Trust.cmd non eseguito | Esegui Setup_Trust.cmd (sezione 4) |
| Verifica firma: chiave assente | Chiave mittente non importata | Esegui Setup_Trust.cmd (sezione 4) |
| File da importare riproposti ogni avvio | File non spostati in `imported\` | Aggiorna a KIT GPG v2.1 |
| Errore all'avvio dello script | Percorso con caratteri speciali (`&`, accenti) | Sposta il kit in percorso senza spazi o simboli (es. `E:\KIT_GPG`) |
| GPG chiede conferma su ogni chiave destinatario | Trust non configurato (versioni precedenti) | Aggiorna a KIT GPG v2.1 — risolto con `--trust-model always` |

### 11.3 Passphrase dimenticata

> ⚠️ Non esiste recupero. Se hai dimenticato la passphrase, quella chiave è inutilizzabile.

Soluzione: genera una nuova chiave con `Setup_keys.cmd`, inviala alle controparti e chiedi di ri-cifrare i file importanti.

### 11.4 Reset completo

1. Decifra tutti i file ancora accessibili
2. Elimina la cartella `home/` dalla chiavetta
3. Elimina tutti i file `public_key_*.asc` dalla root del kit
4. Esegui nuovamente `Setup_keys.cmd`
5. Invia le nuove chiavi pubbliche alle controparti

---

## 12. FAQ - DOMANDE FREQUENTI

**Q: Posso usare il kit su più computer?**  
A: Sì. Il kit è completamente portabile: nessuna installazione richiesta su qualsiasi PC Windows.

**Q: Devo ripetere Setup_Trust.cmd ogni volta?**  
A: No. Basta eseguirlo una volta per ogni chiave ricevuta. Ripetilo solo se la controparte rinnova la sua chiave pubblica.

**Q: Posso cifrare un file per più destinatari contemporaneamente?**  
A: Sì. `cifra.cmd` supporta la selezione multipla di destinatari con sistema toggle. Il file cifrato sarà decifrabile da ognuno dei destinatari selezionati.

**Q: GPG mi chiede conferma prima di cifrare per una chiave?**  
A: Questo non avviene nel KIT GPG v2.0. Lo script usa `--trust-model always` per evitare richieste interattive su chiavi selezionate consapevolmente dall'utente.

**Q: Cosa succede se la chiavetta si danneggia?**  
A: Se hai un backup, usi quello. Se non hai backup, dovrai rifare il setup completo con nuove chiavi.

**Q: Il destinatario può leggere i file dopo averli cifrati?**  
A: Solo se il file è stato cifrato anche per la propria chiave. In `cifra.cmd`, la chiave firmataria (te) non viene aggiunta automaticamente ai destinatari: se vuoi poter riaprire il file, seleziona anche te stesso come destinatario.

**Q: Serve Internet?**  
A: No. Il kit funziona completamente offline.

**Q: Posso condividere la chiave privata in casi eccezionali?**  
A: Mai. Non esiste un caso eccezionale che giustifichi la condivisione della chiave privata.

**Q: Come faccio a sapere quale chiave usare per decifrare?**  
A: GPG la riconosce automaticamente e chiede la passphrase della chiave corretta.

**Q: Quanto spesso fare il backup?**  
A: Dopo ogni generazione o eliminazione di chiavi, e ogni volta che ricevi file importanti.

---

## APPENDICE: GLOSSARIO TERMINI TECNICI

**Chiave pubblica** — Può essere condivisa liberamente. Serve alle controparti per cifrare file destinati a te.

**Chiave privata** — Deve restare assolutamente segreta sulla chiavetta. Serve a te per decifrare i file ricevuti e per firmare i file inviati.

**Fingerprint** — Impronta digitale univoca di una chiave GPG: una stringa esadecimale di 40 caratteri. Serve per verificare che due copie della stessa chiave siano identiche.

**Passphrase** — Password che protegge la chiave privata. Senza di essa la chiave non può essere usata.

**Trust / Fiducia** — Dichiarazione esplicita che una chiave pubblica appartiene davvero alla persona indicata. GPG non si fida automaticamente di nessuna chiave finché non viene dichiarata fidata tramite Setup_Trust.cmd.

**Firma digitale** — Meccanismo crittografico che garantisce autenticità (chi ha creato il file) e integrità (il file non è stato modificato).

**File .gpg** — File cifrato con GPG. Può contenere sia il dato cifrato che la firma digitale.

**File .asc** — Formato testuale (ASCII armor) usato per esportare e condividere chiavi GPG.

**AEAD** — Advanced Encryption with Associated Data: modalità di cifratura moderna usata da GPG 2.3+.

**trust-model always** — Opzione GPG che indica di fidarsi di tutte le chiavi selezionate senza richiedere conferma interattiva. Usata in `cifra.cmd` perché l'utente ha già scelto consapevolmente i destinatari dalla lista.

**GPG (GNU Privacy Guard)** — Software open source che implementa lo standard OpenPGP per cifratura e firma digitale.

---

*KIT GPG Versione 2.1*  
*Per supporto tecnico, contattare il proprio referente interno*
