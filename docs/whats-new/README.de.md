<p align="center"><a href="../readme/README.de.md"><img src="../media/icon.png" width="96" height="96" alt="pikapik"></a></p>
<h1 align="center">Neu in pikapik</h1>
<p align="center">Jedes Update in wenigen Worten und einem Bild, das neueste zuerst.</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <b>Deutsch</b> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.46.0"></a>Die App im Vordergrund per Maustaste ausblenden

<sub>1.46.0 · 13. Oktober 2026</sub>

Drück die mittlere Taste oder eine Seitentaste, und die App, in der du gerade bist, tritt zur Seite, genau wie mit ⌘H.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/hide-app-dark.png"><img src="../media/hide-app-light.png" width="340" alt=""></picture>

Öffne Einstellungen › Maus, schalte „Maustaste blendet die aktuelle App aus“ ein und drück die Taste, die du benutzen möchtest. Mit „Ändern …“ wählst du später eine andere. Die App läuft weiter, und ein Klick auf ihr Symbol im Dock holt sie zurück. Solange du mit eingeschaltetem Spielmodus spielst, macht die Taste im Spiel das, was sie immer gemacht hat. Ist auch „Seitentasten für Zurück und Vorwärts“ an, blendet die gewählte Seitentaste stattdessen Apps aus. Die Funktion braucht die Erlaubnis „Bedienungshilfen“ und ist standardmäßig aus.

In der Version aus dem Mac App Store schneidet ⌘X Dateien im Finder aus: Wähle Dateien aus, drück ⌘X, öffne einen anderen Ordner und wähle dann „Objekte hierherbewegen“ im pikapik-Menü oder drück ⌥⌘V. „Animationen“ und „Zeigerbeschleunigung ausschalten“ sind zurück, und die Seite „Berechtigungen“ hat einen neuen Abschnitt: „Von gelöschten Apps übrig“. Diese Version kann solche Einstellungen nicht selbst ändern. Deshalb sagt dir jede Zeile, was du ändern musst, und öffnet die richtige Stelle in den Systemeinstellungen. Dein Haustier läuft jetzt über die ganze Breite des Bildschirms oberhalb des Docks.

**Ausprobieren:** Einstellungen › Maus › Maustaste blendet die aktuelle App aus

**Behoben**

- Die Zeichnungen auf der Seite „Maus“ sind wieder scharf.
- Tastatur- und Mausfunktionen fragen nur noch nach der Berechtigung, die sie wirklich nutzen. Die meisten brauchen nur „Bedienungshilfen“; vorher wollten sie auch „Eingabeüberwachung“ und blieben ohne sie grau.
- „Sprache wechseln“ zeigt an, wenn es „Eingabeüberwachung“ braucht, und ein Klick darauf öffnet die Seite „Berechtigungen“. Vorher blieb es eingeschaltet, ohne zu funktionieren.
- „Beenden, wenn das letzte Fenster schließt“ wartet, bis du „Eingabeüberwachung“ erlaubst, statt macOS beim Start von pikapik danach fragen zu lassen.
- Unter macOS 27 erscheint „Bedienungshilfen“ unter seinem neuen Namen „Gerätesteuerung und Datenzugriff“, genau wie in den Systemeinstellungen.
- Mit VoiceOver kannst du jetzt unter „Kleiderschrank“ und „Outfits“ Kleidung und Outfits für dein Haustier aussuchen und unter „Auszeichnungen“ seine Auszeichnungen öffnen. Vorher haben diese Kacheln nicht reagiert.

---

## <a id="v1.45.0"></a>Jede App hat ihre eigene Lautstärke

<sub>1.45.0 · 13. Oktober 2026</sub>

Einen lauten Anruf leiser stellen, ein lautes Spiel stummschalten und die Musik lassen, wie sie ist.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.45.0/app-volume-dark.png"><img src="../media/whats-new/1.45.0/app-volume-light.png" width="340" alt=""></picture>

Öffne Einstellungen › Ton und schalte „App-Lautstärke“ ein. Jede App, die Ton abspielt, bekommt einen eigenen Regler und eine Taste zum Stummschalten, in den Einstellungen und im Menü. Die Lautstärke deines Macs und der anderen Apps ändert sich nicht, und pikapik merkt sich die Lautstärke jeder App. Eine App, die du auf voller Lautstärke lässt, bleibt unangetastet.

Um die Lautstärke einer App zu ändern, leitet pikapik ihren Ton durch sich selbst. Dafür braucht es die Berechtigung „Systemaudio-Aufnahme“, die du auf der Seite „Berechtigungen“ erlaubst. Der Ton wird nur weitergeleitet: Er wird nicht aufgenommen, gespeichert oder irgendwohin gesendet, und das Mikrofon wird nicht benutzt. Erfordert macOS 14.2 oder neuer (unter macOS 14.0 und 14.1 bleibt die Funktion ausgeblendet) und ist standardmäßig aus.

**Ausprobieren:** Einstellungen › Ton › App-Lautstärke

---

## <a id="v1.44.3"></a>Im falschen Layout getippte Wörter korrigieren sich von selbst

<sub>1.44.3 · 13. Oktober 2026</sub>

Tippe ein Wort im falschen Tastaturlayout, drücke die Leertaste, und pikapik tippt es im richtigen neu und wechselt das Layout für dich.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/layout-fix-dark.png"><img src="../media/layout-fix-light.png" width="340" alt=""></picture>

Schalte die Funktion unter Einstellungen › Tastatur ein. Kommt ein Wort als Kauderwelsch heraus, etwa ghbdtn statt привет, tippt pikapik es neu, sobald du die Leertaste oder Return drückst, und wechselt das Layout, damit das nächste Wort gleich stimmt. Das klappt mit jedem Tastaturlayout, das du auf deinem Mac hinzugefügt hast, in all deinen Sprachen.

Normaler Text bleibt genau so, wie du ihn getippt hast. pikapik ändert ein Wort nur, wenn es in keiner deiner Sprachen ein Wort ist und dieselben Tasten in einem anderen Layout ein gängiges Wort ergeben. Namen, Tippfehler und seltene Wörter bleiben, wie sie sind, ebenso Passwortfelder, Terminal und die Apps, die du auswählst.

Ist ein Wort durchgerutscht oder willst du eins zurückhaben? Drücke ⌃⇧Leertaste, um das letzte Wort oder den ausgewählten Text zu korrigieren, und drücke noch einmal, um deine anderen Layouts auszuprobieren. Direkt nach einer Korrektur machen dieselben Tasten sie rückgängig, und pikapik korrigiert dieses Wort danach nicht mehr von selbst. In der Version aus dem Mac App Store markierst du den Text und wählst „Tastaturlayout korrigieren“ im Menü „Dienste“.

**Ausprobieren:** Einstellungen › Tastatur › Im falschen Layout getippte Wörter korrigieren

---

## <a id="v1.44.2"></a>VoiceOver öffnet das pikapik-Menü wieder

<sub>1.44.2 · 13. Oktober 2026</sub>

Unter macOS 27 kannst du das pikapik-Menü in der Menüleiste wieder mit VoiceOver öffnen.

Bisher passierte nichts, wenn du das pikapik-Symbol mit VoiceOver oder einer anderen Bedienungshilfe aktiviert hast. Jetzt öffnet sich das Menü, und wenn du das Symbol noch einmal aktivierst, schließt es sich wieder, genau wie bei einem Klick.

---

## <a id="v1.44.0"></a>Sieh, welches Programm einen Port belegt

<sub>1.44.0 · 13. Oktober 2026</sub>

Eine neue Seite „Ports“ in den Einstellungen zeigt, welches Programm welchen Port auf deinem Mac belegt, und macht den Port frei, wenn du ihn brauchst.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/ports-dark.png"><img src="../media/ports-light.png" width="340" alt=""></picture>

Meldet ein Programm, dass sein Port schon belegt ist, öffne Einstellungen › Ports. Dort steht jedes Programm, das einen Port belegt, mit seinem Symbol, den Ports, die es belegt, und der Angabe, ob sich andere Geräte in deinem Netzwerk verbinden können. Gib eine Portnummer ein, um herauszufinden, wer den Port belegt, oder um zu sehen, dass er frei ist.

Klicke auf eine Zeile, um die Adressen zu sehen, die sich im Browser öffnen lassen, die Datei des Programms, den Befehl, mit dem es gestartet wurde, seinen Ordner und seine Prozessnummer. „Freimachen“ bittet das Programm, sich zu beenden, damit es seine Arbeit sichern kann. Schließt es sich nicht, bietet pikapik an, es sofort zu beenden. Vor beiden Schritten fragt pikapik dich zuerst.

Teile von macOS und Programme anderer Benutzer bleiben unberührt. Bei „AirPlay-Empfänger“, „Dateifreigabe“, „Bildschirmfreigabe“ und „Entfernte Anmeldung“ sagt dir pikapik, welcher Schalter in den Systemeinstellungen den Port freigibt. In der Version aus dem Mac App Store zeigt „Freimachen“ das Programm, kopiert einen Befehl, der es im Terminal beendet, oder öffnet die Aktivitätsanzeige.

---

## <a id="v1.43.0"></a>Sieh, was im Hintergrund läuft

<sub>1.43.0 · 13. Oktober 2026</sub>

pikapik zeigt jetzt alles, was von selbst startet, samt der App, die es hinzugefügt hat, und schaltet deine eigenen Aufgaben aus, ohne etwas zu löschen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.43.0/background-dark.png"><img src="../media/whats-new/1.43.0/background-light.png" width="340" alt=""></picture>

Die neue Seite „Hintergrundaufgaben“ in den Einstellungen zeigt Apps, die sich beim Anmelden öffnen, Hintergrunddienste, Helfer in Apps und Reste gelöschter Apps. Bei jeder Aufgabe siehst du, welche App sie hinzugefügt hat, ob sie gerade läuft und wo ihre Datei liegt. Ein Klick zeigt die Datei im Finder.

Deine eigenen Aufgaben schaltest du mit einer Taste aus und wieder ein. Gelöscht wird nichts. Bei Aufgaben für alle Benutzer und für den ganzen Mac öffnet die Taste die Anmeldeobjekte in den Systemeinstellungen.

In der Version aus dem Mac App Store zeigt die Seite die Aufgaben, und ihre Tasten öffnen die Anmeldeobjekte.

---

## <a id="v1.42.0"></a>Sieh, wie warm dein Mac innen ist

<sub>1.42.0 · 13. Oktober 2026</sub>

Eine neue Seite „Temperatur“ in den Einstellungen zeigt, wie warm Prozessor, Grafik, Arbeitsspeicher, SSD, Akku und WLAN sind, und sagt dir in einfachen Worten, ob alles in Ordnung ist.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/temperatures-dark.png"><img src="../media/temperatures-light.png" width="340" alt=""></picture>

Öffne Einstellungen › Temperatur. Oben fasst ein Wort alles zusammen: „Normal“, „Warm“, „Heiß“ oder „Sehr heiß“, und eine kurze Zeile darunter sagt dir, ob dein Mac mit voller Geschwindigkeit läuft oder langsamer wird, um abzukühlen. Weiter unten hat jedes Bauteil, das dein Mac messen kann, eine eigene Zeile mit der Temperatur und einem farbigen Balken: Grün heißt alles gut, Gelb warm und Orange heiß, gemessen daran, was für dieses Bauteil normal ist.

