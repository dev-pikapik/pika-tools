<p align="center"><a href="../readme/README.it.md"><img src="../media/icon.png" width="96" height="96" alt="pikapik"></a></p>
<h1 align="center">Novità di pikapik</h1>
<p align="center">Ogni aggiornamento in poche parole e un’immagine, dal più recente.</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <b>Italiano</b> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.38.1"></a>Un menu del Finder più affidabile

<sub>1.38.1 · 12 ottobre 2026</sub>

Le voci che pikapik aggiunge al Finder con un clic destro non spariscono più quando si collega un disco, si apre un’immagine disco, si riattiva il Mac o si passa al Finder. In rari casi, l’assistente che le mostra si chiudeva proprio in quel momento.

---

## <a id="v1.38.0"></a>Apri e crea archivi nel Finder

<sub>1.38.0 · 12 ottobre 2026</sub>

I nuovi «Archivi nel Finder» aprono RAR e altri archivi che macOS non sa aprire, e creano ZIP e 7Z con un clic destro.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/archive-dark.png"><img src="../media/archive-light.png" width="340" alt=""></picture>

Apri Impostazioni › Finder e attiva «Archivi nel Finder». Fai clic destro su un archivio e scegli «Estrai», e i suoi file compaiono accanto. Fai clic destro su un altro file o cartella e scegli «Crea archivio…» per ottenere uno ZIP, un 7Z, un TAR.GZ o un TAR.XZ. Uno ZIP o un 7Z può avere una password, e qualsiasi archivio si può dividere in parti, per esempio da 15 MB per l’e-mail. Uno ZIP creato così non contiene file di servizio nascosti e mantiene leggibili i nomi in qualsiasi lingua.

pikapik apre anche ciò che macOS non sa aprire: RAR, anche diviso in più file, 7Z protetto da password, ZIPX, CAB, LZH, ARJ, ZST, WIM e altro ancora. Con un doppio clic si aprono in pikapik. I nomi dei file nei vecchi ZIP, per esempio in cirillico, giapponese o cinese, ora si leggono correttamente. L’interruttore «Apri gli archivi con questa app» affida a pikapik anche ZIP e 7Z, mentre TAR e GZ restano all’app per archivi integrata, che li gestisce già bene.

Una finestra chiede la password, «Interrompi» ferma qualsiasi operazione, e da un archivio danneggiato pikapik recupera ciò che si può ancora leggere. Prima di estrarre un archivio che si gonfierebbe fino a una dimensione enorme, pikapik chiede conferma, e gli archivi che cercano di scrivere fuori dalla propria cartella vengono bloccati. Non è nella versione del Mac App Store. Seleziona un archivio e premi Spazio per vedere cosa contiene.

---

## <a id="v1.37.3"></a>L’etichetta FPS chiede il permesso al posto giusto

<sub>1.37.3 · 12 ottobre 2026</sub>

La registrazione dello schermo per l’etichetta FPS ora si consente nella pagina Permessi, insieme a tutti gli altri permessi.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Per contare i fotogrammi di un gioco, «Mostra FPS» può aver bisogno della registrazione dello schermo. Prima pikapik la chiedeva proprio nella pagina Giochi. Ora sta insieme a tutti gli altri permessi: quando «Mostra FPS» ne ha bisogno, compare una riga «Registrazione schermo» in Impostazioni › Permessi, e lì fai clic su «Consenti».

Nella pagina Giochi ora vedi solo la solita riga sotto l’interruttore: «Serve un permesso. Fai clic per consentirlo.» Il suo pulsante «Consenti» ti porta dritto alla riga «Registrazione schermo». Attivare «Mostra FPS» non fa più comparire da solo una domanda, e pikapik continua a non chiedere nulla mentre giochi.

---

## <a id="v1.37.2"></a>Verificato da Apple

<sub>1.37.2 · 12 ottobre 2026</sub>

pikapik ora è firmato da uno sviluppatore Apple verificato e controllato da Apple. Per questo macOS non ti avvisa più alla prima apertura.

Dopo questo aggiornamento macOS potrebbe chiederti di nuovo i permessi dati a pikapik, come Accessibilità, Monitoraggio input o Accesso completo al disco. Consentili ancora una volta in Impostazioni di Sistema › Privacy e sicurezza. Se usi il controllo delle ventole, consentilo di nuovo nelle impostazioni di pikapik, e macOS ti chiederà la password una volta.

---

## <a id="v1.37.1"></a>L’etichetta FPS segue il tuo gioco senza ritardi

<sub>1.37.1 · 12 ottobre 2026</sub>

Sposta la finestra del gioco e ora l’etichetta FPS la segue all’istante.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Prima l’etichetta raggiungeva una finestra in movimento solo circa una volta al secondo, e così restava indietro. Ora controlla la finestra a ogni fotogramma dello schermo e non è mai in ritardo di più di qualche millesimo di secondo. Quando la finestra è ferma, la controlla meno spesso, così pesa pochissimo sul tuo Mac mentre giochi. Inoltre non salta più altrove quando parte della finestra esce dal bordo dello schermo.

Se un gioco tranquillo come gli scacchi mostra 0, va tutto bene: questi giochi disegnano una nuova immagine solo quando qualcosa si muove. Il numero sale mentre un pezzo scivola e torna a 0 quando la scacchiera è ferma.

---

## <a id="v1.37.0"></a>Guarda quanto scorre bene il tuo gioco

<sub>1.37.0 · 12 ottobre 2026</sub>

La nuova opzione «Mostra FPS» mette un piccolo contatore in un angolo del gioco, così vedi subito quanto scorre bene.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Apri Impostazioni › Giochi e attiva «Mostra FPS». Finché la Modalità gioco è attiva, in un angolo di qualsiasi gioco compare una piccola etichetta scura con un numero. FPS significa fotogrammi al secondo: quante immagini disegna il gioco ogni secondo, e più il numero è alto, più il gioco è fluido. Fai clic su un angolo dell’immagine sopra l’interruttore per scegliere dove metterla.

I clic passano attraverso l’etichetta, che segue la finestra del gioco. Un trattino significa che i primi fotogrammi non sono ancora arrivati, e uno 0 sbiadito che il gioco ha smesso di disegnare. «Mostra FPS» resta disattivato finché non lo attivi.

Con macOS 27 la maggior parte dei giochi viene contata da macOS stesso, quindi non serve alcun permesso. Alcuni giochi, per lo più vecchi, si possono contare solo tramite la registrazione dello schermo, e allora il numero non può superare la frequenza di aggiornamento dello schermo. Con macOS da 14 a 26 e nella versione del Mac App Store ogni gioco viene contato così, perciò attivando «Mostra FPS» pikapik chiede «Registrazione schermo». Nessuna immagine viene salvata o inviata.

---

## <a id="v1.36.0"></a>Rimuovi le app senza pensieri

<sub>1.36.0 · 12 ottobre 2026</sub>

La nuova funzione Rimuovi app toglie un’app con tutti i suoi file e rimette tutto a posto se cambi idea.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/uninstaller-dark.png"><img src="../media/uninstaller-light.png" width="340" alt=""></picture>

