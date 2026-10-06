# pika-tools

[English](../../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · **Italiano** · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [Română](README.ro.md) · [Polski](README.pl.md) · [Türkçe](README.tr.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Čeština](README.cs.md) · [繁體中文](README.zh-Hant.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Tiếng Việt](README.vi.md) · [ไทย](README.th.md)

[![Ultima versione](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![Licenza: MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](../../LICENSE)
[![Download](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

Una piccola app per la barra dei menu di macOS che migliora tasti, finestre e Dock: blocca le abbreviazioni con Control, protegge ⌘Q e ⌘W, cambia lingua con Opzione+Maiuscole come Alt+Maiusc su Windows, ripete un tasto tenuto premuto come su Windows, disattiva l’accelerazione del mouse, scorre la rotella del mouse per righe come su Windows, fa andare indietro e avanti con i tasti laterali del mouse, chiude le app quando ne chiudi l’ultima finestra, nasconde un’app con un clic nel Dock e tiene sveglio il Mac.

## Installazione

Con [Homebrew](https://brew.sh):

```bash
brew install --cask dev-pikapik/pika-tools/pika-tools && open -a pika-tools
```

Senza Homebrew, apri Terminale, incolla questa riga e premi A capo:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

Oppure scarica [pika-tools.dmg](https://github.com/dev-pikapik/pika-tools/releases/latest/download/pika-tools.dmg), aprilo e trascina l’app nella cartella Applicazioni.

Sia Homebrew sia lo script mettono l’app in `/Applications`, la avviano, chiedono i permessi e attivano l’apertura al login. Da quel momento l’app si aggiorna da sola, vedi [Aggiornamenti](#aggiornamenti). Per rimuoverla, vedi [Disinstallazione](#disinstallazione).

## Primo avvio

pika-tools ha bisogno di due permessi. Al primo avvio apre le impostazioni sulla pagina Permessi, che ti guida passo passo, e macOS mostra le sue richieste. Vai in **Impostazioni di Sistema › Privacy e sicurezza** e attiva pika-tools in:

- **Accessibilità**, così l’app può modificare la pressione di un tasto o un clic prima che arrivi alle altre app.
- **Monitoraggio input**, così l’app può vedere pressioni dei tasti e clic.

L’app si accorge della modifica in un paio di secondi, senza bisogno di riavviare.

pika-tools non registra, non conserva e non invia nulla di ciò che digiti o clicchi. Gli eventi vengono gestiti in memoria e inoltrati subito. L’unica richiesta di rete è il controllo degli aggiornamenti, che chiede a GitHub qual è l’ultima versione.

## Funzioni

**Blocca le abbreviazioni con Control.** Control diventa un tasto normale. Le app continuano a vederlo premuto, ma macOS non lo trasforma più in abbreviazioni: Control+Spazio non cambia la sorgente di input, Control+frecce non cambiano scrivania e Control-clic è un clic normale invece di aprire un menu contestuale. Il clic secondario e il tocco con due dita funzionano come sempre. Comodo nei giochi e nelle sessioni di desktop remoto, dove Control ha un compito tutto suo.

**Proteggi ⌘Q e ⌘W.** ⌘Q e ⌘W da soli non fanno nulla, così non chiudi un’app o una finestra per sbaglio. Aggiungi Maiuscole per farlo apposta: ⇧⌘Q esce, ⇧⌘W chiude. Funziona in tutte le app. Ogni tasto ha il suo interruttore. Disattivato di default.

**Cambia lingua con Opzione+Maiuscole.** Tieni premuto Opzione e tocca Maiuscole: macOS passa alla sorgente di input successiva. Continua a tenere premuto Opzione e tocca di nuovo Maiuscole per andare avanti. Tieni premuto Maiuscole e tocca Opzione per tornare indietro. Se nel frattempo premi un altro tasto, fai clic o aggiungi Comando, Control o Fn, non cambia nulla, quindi abbreviazioni come Opzione+Maiuscole+freccia funzionano come prima. Disattivato di default.

**Ripeti un tasto tenuto premuto.** Tieni premuto un tasto e la lettera viene scritta più e più volte, come su Windows, invece di aprire il menu degli accenti. Comodo nei giochi e quando scrivi. Le app già aperte lo applicano dopo il riavvio. Se lo disattivi, macOS torna a comportarsi come sempre. Disattivato di default.

**Disattiva l’accelerazione del puntatore.** Il puntatore si sposta esattamente quanto il mouse, a qualsiasi velocità lo muovi, come con LinearMouse. Un cursore **Velocità puntatore** ne regola la velocità. Funziona solo con i mouse, il trackpad resta com’è. Disattivala o esci da pika-tools e macOS riprende le sue impostazioni. Disattivato di default.

**Scorri per righe.** Ogni scatto della rotella del mouse scorre lo stesso numero di righe, per quanto veloce la giri, come su Windows. Scegli da 1 a 10 righe per scatto, 3 di default. Lo scorrimento naturale resta come l’hai impostato in Impostazioni di Sistema. Funziona solo con i mouse, il trackpad resta com’è. Disattivato di default.

**Tasti laterali per indietro e avanti.** I tasti 4 e 5 del mouse vanno indietro e avanti in Safari, nel Finder e in altre app Apple, in Firefox, Opera e ForkLift, proprio come uno swipe sul trackpad. Le altre app, come gli IDE JetBrains, ricevono i tasti così come sono e li gestiscono a modo loro. Se il tuo mouse li ha invertiti, attiva **Inverti i tasti laterali**. Disattivato di default.

**Esci quando si chiude l’ultima finestra.** Chiudi l’ultima finestra di un’app e l’app si chiude, come su Windows. Il Finder resta aperto, così come le app con finestre su altre scrivanie o nel Dock. Puoi indicare le app che non devono mai chiudersi in questo modo. Disattivato di default.

**Nascondi con un clic nel Dock.** Fai clic sull’icona nel Dock dell’app che stai usando e si nasconde. Fai di nuovo clic per riaverla. Disattivato di default.

**Nuovo file nel Finder.** Clic destro in una finestra del Finder o sulla scrivania, scegli **Nuovo file**, scrivi un nome e compare un file vuoto, come Nuovo › Documento di testo su Windows. .txt di default. Disattivato di default.

Ogni strumento ha il suo interruttore nel menu e nelle impostazioni. Ti serve di nuovo il normale Control+C? Disattiva quello strumento.

L’icona nella barra dei menu mostra lo stato a colpo d’occhio: una freccia con un clic quando gli strumenti funzionano, una freccia barrata quando è tutto spento e un triangolo di avviso quando uno strumento è attivo ma mancano i permessi.

L’app usa la lingua del sistema o quella che scegli nelle impostazioni. Sono disponibili tutte le 23 lingue elencate in cima a questa pagina.

## Resta sveglio

Impedisce al Mac di andare in stop mentre sei lontano dalla tastiera: per qualsiasi durata da 1 minuto a 12 mesi, o finché non lo disattivi. Attivalo dal menu e imposta la durata nelle impostazioni in minuti, ore, giorni, settimane o mesi. Il menu mostra quanto tempo resta e quando finisce. **Tieni acceso lo schermo** impedisce anche che lo schermo si oscuri. Uscendo da pika-tools, Resta sveglio termina.

Su un MacBook puoi anche attivare **Funziona con il coperchio chiuso**. macOS non ha un’opzione per farlo, quindi pika-tools esegue `pmset -a disablesleep 1` e chiede una password da amministratore: solo un amministratore può cambiare il modo in cui il Mac va in stop. L’impostazione torna normale da sola quando Resta sveglio finisce, quando esci dall’app o se l’app si chiude in modo imprevisto. Se non inserisci la password, non cambia nulla. Tieni il Mac ben ventilato con il coperchio chiuso. **Interrompi con batteria sotto il 20%** termina la sessione prima che la batteria si esaurisca.

Keep Awake, la modalità schermo e quella a schermo chiuso si possono mettere su un pulsante nel Centro di Controllo, nella barra dei menu o in un widget sulla scrivania tramite l’app Comandi rapidi, con i link che copi da Impostazioni › Resta sveglio.

## Impostazioni

Apri le impostazioni dal menu con **Impostazioni…** o ⌘, oppure avvia di nuovo pika-tools dal Finder, da Launchpad o da Spotlight. Finché la finestra è aperta, l’app compare nel Dock e in ⌘Tab.

- **Generali**: apertura al login, aspetto (Sistema, Chiaro o Scuro), lingua, aggiornamenti e backup: esporta e importa le impostazioni come file, oppure sincronizzale con iCloud Drive.
- **Tastiera**: abbreviazioni con Control, ⌘Q e ⌘W, cambio lingua.
- **Mouse**: accelerazione del puntatore e velocità puntatore, scorrimento per righe, tasti laterali.
- **Finestre e app**: uscita con l’ultima finestra, con un elenco di eccezioni, e nascondi con un clic nel Dock.
- **Resta sveglio**: durata, opzioni per schermo e coperchio.
- **Permessi**: lo stato di entrambi i permessi, e di iCloud Drive quando la sincronizzazione è attiva, con pulsanti che aprono il punto giusto in Impostazioni di Sistema.
- **Info**: versione, link alle novità e per segnalare un problema.

Ogni pagina ha in basso un pulsante **Ripristina default…**. Prima chiede conferma, poi disattiva gli strumenti di quella pagina e ne ripristina le opzioni, come se pika-tools non le avesse mai toccate.

**Sincronizza le impostazioni con iCloud** mantiene pika-tools uguale su tutti i tuoi Mac. Le impostazioni stanno nella cartella pika-tools di iCloud Drive e vince la modifica più recente. È disattivato di default e richiede iCloud Drive attivo. I permessi non vengono sincronizzati: ogni Mac li chiede per conto suo.

## Aggiornamenti

pika-tools cerca nuove versioni all’avvio e ogni 6 ore. Puoi disattivarlo in Impostazioni › Generali. Quando ne esce una, nel menu compare il pulsante **Aggiorna a …**: un clic e l’app scarica l’aggiornamento, lo installa e si riavvia. Puoi anche controllare a mano con **Controlla ora** in Impostazioni › Generali.

Con Homebrew puoi anche eseguire `brew upgrade --cask pika-tools`.

Dalla versione 1.3 i permessi restano attivi dopo gli aggiornamenti.

## Disinstallazione

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

Se hai installato con Homebrew: `brew uninstall --cask --zap pika-tools`.

Entrambi chiudono l’app, la tolgono dagli elementi login e la eliminano. Lo script ne reimposta anche i permessi.

## Domande frequenti

**Perché servono due permessi?**
macOS divide l’accesso a tastiera e mouse in due. Monitoraggio input permette all’app di vedere gli eventi, Accessibilità le permette di modificarli. Per bloccare un’abbreviazione servono entrambi.

**macOS dice che l’app proviene da uno sviluppatore non identificato.**
pika-tools è firmata, ma non autenticata da Apple. Homebrew e lo script di installazione se ne occupano per te. Se hai usato il dmg, apri **Impostazioni di Sistema › Privacy e sicurezza** e fai clic su **Apri comunque**, oppure esegui:

```bash
xattr -dr com.apple.quarantine /Applications/pika-tools.app
```

**Funziona sui Mac con Intel?**
Sì. È un’app universale per Apple Silicon e Intel, con macOS 14 Sonoma o successivo.

**Il permesso è attivo, ma non funziona nulla.**
In **Impostazioni di Sistema › Privacy e sicurezza**, rimuovi pika-tools da entrambi gli elenchi con il pulsante −, poi aggiungila di nuovo. La pagina Permessi nelle impostazioni di pika-tools ha pulsanti che aprono il punto giusto.

## Contribuire

Come compilare dal codice sorgente e pubblicare una versione è spiegato in [CONTRIBUTING.md](../../CONTRIBUTING.md). Le modifiche sono elencate in [CHANGELOG.md](../../CHANGELOG.md).

## Licenza

MIT, © 2026 pikapik. Vedi [LICENSE](../../LICENSE).