Willst du die Temperatur im Blick behalten? Klick unten im pikapik-Menü auf den Stift und setz ein Häkchen bei „Temperatur“. Das Menü zeigt dann dasselbe Wort und die Temperatur des Prozessors, und ein Klick auf die Zeile öffnet die Seite.

Die Temperaturen werden alle zwei Sekunden aktualisiert, aber nur, solange die Seite oder das Menü offen ist, im Hintergrund wird also nichts geprüft. pikapik liest die Temperaturen nur ab, braucht dafür kein Passwort und ändert nichts.

**Behoben**

- Wenn du ausgewählt hast, welche Zeilen das pikapik-Menü zeigt, taucht „Dock auf einem Display halten“ dort nicht mehr von selbst auf. Um die Zeile zu zeigen, klick auf den Stift und setz ein Häkchen bei ihr.
- Wenn du die Einstellungen schließt, hört pikapik jetzt sofort auf, Lüfter und Batterie abzufragen, statt im Hintergrund weiterzumachen.

---

## <a id="v1.41.1"></a>Die Lüftersteuerung fragt nicht mehr nach deinem Passwort

<sub>1.41.1 · 13. Oktober 2026</sub>

Der Helfer, der die Lüftergeschwindigkeit einstellt, aktualisiert sich jetzt zusammen mit pikapik, deshalb fragen neue Versionen nicht mehr nach dem Administratorpasswort.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Dieses Update fragt ein letztes Mal danach. Wenn du die Lüftersteuerung nutzt, öffne Einstellungen › Berechtigungen, klicke neben „Lüftersteuerung“ auf „Erlauben“ und gib das Passwort ein. Danach aktualisiert pikapik den Helfer selbst und akzeptiert nur einen Helfer, der wirklich von pikapik stammt.

**Behoben**

- In Systemeinstellungen › Allgemein › Anmeldeobjekte erscheint der Lüfter-Helfer jetzt als pikapik, mit dem Symbol der App.

---

## <a id="v1.41.0"></a>Sieh, wie es deiner Batterie geht

<sub>1.41.0 · 13. Oktober 2026</sub>

Eine neue Seite „Batterie“ in den Einstellungen zeigt, wie abgenutzt die Batterie ist, womit sie geladen wird und wie sie lange durchhält.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/battery-dark.png"><img src="../media/battery-light.png" width="340" alt=""></picture>

Öffne Einstellungen › Batterie. Dort siehst du den Ladestand und was gerade mit der Batterie passiert, ihren Zustand, die maximale Kapazität im Vergleich zum Neuzustand und die Anzahl der Zyklen, die sie von den vorgesehenen 1.000 schon hinter sich hat.

Wenn dein Mac angeschlossen ist, zeigt die Seite das Netzteil und seine Leistung, beim Laden außerdem die Ladeleistung, also wie viel Strom gerade in die Batterie fließt. Wenn dein Mac mit der Batterie läuft, zeigt die Seite, wie viel Strom er gerade verbraucht.

Tipps ganz unten helfen der Batterie, länger durchzuhalten, und „Batterieeinstellungen …“ öffnet „Batterie“ in den Systemeinstellungen, wo du festlegst, wie macOS sie lädt. Die Seite ändert nichts und braucht keine Erlaubnis, auch nicht in der Version aus dem Mac App Store. Sie erscheint nur auf Macs mit Batterie.

**Behoben**

- Beim Entfernen mit Homebrew schaltet pikapik jetzt auch „Beim Anmelden öffnen“ aus und stellt geänderte Systemeinstellungen wie Animationen, Tastenwiederholung und aktive Ecken wieder her. Hat sich pikapik selbst aktualisiert, führe vor dem Entfernen einmal brew upgrade --cask pikapik aus.

---

## <a id="v1.40.2"></a>Updates mit Homebrew starten das Dock nicht mehr neu

<sub>1.40.2 · 13. Oktober 2026</sub>

Wenn du pikapik mit Homebrew aktualisierst, verschwindet das Dock nicht mehr für einen Moment.

Das Update auf diese Version kann das Dock noch ein letztes Mal neu starten, weil diesen Schritt noch die Version übernimmt, die du vorher hattest. Spätere Updates lassen es in Ruhe.

---

## <a id="v1.40.1"></a>Ein Klick im Dock räumt die Fenster weg

<sub>1.40.1 · 13. Oktober 2026</sub>

Klick im Dock auf das Symbol der App, in der du gerade arbeitest, und alle ihre Fenster werden im Dock abgelegt. Klick noch einmal, und sie kommen alle zurück.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.40.1/dock-minimize-dark.png"><img src="../media/whats-new/1.40.1/dock-minimize-light.png" width="340" alt=""></picture>

Öffne Einstellungen › Dock und schalte „Mit einem Klick im Dock ablegen oder ausblenden“ ein. Die Fenster kommen in derselben Reihenfolge zurück, und das Fenster, in dem du gearbeitet hast, liegt oben. Ein Klick auf eine andere App, langes Drücken auf ein Symbol für sein Menü und das Ziehen von Symbolen funktionieren wie bisher.

Möchtest du lieber die ganze App ausblenden, wie mit ⌘H? Stell unter dem Schalter „Ein Klick aufs Symbol“ auf „Blendet die App aus“. Wenn du Apps schon mit einem Klick im Dock ausgeblendet hast, ändert sich für dich nichts. Der Schalter braucht die Erlaubnis „Bedienungshilfen“, fehlt in der Version aus dem Mac App Store und ist standardmäßig aus.

---

## <a id="v1.40.0"></a>Das Dock bleibt auf einem Display

<sub>1.40.0 · 13. Oktober 2026</sub>

Das Dock springt nicht mehr auf ein anderes Display, wenn der Zeiger gegen dessen Rand drückt, sondern bleibt dort, wo du es haben willst.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-display-dark.png"><img src="../media/dock-display-light.png" width="340" alt=""></picture>

Öffne Einstellungen › Dock und schalte „Dock auf einem Display halten“ ein. Dann bleibt das Dock auf seinem Display, unten oder seitlich, und die aktiven Ecken funktionieren weiter. Dafür ist keine Erlaubnis nötig, auch nicht in der Version aus dem Mac App Store.

Um das Dock gezielt zu verschieben, halte ⌥ gedrückt und drücke den Zeiger gegen den Rand des anderen Displays. Das Dock wechselt dorthin und bleibt von da an auf diesem Display.

Ein zweiter Schalter, „Dock zurückholen“, bringt das Dock nach dem Ruhezustand oder wenn sich Displays ändern von selbst auf sein Display zurück. Er braucht die Erlaubnis „Bedienungshilfen“ und fehlt in der Version aus dem Mac App Store. Beide Schalter sind standardmäßig aus.

---

## <a id="v1.39.4"></a>Die rote Taste hält Archive nicht mehr an

<sub>1.39.4 · 13. Oktober 2026</sub>

Wurde das Passwortfenster mit der roten Taste geschlossen, hat pikapik bis zum nächsten Neustart keine Archive mehr geöffnet oder erstellt. Das ist behoben.

Die rote Taste im Passwortfenster und im Fenster für ein neues Archiv wirkt jetzt genau wie „Abbrechen“, und das nächste Archiv öffnet sich sofort. VoiceOver liest die Taste zum Aktualisieren unter „Einstellungen“ › „Über“ jetzt mit ihrem eigenen Namen vor.

---

## <a id="v1.39.3"></a>Dein Haustier lebt in deinem Rhythmus

<sub>1.39.3 · 13. Oktober 2026</sub>

Während du tippst, wird dein Haustier munter und trabt mit federnden Schritten dahin. Gehst du von deinem Mac weg, wird es müde, setzt sich und döst ein.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.3/pet-rhythm-dark.png"><img src="../media/whats-new/1.39.3/pet-rhythm-light.png" width="340" alt=""></picture>

Rührst du etwa 40 Sekunden lang weder Tastatur noch Maus an, werden ihm die Augen schwer, und nach anderthalb Minuten schläft es tief und fest, während kleine z über ihm nach oben schweben. Drück eine Taste oder beweg die Maus, dann wird es wach, steht auf und läuft weiter. Solange es ein Nickerchen macht, ist es still und verbraucht weniger Energie.

pikapik schaut sich nie an, was du tippst, sondern achtet nur darauf, wie lange der letzte Tastendruck oder die letzte Mausbewegung her ist, genau wie macOS, bevor der Bildschirm dunkler wird. Darum sind keine Berechtigungen nötig. Soll dein Haustier lieber immer munter bleiben? Schalte „Lebt in deinem Rhythmus“ in den Haustier-Einstellungen aus.

**Ausprobieren:** Einstellungen › Haustier › Lebt in deinem Rhythmus

---

## <a id="v1.39.2"></a>Synchronisierte Einstellungen liegen jetzt im Ordner pikapik

<sub>1.39.2 · 13. Oktober 2026</sub>

Wenn du deine Einstellungen mit iCloud synchronisierst, liegen sie jetzt in iCloud Drive im Ordner pikapik statt pika-tools, und pikapik verschiebt sie von selbst dorthin.

<img src="../media/icon.png" width="128" height="128" alt="">

Du musst nichts tun: Deine Einstellungen bleiben, wie sie sind, und der alte Ordner verschwindet, sobald sie umgezogen sind. Hast du eigene Dateien hineingelegt, bleibt er, wo er ist. Synchronisierst du mehrere Macs, aktualisiere pikapik auf jedem, damit sie ihre Einstellungen weiter teilen.

**Behoben**

- Das vollständige Entfernen von pikapik mit Homebrew (brew uninstall --zap) löscht jetzt auch die Liste der zuletzt entfernten Apps.
- Ältere Beiträge auf dieser Seite nennen die App jetzt pikapik.

---

## <a id="v1.39.1"></a>Die gewohnte Titelleiste in Archivfenstern

<sub>1.39.1 · 13. Oktober 2026</sub>

Die Archivfenster haben wieder die gewohnte macOS-Titelleiste mit drei runden Tasten links.

Du kannst ein Fenster wie überall auf dem Mac an seinem oberen Rand ziehen. Im Fenster für ein neues Archiv und im Passwortfenster schließt die rote Taste das Fenster, ohne etwas zu erstellen oder zu entpacken. Tasten, die in einem Fenster nichts zu tun haben, sind grau. Dieselben Tasten hat jetzt auch das Fenster, das den Fortschritt beim Erstellen einer kleineren Kopie oder beim Umwandeln einer Datei zeigt. Der Schalter „Archive in dieser App öffnen“ merkt sich jetzt, welche App ZIP- und 7Z-Dateien vorher geöffnet hat, und gibt sie ihr beim Ausschalten zurück.

---

## <a id="v1.39.0"></a>Neue Archivfenster, und das Passwort zweimal

<sub>1.39.0 · 13. Oktober 2026</sub>

Wenn du ein neues Archiv mit einem Passwort schützt, gibst du es jetzt zweimal ein, damit dich ein Tippfehler nicht aus deinen eigenen Dateien aussperrt.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.0/archive-password-dark.png"><img src="../media/whats-new/1.39.0/archive-password-light.png" width="340" alt=""></picture>

Unter den Feldern erscheint eine grüne Zeile, wenn die Passwörter übereinstimmen, oder eine rote, wenn nicht, und „Erstellen“ wartet, bis sie gleich sind.