Apri Impostazioni › Rimuovi app e scegli un’app, oppure trascinala sull’immagine. pikapik mostra tutto ciò che l’app conserva sul tuo Mac, con il motivo di ogni file. I file che appartengono chiaramente all’app sono spuntati, quelli che forse c’entrano soltanto no. Fai clic su «Sposta nel Cestino» e tutto va nel Cestino, quindi niente viene eliminato per sempre.

Hai cambiato idea? Fai clic su «Rimetti a posto» e tutto torna dov’era. Le ultime dieci rimozioni restano in «Rimossi di recente» finché i loro file sono nel Cestino. «Reimposta app» tiene l’app e toglie solo i suoi dati salvati, le impostazioni e i file temporanei, nel caso faccia i capricci.

Hai spostato tu un’app nel Cestino? La pagina elenca queste app e i file che hanno lasciato, e puoi attivare un interruttore che propone di fare pulizia ogni volta che un’app va nel Cestino. Non viene rimosso nulla finché non scegli. Per vedere tutto, la pagina ha bisogno dell’Accesso completo al disco.

---

## <a id="v1.35.0"></a>Vesti il tuo animaletto

<sub>1.35.0 · 12 ottobre 2026</sub>

Il tuo animaletto ha un guardaroba, e giocando insieme ottieni nuovi capi da fargli indossare.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.35.0/wardrobe-dark.png"><img src="../media/whats-new/1.35.0/wardrobe-light.png" width="340" alt=""></picture>

Apri Impostazioni › Animaletto e scegli cosa fargli indossare: cappelli, occhiali, sciarpe, magliette, scarpe, mantelli e perfino ali. Lo indossa subito. Alcuni capi sono gratis, gli altri sono premi che arrivano mentre giocate insieme: prendi in mano l’animaletto e lancialo, calcia la palla, guardalo arrampicarsi sulle finestre e chiacchierare, oppure fagli semplicemente compagnia giorno dopo giorno. Quando ne ottieni uno, te lo dice lui.

I look già pronti lo vestono da capo a piedi con un clic: mago, pirata, astronauta, supereroe, re e altri. Un look è pronto quando hai ottenuto tutti i suoi pezzi.

Vengono conservati solo numeri semplici, come passi, lanci e giorni insieme. Restano sul tuo Mac, non viene inviato nulla da nessuna parte e puoi cancellarli quando vuoi in Impostazioni › Animaletto.

---

## <a id="v1.34.0"></a>Mouse e trackpad nei giochi

<sub>1.34.0 · 12 ottobre 2026</sub>

Scorrimenti, pizzichi e angoli attivi non ti portano più fuori dal gioco, proprio come le scorciatoie da tastiera.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.34.0/pointer-shortcuts-dark.png"><img src="../media/whats-new/1.34.0/pointer-shortcuts-light.png" width="340" alt=""></picture>

In Impostazioni › Giochi › Altre impostazioni di gioco c’è un gruppo chiamato «Mouse e trackpad». Mostra solo ciò che è attivo in macOS sul tuo Mac, con i nomi di Apple e un piccolo disegno per ciascuno: scorciatoie su un pulsante del mouse, scorrimento tra scrivanie e app a schermo intero, Mission Control e App Exposé, pizzico per le app e allargamento delle dita per la scrivania, scorrimento dal bordo destro per il Centro notifiche e ogni angolo attivo con la sua azione. Finché un gioco è in primo piano, sono sospesi, così uno scorrimento involontario o uno sfioramento di un angolo dello schermo non ti porta fuori dal gioco. I gesti all’interno del gioco continuano a funzionare. Ognuno si può impostare per funzionare come al solito.

---

## <a id="v1.33.2"></a>I gruppi di comandi si aprono all’istante

<sub>1.33.2 · 11 ottobre 2026</sub>

Anche il gruppo più lungo di comandi di sistema si apre subito, e ogni riga ha un nome chiaro.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Prima la finestra delle impostazioni si bloccava per un attimo quando si apriva un gruppo di decine di righe, perché tutte le righe e le loro anteprime animate venivano create insieme. Ora vengono create solo le righe visibili e poche altre vicine. Sono sparite anche le righe «Azione di sistema» con un numero: Dettatura, Siri e i tasti di luminosità e zoom mostrano il loro vero nome, e le azioni a cui macOS non dà un nome sono nascoste, ma restano in pausa nei giochi come prima.

---

## <a id="v1.33.1"></a>I gruppi di comandi rapidi si aprono senza blocchi

<sub>1.33.1 · 11 ottobre 2026</sub>

La pagina Giochi resta fluida quando si apre un lungo elenco di anteprime.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Aprire un gruppo di comandi rapidi di sistema bloccava la finestra delle impostazioni fino a tre secondi, perché ogni riga con la sua anteprima veniva calcolata più volte. Ora ogni riga viene calcolata una sola volta, quindi i gruppi si aprono quasi subito.

---

## <a id="v1.33.0"></a>Tutti i permessi in un solo posto

<sub>1.33.0 · 11 ottobre 2026</sub>

Impostazioni › Permessi ora elenca tutto ciò che usa pikapik e ti lascia revocare qualsiasi permesso.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.33.0/permissions-dark.png"><img src="../media/whats-new/1.33.0/permissions-light.png" width="340" alt=""></picture>

Impostazioni › Permessi ora mostra ogni permesso che usa pikapik, da Accessibilità e Monitoraggio input a Controllo ventole, Estensioni del Finder, iCloud Drive e Accesso completo al disco. Ogni riga dice in una frase a cosa serve, con una spunta verde quando è attivo e una croce arancione quando manca.

Ogni riga ha un solo pulsante: Consenti quando manca, Spegni quando è attivo. Così puoi revocare qualsiasi permesso proprio lì, senza cercare in Impostazioni di Sistema. Per Accessibilità e Monitoraggio input, pikapik chiede prima conferma e poi si riavvia senza questi permessi.

Uno strumento che ha bisogno di un permesso che non hai dato appare in grigio. Fai clic su di esso e si apre Permessi con la riga giusta evidenziata, pronta per un clic su Consenti.

**Provalo:** Apri Impostazioni › Permessi e dai un’occhiata a ogni riga. Fai clic su uno strumento in grigio per andare dritto al permesso che gli serve.

---

## <a id="v1.32.2"></a>Installazione più sicura, e gli aggiornamenti non perdono mai l’app

<sub>1.32.2 · 11 ottobre 2026</sub>

Una serie di correzioni per installare, aggiornare e disinstallare in modo più sicuro.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

L’assistente delle ventole ora viene installato con più cura e verificato prima dell’avvio. Se un aggiornamento non si riesce a copiare, il tuo pikapik attuale resta al suo posto. La disinstallazione rimuove anche l’assistente delle ventole e ripristina l’impostazione di ripetizione dei tasti, gli angoli del Dock e le scorciatoie di sistema.

I tasti tenuti premuti non restano più bloccati quando uno strumento si riavvia, e disattivando «Ripeti un tasto tenuto premuto» riavrai la tua impostazione del menu degli accenti. L’animaletto riposa mentre lo schermo è in stop o bloccato, e una copia di archive.tar.gz ora si chiama archive 2.tar.gz.

---

## <a id="v1.32.1"></a>La velocità manuale delle ventole resta al primo tentativo

<sub>1.32.1 · 11 ottobre 2026</sub>

Scegliere Manuale in Ventole non torna più su Auto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

