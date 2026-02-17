# KIT GPG PORTABILE
**Versione 1.5**  
**Guida Operativa per Destinatari**  
*Sistema sicuro per la ricezione di dati sensibili e riservati*

---

## INDICE

1. [Introduzione al Kit GPG](#1-introduzione-al-kit-gpg)
2. [Cosa contiene il Kit](#2-cosa-contiene-il-kit)
3. [Prima configurazione: generare le proprie chiavi](#3-prima-configurazione-generare-le-proprie-chiavi)
4. [Configurazione obbligatoria: verificare la chiave del mittente](#4-configurazione-obbligatoria-verificare-la-chiave-del-mittente)
5. [Invio della chiave pubblica al mittente](#5-invio-della-chiave-pubblica-al-mittente)
6. [Ricezione e decifratura dei file](#6-ricezione-e-decifratura-dei-file)
7. [Verifica firma digitale](#7-verifica-firma-digitale)
8. [Gestione chiavi multiple](#8-gestione-chiavi-multiple)
9. [Gestione sicura della chiavetta](#9-gestione-sicura-della-chiavetta)
10. [Risoluzione problemi](#10-risoluzione-problemi)
11. [FAQ - Domande frequenti](#11-faq---domande-frequenti)
12. [Appendice: Glossario termini tecnici](#appendice-glossario-termini-tecnici)

---

## 1. INTRODUZIONE AL KIT GPG

### 1.1 Cos'è il Kit GPG

Il Kit GPG è un sistema portabile e autosufficiente per ricevere e decifrare dati sensibili in modo sicuro. È progettato per funzionare direttamente da una chiavetta USB, senza bisogno di installare nulla sul computer.

### 1.2 Come funziona in sintesi

Immagina una cassetta della posta con due chiavi:

- **La chiave pubblica** è come la buca delle lettere: chiunque può inserirci un messaggio (cifrare un file per te), ma solo tu puoi aprire la cassetta.
- **La chiave privata** è la chiave della serratura: solo tu la possiedi e solo con essa puoi leggere i messaggi ricevuti (decifrare i file).

> ⚠️ **IMPORTANTE**  
> La chiave privata non lascia mai la chiavetta. I file cifrati possono essere decifrati solo da chi possiede quella chiave. Se la perdi, perdi l'accesso ai dati.

### 1.3 Il processo di scambio sicuro — dall'inizio alla fine

Il flusso completo, che questa guida descrive passo dopo passo, è il seguente:

```
[TU]                                    [MITTENTE]
  |                                          |
  |-- 1. Generi la tua coppia di chiavi      |
  |        (Setup_keys.cmd)                  |
  |                                          |
  |-- 2. Invii la chiave PUBBLICA ---------->|
  |        (via email/PEC)                   |
  |                                          |
  |-- 3. Ricevi la chiave PUBBLICA          |
  |        del mittente <--------------------|
  |                                          |
  |-- 4. VERIFICHI e dichiari              |
  |        fidata la chiave mittente         |
  |        (Setup_Trust.cmd) ← OBBLIGATORIO |
  |                                          |
  |        [Il mittente cifra il file        |
  |         con la tua chiave pubblica       |
  |         e lo firma con la sua privata]   |
  |                                          |
  |<-- 5. Ricevi il file cifrato ------------|
  |        (estensione .gpg)                 |
  |                                          |
  |-- 6. Decifri e verifichi la firma       |
  |        (decifra.cmd + verifica.cmd)      |
```

---

## 2. COSA CONTIENE IL KIT

### 2.1 Struttura delle cartelle

```
KIT_GPG/
├── run/                        ← Script da eseguire
│   ├── Setup_keys.cmd          ← Genera e gestisce le tue chiavi
│   ├── Setup_Trust.cmd         ← Verifica e dichiara fidata la chiave del mittente
│   ├── decifra.cmd             ← Decifra i file ricevuti
│   ├── verifica.cmd            ← Verifica la firma digitale
│   └── diagnostica.cmd         ← Diagnostica e troubleshooting
│
├── trust/                      ← Chiave pubblica del mittente (fornita dal mittente)
│   ├── publickey.asc           ← Chiave pubblica del mittente
│   └── fingerprint.txt         ← Impronta digitale della chiave (per verifica)
│
├── home/                       ← Keyring GPG — NON toccare, NON condividere
├── in/                         ← Cartella consigliata per file cifrati in arrivo
├── out/                        ← Cartella consigliata per file decifrati
├── docs/                       ← Questa guida e la guida rapida
├── reports/                    ← Report generati dagli script
└── public_key_*.asc            ← La tua chiave pubblica (da inviare al mittente)
```

### 2.2 Script disponibili

| Script | Funzione | Quando usarlo |
|--------|----------|---------------|
| **Setup_keys.cmd** | Genera e gestisce le tue chiavi personali | Prima configurazione, nuove chiavi, export |
| **Setup_Trust.cmd** | Verifica e dichiara fidata la chiave del mittente | **Obbligatorio** prima di decifrare per la prima volta |
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

- **Nome e Cognome** — inserisci il tuo nome completo (es. `Mario Rossi`)
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

Al termine della generazione, lo script:

1. Salva la chiave privata nel keyring (cartella `home`) — **non condividerla mai**
2. Esporta la chiave pubblica nella root del kit come `public_key_Mario_Rossi.asc`

Prosegui con i passaggi 4 e 5 prima di comunicare al mittente che sei pronto.

---

## 4. CONFIGURAZIONE OBBLIGATORIA: VERIFICARE LA CHIAVE DEL MITTENTE

> ⚠️ **QUESTO PASSAGGIO È OBBLIGATORIO**  
> Senza di esso, GPG non si fida della chiave del mittente e la verifica della firma fallirà sempre, anche se il file è autentico.

### 4.1 Cos'è e perché è necessario

Quando ricevi la chiave pubblica del mittente, devi:
1. **Verificare** che sia autentica (che provenga davvero dal mittente, non da terzi)
2. **Dichiarare** a GPG che ti fidi di quella chiave

Senza questo passaggio, GPG non può stabilire se la firma sul file che ricevi è genuina.

### 4.2 Cosa ti serve

Prima di eseguire `Setup_Trust.cmd`, il mittente deve averti fornito:

| File/Dato | Dove si trova | Scopo |
|-----------|---------------|-------|
| `publickey.asc` | Cartella `trust/` del kit | La chiave pubblica del mittente |
| `fingerprint.txt` | Cartella `trust/` del kit | L'impronta digitale univoca della chiave |
| Fingerprint via email/PEC | Nella comunicazione del mittente | Verifica su canale indipendente (opzionale ma consigliata) |

> Il mittente fornisce questi file insieme al kit, oppure separatamente via email/PEC.

### 4.3 Esegui Setup_Trust.cmd

1. Apri la cartella `run` sulla chiavetta
2. Fai doppio clic su **`Setup_Trust.cmd`**
3. Lo script esegue automaticamente:
   - Importa la chiave pubblica del mittente nel keyring
   - Legge il fingerprint atteso dal file `trust/fingerprint.txt`
   - Confronta il fingerprint della chiave importata con quello atteso
   - Se corrispondono: mostra il risultato e chiede la verifica via email

### 4.4 Verifica via email (secondo canale — consigliata)

Dopo la verifica automatica, lo script offre una verifica aggiuntiva:

```
Fingerprint: A893C524F394623C8B9CF6F14AE4DCB5D131BBB3

Inserisci fingerprint da email (o premi INVIO per saltare):
```

- Se hai ricevuto il fingerprint via email/PEC dal mittente, inseriscilo qui e confrontalo
- Se corrisponde → **trust ULTIMATE (livello 5)**: massima sicurezza, doppia verifica
- Se premi INVIO senza inserire nulla → **trust FULL (livello 4)**: verifica singola da file kit

> ℹ️ **Differenza tra i due livelli**  
> - **FULL**: hai verificato che la chiave nel kit corrisponde al fingerprint nel kit. Sufficiente per uso normale.  
> - **ULTIMATE**: hai verificato la chiave su due canali indipendenti (file kit + email). Raccomandato per documenti ad alta sensibilità.

### 4.5 Cosa fare se i fingerprint NON corrispondono

Se lo script segnala una discrepanza:

> ❌ **ERRORE CRITICO: Il fingerprint NON corrisponde! Possibile manomissione della chiave.**

**Non procedere.** Contatta immediatamente il mittente tramite un canale diverso (telefono, PEC separata) per segnalare l'anomalia. Non usare il file ricevuto finché non hai chiarezza.

### 4.6 Quando ripetere questo passaggio

- Ogni volta che il mittente ti invia una **nuova chiave pubblica** (es. dopo rinnovo annuale)
- Se `diagnostica.cmd` segnala che la chiave non è nel keyring
- Se ricevi sempre errori di firma anche su file corretti

---

## 5. INVIO DELLA CHIAVE PUBBLICA AL MITTENTE

Dopo aver generato le tue chiavi (passo 3), devi inviare la tua chiave **pubblica** al mittente. Solo così potrà cifrare i file destinati a te.

### 5.1 Dove trovare il file

Nella cartella principale del kit trovi il file:
```
public_key_Mario_Rossi.asc
```
dove `Mario_Rossi` è il nome inserito durante la generazione.

### 5.2 Come inviarlo

- **Email / PEC**: come allegato al referente del mittente
- **Portale web**: upload su piattaforma dedicata, se disponibile
- **Altro canale**: secondo le indicazioni ricevute

> ✅ **La chiave pubblica può essere condivisa liberamente.** Non contiene informazioni riservate. Solo la chiave **privata** (che rimane sulla chiavetta) deve restare segreta.

### 5.3 Cosa comunicare insieme alla chiave

Quando invii la chiave pubblica, è buona pratica comunicare anche il fingerprint, così il mittente può verificare di aver ricevuto la chiave giusta. Il fingerprint è visibile eseguendo `diagnostica.cmd`.

---

## 6. RICEZIONE E DECIFRATURA DEI FILE

### 6.1 Ricevere il file cifrato

1. Riceverai il file `.gpg` via email, PEC o portale
2. Salvalo direttamente sulla chiavetta USB (consigliato nella cartella `in/`)
3. Evita di salvarlo sul disco fisso del computer

### 6.2 Decifrare con Drag & Drop (metodo consigliato)

1. Apri la cartella `run` sulla chiavetta
2. Trascina il file `.gpg` sopra **`decifra.cmd`**
3. Si aprirà una finestra che chiede la passphrase
4. Inserisci la passphrase della tua chiave privata
5. Il file decifrato apparirà nella stessa cartella del file `.gpg`

### 6.3 Decifrare con doppio clic

1. Fai doppio clic su `decifra.cmd`
2. Quando richiesto, trascina il file `.gpg` nella finestra
3. Premi Invio e inserisci la passphrase

### 6.4 Dove trovare il file decifrato

Il file decifrato viene salvato nella stessa cartella del file `.gpg`, con lo stesso nome ma senza estensione `.gpg`:

```
documento_riservato.pdf.gpg   →   documento_riservato.pdf
```

### 6.5 Interpretare l'esito

| Esito visualizzato | Significato |
|--------------------|-------------|
| `[OK] File decifrato con successo` | Tutto OK, firma valida |
| `[OK] File decifrato con AVVISI` | Decifrato, ma trust non completamente validato — esegui Setup_Trust.cmd |
| `Decifratura fallita - Bad passphrase` | Passphrase errata, riprova |
| `Decifratura fallita - No secret key` | Il mittente ha usato una chiave pubblica diversa dalla tua attuale |

---

## 7. VERIFICA FIRMA DIGITALE

La firma digitale garantisce che il file provenga davvero dal mittente dichiarato e non sia stato alterato durante il trasporto.

### 7.1 Come verificare

1. Apri la cartella `run`
2. Trascina il file `.gpg` sopra **`verifica.cmd`**
3. Lo script verifica automaticamente la firma
4. Un report dettagliato viene salvato nella cartella `reports/`

> ℹ️ Per ottenere una verifica completa (GOOD SIGNATURE), è necessario aver eseguito **Setup_Trust.cmd** in precedenza (sezione 4).

### 7.2 Interpretare i risultati

| Esito | Significato | Azione |
|-------|-------------|--------|
| ✅ **GOOD SIGNATURE (TRUST OK)** | Firma valida, chiave fidata | Procedi con la decifratura |
| 🟡 **SIGNATURE OK ma TRUST non verificato** | Firma tecnicamente valida, ma chiave non dichiarata fidata | Esegui Setup_Trust.cmd, poi riverifica |
| ❌ **BAD SIGNATURE** | Il file è stato alterato o la firma non è autentica | Non aprire il file, contatta il mittente |
| ⚠️ **Chiave pubblica assente** | Non hai importato la chiave del mittente | Esegui Setup_Trust.cmd |

---

## 8. GESTIONE CHIAVI MULTIPLE

### 8.1 Perché avere più chiavi

- Separare contesti diversi (lavoro, progetti, enti)
- Rigenerare periodicamente le chiavi mantenendo quelle vecchie per file storici
- Avere una chiave per ogni mittente/organizzazione

### 8.2 Gestire le chiavi con Setup_keys.cmd

Quando esegui `Setup_keys.cmd` con chiavi già presenti, vedrai un menu:

```
================== SELEZIONE CHIAVE ==================
Trovate 2 chiavi.

  [1] Mario Rossi
  [2] Mario Rossi - Lavoro

Seleziona numero [1-2] o [G] per generare:
```

Dopo aver selezionato una chiave:

```
================== MENU ==================
Chiave selezionata: Mario Rossi
Fingerprint: A893C524...

 [U] Usa questa chiave (export pubblica)
 [D] Cancella questa chiave
 [S] Cambia chiave
 [Q] Esci
```

### 8.3 Eliminare una chiave

> ⚠️ **Operazione irreversibile.** Dopo l'eliminazione non sarà più possibile decifrare i file ricevuti con quella chiave, né recuperarla.

Seleziona la chiave, poi `[D]` e conferma con `S`.

---

## 9. GESTIONE SICURA DELLA CHIAVETTA

### 9.1 Regole fondamentali

✅ **FARE:**
- Conservare la chiavetta in luogo sicuro (cassaforte, cassetto chiuso a chiave)
- Creare un backup su una seconda chiavetta USB
- Aggiornare il backup dopo ogni modifica alle chiavi
- Annotare offline le passphrase

❌ **NON FARE:**
- Mai copiare la cartella `home/` sul disco fisso del computer
- Mai condividere la chiave privata o la passphrase
- Mai lasciare la chiavetta incustodita

### 9.2 Creare un backup

1. Usa una seconda chiavetta USB
2. Copia l'intera cartella `KIT_GPG` sulla seconda chiavetta
3. Verifica che tutti i file siano stati copiati
4. Conserva il backup in un luogo fisicamente separato dall'originale

> ⚠️ **Senza backup, la perdita o il danneggiamento della chiavetta comporta la perdita definitiva di tutte le chiavi e l'impossibilità di decifrare i file già ricevuti.**

---

## 10. RISOLUZIONE PROBLEMI

### 10.1 Usa diagnostica.cmd come primo passo

In caso di problemi, esegui prima `diagnostica.cmd`: verifica la struttura del kit, le chiavi presenti, la configurazione GPG e genera un report completo.

### 10.2 Problemi comuni

| Problema | Causa probabile | Soluzione |
|----------|----------------|-----------|
| `decryption failed: No secret key` | Il mittente ha usato una chiave pubblica diversa | Reinvia la chiave pubblica corretta al mittente |
| `decryption failed: Bad passphrase` | Passphrase errata | Riprova; controlla CAPS LOCK |
| Verifica firma: TRUST non verificato | Setup_Trust.cmd non eseguito | Esegui Setup_Trust.cmd (sezione 4) |
| Verifica firma: chiave assente | Chiave mittente non importata | Esegui Setup_Trust.cmd (sezione 4) |
| Errore all'avvio dello script | Percorso con caratteri speciali | Sposta il kit in un percorso senza accenti o spazi |

### 10.3 Passphrase dimenticata

> ⚠️ **Non esiste recupero.** Se hai dimenticato la passphrase di una chiave, quella chiave è inutilizzabile.

Soluzione: genera una nuova chiave con `Setup_keys.cmd`, inviala al mittente e chiedigli di ri-cifrare i file importanti con la nuova chiave.

### 10.4 Reset completo

Se devi ripartire da zero:

1. Decifra tutti i file importanti ancora accessibili
2. Elimina la cartella `home/` dalla chiavetta
3. Elimina tutti i file `public_key_*.asc` dalla root del kit
4. Esegui nuovamente `Setup_keys.cmd`
5. Invia le nuove chiavi pubbliche ai mittenti

---

## 11. FAQ - DOMANDE FREQUENTI

**Q: Posso usare il kit su più computer?**  
A: Sì. Il kit è completamente portabile: nessuna installazione richiesta su qualsiasi PC Windows.

**Q: Devo ripetere Setup_Trust.cmd ogni volta?**  
A: No. Basta eseguirlo una volta per ogni chiave del mittente. Ripetilo solo se il mittente rinnova la sua chiave pubblica.

**Q: Cosa succede se la chiavetta si danneggia?**  
A: Se hai un backup, usi quello. Se non hai backup, dovrai rifare il setup completo con nuove chiavi e richiedere al mittente di ri-cifrare i documenti.

**Q: Il mittente può leggere i file dopo averli cifrati?**  
A: Solo se il file è stato cifrato anche per la propria chiave. I file cifrati esclusivamente con la tua chiave pubblica possono essere decifrati solo da te.

**Q: Serve Internet?**  
A: No. Il kit funziona completamente offline.

**Q: Posso condividere la chiave privata in casi eccezionali?**  
A: Mai. Non esiste un caso eccezionale che giustifichi la condivisione della chiave privata.

**Q: Come faccio a sapere quale chiave usare per decifrare?**  
A: GPG la riconosce automaticamente e chiede la passphrase della chiave corretta.

**Q: Quanto spesso fare il backup?**  
A: Dopo ogni generazione o eliminazione di chiavi, e ogni volta che ricevi file importanti decifrati.

---

## APPENDICE: GLOSSARIO TERMINI TECNICI

**Chiave pubblica** — Può essere condivisa liberamente. Serve al mittente per cifrare file destinati a te.

**Chiave privata** — Deve restare assolutamente segreta. Serve a te per decifrare i file ricevuti.

**Fingerprint** — Impronta digitale univoca di una chiave GPG: una stringa esadecimale di 40 caratteri che identifica una specifica chiave. Serve per verificare che due copie della stessa chiave siano identiche.

**Passphrase** — Password che protegge la chiave privata. Senza di essa la chiave non può essere usata.

**Trust / Fiducia** — Dichiarazione esplicita che una chiave pubblica appartiene davvero alla persona indicata. GPG non si fida automaticamente di nessuna chiave finché non viene dichiarata fidata.

**Firma digitale** — Meccanismo crittografico che garantisce autenticità (chi ha creato il file) e integrità (il file non è stato modificato).

**File .gpg** — File cifrato con GPG. Può contenere sia il dato cifrato che la firma digitale.

**File .asc** — Formato testuale (ASCII armor) usato per esportare chiavi GPG.

**AEAD** — Advanced Encryption with Associated Data: modalità di cifratura moderna usata da GPG 2.3+, più sicura della modalità classica.

**GPG (GNU Privacy Guard)** — Software open source che implementa lo standard OpenPGP per cifratura e firma digitale.

---

*KIT GPG Versione 1.5*  
*Per supporto tecnico, contattare il proprio referente interno*