Alle Archivfenster sehen neu aus: ein großes Symbol, ein einziger Schalter für das Passwort und eine kurze Zeile, die dir sagt, ob die Dateinamen sichtbar bleiben, wie bei ZIP, oder ebenfalls verborgen werden, wie bei 7Z. Unter macOS 26 sind die Tasten aus Liquid Glass.

Auch die Installation ist einfacher: Der Befehl oben auf der pikapik-Seite bei GitHub braucht sonst nichts auf deinem Mac. Er installiert pikapik nur, wenn der Download vom Entwickler signiert ist und Apples Prüfung auf Schadsoftware bestanden hat.

---

## <a id="v1.38.2"></a>Sichere Updates neben der Version aus dem App Store

<sub>1.38.2 · 12. Oktober 2026</sub>

Hast du pikapik auch aus dem App Store auf deinem Mac, wird die GitHub-Version jetzt an Ort und Stelle aktualisiert und die Version aus dem App Store bleibt unangetastet.

Früher wurde das Update nicht installiert, wenn die GitHub-Version noch ihren alten Namen pika-tools trug und nicht mit Homebrew installiert war. Stattdessen öffnete sich die Version aus dem App Store, und das Öffnen von pikapik beim Anmelden wurde ausgeschaltet.

---

## <a id="v1.38.1"></a>Ein verlässlicheres Finder-Menü

<sub>1.38.1 · 12. Oktober 2026</sub>

Die Einträge von pikapik, die per Rechtsklick im Finder erscheinen, verschwinden nicht mehr, wenn du ein Laufwerk anschließt, ein Disk-Image öffnest, deinen Mac aus dem Ruhezustand weckst oder zum Finder wechselst.

In seltenen Fällen wurde der Helfer, der sie anzeigt, genau in diesem Moment beendet.

---

## <a id="v1.38.0"></a>Archive im Finder öffnen und erstellen

<sub>1.38.0 · 12. Oktober 2026</sub>

Die neuen „Archive im Finder“ öffnen RAR und andere Archive, die macOS nicht kennt, und erstellen ZIP und 7Z per Rechtsklick.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/archive-dark.png"><img src="../media/archive-light.png" width="340" alt=""></picture>

Öffne Einstellungen › Finder und schalte „Archive im Finder“ ein. Klicke ein Archiv mit der rechten Maustaste an und wähle „Entpacken“, und die Dateien erscheinen daneben. Klicke eine andere Datei oder einen Ordner mit der rechten Maustaste an und wähle „Archiv erstellen …“, um ein ZIP, 7Z, TAR.GZ oder TAR.XZ anzulegen. ZIP und 7Z können ein Passwort haben, und jedes Archiv lässt sich in Teile aufteilen, zum Beispiel in 15 MB große für E-Mail. Ein so erstelltes ZIP enthält keine versteckten Hilfsdateien, und Namen in jeder Sprache bleiben lesbar.

pikapik öffnet auch, was macOS nicht kann: RAR, auch auf mehrere Dateien verteilt, 7Z mit Passwort, ZIPX, CAB, LZH, ARJ, ZST, WIM und mehr. Ein Doppelklick öffnet sie in pikapik. Dateinamen in alten ZIPs, etwa auf Kyrillisch, Japanisch oder Chinesisch, erscheinen jetzt lesbar. Der Schalter „Archive in dieser App öffnen“ übergibt pikapik auch ZIP und 7Z, während TAR und GZ bei der eingebauten Archiv-App bleiben, die damit ohnehin gut zurechtkommt.

Ein Fenster fragt nach dem Passwort, „Stopp“ bricht jede Aufgabe ab, und aus einem beschädigten Archiv holt pikapik heraus, was sich noch lesen lässt. Vor dem Entpacken eines Archivs, das riesig anschwellen würde, fragt pikapik nach, und Archive, die außerhalb ihres eigenen Ordners schreiben wollen, werden blockiert. Nicht in der Version aus dem Mac App Store. Wähle ein Archiv aus und drücke die Leertaste, um zu sehen, was darin ist.

---

## <a id="v1.37.3"></a>Die FPS-Anzeige fragt jetzt am richtigen Ort nach

<sub>1.37.3 · 12. Oktober 2026</sub>

Die Bildschirmaufnahme für die FPS-Anzeige erlaubst du jetzt auf der Seite „Berechtigungen“, zusammen mit allen anderen Berechtigungen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Um die Bilder eines Spiels zu zählen, braucht „FPS anzeigen“ vielleicht die Bildschirmaufnahme. Früher hat pikapik direkt auf der Seite „Spiele“ danach gefragt. Jetzt steht sie bei allen anderen Berechtigungen: Wenn „FPS anzeigen“ sie braucht, erscheint in den Einstellungen auf der Seite „Berechtigungen“ die Zeile „Bildschirmaufnahme“, und du klickst dort auf „Erlauben“.

Auf der Seite „Spiele“ siehst du jetzt nur noch die gewohnte Zeile unter dem Schalter: „Braucht eine Berechtigung. Klicke, um sie zu erlauben.“ Ihre Taste „Erlauben“ führt dich direkt zur Zeile „Bildschirmaufnahme“. Das Einschalten von „FPS anzeigen“ stellt keine Frage mehr von selbst, und mitten im Spiel fragt pikapik weiterhin nie.

---

## <a id="v1.37.2"></a>Von Apple geprüft

<sub>1.37.2 · 12. Oktober 2026</sub>

pikapik ist jetzt von einem verifizierten Apple-Entwickler signiert und von Apple geprüft. Darum warnt dich macOS beim ersten Öffnen nicht mehr.

Nach diesem Update fragt macOS eventuell erneut nach den Berechtigungen, die du pikapik gegeben hast, etwa Bedienungshilfen, Eingabeüberwachung oder Vollzugriff auf die Festplatte. Erlaube sie einfach noch einmal unter Systemeinstellungen › Datenschutz & Sicherheit. Wenn du die Lüftersteuerung nutzt, erlaube sie in den Einstellungen von pikapik erneut; macOS fragt dann einmal nach deinem Passwort.

---

## <a id="v1.37.1"></a>Die FPS-Anzeige hält mit deinem Spiel Schritt

<sub>1.37.1 · 12. Oktober 2026</sub>

Verschiebe das Spielfenster, und die FPS-Anzeige wandert jetzt direkt mit.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Bisher holte die Anzeige ein bewegtes Fenster nur etwa einmal pro Sekunde ein und hinkte deshalb hinterher. Jetzt prüft sie das Fenster bei jedem neuen Bild auf dem Bildschirm und liegt höchstens ein paar Tausendstelsekunden zurück. Steht das Fenster still, prüft sie seltener, sodass sie deinen Mac beim Spielen kaum belastet. Außerdem springt sie nicht mehr weg, wenn ein Teil des Fensters über den Bildschirmrand hinausragt.

Zeigt ein ruhiges Spiel wie Schach 0 an, ist alles in Ordnung: Solche Spiele zeichnen nur dann ein neues Bild, wenn sich etwas bewegt. Die Zahl steigt, während eine Figur gleitet, und fällt wieder auf 0, sobald das Brett ruht.

---

## <a id="v1.37.0"></a>Sieh, wie flüssig dein Spiel läuft

<sub>1.37.0 · 12. Oktober 2026</sub>

Der neue Schalter „FPS anzeigen“ setzt einen kleinen Zähler in eine Ecke deines Spiels, damit du siehst, wie flüssig es läuft.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Öffne Einstellungen › Spiele und schalte „FPS anzeigen“ ein. Solange der Spielmodus an ist, sitzt in einer Ecke jedes Spiels eine kleine dunkle Anzeige mit einer Zahl. FPS heißt Bilder pro Sekunde: wie viele Bilder das Spiel jede Sekunde zeichnet, und je höher die Zahl, desto flüssiger läuft es. Die Ecke wählst du mit einem Klick auf das Bild über dem Schalter.

Klicks gehen einfach durch die Anzeige hindurch, und sie folgt dem Spielfenster. Ein Strich heißt, dass die ersten Bilder noch nicht da sind, eine blasse 0, dass das Spiel nichts mehr zeichnet. „FPS anzeigen“ ist aus, bis du es einschaltest.

Unter macOS 27 zählt macOS die meisten Spiele selbst, deshalb ist keine Erlaubnis nötig. Einige Spiele, meist ältere, lassen sich nur über die Bildschirmaufnahme zählen, und dann kann die Zahl nicht höher sein als die Bildwiederholrate des Bildschirms. Unter macOS 14 bis 26 und in der Version aus dem Mac App Store wird jedes Spiel so gezählt, deshalb bittet pikapik beim Einschalten von „FPS anzeigen“ um die „Bildschirmaufnahme“. Es wird nie ein Bild gespeichert oder gesendet.

---

## <a id="v1.36.0"></a>Apps entfernen ohne Sorge

<sub>1.36.0 · 12. Oktober 2026</sub>

Das neue Entfernen von Apps nimmt eine App mit allen Dateien weg und legt alles zurück, wenn du es dir anders überlegst.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/uninstaller-dark.png"><img src="../media/uninstaller-light.png" width="340" alt=""></picture>

Öffne Einstellungen › Apps entfernen und such dir eine App aus oder zieh sie auf das Bild. pikapik zeigt alles, was die App auf deinem Mac aufbewahrt, und sagt dir bei jeder Datei, warum sie in der Liste steht. Dateien, die eindeutig zur App gehören, sind angehakt, solche, die nur vielleicht dazugehören, nicht. Klicke auf „In den Papierkorb legen“, und alles kommt in den Papierkorb, sodass nichts endgültig gelöscht wird.

Doch anders überlegt? Klicke auf „Zurücklegen“, und alles ist wieder da, wo es war. Die letzten zehn Entfernungen warten unter „Zuletzt entfernt“, solange ihre Dateien noch im Papierkorb liegen. „App zurücksetzen“ behält die App und entfernt nur ihre gespeicherten Daten, Einstellungen und temporären Dateien, falls sie spinnt.

Eine App selbst in den Papierkorb gelegt? Die Seite listet solche Apps samt den Dateien auf, die sie hinterlassen haben, und wenn du einen Schalter einschaltest, bietet pikapik jedes Mal an aufzuräumen, sobald eine App in den Papierkorb kommt. Nichts wird entfernt, bevor du wählst. Damit die Seite alles sehen kann, braucht sie den Festplattenvollzugriff.

---

## <a id="v1.35.0"></a>Zieh dein Haustier an

<sub>1.35.0 · 12. Oktober 2026</sub>

Dein Haustier hat jetzt einen Kleiderschrank, und beim gemeinsamen Spielen verdienst du neue Sachen zum Anziehen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.35.0/wardrobe-dark.png"><img src="../media/whats-new/1.35.0/wardrobe-light.png" width="340" alt=""></picture>

Öffne Einstellungen › Haustier und such aus, was dein Haustier trägt: Hüte, Brillen, Schals, Hemden, Schuhe, Umhänge und sogar Flügel. Dein Haustier zieht es sofort an. Ein paar Teile sind von Anfang an frei, die übrigen sind Auszeichnungen, die ihr beim gemeinsamen Spielen sammelt: Heb dein Haustier hoch und wirf es, kick den Ball herum, sieh zu, wie es auf Fenster klettert und plaudert, oder leiste ihm einfach Tag für Tag Gesellschaft. Wenn du eine Auszeichnung verdient hast, sagt dir dein Haustier Bescheid.