A volte il primo tocco su Manuale riportava le ventole su Auto con un avviso di sicurezza, e funzionava solo il secondo. Ora Manuale resta attivo già al primo tentativo.

Se una ventola esce comunque da sola dalla modalità Manuale, pikapik la riporta davvero su Auto, così ciò che vedi corrisponde sempre a ciò che fa il tuo Mac.

Non devi consentire di nuovo nulla. Aggiorna e funziona.

**Provalo:** Apri Impostazioni › Ventole e scegli Manuale.

---

## <a id="v1.32.0"></a>Guarda quanto veloce girano le tue ventole

<sub>1.32.0 · 11 ottobre 2026</sub>

Una nuova scheda Ventole mostra ogni ventola in diretta e ti lascia scegliere la velocità.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Le ventole ora hanno una scheda tutta loro nelle Impostazioni e una riga nel menu. Vedi in tempo reale quanto veloce gira ogni ventola, con una piccola ventola che gira insieme a lei.

Lascia su Auto e il Mac decide da solo, come sempre. Oppure scegli Manuale e trascina un solo cursore per impostare la velocità che vuoi. La prima volta lo consenti una volta sola con la password di amministratore, e basta.

È pensato per essere sicuro. Le ventole tornano su Auto quando esci da pikapik, quando il Mac va in stop, se pikapik si chiude per un errore o quando il Mac si scalda troppo.

**Provalo:** Apri Impostazioni › Ventole e guarda la velocità. Scegli Manuale per provare il cursore.

---

## <a id="v1.31.4"></a>I dettagli quando servono

<sub>1.31.4 · 11 ottobre 2026</sub>

Una pagina Giochi più tranquilla e una sola ricerca.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.4/game-choices-dark.png"><img src="../media/whats-new/1.31.4/game-choices-light.png" width="340" alt=""></picture>

Ogni modalità spiega il proprio effetto nell’elenco a discesa. Quando è chiuso, sulla pagina resta solo il nome scelto.

Le descrizioni che ripetono il nome dell’azione sono state rimosse. Le informazioni aggiuntive utili restano.

La ricerca globale trova le azioni di sistema per nome, funzione e tasti. Un risultato apre ed evidenzia l’impostazione esatta.

**Provalo:** Trova un’azione nella ricerca globale e apri il suo elenco di modalità.

---

## <a id="v1.31.3"></a>Uno stile comune per le impostazioni di gioco

<sub>1.31.3 · 11 ottobre 2026</sub>

Anteprime uniformi e scelte più chiare.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.3/game-preview-dark.png"><img src="../media/whats-new/1.31.3/game-preview-light.png" width="340" alt=""></picture>

Ogni scorciatoia ha ora la stessa anteprima ampia delle protezioni del gioco e delle altre pagine delle impostazioni. Sotto trovi descrizione, controlli e spiegazione dell’opzione selezionata.

«Segui le regole della modalità Gioco». Una scorciatoia breve cambia lingua senza menu. I tasti di gioco tenuti premuti evitano cambi accidentali.

«Disattiva nei giochi». Questa azione macOS è disattivata quando il gioco è in primo piano. Quando lo lasci, funziona come prima. «Consenti nei giochi». macOS esegue l’azione normalmente, anche se apre una finestra o sposta il focus dal gioco.

**Provalo:** Apri Altre impostazioni di gioco, espandi i controlli di sistema e scegli il comportamento di un’azione mentre giochi.

---

## <a id="v1.31.2"></a>Impostazioni di gioco più chiare

<sub>1.31.2 · 11 ottobre 2026</sub>

Regola la protezione ed esplora le scorciatoie del Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.2/game-settings-dark.png"><img src="../media/whats-new/1.31.2/game-settings-light.png" width="340" alt=""></picture>

Otto argomenti chiari sostituiscono le cartelle ripetute. Ogni titolo ha un nome, una spiegazione, un’icona e un conteggio. Fai clic in qualsiasi punto della riga per aprirlo.

Ogni azione spiega la propria funzione accanto all’anteprima animata. I tasti attuali e il comportamento nel gioco hanno una riga dedicata. La ricerca trova anche le descrizioni.

I tasti non assegnati hanno un collegamento chiaro a Impostazioni di Sistema. Le protezioni generali del gioco sono raccolte separatamente e le tue scelte restano salvate.

**Provalo:** Apri Altre impostazioni di gioco, espandi un argomento e confronta la descrizione di un’azione con la sua anteprima.

---

## <a id="v1.31.1"></a>Gesti della lingua nei giochi

<sub>1.31.1 · 11 ottobre 2026</sub>

Semplice per impostazione predefinita, con il catalogo completo quando serve.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/input-switch-dark.png"><img src="../media/input-switch-light.png" width="340" alt=""></picture>

Il gesto della lingua di pikapik funziona nel gioco anche se le scorciatoie della lingua di macOS non sono assegnate o sono disattivate.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automatico sospende le azioni che aprono finestre o spostano il focus. Un comando della lingua breve e intenzionale cambia la sorgente senza una finestra di sistema. I tasti di movimento tenuti premuti hanno priorità, così correre e saltare non cambiano lingua per sbaglio.

Ogni azione si regola nel catalogo con ricerca. La lingua può cambiare in background; le altre azioni possono essere sospese o consentite normalmente. Le scelte vengono sincronizzate. Le altre app che osservano i tasti compaiono a parte. Uscita forzata resta disponibile.

**Provalo:** Tieni premuto ⌥ e premi ⇧: lingua successiva. Tieni premuto ⇧ e premi ⌥: precedente

---

## <a id="v1.31.0"></a>La modalità Gioco conosce i comandi del Mac

<sub>1.31.0 · 11 ottobre 2026</sub>

Semplice per impostazione predefinita, con il catalogo completo quando serve.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Attiva la modalità Gioco e gioca. Altre impostazioni di gioco contiene il catalogo del Mac con i tasti attuali e un’anteprima animata per ogni azione.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automatico sospende le azioni che aprono finestre o spostano il focus. Un comando della lingua breve e intenzionale cambia la sorgente senza una finestra di sistema. I tasti di movimento tenuti premuti hanno priorità, così correre e saltare non cambiano lingua per sbaglio.

Ogni azione si regola nel catalogo con ricerca. La lingua può cambiare in background; le altre azioni possono essere sospese o consentite normalmente. Le scelte vengono sincronizzate. Le altre app che osservano i tasti compaiono a parte. Uscita forzata resta disponibile.

**Provalo:** Apri le impostazioni aggiuntive, cerca un comando di cattura o lingua e confronta l’anteprima con e senza protezione.

---

## <a id="v1.30.14"></a>I collegamenti ai comandi si aprono senza arresti

<sub>1.30.14 · 11 ottobre 2026</sub>

Fare clic su un comando disattivato non chiude più pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Nella pagina Giochi puoi fare clic su un comando anche senza tasti assegnati. Impostazioni di Sistema si apre in sicurezza.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Prima pikapik poteva leggere due volte la stessa riga che cambiava mentre si apriva la finestra. Se il testo spariva tra le letture, l’app si arrestava.

Ogni riga viene ora letta una volta. Il testo mancante viene saltato. La correzione copre anche i collegamenti nelle altre pagine.

**Provalo:** Fai clic su un comando disattivato nella pagina Giochi.

---

