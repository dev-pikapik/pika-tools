# pika-tools

[English](../../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · **Română** · [Polski](README.pl.md) · [Türkçe](README.tr.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Čeština](README.cs.md) · [繁體中文](README.zh-Hant.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Tiếng Việt](README.vi.md) · [ไทย](README.th.md)

[![Ultima versiune](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![Licență: MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](../../LICENSE)
[![Descărcări](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

O aplicație mică pentru bara de meniu din macOS, care îmbunătățește tastele, ferestrele și Dock-ul: blochează scurtăturile cu Control, protejează ⌘Q și ⌘W, schimbă limba cu Opțiune+Shift, așa cum funcționează Alt+Shift pe Windows, repetă tasta ținută apăsată ca pe Windows, dezactivează accelerarea mausului, derulează rotița mausului pe rânduri ca pe Windows, face ca butoanele laterale ale mausului să meargă înapoi și înainte, închide aplicațiile când le închizi ultima fereastră, ascunde o aplicație cu un clic în Dock și ține Mac-ul treaz.

## Instalare

Cu [Homebrew](https://brew.sh):

```bash
brew install --cask dev-pikapik/pika-tools/pika-tools && open -a pika-tools
```

Fără Homebrew, deschide Terminal, lipește această linie și apasă Retur:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

Sau descarcă [pika-tools.dmg](https://github.com/dev-pikapik/pika-tools/releases/latest/download/pika-tools.dmg), deschide-l și trage aplicația în dosarul Aplicații.

Atât Homebrew, cât și scriptul pun aplicația în `/Applications`, o pornesc, cer permisiunile și activează deschiderea la autentificare. După aceea, aplicația se actualizează singură, vezi [Actualizări](#actualizări). Pentru a o elimina, vezi [Dezinstalare](#dezinstalare).

## Prima pornire

pika-tools are nevoie de două permisiuni. La prima pornire, deschide configurările pe pagina Permisiuni, care te ghidează pas cu pas, iar macOS afișează propriile solicitări. Mergi la **Configurări sistem › Confidențialitate și securitate** și activează pika-tools în:

- **Accesibilitate**, ca aplicația să poată modifica o apăsare de tastă sau un clic înainte să ajungă la alte aplicații.
- **Monitorizare intrare**, ca aplicația să poată vedea apăsările de taste și clicurile.

Aplicația observă schimbarea în câteva secunde, fără repornire.

pika-tools nu înregistrează, nu păstrează și nu trimite nimic din ce tastezi sau pe ce dai clic. Evenimentele sunt procesate în memorie și transmise imediat mai departe. Singura cerere în rețea este verificarea actualizărilor, care întreabă GitHub care este cea mai nouă versiune.

## Funcționalități

**Blocarea scurtăturilor cu Control.** Control devine o tastă obișnuită. Aplicațiile văd în continuare că este apăsată, dar macOS nu o mai transformă în scurtături: Control+Spațiu nu schimbă sursa de introducere, Control+săgeți nu schimbă spațiul de lucru, iar Control-clic este un clic normal în loc de un meniu contextual. Clicul secundar și atingerea cu două degete funcționează ca de obicei. Util în jocuri și în sesiunile de desktop la distanță, unde Control are propriul rol.

**Protejarea ⌘Q și ⌘W.** ⌘Q și ⌘W singure nu fac nimic, așa că nu închizi din greșeală o aplicație sau o fereastră. Adaugă Shift ca să o faci intenționat: ⇧⌘Q închide aplicația, ⇧⌘W închide fereastra. Funcționează în toate aplicațiile. Fiecare tastă are propriul comutator. Dezactivat implicit.

**Schimbarea limbii cu Opțiune+Shift.** Ține apăsat Opțiune și atinge Shift: macOS trece la următoarea sursă de introducere. Ține în continuare Opțiune și atinge din nou Shift ca să mergi mai departe. Ține apăsat Shift și atinge Opțiune ca să revii. Dacă între timp apeși altă tastă, dai clic sau adaugi Comandă, Control sau Fn, limba nu se schimbă, așa că scurtături precum Opțiune+Shift+săgeată funcționează ca înainte. Dezactivat implicit.

**Repetă tasta ținută apăsată.** Ține apăsată o tastă și litera se scrie din nou și din nou, ca pe Windows, în loc să apară meniul cu accente. Util în jocuri și când scrii. Aplicațiile deja deschise preiau asta după repornire. Dacă o dezactivezi, macOS se poartă din nou ca de obicei. Dezactivat implicit.

**Dezactivează accelerarea cursorului.** Cursorul se mișcă exact cât mausul, oricât de repede l-ai mișca, ca în LinearMouse. Un glisor **Viteză urmărire** stabilește cât de repede merge. Funcționează doar cu mausuri, trackpadul rămâne cum este. Dezactiveaz-o sau închide pika-tools, iar macOS își recapătă propriile setări. Dezactivat implicit.

**Derulare pe rânduri.** Fiecare clic al rotiței mausului derulează același număr de rânduri, oricât de repede o rotești, ca pe Windows. Alege de la 1 la 10 rânduri per clic, implicit 3. Derularea naturală rămâne așa cum ai setat-o în Configurări sistem. Funcționează doar pentru mausuri, trackpadul rămâne cum este. Dezactivat implicit.

**Butoanele laterale merg înapoi și înainte.** Butoanele 4 și 5 ale mausului merg înapoi și înainte în Safari, Finder și alte aplicații Apple, în Firefox, Opera și ForkLift, la fel ca o glisare pe trackpad. Alte aplicații, precum mediile JetBrains, primesc butoanele așa cum sunt și le tratează în felul lor. Dacă mausul tău le are invers, activează **Inversează butoanele laterale**. Dezactivat implicit.

**Ieșire la închiderea ultimei ferestre.** Închide ultima fereastră a unei aplicații, iar aplicația se închide, ca pe Windows. Finder rămâne deschis, la fel ca aplicațiile cu ferestre pe alte spații de lucru sau în Dock. Poți face o listă de aplicații care nu trebuie să se închidă niciodată așa. Dezactivat implicit.

**Ascundere cu un clic în Dock.** Dă clic pe pictograma din Dock a aplicației în care lucrezi și aceasta se ascunde. Dă clic din nou ca s-o readuci. Dezactivat implicit.

Fiecare instrument are propriul comutator în meniu și în configurări. Ai nevoie din nou de Control+C obișnuit? Dezactivează instrumentul respectiv.

Pictograma din bara de meniu arată starea dintr-o privire: o săgeată cu un clic când instrumentele funcționează, o săgeată tăiată când totul este dezactivat și un triunghi de avertizare când un instrument este activat, dar lipsesc permisiuni.

Aplicația folosește limba sistemului sau pe cea aleasă în configurări. Sunt disponibile toate cele 23 de limbi din lista de la începutul acestei pagini.

## Rămâi treaz

Împiedică Mac-ul să intre în repaus cât timp nu ești la tastatură: pentru orice durată între 1 minut și 12 luni sau până când îl dezactivezi. Activează-l din meniu și setează durata în configurări în minute, ore, zile, săptămâni sau luni. Meniul arată cât timp a mai rămas și când se termină. **Păstrează ecranul aprins** împiedică și întunecarea ecranului. Dacă închizi pika-tools, se oprește și Rămâi treaz.

Pe un MacBook poți activa și **Funcționează cu capacul închis**. macOS nu are o opțiune pentru asta, așa că pika-tools rulează `pmset -a disablesleep 1` și cere o parolă de administrator: doar un administrator poate schimba modul în care Mac-ul intră în repaus. Configurarea revine singură la normal când se termină Rămâi treaz, când închizi aplicația sau dacă aceasta se blochează. Dacă nu introduci parola, nu se schimbă nimic. Asigură-te că Mac-ul are o ventilație bună cu capacul închis. **Oprește când bateria scade sub 20%** încheie sesiunea înainte să se descarce bateria.

## Configurări

Deschide configurările din meniu cu **Configurări…** sau ⌘, ori pornește din nou pika-tools din Finder, Launchpad sau Spotlight. Cât timp fereastra este deschisă, aplicația apare în Dock și în ⌘Tab.

- **General**: deschidere la autentificare, aspect (Sistem, Luminos sau Întunecat), limbă, actualizări și copie de siguranță: exportă și importă configurările ca fișier sau sincronizează-le prin iCloud Drive.
- **Tastatură**: scurtături cu Control, ⌘Q și ⌘W, schimbarea limbii.
- **Maus**: accelerarea cursorului și viteza de urmărire, derularea pe rânduri, butoanele laterale.
- **Ferestre și aplicații**: ieșire la ultima fereastră, cu o listă de excepții, și ascundere cu un clic în Dock.
- **Rămâi treaz**: durată, opțiuni pentru ecran și capac.
- **Permisiuni**: starea ambelor permisiuni și a iCloud Drive când sincronizarea este pornită, cu butoane care deschid locul potrivit din Configurări sistem.
- **Despre**: versiune, linkuri către lista de modificări și pentru raportarea unei probleme.

Fiecare pagină are jos un buton **Restaurează valorile implicite…**. Întreabă mai întâi, apoi dezactivează instrumentele de pe pagina respectivă și le readuce opțiunile, ca și cum pika-tools nu le-ar fi atins niciodată.

**Sincronizează configurările cu iCloud** ține pika-tools la fel pe toate Mac-urile tale. Configurările stau în folderul pika-tools din iCloud Drive, iar cea mai recentă modificare câștigă. Este dezactivat implicit și are nevoie de iCloud Drive pornit. Permisiunile nu se sincronizează: fiecare Mac le cere separat.

## Actualizări

pika-tools caută versiuni noi la pornire și la fiecare 6 ore. Poți dezactiva asta în Configurări › General. Când apare o versiune nouă, în meniu apare butonul **Actualizează la …**: un clic, iar aplicația descarcă actualizarea, o instalează și repornește. Poți verifica și manual cu **Verifică acum** în Configurări › General.

Cu Homebrew poți rula și `brew upgrade --cask pika-tools`.

Începând cu versiunea 1.3, permisiunile rămân valabile după actualizări.

## Dezinstalare

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

Dacă ai instalat cu Homebrew: `brew uninstall --cask --zap pika-tools`.

Ambele închid aplicația, o scot din articolele de autentificare și o șterg. Scriptul îi resetează și permisiunile.

## Întrebări frecvente

**De ce are nevoie de două permisiuni?**
macOS împarte accesul la tastatură și mouse în două. Monitorizarea intrării îi permite aplicației să vadă evenimentele, iar Accesibilitatea îi permite să le modifice. Pentru a bloca o scurtătură e nevoie de amândouă.

**macOS spune că aplicația provine de la un dezvoltator neidentificat.**
pika-tools este semnată, dar nu este notarizată de Apple. Homebrew și scriptul de instalare se ocupă de asta în locul tău. Dacă ai folosit dmg-ul, deschide **Configurări sistem › Confidențialitate și securitate** și dă clic pe **Deschide oricum** sau rulează:

```bash
xattr -dr com.apple.quarantine /Applications/pika-tools.app
```

**Funcționează pe Mac-uri cu Intel?**
Da. Este o aplicație universală pentru Apple Silicon și Intel, cu macOS 14 Sonoma sau mai nou.

**Permisiunea este activată, dar nu funcționează nimic.**
În **Configurări sistem › Confidențialitate și securitate**, elimină pika-tools din ambele liste cu butonul −, apoi adaug-o din nou. Pagina Permisiuni din configurările pika-tools are butoane care deschid locul potrivit.

## Contribuții

Compilarea din codul sursă și publicarea versiunilor sunt descrise în [CONTRIBUTING.md](../../CONTRIBUTING.md). Modificările sunt listate în [CHANGELOG.md](../../CHANGELOG.md).

## Licență

MIT, © 2026 pikapik. Vezi [LICENSE](../../LICENSE).