Fertige Outfits kleiden dein Haustier mit einem Klick von Kopf bis Fuß ein: Zauberer, Pirat, Astronaut, Superheld, König und mehr. Ein Outfit ist bereit, sobald du alle seine Teile verdient hast.

Gespeichert werden nur einfache Zahlen, etwa Schritte, Würfe und gemeinsame Tage. Sie bleiben auf deinem Mac, nichts wird irgendwohin gesendet, und du kannst sie jederzeit in Einstellungen › Haustier löschen.

---

## <a id="v1.34.0"></a>Maus und Trackpad in Spielen

<sub>1.34.0 · 12. Oktober 2026</sub>

Wischgesten, Zusammenziehen der Finger und aktive Ecken holen dich jetzt nicht mehr aus dem Spiel, genau wie Tastaturkurzbefehle.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.34.0/pointer-shortcuts-dark.png"><img src="../media/whats-new/1.34.0/pointer-shortcuts-light.png" width="340" alt=""></picture>

Unter Einstellungen › Spiele › Weitere Spieleinstellungen gibt es die Gruppe „Maus und Trackpad“. Sie zeigt nur, was in macOS auf deinem Mac eingeschaltet ist, mit den Namen von Apple und einer kleinen Zeichnung zu jedem Eintrag: Kurzbefehle auf einer Maustaste, Wischen zwischen Schreibtischen und Apps im Vollbildmodus, Mission Control und App Exposé, Zusammenziehen der Finger für Apps und Spreizen für den Schreibtisch, das Wischen vom rechten Rand für die Mitteilungszentrale und jede aktive Ecke mit ihrer Aktion. Solange ein Spiel vorn ist, sind sie pausiert. Eine versehentliche Wischgeste oder ein Streifen über eine Bildschirmecke holt dich dann nicht aus dem Spiel. Gesten innerhalb des Spiels funktionieren weiter. Jeder Eintrag lässt sich auf normales Verhalten stellen.

---

## <a id="v1.33.2"></a>Kürzelgruppen öffnen sich sofort

<sub>1.33.2 · 11. Oktober 2026</sub>

Selbst die längste Gruppe von Systemkürzeln geht sofort auf, und jede Zeile hat einen verständlichen Namen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Bisher stockte das Einstellungsfenster kurz, wenn sich eine Gruppe mit Dutzenden Zeilen öffnete, weil alle Zeilen samt animierter Vorschau auf einmal aufgebaut wurden. Jetzt werden nur die sichtbaren Zeilen und einige in ihrer Nähe aufgebaut. Auch die Zeilen „Systemaktion“ mit Nummer sind verschwunden: Diktat, Siri und die Tasten für Helligkeit und Zoom zeigen ihre echten Namen, und Aktionen, denen macOS keinen Namen gibt, sind ausgeblendet, werden in Spielen aber weiterhin pausiert.

---

## <a id="v1.33.1"></a>Kürzelgruppen öffnen sich ohne Hänger

<sub>1.33.1 · 11. Oktober 2026</sub>

Die Seite „Spiele“ bleibt flüssig, wenn eine lange Liste mit Vorschauen aufklappt.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Beim Aufklappen einer Gruppe von Systemtastenkürzeln fror das Einstellungsfenster bisher bis zu drei Sekunden ein, weil jede Zeile mit ihrer Vorschau mehrmals berechnet wurde. Jetzt wird jede Zeile nur einmal berechnet, sodass sich Gruppen fast sofort öffnen.

---

## <a id="v1.33.0"></a>Alle Berechtigungen an einem Ort

<sub>1.33.0 · 11. Oktober 2026</sub>

Unter Einstellungen › Berechtigungen steht jetzt alles, was pikapik nutzt, und jede Berechtigung können Sie dort zurücknehmen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.33.0/permissions-dark.png"><img src="../media/whats-new/1.33.0/permissions-light.png" width="340" alt=""></picture>

Einstellungen › Berechtigungen zeigt jetzt jede Berechtigung, die pikapik nutzt: von Bedienungshilfen und Eingabeüberwachung bis zu Lüftersteuerung, Finder-Erweiterungen, iCloud Drive und Festplattenvollzugriff. Jede Zeile sagt in einem Satz, wofür sie da ist, mit grünem Haken, wenn sie an ist, und orangefarbenem Kreuz, wenn sie fehlt.

Jede Zeile hat eine Schaltfläche: „Erlauben“, wenn die Berechtigung fehlt, „Ausschalten“, wenn sie an ist. So nehmen Sie jede Berechtigung gleich dort zurück, ohne in den Systemeinstellungen zu suchen. Bei Bedienungshilfen und Eingabeüberwachung fragt pikapik erst nach und startet dann ohne sie neu.

Ein Tool, das eine noch nicht erteilte Berechtigung braucht, wirkt halb ausgegraut. Klicken Sie darauf, dann öffnet sich „Berechtigungen“ mit der passenden Zeile, bereit für einen Klick auf „Erlauben“.

**Ausprobieren:** Öffnen Sie Einstellungen › Berechtigungen und sehen Sie sich jede Zeile an. Klicken Sie auf ein ausgegrautes Tool, um direkt zur nötigen Berechtigung zu springen.

---

## <a id="v1.32.2"></a>Sicherere Installation, und Updates verlieren die App nie

<sub>1.32.2 · 11. Oktober 2026</sub>

Eine Runde Korrekturen für sichereres Installieren, Aktualisieren und Deinstallieren.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Der Lüfter-Helfer wird jetzt sorgfältiger installiert und vor dem Start geprüft. Lässt sich ein Update nicht kopieren, bleibt Ihr aktuelles pikapik erhalten. Beim Deinstallieren wird auch der Lüfter-Helfer entfernt, und Ihre Einstellung für die Tastenwiederholung, die Dock-Ecken und die Systemkurzbefehle werden zurückgesetzt.

Gehaltene Tasten bleiben nicht mehr hängen, wenn ein Werkzeug neu startet, und beim Ausschalten von „Gehaltene Taste wiederholen“ bekommen Sie Ihre eigene Einstellung für das Akzentmenü zurück. Das Haustier ruht, solange der Bildschirm schläft oder gesperrt ist, und eine Kopie von archive.tar.gz heißt jetzt archive 2.tar.gz.

---

## <a id="v1.32.1"></a>Manuelle Lüfterdrehzahl klappt jetzt gleich beim ersten Mal

<sub>1.32.1 · 11. Oktober 2026</sub>

„Manuell“ bei den Lüftern springt nicht mehr zurück auf Automatisch.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Manchmal schickte der erste Tipp auf „Manuell“ die Lüfter mit einer Sicherheitswarnung zurück auf „Automatisch“, und erst der zweite Tipp funktionierte. Jetzt hält „Manuell“ gleich beim ersten Versuch.

Sollte ein Lüfter den manuellen Modus doch einmal von selbst verlassen, setzt pikapik ihn jetzt tatsächlich auf „Automatisch“ zurück. Was Sie sehen, entspricht also immer dem, was Ihr Mac tut.

Sie müssen nichts erneut erlauben. Aktualisieren, und es funktioniert.

**Ausprobieren:** Öffnen Sie Einstellungen › Lüfter und wählen Sie „Manuell“.

---

## <a id="v1.32.0"></a>Sehen, wie schnell Ihre Lüfter drehen

<sub>1.32.0 · 11. Oktober 2026</sub>

Ein neuer Tab „Lüfter“ zeigt jeden Lüfter live und lässt Sie die Drehzahl wählen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Die Lüfter haben jetzt einen eigenen Tab in den Einstellungen und eine Zeile im Menü. Sie sehen in Echtzeit, wie schnell sich jeder Lüfter gerade dreht, und daneben dreht sich ein kleiner Lüfter mit.

Lassen Sie es auf „Automatisch“, dann entscheidet Ihr Mac wie gewohnt. Oder wählen Sie „Manuell“ und stellen die gewünschte Drehzahl mit einem einzigen Regler ein. Beim ersten Mal erlauben Sie das einmalig mit Ihrem Administratorpasswort, mehr ist nicht nötig.

Es ist auf Sicherheit ausgelegt. Die Lüfter kehren zu „Automatisch“ zurück, wenn Sie pikapik beenden, wenn Ihr Mac in den Ruhezustand geht, wenn pikapik abstürzt oder wenn Ihr Mac heiß wird.

**Ausprobieren:** Öffnen Sie Einstellungen › Lüfter und beobachten Sie die Drehzahl. Wählen Sie „Manuell“, um den Regler auszuprobieren.

---

## <a id="v1.31.4"></a>Details, wenn du sie brauchst

<sub>1.31.4 · 11. Oktober 2026</sub>

Eine ruhigere Spielseite und eine gemeinsame Suche.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.4/game-choices-dark.png"><img src="../media/whats-new/1.31.4/game-choices-light.png" width="340" alt=""></picture>

Jeder Modus erklärt seine Wirkung direkt in der Auswahlliste. Ist sie geschlossen, bleibt nur der gewählte Name auf der Seite.

Beschreibungen, die den Aktionsnamen wiederholen, wurden entfernt. Nützliche Zusatzinformationen bleiben erhalten.

Die gemeinsame Suche findet Systemaktionen nach Name, Bedeutung und Tasten. Ein Ergebnis öffnet und markiert genau diese Einstellung.

**Ausprobieren:** Finde eine Aktion in der gemeinsamen Suche und öffne ihre Modusliste.

---

## <a id="v1.31.3"></a>Einheitliche Spieloptionen

<sub>1.31.3 · 11. Oktober 2026</sub>

Passende Vorschauen und verständliche Kurzbefehle.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.3/game-preview-dark.png"><img src="../media/whats-new/1.31.3/game-preview-light.png" width="340" alt=""></picture>

Jeder Kurzbefehl hat jetzt dieselbe breite Vorschau wie der Spielschutz und die anderen Einstellungsseiten. Darunter stehen Beschreibung, Bedienelemente und eine Erklärung der gewählten Option.

«Spielmodus-Regeln verwenden». Ein kurzer Tastendruck wechselt die Sprache ohne Menü. Gedrückte Spieltasten verhindern versehentliche Wechsel.

«In Spielen deaktivieren». Diese macOS-Aktion ist deaktiviert, solange das Spiel im Vordergrund ist. Danach funktioniert sie wie zuvor. «In Spielen erlauben». macOS führt die Aktion normal aus, auch wenn sie ein Fenster öffnet oder den Fokus vom Spiel nimmt.

**Ausprobieren:** Öffne Weitere Spieloptionen, klappe die Systemsteuerung auf und wähle das Verhalten einer Aktion beim Spielen.

---

## <a id="v1.31.2"></a>Spieloptionen mit klarem Zweck

<sub>1.31.2 · 11. Oktober 2026</sub>

Schutz anpassen und die Kurzbefehle deines Mac erkunden.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.2/game-settings-dark.png"><img src="../media/whats-new/1.31.2/game-settings-light.png" width="340" alt=""></picture>

Acht klare Themen ersetzen wiederholte Ordner. Jede Überschrift hat einen Namen, eine Erklärung, ein Symbol und eine Anzahl. Ein Klick auf die ganze Zeile öffnet den Abschnitt.

Jede Aktion erklärt ihre Funktion neben der animierten Vorschau. Die aktuellen Tasten und das Verhalten im Spiel stehen in einer eigenen Zeile. Die Suche findet auch Beschreibungen.