## <a id="v1.30.13"></a>Tieni premuto Control e continua a giocare

<sub>1.30.13 · 10 ottobre 2026</sub>

Control non lascia più che il cambio di lingua sottragga Spazio al gioco.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Tieni Control per correre e premi Spazio per saltare. In modalità Gioco, il cambio di lingua con Control+Spazio e Control+Option+Spazio viene sospeso.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Anche gli altri comandi macOS con Control, o Maiusc e Option senza Command, sono sospesi, comprese le tue assegnazioni. Pressioni, rilasci e tasti tenuti premuti arrivano insieme al gioco.

Il gesto della lingua di pikapik e i comandi di uscita con modificatori di gioco non interferiscono. Quando lasci il gioco, i comandi di sistema tornano esattamente com’erano.

**Provalo:** Tieni Control, muoviti e premi Spazio più volte. Poi lascia il gioco e cambia lingua come sempre.

---

## <a id="v1.30.12"></a>Trascina il gioco da Monitoraggio Attività

<sub>1.30.12 · 10 ottobre 2026</sub>

La modalità Gioco accetta processi trascinati da Monitoraggio Attività.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Trova il processo del gioco e trascina la riga su I tuoi giochi in Impostazioni → Giochi.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Funziona anche con giochi Java senza la normale icona nel Dock. Prima queste righe venivano ignorate perché contengono numero e nome del processo, non un file.

Il gioco resta salvato per gli avvii futuri. Minecraft appare con il suo nome. Numero e nome devono corrispondere a un processo in esecuzione.

**Provalo:** Trascina la riga java di Minecraft aperto su I tuoi giochi.

---

## <a id="v1.30.11"></a>Aggiungi il gioco mentre è aperto

<sub>1.30.11 · 10 ottobre 2026</sub>

I giochi aperti compaiono per primi quando aggiungi un gioco.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Apri Impostazioni → Giochi → Aggiungi un gioco e fai clic sul gioco in esecuzione. Compaiono anche i giochi che usano Java o altri ambienti, senza un file .app. Minecraft si chiama Minecraft anziché java.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Le app del Dock hanno un elenco espandibile separato, così trovi subito il gioco aperto.

Altro… e il trascinamento accettano anche il file eseguibile del gioco, oltre alle app. Dopo averlo aggiunto, la modalità Gioco si attiva quando passi al gioco.

**Provalo:** Lascia il gioco aperto, scegli Aggiungi un gioco e fai clic sulla sua icona. Niente ricerche tra le cartelle.

---

## <a id="v1.30.10"></a>L’animaletto resta in vista quando salta

<sub>1.30.10 · 10 ottobre 2026</sub>

L’animaletto non sparisce più dietro le finestre quando salta su uno schermo senza Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Prima, se il Dock era su un altro schermo o nascosto, l’animaletto saltava dietro le finestre e spariva fino all’atterraggio. Ora, appena si stacca da terra, compare davanti alle finestre su ogni schermo, con o senza Dock. Lo stesso vale per la palla.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Una finestra che sfiora solo il bordo dell’animaletto non lo nasconde più durante il salto. Resta dietro una finestra solo quando la finestra lo copre davvero, come un video che stai guardando.

A terra, l’animaletto e la sua palla passeggiano dietro le tue finestre, come prima.

**Provalo:** Fai nascondere il Dock o spostalo su un altro schermo, poi premi Spazio accanto a una finestra. L’animaletto salta davanti.

---

## <a id="v1.30.9"></a>Lo schermo intero è tuo, e la palla gioca pulito

<sub>1.30.9 · 10 ottobre 2026</sub>

L’animaletto non sbuca più in un video a schermo intero, e la palla non urta più cose che non ci sono.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Prima, mentre guardavi un video a schermo intero, l’animaletto poteva spuntare ogni tanto. Ora pikapik chiede direttamente a macOS se uno schermo è a schermo intero e ricontrolla quando il passaggio è finito. L’animaletto e la sua palla restano nascosti finché non esci dallo schermo intero.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

La palla non rimbalza più contro il vuoto. Vola sopra il Dock invece di sbattere contro un muro invisibile. Il mouse ora colpisce la palla solo quando il puntatore la tocca davvero. Un tocco leggero la fa rotolare, un colpo veloce la fa volare. E se l’animaletto o la sua palla si nascondono dietro una finestra, il mouse sopra quella finestra li lascia stare.

Trascinare un file sulla scrivania non costruisce più un gradino per l’animaletto. Lo fa solo un riquadro di selezione.

**Provalo:** Guarda un video a schermo intero e mettilo in pausa qualche volta con la barra spaziatrice. L’animaletto resta nascosto. Poi colpisci la palla con un colpo di mouse.

---

## <a id="v1.30.8"></a>Gli angoli dello schermo restano tranquilli mentre giochi

<sub>1.30.8 · 10 ottobre 2026</sub>

In Modalità gioco, il mouse ai bordi e negli angoli dello schermo non attiva più gli angoli attivi e non fa più uscire il Dock nascosto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Prima, nel bel mezzo di una partita, il mouse in un angolo o sul bordo dello schermo poteva attivare un angolo attivo o far uscire il Dock nascosto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Ora la Modalità gioco spegne gli angoli attivi e il Dock nascosto mentre giochi. Qualche secondo dopo che esci dal gioco, o quando chiudi pikapik, tornano esattamente com’erano.

E il puntatore non scatta più sul bordo dello schermo del gioco.

**Provalo:** Attiva la Modalità gioco, avvia un gioco e porta il mouse in un angolo dello schermo. Non spunta fuori niente.

---

## <a id="v1.30.7"></a>L’animaletto non si intromette più nel tuo video

<sub>1.30.7 · 10 ottobre 2026</sub>

Quando l’animaletto o la sua palla sono dietro una finestra, restano lì anche quando saltano o volano.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Prima, se l’animaletto o la sua palla si nascondevano dietro un video o un gioco, un salto o un volo poteva farli spuntare proprio sopra quello che stavi guardando. Anche premere Spazio per mettere in pausa un video faceva uscire l’animaletto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Ora restano dietro la finestra che li copre, qualunque cosa facciano. E un video a schermo intero in Firefox li nasconde subito.

Dietro le finestre normali continuano a nascondersi come prima.

**Provalo:** Avvia un video in una finestra grande che copre la parte bassa dello schermo e premi Spazio per metterlo in pausa. L’animaletto resta dietro il video.

---

## <a id="v1.30.6"></a>A schermo intero l’animaletto si riposa ovunque

<sub>1.30.6 · 10 ottobre 2026</sub>

Quando un’app è a schermo intero, l’animaletto e la sua palla ora si nascondono su tutti i monitor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Prima, quando aprivi un video o un gioco a schermo intero, l’animaletto e la sua palla a volte scappavano su un altro monitor e continuavano a giocare lì.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Ora, finché un’app è a schermo intero, si nascondono su tutti i tuoi monitor. Esci dallo schermo intero e tornano subito.

Dietro le finestre normali continuano a nascondersi come prima.

**Provalo:** Se hai due monitor, apri un video a schermo intero su uno dei due. L’animaletto e la sua palla spariscono da entrambi e tornano quando esci dallo schermo intero.

---

## <a id="v1.30.5"></a>L’animaletto si fa da parte mentre guardi o giochi