Nicht belegte Tasten haben einen klaren Link zu den Systemeinstellungen. Allgemeine Schutzoptionen sind getrennt gesammelt, und deine Auswahl bleibt erhalten.

**Ausprobieren:** Öffne Weitere Spieloptionen, klappe ein Thema auf und vergleiche die Beschreibung einer Aktion mit ihrer Vorschau.

---

## <a id="v1.31.1"></a>Sprachgesten im Spiel

<sub>1.31.1 · 11. Oktober 2026</sub>

Standardmäßig einfach, mit dem vollständigen Systemkatalog bei Bedarf.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/input-switch-dark.png"><img src="../media/input-switch-light.png" width="340" alt=""></picture>

Die Sprachgeste von pikapik funktioniert im Spiel auch dann, wenn die macOS-Sprachkurzbefehle nicht belegt oder ausgeschaltet sind.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automatisch pausiert Aktionen, die Fenster öffnen oder den Fokus wechseln. Ein kurzes bewusstes Sprachkürzel wechselt die Eingabequelle ohne Systemfenster. Gehaltene Bewegungstasten haben Vorrang, damit Rennen und Springen nicht versehentlich die Sprache ändern.

Jede Aktion lässt sich im durchsuchbaren Katalog einstellen. Sprachaktionen können im Hintergrund laufen; andere Aktionen lassen sich pausieren oder normal erlauben. Die Auswahl wird synchronisiert. Andere Apps mit Tastenzugriff erscheinen separat. Sofort beenden bleibt verfügbar.

**Ausprobieren:** ⌥ halten und ⇧ tippen: nächste Sprache. ⇧ halten und ⌥ tippen: vorherige

---

## <a id="v1.31.0"></a>Der Spielmodus kennt die Kürzel deines Macs

<sub>1.31.0 · 11. Oktober 2026</sub>

Standardmäßig einfach, mit dem vollständigen Systemkatalog bei Bedarf.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Schalte den Spielmodus ein und spiele. Weitere Spieleinstellungen enthält den Katalog deines Macs mit aktuellen Tasten und einer animierten Vorschau für jede Aktion.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automatisch pausiert Aktionen, die Fenster öffnen oder den Fokus wechseln. Ein kurzes bewusstes Sprachkürzel wechselt die Eingabequelle ohne Systemfenster. Gehaltene Bewegungstasten haben Vorrang, damit Rennen und Springen nicht versehentlich die Sprache ändern.

Jede Aktion lässt sich im durchsuchbaren Katalog einstellen. Sprachaktionen können im Hintergrund laufen; andere Aktionen lassen sich pausieren oder normal erlauben. Die Auswahl wird synchronisiert. Andere Apps mit Tastenzugriff erscheinen separat. Sofort beenden bleibt verfügbar.

**Ausprobieren:** Öffne Weitere Spieleinstellungen, suche ein Bildschirmfoto- oder Sprachkürzel und vergleiche die Vorschau mit und ohne Schutz.

---

## <a id="v1.30.14"></a>Tastenkürzel-Links öffnen ohne Absturz

<sub>1.30.14 · 11. Oktober 2026</sub>

Ein Klick auf ein ausgeschaltetes Tastenkürzel beendet pikapik nicht mehr.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Auf der Spiele-Seite kannst du ein Tastenkürzel anklicken, auch wenn keine Tasten zugewiesen sind. Die Systemeinstellungen öffnen sicher.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Bisher konnte pikapik dieselbe sich ändernde Zeile zweimal lesen, während das Einstellungsfenster öffnete. Verschwand der Text dazwischen, stürzte die App ab.

Jede Zeile wird jetzt einmal gelesen. Fehlender Text wird übersprungen. Das gilt auch für Tastenkürzel-Links auf anderen Seiten.

**Ausprobieren:** Klicke auf ein ausgeschaltetes Tastenkürzel auf der Spiele-Seite.

---

## <a id="v1.30.13"></a>Halte Control gedrückt und spiele weiter

<sub>1.30.13 · 10. Oktober 2026</sub>

Control lässt den Sprachwechsel deinem Spiel nicht mehr die Leertaste wegnehmen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Halte Control zum Laufen und drücke die Leertaste zum Springen. Im Spielmodus wird der Sprachwechsel mit Control+Leertaste und Control+Option+Leertaste pausiert.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Andere macOS-Tastenkürzel mit Control oder mit Shift und Option ohne Command werden ebenfalls pausiert, auch eigene Zuweisungen. Tastendrücke, Loslassen und gehaltene Tasten erreichen das Spiel gemeinsam.

Auch pikapiks Sprachgeste und Beenden-Kürzel mit Spieltasten stören nicht. Wenn du das Spiel verlässt, funktionieren die Systemkürzel wieder genau wie vorher.

**Ausprobieren:** Halte Control, bewege dich und drücke mehrmals die Leertaste. Verlasse dann das Spiel und wechsle wie gewohnt die Sprache.

---

## <a id="v1.30.12"></a>Ziehe dein Spiel aus der Aktivitätsanzeige

<sub>1.30.12 · 10. Oktober 2026</sub>

Der Spielmodus nimmt jetzt Prozesse aus der Aktivitätsanzeige an.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Suche den Spielprozess und ziehe seine Zeile auf Deine Spiele unter Einstellungen → Spiele.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Java-Spiele funktionieren auch ohne normales Symbol im Dock. Bisher wurden diese Zeilen ignoriert, weil sie Prozessnummer und Namen statt einer Datei enthalten.

Das Spiel bleibt für spätere Starts gespeichert. Minecraft erscheint unter seinem Namen. Nummer und Name müssen zu einem laufenden Prozess passen.

**Ausprobieren:** Ziehe die java-Zeile deines laufenden Minecraft auf Deine Spiele.

---

## <a id="v1.30.11"></a>Füge dein Spiel hinzu, während es läuft

<sub>1.30.11 · 10. Oktober 2026</sub>

Beim Hinzufügen siehst du jetzt zuerst deine geöffneten Spiele.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Öffne Einstellungen → Spiele → Spiel hinzufügen und klicke auf dein laufendes Spiel. Auch Spiele über Java und andere Laufzeitumgebungen erscheinen hier, selbst ohne .app. Minecraft heißt Minecraft statt java.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Die Apps im Dock haben jetzt eine eigene aufklappbare Liste. So findest du dein laufendes Spiel sofort.

Über Andere… und per Drag-and-drop kannst du neben Apps auch die ausführbare Datei des Spiels hinzufügen. Danach aktiviert sich der Spielmodus, wenn du zum Spiel wechselst.

**Ausprobieren:** Lass dein Spiel geöffnet, wähle Spiel hinzufügen und klicke auf sein Symbol. Kein Suchen in Ordnern.

---

## <a id="v1.30.10"></a>Dein Haustier bleibt im Blick, wenn es springt

<sub>1.30.10 · 10. Oktober 2026</sub>

Dein Haustier verschwindet nicht mehr hinter Fenstern, wenn es auf einem Bildschirm ohne Dock springt.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Bisher sprang dein Haustier hinter deine Fenster und war bis zur Landung weg, wenn das Dock auf einem anderen Bildschirm lag oder ausgeblendet war. Jetzt erscheint es vor deinen Fenstern, sobald es den Boden verlässt, auf jedem Bildschirm, mit oder ohne Dock. Der Ball macht es genauso.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Ein Fenster, das dein Haustier nur am Rand berührt, versteckt es beim Springen nicht mehr. Dein Haustier bleibt nur hinter einem Fenster, das es wirklich verdeckt, etwa einem Video, das du gerade schaust.

Am Boden laufen dein Haustier und sein Ball wie gewohnt hinter deinen Fenstern.

**Ausprobieren:** Lass das Dock automatisch ausblenden oder schieb es auf einen anderen Bildschirm und drück neben einem Fenster die Leertaste. Dein Haustier springt davor.

---

## <a id="v1.30.9"></a>Das Vollbild gehört dir, und der Ball spielt fair

<sub>1.30.9 · 10. Oktober 2026</sub>

Dein Haustier schlüpft nicht mehr in ein Video im Vollbild, und der Ball stößt nicht mehr an Dinge, die gar nicht da sind.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Früher konnte dein Haustier ab und zu auftauchen, während du ein Video im Vollbild geschaut hast. Jetzt fragt pikapik macOS direkt, ob ein Bildschirm im Vollbild ist, und prüft noch einmal, wenn der Wechsel vorbei ist. Dein Haustier und sein Ball bleiben versteckt, bis du das Vollbild verlässt.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Der Ball prallt nicht mehr an leerer Luft ab. Er fliegt über das Dock, statt gegen eine unsichtbare Wand darüber zu stoßen. Die Maus trifft den Ball jetzt nur, wenn der Zeiger ihn wirklich berührt. Eine leichte Berührung lässt ihn rollen, ein schneller Schwung lässt ihn fliegen. Und versteckt sich dein Haustier oder sein Ball hinter einem Fenster, lässt die Maus über diesem Fenster sie in Ruhe.

Eine Datei über den Schreibtisch zu ziehen, baut deinem Haustier keine Stufe mehr. Das macht nur ein Auswahlrahmen.

**Ausprobieren:** Schau ein Video im Vollbild und pausiere es ein paar Mal mit der Leertaste. Dein Haustier bleibt unsichtbar. Dann schwing die Maus gegen den Ball.

---

## <a id="v1.30.8"></a>Die Bildschirmecken bleiben still, während du spielst

<sub>1.30.8 · 10. Oktober 2026</sub>

Im Spielmodus lösen Mausbewegungen an Rändern und Ecken keine aktiven Ecken mehr aus und holen kein ausgeblendetes Dock mehr hervor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Früher konnte die Maus in einer Ecke oder am Bildschirmrand mitten im Spiel eine aktive Ecke auslösen oder ein ausgeblendetes Dock hervorholen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Jetzt schaltet der Spielmodus aktive Ecken und das ausgeblendete Dock ab, solange du spielst. Ein paar Sekunden nachdem du das Spiel verlässt oder pikapik beendest, sind sie genau wie vorher wieder da.

Und der Zeiger ruckelt nicht mehr am Rand des Bildschirms mit dem Spiel.

**Ausprobieren:** Schalte den Spielmodus ein, starte ein Spiel und bewege die Maus in eine Bildschirmecke. Nichts springt auf.

---

## <a id="v1.30.7"></a>Dein Haustier bleibt aus deinem Video raus

<sub>1.30.7 · 10. Oktober 2026</sub>

Ist dein Haustier oder sein Ball hinter einem Fenster, bleibt es dort, auch wenn es springt oder fliegt.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Früher konnte ein Sprung oder Flug dein Haustier oder seinen Ball genau über das holen, was du gerade schaust, obwohl sie sich hinter einem Video oder Spiel versteckt hatten. Auch die Leertaste zum Anhalten eines Videos hat dein Haustier hervorgelockt.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Jetzt bleiben sie hinter dem Fenster, das sie verdeckt, egal was sie tun. Und ein Vollbild-Video in Firefox versteckt sie sofort.

Hinter normalen Fenstern verschwinden sie weiterhin genau wie früher.

**Ausprobieren:** Spiel ein Video in einem großen Fenster ab, das den unteren Bildschirmrand verdeckt, und drück die Leertaste zum Anhalten. Dein Haustier bleibt hinter dem Video.