<sub>1.30.5 · 10 ottobre 2026</sub>

L’animaletto e la sua palla ora si nascondono quando un’app è a schermo intero, anche sui Mac con notch.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Prima, su un Mac con notch, l’animaletto poteva restare sopra un video o un gioco a schermo intero, e la palla a volte spuntava sopra un’app a schermo intero su un altro monitor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Ora, finché un’app riempie tutto lo schermo, l’animaletto e la sua palla aspettano fuori vista. Esci dallo schermo intero e tornano subito.

Dietro le finestre normali continuano a nascondersi come prima.

**Provalo:** Apri un video a schermo intero o avvia un gioco. L’animaletto e la sua palla non danno fastidio finché non hai finito.

---

## <a id="v1.30.4"></a>L’animaletto resta in vista quando salta o viaggia su una selezione

<sub>1.30.4 · 10 ottobre 2026</sub>

L’animaletto e la sua palla non spariscono più dietro le finestre mentre sono in aria.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Prima, quando l’animaletto saltava sopra il puntatore o saliva su un riquadro di selezione, una finestra ingrandita lo copriva e sembrava che fosse sparito.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Ora, finché l’animaletto o la sua palla sono più in alto del Dock, si vedono davanti alle tue finestre. Tornati a terra, passano di nuovo dietro.

E l’animaletto può di nuovo passeggiare dietro il Dock, proprio come prima.

**Provalo:** Ingrandisci una finestra a tutto schermo, inizia un riquadro di selezione sulla scrivania accanto al Dock perché l’animaletto ci salga sopra, e trascinalo piano verso l’alto. L’animaletto ci viaggia sopra davanti alla finestra.

---

## <a id="v1.30.3"></a>L’animaletto e la sua palla non finiscono più sotto il Dock

<sub>1.30.3 · 9 ottobre 2026</sub>

L’animaletto non passeggia e non dorme più sotto il Dock, così lo vedi sempre.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Prima l’animaletto e la sua palla spesso passeggiavano e riposavano proprio sotto il Dock, dove nessuno poteva vederli. Con una finestra ingrandita sembrava che l’animaletto fosse sparito per sempre.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Ora il Dock è come un muro per loro. L’animaletto si gira al suo bordo e la palla ci rimbalza contro.

Così l’animaletto resta sempre visibile accanto al Dock, anche quando una finestra occupa tutto lo schermo.

**Provalo:** Ingrandisci una finestra a tutto schermo e osserva per un paio di minuti. L’animaletto si vede sempre a sinistra o a destra del Dock.

---

## <a id="v1.30.2"></a>Il tuo animaletto non sparisce più dietro le finestre

<sub>1.30.2 · 9 ottobre 2026</sub>

Anche quando una finestra lo copre, il tuo animaletto continua a vivere e cade a terra quando lasci la selezione.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Quando le finestre coprivano tutta la striscia in cui vive il tuo animaletto, pikapik lo metteva in pausa e poteva restare bloccato a mezz’aria. Ora l’animaletto e la sua palla continuano a vivere dietro la finestra: camminano, cadono e giocano. Solo il disegno si prende una pausa.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Se un riquadro di selezione solleva l’animaletto dietro una finestra, cade appena lo lasci e lo rivedi vicino al Dock.

E un riquadro di selezione non solleva più l’animaletto oltre la sua striscia.

**Provalo:** Ingrandisci una finestra, solleva l’animaletto con un riquadro di selezione dietro di essa e lascia. Cade e ricompare vicino al Dock.

---

## <a id="v1.30.1"></a>Le selezioni sulla scrivania funzionano di nuovo

<sub>1.30.1 · 9 ottobre 2026</sub>

Il tuo animaletto e la sua palla saltano di nuovo sui riquadri di selezione, e le liste di app si illuminano solo per le app.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Quando il Dock o un’app di desktop remoto copriva tutto lo schermo, pikapik non si accorgeva del riquadro di selezione che disegni sulla scrivania. Ora se ne accorge di nuovo, e il tuo animaletto e la sua palla ci saltano sopra come prima.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Le liste di app nelle impostazioni si illuminano solo quando ci trascini sopra un’app. Gli altri file vengono ignorati: non compare nessuna cornice e non si aggiunge niente di troppo. Se trascini un’app insieme ad altri file, viene aggiunta solo l’app.

E la cornice si spegne appena lasci andare l’app o allontani il puntatore.

**Provalo:** Disegna un riquadro di selezione sulla scrivania e guarda il tuo animaletto saltarci sopra.

---

## <a id="v1.30.0"></a>Esci non spegne più pikapik

<sub>1.30.0 · 9 ottobre 2026</sub>

Hai scelto Esci per abitudine? Le abbreviazioni, «Resta sveglio» e il tuo animaletto continuano a funzionare.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/keep-awake-dark.png"><img src="../media/keep-awake-light.png" width="340" alt=""></picture>

Quando scegli «Esci», premi ⌘Q o chiudi pikapik dal Dock, chiude le sue finestre e nasconde l’icona nella barra dei menu, ma continua a lavorare in silenzio in background: le abbreviazioni, «Resta sveglio» e il tuo animaletto restano attivi. Per riavere l’icona, basta aprire di nuovo pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Vuoi uscire davvero? Tieni premuto Opzione (⌥) e scegli «Esci», oppure premi ⌥⌘Q. La prima volta che pikapik passa in background, ti spiega cosa è successo e ti propone di uscire del tutto subito.

Preferisci come prima? Disattiva «Continua in background dopo Esci» in Impostazioni › Generali. Gli aggiornamenti, il cambio di lingua, il logout, il riavvio e lo spegnimento chiudono sempre pikapik del tutto, quindi non devono mai aspettarlo.

**Provalo:** Premi ⌘Q, poi apri di nuovo pikapik per riavere la sua icona.

---

## <a id="v1.29.1"></a>Il tuo animaletto passeggia su tutti gli schermi

<sub>1.29.1 · 9 ottobre 2026</sub>

Hai più di un monitor? Il tuo animaletto e la sua palla ora vanno ovunque guardi, e non si perdono mai.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Quando arriva al bordo di uno schermo, l’animaletto passa semplicemente a quello accanto, e la palla rotola dietro di lui. Puoi anche prendere l’animaletto o la palla con il mouse e portarli su qualsiasi schermo. Se un’app va a tutto schermo, si spostano su un altro schermo per non dare fastidio, e se scolleghi un monitor tornano su quello principale.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

La palla non resta più incastrata in un angolo. L’animaletto corre lì, la rilancia all’indietro sopra la testa e continua a giocare.

E il tuo animaletto non sparisce più. Ogni due secondi controlla di essere ancora sullo schermo, e se qualcosa è andato storto, dopo lo stop, il blocco del Mac, il cambio di scrivania o il tutto schermo, torna subito da solo.

**Provalo:** Porta l’animaletto su un altro schermo, o fai rotolare la palla in un angolo.

**Corretto**

- Un animaletto lanciato non atterra più su un riquadro di selezione più alto di quanto possa saltare, e non sparisce più per questo.

---

## <a id="v1.29.0"></a>Il tuo animaletto ha una palla

<sub>1.29.0 · 9 ottobre 2026</sub>

Ora un piccolo pallone da calcio rotola lungo il bordo inferiore dello schermo. L’animaletto ci gioca, e puoi farlo anche tu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