---

## <a id="v1.30.6"></a>Im Vollbild macht dein Haustier überall Pause

<sub>1.30.6 · 10. Oktober 2026</sub>

Solange eine App im Vollbild läuft, verstecken sich dein Haustier und sein Ball jetzt auf allen Bildschirmen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Früher, wenn du ein Video oder Spiel im Vollbild geöffnet hast, sind dein Haustier und sein Ball manchmal auf einen anderen Bildschirm gelaufen und haben dort weitergespielt.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Jetzt verstecken sie sich auf all deinen Bildschirmen, solange irgendeine App im Vollbild läuft. Verlässt du das Vollbild, sind sie sofort wieder da.

Hinter normalen Fenstern verschwinden sie weiterhin genau wie früher.

**Ausprobieren:** Wenn du zwei Bildschirme hast, öffne auf einem davon ein Video im Vollbild. Dein Haustier und sein Ball verschwinden von beiden und kommen zurück, sobald du das Vollbild verlässt.

---

## <a id="v1.30.5"></a>Dein Haustier macht Platz, wenn du schaust oder spielst

<sub>1.30.5 · 10. Oktober 2026</sub>

Dein Haustier und sein Ball verstecken sich jetzt, solange eine App im Vollbild läuft, auch auf Macs mit Notch.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Früher konnte dein Haustier auf einem Mac mit Notch über einem Video oder Spiel im Vollbild bleiben, und der Ball tauchte manchmal über einer Vollbild-App auf einem anderen Bildschirm auf.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Jetzt warten dein Haustier und sein Ball außer Sicht, solange eine App den ganzen Bildschirm füllt. Verlässt du das Vollbild, sind sie sofort wieder da.

Hinter normalen Fenstern verschwinden sie weiterhin genau wie früher.

**Ausprobieren:** Öffne ein Video im Vollbild oder starte ein Spiel. Dein Haustier und sein Ball halten sich raus, bis du fertig bist.

---

## <a id="v1.30.4"></a>Dein Haustier bleibt sichtbar, wenn es springt oder auf einer Auswahl mitfährt

<sub>1.30.4 · 10. Oktober 2026</sub>

Dein Haustier und sein Ball verschwinden nicht mehr hinter Fenstern, solange sie in der Luft sind.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Wenn dein Haustier früher über den Zeiger sprang oder auf einem Auswahlrahmen nach oben fuhr, hat ein bildschirmfüllendes Fenster es verdeckt, und es sah so aus, als wäre es verschwunden.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Solange dein Haustier oder sein Ball jetzt höher als das Dock ist, siehst du sie vor deinen Fenstern. Zurück am Boden gehen sie wieder dahinter.

Und dein Haustier kann wieder hinter dem Dock laufen, genau wie früher.

**Ausprobieren:** Mach ein Fenster bildschirmfüllend, zieh auf dem Schreibtisch neben dem Dock einen Auswahlrahmen auf, damit dein Haustier hinaufklettert, und zieh ihn langsam nach oben. Dein Haustier fährt darauf vor dem Fenster mit.

---

## <a id="v1.30.3"></a>Dein Haustier und sein Ball bleiben nicht mehr unter dem Dock

<sub>1.30.3 · 9. Oktober 2026</sub>

Dein Haustier läuft und schläft nicht mehr unter dem Dock, du siehst es also immer.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Früher liefen und lagen dein Haustier und sein Ball oft direkt unter dem Dock, wo niemand sie sehen konnte. Bei einem bildschirmfüllenden Fenster sah es so aus, als wäre dein Haustier ganz verschwunden.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Jetzt ist das Dock für sie wie eine Wand. Dein Haustier dreht an seinem Rand um, und der Ball prallt davon ab.

So bleibt dein Haustier immer neben dem Dock sichtbar, auch wenn ein Fenster den ganzen Bildschirm füllt.

**Ausprobieren:** Mach ein Fenster bildschirmfüllend und schau ein paar Minuten zu. Dein Haustier ist immer links oder rechts vom Dock zu sehen.

---

## <a id="v1.30.2"></a>Dein Haustier verschwindet nicht mehr hinter Fenstern

<sub>1.30.2 · 9. Oktober 2026</sub>

Auch wenn ein Fenster dein Haustier verdeckt, lebt es weiter und fällt zu Boden, sobald du die Auswahl loslässt.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Wenn Fenster den ganzen Streifen bedeckten, auf dem dein Haustier lebt, hat pikapik es angehalten, und es konnte mitten in der Luft erstarren. Jetzt leben dein Haustier und sein Ball hinter dem Fenster weiter: Sie laufen, fallen und spielen. Nur das Zeichnen macht Pause.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Hebt ein Auswahlrahmen dein Haustier hinter einem Fenster hoch, fällt es herunter, sobald du loslässt, und du siehst es wieder am Dock.

Und ein Auswahlrahmen hebt dein Haustier nicht mehr höher als seinen Streifen.

**Ausprobieren:** Mach ein Fenster bildschirmfüllend, heb dein Haustier mit einem Auswahlrahmen dahinter hoch und lass los. Es fällt herunter und taucht am Dock auf.

---

## <a id="v1.30.1"></a>Auswahlrahmen auf dem Schreibtisch funktionieren wieder

<sub>1.30.1 · 9. Oktober 2026</sub>

Dein Haustier und sein Ball springen wieder auf Auswahlrahmen, und App-Listen leuchten nur noch für Apps auf.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Wenn das Dock oder eine Fernwartungs-App den ganzen Bildschirm bedeckte, bemerkte pikapik den Auswahlrahmen nicht, den du auf dem Schreibtisch aufziehst. Jetzt klappt das wieder, und dein Haustier und sein Ball springen darauf wie früher.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

App-Listen in den Einstellungen leuchten nur auf, wenn du eine App darüberziehst. Andere Dateien werden ignoriert: Es erscheint kein Rahmen und nichts Überflüssiges wird hinzugefügt. Ziehst du eine App zusammen mit anderen Dateien, wird nur die App hinzugefügt.

Und der Rahmen erlischt, sobald du die App loslässt oder den Zeiger wegbewegst.

**Ausprobieren:** Zieh auf dem Schreibtisch einen Auswahlrahmen auf und sieh zu, wie dein Haustier daraufspringt.

---

## <a id="v1.30.0"></a>Beenden schaltet pikapik nicht mehr aus

<sub>1.30.0 · 9. Oktober 2026</sub>

Aus Gewohnheit auf Beenden gedrückt? Tastenkürzel, „Wach bleiben“ und dein Haustier laufen trotzdem weiter.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/keep-awake-dark.png"><img src="../media/keep-awake-light.png" width="340" alt=""></picture>

Wenn du „Beenden“ wählst, ⌘Q drückst oder pikapik im Dock beendest, schließt es seine Fenster und blendet sein Symbol in der Menüleiste aus, arbeitet aber still im Hintergrund weiter: Tastenkürzel, „Wach bleiben“ und dein Haustier bleiben aktiv. Um das Symbol zurückzuholen, öffne pikapik einfach noch einmal.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Willst du wirklich beenden? Halte die Wahltaste (⌥) gedrückt und wähle „Beenden“, oder drücke ⌥⌘Q. Wenn pikapik zum ersten Mal in den Hintergrund geht, erklärt es, was passiert ist, und bietet dir an, es gleich ganz zu beenden.

Lieber wie früher? Schalte „Nach dem Beenden im Hintergrund weiterlaufen“ in Einstellungen › Allgemein aus. Updates, ein Sprachwechsel, Abmelden, Neustart und Ausschalten beenden pikapik immer vollständig, sie müssen also nie darauf warten.

**Ausprobieren:** Drücke ⌘Q und öffne pikapik dann erneut, um sein Symbol zurückzuholen.

---

## <a id="v1.29.1"></a>Dein Haustier läuft über alle Bildschirme

<sub>1.29.1 · 9. Oktober 2026</sub>

Mehr als ein Monitor? Dein Haustier und sein Ball sind jetzt überall, wo du hinschaust, und gehen nie verloren.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Am Rand eines Bildschirms geht dein Haustier einfach auf den nächsten weiter, und der Ball rollt hinterher. Du kannst das Haustier oder den Ball auch mit der Maus auf jeden Bildschirm tragen. Geht eine App in den Vollbildmodus, wechseln beide auf einen anderen Bildschirm, damit sie nicht stören. Und wenn du einen Monitor absteckst, kommen sie zum Hauptbildschirm zurück.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Der Ball bleibt nicht mehr in einer Ecke hängen. Dein Haustier läuft hin, schaufelt ihn über den Kopf zurück und spielt weiter.

Und dein Haustier verschwindet nicht mehr. Alle zwei Sekunden prüft es, ob es noch auf dem Bildschirm ist. Lief etwas schief, nach dem Ruhezustand, dem Sperren des Mac, einem Schreibtischwechsel oder dem Vollbildmodus, kommt es von selbst sofort zurück.

**Ausprobieren:** Trag dein Haustier auf einen anderen Bildschirm oder roll den Ball in eine Ecke.

**Behoben**

- Ein geworfenes Haustier landet nicht mehr auf einem Auswahlrahmen, der höher ist, als es springen kann, und verschwindet dadurch nicht mehr.

---

## <a id="v1.29.0"></a>Dein Haustier hat einen Ball

<sub>1.29.0 · 9. Oktober 2026</sub>

Unten am Bildschirmrand rollt jetzt ein kleiner Fußball. Dein Haustier spielt damit, und du kannst mitspielen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Der Ball rollt und springt wie ein echter. Dein Haustier rennt hinterher, schießt ihn weg und jagt ihm wieder nach. Fahr mit dem Zeiger schnell gegen den Ball, um ihn selbst zu schießen, oder heb ihn auf, trag ihn herum und wirf ihn, genau wie das Haustier.

Ein kleiner Trick: Klick auf eine freie Stelle des Schreibtischs und zieh einen Auswahlrahmen auf, mit oder ohne Shift. Solange du die Maustaste hältst, wird der Rahmen zum Regalbrett: Dein Haustier springt hinauf, und auch der Ball kann darauf landen. Lass los, und das Brett ist wieder weg.

Lieber Ruhe auf dem Schreibtisch? Schalte Ball in den Haustier-Einstellungen aus, dann spaziert dein Haustier wieder für sich allein.

**Ausprobieren:** Einstellungen › Haustier › Ball

**Behoben**

- Neben dem Dock springt das Haustier wieder so hoch, wie es will. Nur direkt über dem Dock bleibt es unten, damit es nie darüber hinausschaut.

---

## <a id="v1.28.0"></a>Apps mit einem Klick oder per Ziehen hinzufügen

<sub>1.28.0 · 9. Oktober 2026</sub>

Jede App-Liste in den Einstellungen zeigt jetzt, was im Dock liegt und gerade geöffnet ist, und du kannst Apps einfach aus dem Finder darauf ziehen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Bei manchen Funktionen kannst du Apps auswählen, in denen sie sich zurückhalten, etwa beim grünen Knopf oder bei Home und Ende. Bisher öffnete „App hinzufügen …“ nur einen langen Ordner mit allem. Jetzt erscheint ein Regal mit den Apps aus deinem Dock und denen, die gerade offen sind. Klick auf eine App, und sie ist dabei; klick noch einmal, und sie ist wieder weg. Für alles andere gibt es „Andere …“.

Du kannst eine App auch direkt aus dem Finder auf eine Liste ziehen. Die Liste leuchtet auf und zeigt, wo die App landet. Bei deinen Spielen geht das genauso, mit demselben Regal.

Und falls etwas schiefgeht: Im Formular für Fehlermeldungen auf GitHub wählst du deine pikapik-Version und macOS jetzt aus einer Liste. So erzählst du uns schneller davon.

**Ausprobieren:** Einstellungen › Fenster, dann „App hinzufügen …“

**Behoben**

- Scrollen über AnyDesk oder eine andere Fernsteuerungs-App wird nicht mehr doppelt umgedreht, wenn auf beiden Macs die klassische Richtung eingestellt ist. pikapik dreht jetzt nur noch das Scrollen einer echten Maus oder eines Trackpads um. Wenn eine App selbst weich scrollt, wie Mos, stell die Richtung dort ein.
- Das Haustier bleibt beim Springen hinter dem Dock, genau wie beim Laufen, und kommt von selbst zurück, wenn du eine Vollbild-App oder ein Spiel verlässt.
- Die feinen Rahmen um die kleinen Bilder in den Einstellungen verschwinden auf normalen Bildschirmen ohne Retina nicht mehr.

---

## <a id="v1.27.3"></a>Das Haustier bleibt in Sicht, und Fenster öffnen sich bereit

<sub>1.27.3 · 9. Oktober 2026</sub>

Das Haustier verschwindet mitten im Sprung nicht mehr hinter Fenstern, und die Fenster von pikapik öffnen sich gleich einsatzbereit.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Wenn das Haustier über den Zeiger hüpfte oder einen Purzelbaum schlug, konnte es hinter die Fenster anderer Apps rutschen und mitten in der Luft verschwinden. Jetzt bleibt es den ganzen Sprung über vorne und geht nach der Landung wieder hinter deine Fenster.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Wenn pikapik still im Hintergrund startete, bei der Anmeldung, nach einem Update oder über einen pikapik://-Link, konnten seine Fenster grau aufgehen und hinter anderen Fenstern bleiben, bis du sie angeklickt hast. Jetzt kommen die Einstellungen und das Fenster „Neue Datei“ nach vorne, und du kannst sofort tippen.

Das gilt auch für die Meldung nach „Kleinere Kopie erstellen“ und für die Liste, in der du eine App zum Hinzufügen auswählst. Du musst nichts tun.

**Ausprobieren:** Einstellungen › Haustier

---

## <a id="v1.27.2"></a>Neue Datei ist zurück, und die Einstellungen sind noch leichter

<sub>1.27.2 · 9. Oktober 2026</sub>

Neue Datei steht für alle wieder im Kontextmenü des Finders, und die Einstellungen fordern deinen Mac noch weniger.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Nach dem letzten Update konnte der Finder Neue Datei im Hintergrund neu starten und dabei vergessen, in welchen Ordnern es arbeitet. Dann verschwand der Eintrag still aus dem Kontextmenü. Jetzt erinnert Neue Datei den Finder bei jedem Start an seine Ordner, und pikapik prüft kurz nach dem Start, ob der Finder es sich gemerkt hat. Du musst nichts tun.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Die bewegten Bilder in den Einstellungen laufen jetzt nur, solange mindestens die Hälfte eines Bildes zu sehen ist. In den Spielbildern bewegt sich der kleine Held weiterhin 30-mal pro Sekunde, die Hügel und der Boden dahinter 15-mal. So fordert die Seite Spiele deinen Mac viel weniger. Alles sieht aus wie vorher.

Nach einem Update fügt pikapik seine Finder-Einträge nur noch neu hinzu, wenn die App wirklich umgezogen ist. So muss der Finder sie nicht jedes Mal neu laden.

**Ausprobieren:** Einstellungen › Spiele

---

## <a id="v1.27.1"></a>Leiser, leichter, und der Finder ist sofort bereit

<sub>1.27.1 · 9. Oktober 2026</sub>

Die Einstellungen belasten deinen Mac kaum noch, und die Rechtsklick-Befehle im Finder funktionieren gleich nach dem Umzug zu pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/wheel-lines-dark.png"><img src="../media/wheel-lines-light.png" width="340" alt=""></picture>

Die kleinen bewegten Bilder in den Einstellungen haben früher die ganze Seite viele Male pro Sekunde neu gezeichnet, ein offenes Fenster hielt deinen Mac also beschäftigt. Jetzt zeichnet jedes Bild nur sich selbst neu, höchstens 30-mal pro Sekunde, und ruht, wenn du daran vorbeiscrollst oder das Fenster ausblendest. Sie sehen genauso aus wie vorher.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Nach dem Umzug von pika-tools zu pikapik konnte der Finder weiter nach der alten App suchen, und „Neue Datei“, „Umwandeln in“ und die anderen Rechtsklick-Befehle taten nichts. pikapik bemerkt das jetzt beim ersten Start und startet den Finder selbst neu, wenn keine Finder-Fenster offen sind und nichts kopiert wird. Sonst bietet eine kurze Zeile auf der Finder-Seite die Taste „Finder neu starten“ an.

In den Systemeinstellungen, bei den Apps, die beim Anmelden öffnen, steht jetzt der neue Name pikapik, und die App bleibt eingeschaltet.

**Ausprobieren:** Einstellungen › Finder

---

## <a id="v1.27.0"></a>Darf ich vorstellen: dein Haustier auf dem Schreibtisch

<sub>1.27.0 · 9. Oktober 2026</sub>

Unten auf deinem Bildschirm wohnt jetzt ein kleiner Freund, und die App hat einen neuen Namen: pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Schalte es unter Einstellungen › Haustier ein. Es spaziert hinter deinen Fenstern und dem Dock, springt über den Zeiger, wenn er im Weg ist, und hüpft, wenn du die Leertaste drückst. Du kannst es hochheben, tragen, werfen und mitten im Sprung wieder auffangen.

Ab und zu setzt es sich hin und sagt etwas Kurzes. Wenn wirklich eine neue Version erscheint, sagt es dir das einmal, und ein Klick darauf öffnet die Einstellungen, wo das Update wartet.

pika-tools heißt jetzt pikapik. Deine Berechtigungen, Einstellungen und Links in Kurzbefehle bleiben, wie sie waren. Wenn du die App mit Homebrew installiert hast, führe einmal `brew update && brew upgrade --cask pikapik` aus.

**Ausprobieren:** Einstellungen › Haustier

**Behoben**

- Die Update-Prüfung meldete eine neue Version, obwohl du schon die neueste hattest.
- Die Seite Berechtigungen hat deinen Mac beschäftigt, solange sie offen war.

---

## <a id="v1.26.2"></a>Neuerungen in deiner Sprache

<sub>1.26.2 · 8. Oktober 2026</sub>

„Neuerungen“ in den Einstellungen öffnet jetzt diese Seite, in derselben Sprache wie die App.

<img src="../media/icon.png" width="128" height="128" alt="">

Öffne Einstellungen › Über und klicke auf „Neuerungen“. Du landest genau hier, auf der Seite mit einem Bild zu jedem Update, in der Sprache, die pikapik spricht.

Auch die vollständige Liste der Änderungen ist aufgeräumter. Jede Version zeigt den Tag, an dem sie erschienen ist, und jede Versionsnummer öffnet ihre Download-Seite.

An der Arbeitsweise von pikapik ändert sich nichts. Updates kommen wie bisher, von selbst oder über Homebrew.

**Ausprobieren:** Einstellungen › Über › Neuerungen

**Behoben**

- „Neuerungen“ öffnete statt dieser Seite eine lange technische Liste auf Englisch.
- Links in der Liste der Änderungen, die ins Leere führten, öffnen jetzt die richtige Seite.

---

## <a id="v1.26.1"></a>Die Spielbilder werden lebendig

<sub>1.26.1 · 8. Oktober 2026</sub>

Die Bilder auf der Seite „Spiele“ bewegen sich jetzt, und du siehst, was jeder Schalter stoppt.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.26.1/game-previews-dark.png"><img src="../media/whats-new/1.26.1/game-previews-light.png" width="340" alt=""></picture>

Hinter jedem Schalter auf der Seite „Spiele“ läuft jetzt ein kleines Spiel. Tasten erscheinen und werden gedrückt, und du siehst, was über dein Spiel springen würde, etwa Spotlight oder Mission Control, während das Spiel stehen bleibt. Ist der Schalter an, leuchten die Tasten nur sanft auf, und das Spiel läuft weiter. Leg einen Schalter um, und das Bild zeigt den Unterschied sofort.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Das kleine Spiel folgt dem Aussehen deines Mac: ein sonniger Tag im hellen Modus und eine ruhige Nacht mit Mond und Sternen im dunklen Modus.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

In allen Bildern der App bewegt sich der Zeiger jetzt wie eine Hand: Für weite Wege lässt er sich etwas mehr Zeit, kommt zur Ruhe und klickt erst dann. Beginnt ein Bild von vorn, gleitet es sanft zum Anfang zurück, statt zu springen. Ist das Fenster verdeckt, ruhen die Bilder, und mit „Bewegung reduzieren“ stehen sie still.

**Ausprobieren:** Einstellungen › Spiele

---

## <a id="v1.26.0"></a>Ein neues Symbol und reiner Tisch bei alten Berechtigungen

<sub>1.26.0 · 8. Oktober 2026</sub>

pikapik hat ein neues Gesicht und räumt jetzt die Berechtigungen auf, die gelöschte Apps zurücklassen.

<img src="../media/icon.png" width="128" height="128" alt="">

Das neue Symbol ist das pikapik-Zeichen in Blau, Violett und Koralle auf einer dunklen Kachel. Die Menüleiste zeigt dieselbe Form, und sie passt sich einer hellen oder dunklen Menüleiste an. Wenn alle Werkzeuge aus sind, wird die Form blass.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>

Wenn du eine App löschst, behält macOS die Berechtigungen, die du ihr gegeben hast, und in den Systemeinstellungen lassen sie sich nicht entfernen. Jetzt hat die Seite „Berechtigungen“ die Liste „Von gelöschten Apps übrig“: jede App mit ihrem Symbol, was sie durfte und wann. „Entfernen“ räumt eine App auf, „Alle entfernen“ alle auf einmal, und eine App, die du wieder installierst, fragt einfach neu. Damit du die Liste siehst, gib pikapik den Festplattenvollzugriff: Es schaut nur und ändert nichts, bis du auf „Entfernen“ klickst.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Die Bilder auf den Seiten „Animationen“ und „Spiele“ sind für ihre echte Größe neu gezeichnet und deshalb scharf. Ein Fenster schrumpft mit runden Ecken ins Dock, und der Zeiger klickt zuerst, erst dann öffnet sich ein Menü. Und unten in „Über“ steht jetzt eine leise Zeile: „Mit Liebe gemacht · Spendier mir einen Kaffee“. Nichts springt auf, nichts erinnert dich.

**Ausprobieren:** Einstellungen › Berechtigungen, dann „Von gelöschten Apps übrig“

**Behoben**

- Ein Klick auf einen Systemkurzbefehl öffnet genau seinen Bereich in den Systemeinstellungen, etwa Mission Control, und nicht nur „Tastatur“.
- Der Hinweis neben den Tasten verschwindet nicht mehr, sobald sich die Systemeinstellungen öffnen.