La palla rotola e rimbalza come una vera. L’animaletto le corre dietro, la calcia e la rincorre di nuovo. Passa veloce il puntatore sulla palla per calciarla tu, oppure prendila, portala in giro e lanciala, proprio come l’animaletto.

Un piccolo trucco: fai clic su un punto vuoto della scrivania e trascina per disegnare un riquadro di selezione, con o senza Maiuscole. Finché tieni premuto il tasto del mouse, il riquadro diventa una mensola: l’animaletto ci salta sopra e anche la palla può atterrarci. Lascia il tasto e la mensola sparisce.

Preferisci una scrivania tranquilla? Disattiva Palla nelle impostazioni dell’animaletto e tornerà a passeggiare per conto suo.

**Provalo:** Impostazioni › Animaletto › Palla

**Corretto**

- Accanto al Dock l’animaletto torna a saltare in alto quanto vuole. Resta basso solo proprio sopra il Dock, così non spunta mai da dietro.

---

## <a id="v1.28.0"></a>Aggiungi app con un clic o trascinandole

<sub>1.28.0 · 9 ottobre 2026</sub>

Ogni elenco di app nelle Impostazioni ora mostra cosa c’è nel Dock e cosa è aperto adesso, e puoi trascinarci le app dal Finder.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Alcune funzioni ti fanno scegliere le app in cui si fanno da parte, come il pulsante verde o Inizio e Fine. Prima, «Aggiungi app…» apriva solo una lunga cartella con tutto quello che hai. Ora compare uno scaffale con le app del Dock e quelle aperte in questo momento. Fai clic su un’app per aggiungerla, di nuovo per toglierla. Per tutto il resto c’è «Altro…».

Puoi anche trascinare un’app dal Finder direttamente su un elenco. L’elenco si illumina per mostrarti dove finirà l’app. Con i tuoi giochi funziona allo stesso modo, con lo stesso scaffale.

E se qualcosa va storto, il modulo per segnalare un problema su GitHub ora ti fa scegliere la versione di pikapik e di macOS da un elenco, così raccontarcelo richiede meno tempo.

**Provalo:** Impostazioni › Finestre, poi «Aggiungi app…»

**Corretto**

- Lo scorrimento tramite AnyDesk o un’altra app di desktop remoto non viene più invertito due volte quando usi la direzione classica su entrambi i Mac. Ora pikapik inverte solo lo scorrimento di un vero mouse o trackpad. Se un’app fa da sé lo scorrimento fluido, come Mos, imposta la direzione in quell’app.
- L’animaletto resta dietro il Dock quando salta, proprio come quando cammina, e torna da solo quando esci da un’app a tutto schermo o da un gioco.
- Le sottili cornici attorno alle piccole immagini nelle Impostazioni non spariscono più sui normali schermi senza Retina.

---

## <a id="v1.27.3"></a>L’animaletto resta in vista, e le finestre si aprono pronte

<sub>1.27.3 · 9 ottobre 2026</sub>

L’animaletto non si nasconde più dietro le finestre a metà salto, e le finestre di pikapik si aprono pronte all’uso.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Quando l’animaletto saltava sopra il puntatore o faceva una capriola, poteva scivolare dietro le finestre di altre app e sparire a mezz’aria. Ora resta davanti per tutto il salto e torna dietro le tue finestre appena atterra.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Quando pikapik partiva in silenzio in background, all’accesso, dopo un aggiornamento o da un link pikapik://, le sue finestre potevano aprirsi grigie e restare dietro le altre finché non ci cliccavi sopra. Ora le Impostazioni e la finestra Nuovo file vengono in primo piano, pronte per scrivere.

Lo stesso vale per il messaggio dopo Crea copia più leggera e per l’elenco in cui scegli un’app da aggiungere. Non devi fare nulla.

**Provalo:** Impostazioni › Animaletto

---

## <a id="v1.27.2"></a>Nuovo file è tornato e le Impostazioni sono ancora più leggere

<sub>1.27.2 · 9 ottobre 2026</sub>

Nuovo file torna per tutti nel menu del clic destro del Finder, e le Impostazioni chiedono ancora meno al tuo Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Dopo l’ultimo aggiornamento, il Finder poteva riavviare Nuovo file in background e dimenticare in quali cartelle lavora, così la voce spariva in silenzio dal menu del clic destro. Ora Nuovo file ricorda al Finder le sue cartelle a ogni avvio, e pikapik controlla poco dopo l’apertura che il Finder le abbia ricevute. Non devi fare nulla.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Le immagini animate nelle Impostazioni ora si muovono solo quando almeno metà dell’immagine è sullo schermo. Nelle immagini dei giochi il piccolo eroe si muove sempre 30 volte al secondo, mentre le colline e il terreno dietro di lui 15. Così la pagina Giochi chiede molto meno al tuo Mac. Tutto ha lo stesso aspetto.

Dopo un aggiornamento, pikapik non aggiunge più di nuovo le sue voci del Finder a meno che l’app non si sia davvero spostata, così il Finder non deve ricaricarle ogni volta.

**Provalo:** Impostazioni › Giochi

---

## <a id="v1.27.1"></a>Più silenzioso, più leggero e il Finder pronto subito

<sub>1.27.1 · 9 ottobre 2026</sub>

Le Impostazioni pesano appena sul tuo Mac, e i comandi del clic destro nel Finder funzionano subito dopo il passaggio a pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/wheel-lines-dark.png"><img src="../media/wheel-lines-light.png" width="340" alt=""></picture>

Le piccole immagini animate nelle Impostazioni ridisegnavano l’intera pagina molte volte al secondo, così una finestra aperta teneva occupato il Mac. Ora ogni immagine ridisegna solo sé stessa, al massimo 30 volte al secondo, e si riposa quando la scorri via o nascondi la finestra. Hanno esattamente lo stesso aspetto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Dopo il passaggio da pika-tools a pikapik, il Finder poteva continuare a cercare la vecchia app, e «Nuovo file», «Converti in» e gli altri comandi del clic destro non facevano nulla. Ora pikapik se ne accorge al primo avvio e riavvia il Finder da solo quando non ci sono finestre del Finder aperte e nessuna copia in corso. Altrimenti una breve riga nella pagina Finder offre il pulsante «Riavvia il Finder».

In Impostazioni di Sistema, tra le app che si aprono all’accesso, l’app ora ha il suo nuovo nome, pikapik, e resta attiva.

**Provalo:** Impostazioni › Finder

---

## <a id="v1.27.0"></a>Ecco il tuo animaletto sulla scrivania

<sub>1.27.0 · 9 ottobre 2026</sub>

In fondo allo schermo ora vive un piccolo amico, e l’app ha un nome nuovo: pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Attivalo in Impostazioni › Animaletto. Passeggia dietro le finestre e il Dock, salta il puntatore se gli sbarra la strada e fa un balzo quando premi Spazio. Puoi prenderlo, portarlo in giro, lanciarlo e riprenderlo a metà salto.

Ogni tanto si siede e dice qualcosa di breve. Quando esce davvero una nuova versione, te lo dice una volta, e un clic su di lui apre le Impostazioni, dove ti aspetta l’aggiornamento.