---

## <a id="v1.25.2"></a>Kurzbefehle öffnen sich dort, wo du sie änderst

<sub>1.25.2 · 8. Oktober 2026</sub>

Klicke in den Einstellungen auf einen Kurzbefehl, und die Systemeinstellungen öffnen sich an der richtigen Stelle.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Bisher führte ein Klick auf einen Kurzbefehl, etwa den für Spotlight, immer zu „Sondertasten“. Jetzt öffnen die Spotlight-Tasten direkt Spotlight.

Bei den anderen Kurzbefehlen öffnen sich die Systemeinstellungen bei „Tastatur“, und ein kurzer Hinweis neben den Tasten sagt dir, wo du klicken musst: „Tastaturkurzbefehle …“, dann „Mission Control“ oder ein anderer Bereich.

Das gilt auch für die Seite „Spiele“ und für „Dateien im Finder ausschneiden“. Beim Ausschneiden führt der Hinweis zu „App-Kurzbefehle“.

**Ausprobieren:** Einstellungen › Spiele, dann auf die Tasten neben „Die Suche springt nicht auf“ klicken

**Behoben**

- Ein Klick auf einen Kurzbefehl öffnet nicht mehr „Sondertasten“.

---

## <a id="v1.25.1"></a>Große Bilder und Spiele direkt aus dem Dock

<sub>1.25.1 · 8. Oktober 2026</sub>

Jeder Schalter hat jetzt ein großes Bild, und „Spiel hinzufügen …“ zeigt, was in deinem Dock ist.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

Auf den Seiten „Animationen“ und „Spiele“ sind alle Bilder jetzt groß, genau wie das Bild oben auf der Seite. So siehst du sofort, was jeder Schalter macht, und die Bilder bewegen sich weiter in dem Tempo, das du gewählt hast.

Klick auf „Spiel hinzufügen …“, und du siehst dein Dock: die Apps, die du dort behältst, und die, die gerade offen sind, in derselben Reihenfolge. Ein Spiel aus dem Dock ist auch dann da, wenn es geschlossen ist, Minecraft auch. Ein Klick fügt es hinzu, und ein Häkchen zeigt, dass es in der Liste ist. Klick noch einmal, um es wieder zu entfernen.

Du kannst ein Spiel weiterhin aus dem Finder hierher ziehen. Aus dem Dock musst du es nicht mehr herausziehen, also bietet das Dock auch nicht mehr an, es zu entfernen.

**Ausprobieren:** Einstellungen › Spiele, dann „Spiel hinzufügen …“

**Behoben**

- Ein Spiel, das im Dock liegt, aber geschlossen ist, erscheint jetzt in der Liste zum Hinzufügen.

---

## <a id="v1.25.0"></a>Ein Spiel mit einem Klick hinzufügen und eigene Tasten wählen

<sub>1.25.0 · 8. Oktober 2026</sub>

Wähl ein Spiel einfach aus dem, was gerade offen ist, und leg die Tasten zum Beenden und Schließen selbst fest.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

Klick auf „Spiel hinzufügen …“, und die gerade geöffneten Apps erscheinen mit großen Symbolen, wie im Dock. Ein Klick fügt ein Spiel hinzu, oder zieh sein Symbol in die Liste. Du kannst ein Spiel auch direkt aus dem Finder oder dem Dock ablegen. Jetzt kann jede App ein Spiel sein, sogar Minecraft, das mit Java läuft, und deine bisherigen Spiele bleiben erhalten.

Die Schalter im Spielmodus sprechen jetzt Klartext, etwa „Das Spiel schließt sich nicht“ oder „Die Suche springt nicht auf“, und jeder hat ein kleines Bild von dem, was er stoppt. Der Name im System, etwa Spotlight, steht grau daneben.

Klick unter Einstellungen › Fenster auf die Tasten neben „App beenden“ oder „Fenster schließen“ und drück neue. ⌫ holt ⇧⌘Q und ⇧⌘W zurück, und wenn die Tasten schon belegt sind, fragt pikapik zuerst nach. Der Spielmodus nutzt ebenfalls deine Tasten. Und jeder Kurzbefehl in den Einstellungen zeigt jetzt, wie er auf deinem Mac wirklich eingerichtet ist: deine Tasten oder „Aus“.

**Ausprobieren:** Einstellungen › Spiele, dann „Spiel hinzufügen …“

**Behoben**

- Das Ausschneiden von Dateien im Finder folgt dem Kurzbefehl für „Ausschneiden“, den du in den Systemeinstellungen für den Finder festgelegt hast.
- App-Namen in Listen erscheinen ohne „.app“.

---

## <a id="v1.24.1"></a>Mehr Tempo, das du sofort siehst

<sub>1.24.1 · 8. Oktober 2026</sub>

Die Seite „Animationen“ zeigt jetzt, wo eine Änderung ankommt, und schützt deine eigenen Werte.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

Das Dock fährt nur dann schneller ein und aus, wenn es sich ausblendet. Bleibt deins immer stehen, findest du den Schalter „Dock automatisch ein- und ausblenden“ jetzt direkt unter dem Tempo-Regler.

Nach einer Änderung sagt dir eine Zeile unten auf der Seite, dass Apps sie übernehmen, sobald du sie neu öffnest. Neues Tempo für Übersicht und Spalten zeigt der Finder erst nach einem Neustart, deshalb hat die Zeile eine Schaltfläche „Finder neu starten“.

Der Regler macht nie etwas langsamer, das du schon beschleunigt hattest, zum Beispiel mit Befehlen im Terminal. Und „Standard wiederherstellen“ oder das Deinstallieren von pikapik bringt deine vorherigen Werte zurück, statt sie zu löschen.

**Ausprobieren:** Einstellungen › Animationen

**Behoben**

- Das Dock startet nicht mehr grundlos neu, wenn es sich nicht ausblendet.

---

## <a id="v1.24.0"></a>Bestimm, wie schnell sich dein Mac bewegt

<sub>1.24.0 · 8. Oktober 2026</sub>

Auf der neuen Seite „Animationen“ legst du fest, wie schnell sich auf deinem Mac etwas öffnet, gleitet und erscheint.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Ein Regler reicht. Schieb ihn, und das ausgeblendete Dock, neue Fenster, Sichern-Dialoge, Übersicht und Spalten im Finder werden alle zusammen schneller, von „Wie in macOS“ bis „Sofort“.

Du willst nur eine Sache anpassen? Jeder Effekt hat seine eigene Einstellung, genau wie der Effekt beim Ablegen, hüpfende Symbole im Dock und Finder-Animationen. Neben jeder Einstellung bewegt sich ein kleines Bild genau in dem Tempo, das du gewählt hast.

„Standard wiederherstellen“ setzt nur zurück, was pikapik geändert hat, und beim Deinstallieren passiert dasselbe. Hast du einen dieser Werte früher selbst im Terminal gesetzt, zeigt pikapik ihn so, wie er ist.

**Ausprobieren:** Einstellungen › Animationen

---

## <a id="v1.23.2"></a>Ein Schalter für jeden Kurzbefehl im Spielmodus

<sub>1.23.2 · 8. Oktober 2026</sub>

Jetzt entscheidest du für jeden Kurzbefehl einzeln, was der Spielmodus beim Spielen stummschaltet.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Q und ⌘W haben jetzt eigene Schalter, genau wie Spotlight, Siri, ⌘Tab, Mission Control, Wischen, der Zeiger, der Bildschirm und alles andere. Deine bisherigen Einstellungen bleiben erhalten.

Jede Zeile zeigt genau die Tasten, die sie stoppt. So weißt du immer, was ein Schalter tut.

Die Einstellung für die Tastatursprache ist aus dem Spielmodus verschwunden. ⌃Leertaste und andere Wege, die Sprache zu wechseln, funktionieren immer, auch im Spiel.

**Ausprobieren:** Einstellungen › Spiele

**Behoben**

- Die Tasten eines Kurzbefehls stehen enger zusammen, und zwischen verschiedenen Kurzbefehlen ist etwas mehr Platz. So siehst du leicht, wo einer endet und der nächste beginnt.

---

## <a id="v1.23.1"></a>Wie schnell dein Internet ist, in einfachen Worten

<sub>1.23.1 · 8. Oktober 2026</sub>

Der Speedtest prüft deine Verbindung und sagt dir einfach, wofür sie reicht.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

Klick auf „Geschwindigkeit prüfen“, und nach etwa einer halben Minute siehst du Download, Upload, Ping und Reaktionsfähigkeit. Unter den Zahlen steht in einfachen Worten, ob es für 4K-Filme, Videoanrufe, Online-Spiele und große Downloads reicht.

Die Messung läuft über Server von Apple, und das letzte Ergebnis bleibt bis zur nächsten Messung stehen. Der Speedtest hat eine eigene Seite in den Einstellungen, eine Zeile im Feld der Menüleiste und einen Link für die App „Kurzbefehle“: `pikapik://speed-test`.

Der Spielmodus kann zwei neue Dinge. Das Blockieren von Ctrl-Kurzbefehlen gehört jetzt zu ihm: Im Spiel bleibt ⌃-Klick ein Klick und Kurzbefehle mit ⌃ lösen nichts aus, überall sonst funktioniert ⌃ wie gewohnt. Außerdem erkennt er Minecraft: Füg den Minecraft Launcher oder CurseForge zu deinen Spielen hinzu, und der Spielmodus schaltet sich ein, sobald Minecraft selbst vorne ist.

**Ausprobieren:** Einstellungen › Speedtest, dann „Geschwindigkeit prüfen“

**Behoben**

- Testversionen von pikapik, die man selbst baut, halten ihre Einstellungen in iCloud Drive getrennt und rühren deine nicht mehr an.

---

## <a id="v1.23.0"></a>Spielmodus: Spielen ohne Unterbrechung

<sub>1.23.0 · 7. Oktober 2026</sub>

Füg deine Spiele hinzu, und dein Mac reißt dich nicht mehr aus ihnen heraus.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Während du spielst, öffnen sich Spotlight, Siri, ⌘Tab, Mission Control und Wischen zwischen Schreibtischen nicht über dem Spiel. ⌘Q und ⌘W schließen es nicht aus Versehen, der Zeiger bleibt auf dem Bildschirm des Spiels, und der Bildschirm bleibt an.

Um ein Spiel zu verlassen, drück ⇧⌘Q, um sein Fenster zu schließen, ⇧⌘W. ⌥⌘Esc funktioniert immer. pikapik schlägt Spiele vor, die es auf deinem Mac findet. Der Spielmodus bleibt aus, bis du ihn einschaltest.

Bei „Wach bleiben“ wählst du jetzt, was der Bildschirm macht: anbleiben, ohne Bildschirmschoner und Sperrbildschirm, oder wie gewohnt ausgehen, während dein Mac weiterarbeitet. Die neue Schaltfläche „Display jetzt ausschalten“ macht ihn sofort dunkel; beweg die Maus oder drück eine Taste, und er ist wieder da.

**Ausprobieren:** Einstellungen › Spiele, dann „Spiel hinzufügen …“

**Behoben**

- Auf Macs ohne Deckel zeigt „Wach bleiben“ keine Optionen für den zugeklappten Deckel mehr.

---

<p align="center"><sub>Ältere Versionen findest du im <a href="../../CHANGELOG.md">Änderungsprotokoll</a> (auf Englisch).</sub></p>