pika-tools ora si chiama pikapik. Permessi, impostazioni e link in Comandi Rapidi restano come prima. Se l’hai installata con Homebrew, esegui una volta `brew update && brew upgrade --cask pikapik`.

**Provalo:** Impostazioni › Animaletto

**Corretto**

- Il controllo degli aggiornamenti segnalava una nuova versione anche quando avevi già l’ultima.
- La pagina Permessi teneva occupato il Mac finché era aperta.

---

## <a id="v1.26.2"></a>Novità nella tua lingua

<sub>1.26.2 · 8 ottobre 2026</sub>

«Novità» nelle impostazioni ora apre questa pagina, nella stessa lingua dell’app.

<img src="../media/icon.png" width="128" height="128" alt="">

Apri Impostazioni › Info e fai clic su «Novità». Arrivi proprio qui, sulla pagina con un’immagine per ogni aggiornamento, nella lingua che parla pika-tools.

Anche l’elenco completo delle modifiche è più ordinato. Ogni versione mostra il giorno in cui è uscita, e ogni numero di versione apre la sua pagina di download.

Nel funzionamento di pika-tools non cambia nulla. Gli aggiornamenti arrivano come prima, da soli o tramite Homebrew.

**Provalo:** Impostazioni › Info › Novità

**Corretto**

- «Novità» apriva un lungo elenco tecnico in inglese invece di questa pagina.
- I link dell’elenco delle modifiche che non portavano da nessuna parte ora aprono la pagina giusta.

---

## <a id="v1.26.1"></a>Le immagini dei giochi prendono vita

<sub>1.26.1 · 8 ottobre 2026</sub>

Le immagini della pagina «Giochi» ora si muovono, così vedi cosa ferma ogni interruttore.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.26.1/game-previews-dark.png"><img src="../media/whats-new/1.26.1/game-previews-light.png" width="340" alt=""></picture>

Dietro ogni interruttore della pagina «Giochi» ora gira un piccolo gioco. Compaiono dei tasti, vengono premuti, e vedi cosa salterebbe fuori sopra il tuo gioco, come Spotlight o Mission Control, mentre il gioco si ferma. Con l’interruttore attivo, i tasti si illuminano appena e il gioco va avanti. Sposta un interruttore e l’immagine mostra subito la differenza.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Il piccolo gioco segue l’aspetto del tuo Mac: una giornata di sole in modalità chiara e una notte tranquilla con luna e stelle in modalità scura.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

In tutte le immagini dell’app il puntatore ora si muove come una mano: per i tragitti lunghi ci mette un po’ di più, si ferma e solo allora fa clic. Quando un’immagine ricomincia, torna dolcemente all’inizio invece di saltare. Le immagini riposano quando la finestra è nascosta, e con «Riduci movimento» restano ferme.

**Provalo:** Impostazioni › Giochi

---

## <a id="v1.26.0"></a>Una nuova icona e tabula rasa per i vecchi permessi

<sub>1.26.0 · 8 ottobre 2026</sub>

pika-tools ha un volto nuovo e ora toglie i permessi che le app eliminate si lasciano dietro.

<img src="../media/icon.png" width="128" height="128" alt="">

La nuova icona è il simbolo pikapik in blu, viola e corallo su una piastrella scura. La barra dei menu mostra la stessa forma, che si adatta a una barra chiara o scura. Quando tutti gli strumenti sono spenti, la forma diventa più chiara.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>

Quando elimini un’app, macOS conserva i permessi che le avevi dato, e Impostazioni di Sistema non permette di toglierli. Ora la pagina «Permessi» ha un elenco «Lasciati dalle app eliminate»: ogni app con la sua icona, cosa poteva fare e quando. «Rimuovi» ripulisce un’app, «Rimuovi tutto» tutte insieme, e un’app che reinstalli chiederà semplicemente di nuovo. Per vedere l’elenco, dai a pika-tools l’accesso completo al disco: guarda soltanto e non cambia nulla finché non premi «Rimuovi».

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Le immagini delle pagine «Animazioni» e «Giochi» sono ridisegnate per la loro vera dimensione, quindi sono nitide. Una finestra si rimpicciolisce nel Dock con gli angoli arrotondati, e il puntatore fa clic prima, solo dopo si apre un menu. E in fondo a «Info» ora c’è una riga discreta: «Fatto con cura · Offrimi un caffè». Niente compare all’improvviso e niente te lo ricorda.

**Provalo:** Impostazioni › Permessi, poi «Lasciati dalle app eliminate»

**Corretto**

- Un clic su una scorciatoia di sistema apre proprio la sua sezione in Impostazioni di Sistema, come Mission Control, e non solo «Tastiera».
- Il suggerimento accanto ai tasti non sparisce più appena si apre Impostazioni di Sistema.

---

## <a id="v1.25.2"></a>Le scorciatoie si aprono dove le cambi

<sub>1.25.2 · 8 ottobre 2026</sub>

Fai clic su una scorciatoia in Impostazioni e Impostazioni di Sistema si apre nel punto giusto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Prima, un clic su una scorciatoia, come quella di Spotlight, portava sempre a «Tasti modificatori». Ora i tasti di Spotlight aprono direttamente Spotlight.

Per le altre scorciatoie, Impostazioni di Sistema si apre su «Tastiera» e un breve suggerimento accanto ai tasti ti dice dove fare clic: «Scorciatoie da tastiera…», poi «Mission Control» o un’altra sezione.

Funziona allo stesso modo nella pagina Giochi e per «Taglia i file nel Finder». Per tagliare i file, il suggerimento porta a «Scorciatoie app».

**Provalo:** Impostazioni › Giochi, poi fai clic sui tasti accanto a «La ricerca non salta fuori»

**Corretto**

- Un clic su una scorciatoia non apre più «Tasti modificatori».

---

## <a id="v1.25.1"></a>Immagini grandi e giochi direttamente dal Dock

<sub>1.25.1 · 8 ottobre 2026</sub>

Ogni interruttore ora ha un’immagine grande, e «Aggiungi gioco…» mostra cosa c’è nel tuo Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

Nelle pagine Animazioni e Giochi tutte le immagini ora sono grandi, come quella in cima alla pagina. Si capisce subito cosa fa ogni interruttore, e le immagini si muovono ancora alla velocità che hai scelto.

Fai clic su «Aggiungi gioco…» e vedi il tuo Dock: le app che tieni lì e quelle aperte adesso, nello stesso ordine. Un gioco del Dock compare anche quando è chiuso, anche Minecraft. Un clic lo aggiunge, e un segno di spunta mostra che è nell’elenco. Fai di nuovo clic per toglierlo.

Puoi ancora trascinare qui un gioco dal Finder. Non serve più tirarlo fuori dal Dock, quindi il Dock non ti proporrà di rimuoverlo.

**Provalo:** Impostazioni › Giochi, poi «Aggiungi gioco…»

**Corretto**

- Un gioco che sta nel Dock ma è chiuso ora compare nell’elenco da aggiungere.

---

## <a id="v1.25.0"></a>Aggiungi un gioco con un clic e scegli i tuoi tasti

<sub>1.25.0 · 8 ottobre 2026</sub>

Scegli un gioco tra ciò che è aperto adesso e decidi i tasti per uscire e chiudere.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

Fai clic su «Aggiungi gioco…» e le app aperte adesso compaiono con icone grandi, come nel Dock. Un clic aggiunge un gioco, oppure trascina la sua icona nell’elenco. Puoi anche rilasciare un gioco direttamente dal Finder o dal Dock. Ora qualsiasi app può essere un gioco, perfino Minecraft che gira su Java, e i giochi aggiunti prima restano.

Gli interruttori della Modalità gioco ora parlano chiaro, come «Il gioco non si chiude» o «La ricerca non salta fuori», e ognuno ha una piccola immagine di ciò che ferma. Il nome di sistema, come Spotlight, compare accanto in grigio.

In Impostazioni › Finestre, fai clic sui tasti accanto a «Esci dall’app» o «Chiudi finestra» e premi quelli nuovi. ⌫ riporta ⇧⌘Q e ⇧⌘W, e se i tasti sono già usati, pika-tools te lo chiede prima. Anche la Modalità gioco usa i tuoi tasti. E ogni scorciatoia in Impostazioni ora mostra come è davvero impostata sul tuo Mac: i tuoi tasti, oppure Disattivato.

**Provalo:** Impostazioni › Giochi, poi «Aggiungi gioco…»

**Corretto**

- Tagliare i file nel Finder segue la scorciatoia di Taglia che hai impostato per il Finder in Impostazioni di Sistema.
- I nomi delle app negli elenchi compaiono senza «.app».

---

## <a id="v1.24.1"></a>Una velocità che vedi subito

<sub>1.24.1 · 8 ottobre 2026</sub>

La pagina Animazioni ora ti dice dove si vede una modifica e protegge i tuoi valori.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

Il Dock può scorrere più veloce solo se si nasconde. Se il tuo resta sempre al suo posto, l’interruttore «Nascondi automaticamente il Dock» ora è proprio sotto il cursore della velocità.

Dopo una modifica, una riga in fondo alla pagina ti dice che le app la applicano quando le riapri. Il Finder mostra le nuove velocità di Visualizzazione rapida e delle colonne solo dopo un riavvio, quindi la riga ha un pulsante «Riavvia il Finder».

Il cursore non rallenta mai ciò che avevi già accelerato, per esempio con comandi nel Terminale. E «Ripristina default» o la disinstallazione di pika-tools riportano i valori che avevi prima, invece di cancellarli.

**Provalo:** Impostazioni › Animazioni

**Corretto**

- Il Dock non si riavvia più senza motivo quando non si nasconde.

---

## <a id="v1.24.0"></a>Scegli quanto veloce si muove il tuo Mac

<sub>1.24.0 · 8 ottobre 2026</sub>

La nuova pagina Animazioni decide quanto in fretta le cose si aprono, scorrono e compaiono sul tuo Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Basta un cursore. Spostalo, e il Dock nascosto, le nuove finestre, i pannelli di salvataggio, Visualizzazione rapida e le colonne del Finder accelerano tutti insieme, da «Come in macOS» ad «All’istante».

Vuoi regolare una cosa sola? Ogni effetto ha la sua impostazione, così come l’effetto di riduzione, le icone che rimbalzano nel Dock e le animazioni del Finder. Accanto a ogni impostazione, una piccola immagine si muove esattamente alla velocità che hai scelto.

«Ripristina default» rimette a posto solo ciò che ha cambiato pika-tools, e la disinstallazione fa lo stesso. Se un tempo hai impostato tu uno di questi valori nel Terminale, pika-tools lo mostra così com’è.

**Provalo:** Impostazioni › Animazioni

---

## <a id="v1.23.2"></a>Un interruttore per ogni scorciatoia nella Modalità gioco

<sub>1.23.2 · 8 ottobre 2026</sub>

Ora decidi tu, una scorciatoia alla volta, cosa la Modalità gioco mette a tacere mentre giochi.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Q e ⌘W hanno ora interruttori separati, come Spotlight, Siri, ⌘Tab, Mission Control, gli scorrimenti, il puntatore, lo schermo e tutto il resto. Le tue scelte precedenti restano.

Ogni riga mostra esattamente i tasti che ferma, così sai sempre cosa fa un interruttore.

L’impostazione della lingua della tastiera ha lasciato la Modalità gioco. ⌃Spazio e gli altri modi per cambiare lingua funzionano sempre, anche in gioco.

**Provalo:** Impostazioni › Giochi

**Corretto**

- I tasti di una stessa scorciatoia sono più vicini e tra scorciatoie diverse c’è un po’ più di spazio, così si vede subito dove finisce una e comincia l’altra.

---

## <a id="v1.23.1"></a>Quanto è veloce la tua connessione, in parole semplici

<sub>1.23.1 · 8 ottobre 2026</sub>

Velocità internet controlla la tua connessione e ti dice semplicemente a cosa basta.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

Premi «Misura velocità» e in circa mezzo minuto vedi download, upload, ping e reattività. Sotto i numeri, parole semplici ti dicono se basta per film in 4K, videochiamate, giochi online e download pesanti.

La misura avviene sui server di Apple e l’ultimo risultato resta fino alla prossima. Velocità internet ha una sua pagina nelle Impostazioni, una riga nel pannello della barra dei menu e un link per l’app Comandi Rapidi: `pika-tools://speed-test`.

La Modalità gioco ha imparato due cose. Il blocco delle scorciatoie con Control ora fa parte di lei: in gioco, ⌃-clic resta un clic e le scorciatoie con ⌃ non scattano; ovunque altro, ⌃ funziona come sempre. E riconosce Minecraft: aggiungi Minecraft Launcher o CurseForge ai tuoi giochi, e la Modalità gioco si attiva quando in primo piano c’è Minecraft stesso.

**Provalo:** Impostazioni › Velocità internet, poi «Misura velocità»

**Corretto**

- Le versioni di prova di pika-tools compilate in proprio tengono le loro impostazioni separate in iCloud Drive e non toccano più le tue.

---

## <a id="v1.23.0"></a>Modalità gioco: gioca senza interruzioni

<sub>1.23.0 · 7 ottobre 2026</sub>

Aggiungi i tuoi giochi, e il Mac smette di tirarti fuori.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Mentre giochi, Spotlight, Siri, ⌘Tab, Mission Control e gli scorrimenti tra le scrivanie non si aprono sopra il gioco. ⌘Q e ⌘W non lo chiudono per sbaglio, il puntatore resta sullo schermo del gioco e lo schermo resta acceso.

Per uscire da un gioco premi ⇧⌘Q; per chiuderne la finestra, ⇧⌘W. ⌥⌘Esc funziona sempre. pika-tools ti suggerisce i giochi che trova sul tuo Mac. La Modalità gioco resta spenta finché non la accendi.

Resta sveglio ti fa scegliere cosa fa lo schermo: restare acceso, senza salvaschermo né schermata di blocco, oppure spegnersi come al solito mentre il Mac continua a lavorare. Il nuovo pulsante «Spegni lo schermo ora» lo spegne subito; muovi il mouse o premi un tasto per riaccenderlo.

**Provalo:** Impostazioni › Giochi, poi «Aggiungi gioco…»

**Corretto**

- Sui Mac senza coperchio, Resta sveglio non mostra più le opzioni per il coperchio chiuso.

---

<p align="center"><sub>Le versioni precedenti sono nel <a href="../../CHANGELOG.md">registro delle modifiche</a> (in inglese).</sub></p>
