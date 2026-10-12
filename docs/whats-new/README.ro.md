<p align="center"><a href="../readme/README.ro.md"><img src="../media/icon.png" width="96" height="96" alt="pikapik"></a></p>
<h1 align="center">Ce e nou în pikapik</h1>
<p align="center">Fiecare actualizare în câteva cuvinte și o imagine, cele mai noi primele.</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <b>Română</b> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.39.1"></a>Bara de titlu obișnuită în ferestrele pentru arhive

<sub>1.39.1 · 13 octombrie 2026</sub>

Ferestrele pentru arhive au din nou bara de titlu obișnuită din macOS, cu trei butoane rotunde în stânga.

Poți trage o fereastră de partea de sus, ca oriunde pe Mac. În fereastra pentru o arhivă nouă și în cea pentru parolă, butonul roșu închide fereastra fără să creeze sau să dezarhiveze ceva. Butoanele care nu au ce face într-o fereastră sunt gri. Fereastra care arată cum avansează o copie mai mică sau conversia unui fișier are acum aceleași butoane. Acum comutatorul „Deschide arhivele cu această aplicație” ține minte ce aplicație deschidea înainte fișierele ZIP și 7Z și i le dă înapoi când îl dezactivezi.

---

## <a id="v1.39.0"></a>Ferestre noi pentru arhive și parola scrisă de două ori

<sub>1.39.0 · 13 octombrie 2026</sub>

Când pui o parolă pe o arhivă nouă, acum o scrii de două ori, ca o greșeală de tastare să nu te lase fără acces la propriile fișiere.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.0/archive-password-dark.png"><img src="../media/whats-new/1.39.0/archive-password-light.png" width="340" alt=""></picture>

Sub câmpuri apare un rând verde când parolele se potrivesc sau unul roșu când nu, iar „Creează” așteaptă până când sunt la fel.

Toate ferestrele pentru arhive arată nou: o pictogramă mare, un singur comutator pentru parolă și un rând scurt care îți spune dacă numele fișierelor rămân vizibile, ca la ZIP, sau sunt ascunse și ele, ca la 7Z. Pe macOS 26 butoanele sunt din Liquid Glass.

Și instalarea e mai simplă: comanda din capul paginii pikapik de pe GitHub nu are nevoie de nimic altceva pe Mac-ul tău. Instalează pikapik doar dacă descărcarea e semnată de dezvoltator și a trecut verificarea Apple pentru programe rău intenționate.

---

## <a id="v1.38.2"></a>Actualizări mai sigure alături de versiunea din App Store

<sub>1.38.2 · 12 octombrie 2026</sub>

Dacă ai pe Mac și pikapik din App Store, versiunea de pe GitHub se actualizează acum pe loc și nu o atinge pe cea din App Store.

Înainte, dacă versiunea de pe GitHub avea încă numele vechi, pika-tools, și nu era instalată cu Homebrew, actualizarea nu se instala, se deschidea în schimb versiunea din App Store, iar deschiderea pikapik la autentificare era dezactivată.

---

## <a id="v1.38.1"></a>Un meniu Finder mai fiabil

<sub>1.38.1 · 12 octombrie 2026</sub>

Opțiunile pikapik din meniul de clic dreapta al Finder nu mai dispar la conectarea unui disc, la deschiderea unei imagini de disc, la trezirea Mac-ului din repaus sau la trecerea în Finder.

În cazuri rare, asistentul care le afișează se închidea exact în acel moment.

---

## <a id="v1.38.0"></a>Deschide și creează arhive în Finder

<sub>1.38.0 · 12 octombrie 2026</sub>

Noul „Arhive în Finder” deschide RAR și alte arhive pe care macOS nu le poate deschide și creează ZIP și 7Z din meniul de clic dreapta.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/archive-dark.png"><img src="../media/archive-light.png" width="340" alt=""></picture>

Deschide Setări › Finder și pornește „Arhive în Finder”. Fă clic dreapta pe o arhivă și alege „Extrage”, iar fișierele ei apar alături. Fă clic dreapta pe orice alt fișier sau folder și alege „Creează arhivă…” ca să obții un ZIP, 7Z, TAR.GZ sau TAR.XZ. ZIP și 7Z pot avea parolă, iar orice arhivă poate fi împărțită în părți, de exemplu de câte 15 MB pentru e-mail. Un ZIP făcut așa nu are fișiere de serviciu ascunse și păstrează lizibile numele în orice limbă.

pikapik deschide și ce nu poate deschide macOS: RAR, chiar împărțit în mai multe fișiere, 7Z cu parolă, ZIPX, CAB, LZH, ARJ, ZST, WIM și altele. Un dublu clic le deschide în pikapik. Numele fișierelor din ZIP-urile vechi, de exemplu în chirilică, japoneză sau chineză, ies lizibile. Comutatorul „Deschide arhivele cu această aplicație” face ca pikapik să preia și ZIP-urile, și 7Z-urile, iar TAR și GZ rămân la aplicația de arhive integrată, care le tratează deja bine.

O fereastră cere parola, „Oprește” anulează orice lucrare, iar dintr-o arhivă deteriorată pikapik scoate ce se mai poate citi. Te întreabă înainte să extragă o arhivă care ar ajunge la o dimensiune uriașă și blochează arhivele care încearcă să scrie în afara propriului folder. Nu există în versiunea din Mac App Store. Apasă Spațiu pe o arhivă ca să vezi ce conține.

---

## <a id="v1.37.3"></a>Eticheta FPS cere permisiunea în locul potrivit

<sub>1.37.3 · 12 octombrie 2026</sub>

Înregistrarea ecranului pentru eticheta FPS se permite acum pe pagina Permisiuni, laolaltă cu toate celelalte permisiuni.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Ca să numere cadrele unui joc, „Afișează FPS” poate avea nevoie de Înregistrare ecran. Înainte, pikapik o cerea chiar pe pagina Jocuri. Acum e la un loc cu toate celelalte permisiuni: când „Afișează FPS” are nevoie de ea, apare un rând „Înregistrare ecran” în Setări › Permisiuni, iar tu dai clic acolo pe „Permite”.

Pe pagina Jocuri vezi acum doar rândul obișnuit de sub comutator: „Are nevoie de o permisiune. Dă clic pentru a o permite.” Butonul lui „Permite” te duce direct la rândul „Înregistrare ecran”. Pornirea lui „Afișează FPS” nu mai scoate singură o întrebare, iar pikapik tot nu cere nimic în timp ce joci.

---

## <a id="v1.37.2"></a>Verificat de Apple

<sub>1.37.2 · 12 octombrie 2026</sub>

pikapik este acum semnat de un dezvoltator Apple verificat și controlat de Apple. De aceea macOS nu te mai avertizează la prima deschidere.

După această actualizare, macOS poate cere din nou permisiunile pe care i le-ai dat lui pikapik, de exemplu Accesibilitate, Monitorizare intrare sau Acces complet la disc. Permite-le încă o dată în Setări de sistem › Confidențialitate și securitate. Dacă folosești controlul ventilatoarelor, permite-l din nou în setările pikapik, iar macOS îți va cere parola o dată.

---

## <a id="v1.37.1"></a>Eticheta FPS ține pasul cu jocul tău

<sub>1.37.1 · 12 octombrie 2026</sub>

Mută fereastra jocului, iar eticheta FPS se mișcă acum odată cu ea.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Înainte, eticheta se alinia cu o fereastră în mișcare doar cam o dată pe secundă, așa că rămânea în urmă. Acum verifică fereastra la fiecare cadru al ecranului și nu întârzie niciodată mai mult de câteva miimi de secundă. Când fereastra stă pe loc, verifică mai rar, deci aproape nu-ți solicită Mac-ul cât joci. În plus, nu mai sare în alt loc când o parte din fereastră trece de marginea ecranului.

Dacă un joc liniștit, precum șahul, arată 0, totul e în regulă: astfel de jocuri desenează o imagine nouă doar când se mișcă ceva. Numărul crește cât timp o piesă alunecă și revine la 0 când tabla stă nemișcată.

---

## <a id="v1.37.0"></a>Vezi cât de fluid rulează jocul

<sub>1.37.0 · 12 octombrie 2026</sub>

Noua opțiune „Afișează FPS” pune un mic contor într-un colț al jocului, ca să vezi cât de fluid rulează.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Deschide Configurări › Jocuri și pornește „Afișează FPS”. Cât timp Modul Joc este pornit, o mică etichetă închisă la culoare, cu un număr, apare într-un colț al oricărui joc. FPS înseamnă cadre pe secundă: câte imagini desenează jocul în fiecare secundă, iar cu cât numărul e mai mare, cu atât jocul e mai fluid. Apasă pe un colț în imaginea de deasupra comutatorului ca să alegi unde stă eticheta.

Apăsările trec prin etichetă, iar ea urmează fereastra jocului. O liniuță înseamnă că primele cadre nu au ajuns încă, iar un 0 estompat înseamnă că jocul a încetat să deseneze. „Afișează FPS” e oprit până îl pornești.

Pe macOS 27, cele mai multe jocuri sunt numărate chiar de macOS, deci nu e nevoie de nicio permisiune. Câteva jocuri, mai ales cele vechi, pot fi numărate doar prin înregistrarea ecranului, iar atunci numărul nu poate depăși rata de reîmprospătare a ecranului. Pe macOS 14–26 și în versiunea din Mac App Store toate jocurile sunt numărate așa, de aceea, când pornești „Afișează FPS”, pikapik cere „Înregistrare ecran”. Nicio imagine nu e păstrată sau trimisă.

---

## <a id="v1.36.0"></a>Elimină aplicații fără griji

<sub>1.36.0 · 12 octombrie 2026</sub>

Noua funcție Eliminare aplicații scoate o aplicație cu toate fișierele ei și pune totul la loc dacă te răzgândești.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/uninstaller-dark.png"><img src="../media/uninstaller-light.png" width="340" alt=""></picture>

Deschide Configurări › Eliminare aplicații și alege o aplicație sau trage una peste imagine. pikapik arată tot ce păstrează aplicația pe Mac-ul tău, cu motivul pentru fiecare fișier. Fișierele care aparțin clar aplicației sunt bifate, iar cele care poate au legătură nu sunt. Apasă „Mută în Coș” și totul ajunge în Coș, așa că nimic nu se șterge definitiv.

Te-ai răzgândit? Apasă „Pune la loc” și totul revine unde a fost. Ultimele zece eliminări așteaptă la „Eliminate recent” cât timp fișierele lor sunt în Coș. „Resetează aplicația” păstrează aplicația și elimină doar datele ei salvate, setările și fișierele temporare, în caz că se poartă ciudat.

Ai mutat tu o aplicație în Coș? Pagina arată și aceste aplicații, cu fișierele rămase, iar un comutator poate oferi curățarea de fiecare dată când o aplicație ajunge în Coș. Nu se elimină nimic până nu alegi tu. Pentru a vedea tot, pagina are nevoie de Acces complet la disc.

---

## <a id="v1.35.0"></a>Îmbracă-ți animăluțul

<sub>1.35.0 · 12 octombrie 2026</sub>

Animăluțul tău are acum o garderobă, iar piese noi câștigi jucându-vă împreună.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.35.0/wardrobe-dark.png"><img src="../media/whats-new/1.35.0/wardrobe-light.png" width="340" alt=""></picture>

Deschide Configurări › Animăluț și alege ce poartă animăluțul: pălării, ochelari, fulare, tricouri, încălțăminte, pelerine și chiar aripi. Animăluțul le îmbracă pe loc. Câteva piese sunt gratuite, iar restul sunt premii care vin cât vă jucați împreună: ridică animăluțul și aruncă-l, dă cu piciorul în minge, uită-te cum urcă pe ferestre și vorbește sau pur și simplu ține-i companie zi de zi. Când câștigi un premiu, animăluțul îți spune.

Ținutele gata făcute îl îmbracă din cap până în picioare cu un singur clic: vrăjitor, pirat, astronaut, supererou, rege și altele. O ținută e gata când ai câștigat toate piesele ei.

Se păstrează doar numere simple, cum ar fi pașii, aruncările și zilele petrecute împreună. Ele rămân pe Mac-ul tău, nimic nu este trimis nicăieri, iar tu le poți șterge oricând din Configurări › Animăluț.

---

## <a id="v1.34.0"></a>Mouse și trackpad în jocuri

<sub>1.34.0 · 12 octombrie 2026</sub>

Glisările, ciupirile și colțurile active nu te mai scot din joc, la fel ca scurtăturile de tastatură.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.34.0/pointer-shortcuts-dark.png"><img src="../media/whats-new/1.34.0/pointer-shortcuts-light.png" width="340" alt=""></picture>

În Configurări › Jocuri › Mai multe configurări de joc există grupul „Mouse și trackpad”. Arată doar ce este activat în macOS pe Mac-ul tău, cu numele date de Apple și un desen mic pentru fiecare: scurtături pe un buton al mouse-ului, glisarea între desktopuri și aplicații pe tot ecranul, Mission Control și App Exposé, ciupirea pentru aplicații și îndepărtarea degetelor pentru desktop, glisarea de la marginea dreaptă pentru Centrul de notificări și fiecare colț activ cu acțiunea lui. Cât timp un joc este în prim-plan, acestea sunt oprite, așa că o glisare accidentală sau o atingere a unui colț al ecranului nu te scoate din joc. Gesturile din interiorul jocului continuă să funcționeze. Fiecare poate fi setat să funcționeze ca de obicei.

---

## <a id="v1.33.2"></a>Grupurile de scurtături se deschid instantaneu

<sub>1.33.2 · 11 octombrie 2026</sub>

Chiar și cel mai lung grup de scurtături de sistem se deschide imediat, iar fiecare rând are un nume clar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Înainte, fereastra de setări se bloca o clipă la deschiderea unui grup cu zeci de rânduri, pentru că toate rândurile și previzualizările lor animate erau construite deodată. Acum se construiesc doar rândurile vizibile și câteva din apropiere. Au dispărut și rândurile „Acțiune de sistem” urmate de un număr: Dictarea, Siri și tastele de luminozitate și zoom își arată numele real, iar acțiunile cărora macOS nu le dă un nume sunt ascunse, dar rămân în pauză în jocuri ca înainte.

---

## <a id="v1.33.1"></a>Grupurile de scurtături se deschid fără blocaje

<sub>1.33.1 · 11 octombrie 2026</sub>

Pagina Jocuri rămâne fluidă când se deschide o listă lungă de previzualizări.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Deschiderea unui grup de scurtături de tastatură ale sistemului bloca fereastra de setări până la trei secunde, pentru că fiecare rând cu previzualizarea lui era calculat de mai multe ori. Acum fiecare rând este calculat o singură dată, așa că grupurile se deschid aproape imediat.

---

## <a id="v1.33.0"></a>Toate permisiunile într-un singur loc

<sub>1.33.0 · 11 octombrie 2026</sub>

Setări › Permisiuni arată acum tot ce folosește pikapik și vă lasă să retrageți orice permisiune.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.33.0/permissions-dark.png"><img src="../media/whats-new/1.33.0/permissions-light.png" width="340" alt=""></picture>

Setări › Permisiuni arată acum fiecare permisiune pe care o folosește pikapik, de la Accesibilitate și Monitorizare introducere până la Controlul ventilatoarelor, Extensii Finder, iCloud Drive și Acces complet la disc. Fiecare rând spune într-o frază la ce servește, cu o bifă verde când e activă și o cruce portocalie când lipsește.

Fiecare rând are un singur buton: Permite când lipsește, Stinge când e activă. Așa puteți retrage orice permisiune chiar acolo, fără să căutați prin Setări de sistem. Pentru Accesibilitate și Monitorizare introducere, pikapik vă întreabă mai întâi și apoi repornește fără ele.

O unealtă care are nevoie de o permisiune pe care nu ați dat-o apare în gri. Faceți clic pe ea și se deschide Permisiuni cu rândul potrivit evidențiat, gata de un clic pe Permite.

**Încearcă:** Deschideți Setări › Permisiuni și priviți fiecare rând. Faceți clic pe o unealtă gri ca să ajungeți direct la permisiunea de care are nevoie.

---

## <a id="v1.32.2"></a>Instalare mai sigură, iar actualizările nu pierd niciodată aplicația

<sub>1.32.2 · 11 octombrie 2026</sub>

O serie de remedieri care fac instalarea, actualizarea și dezinstalarea mai sigure.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Asistentul ventilatoarelor se instalează acum mai atent și este verificat înainte de pornire. Dacă o actualizare nu poate fi copiată, pikapik-ul actual rămâne la locul lui. La dezinstalare se elimină și asistentul ventilatoarelor, iar setarea de repetare a tastelor, colțurile Dock și scurtăturile de sistem revin cum erau.

Tastele ținute apăsate nu se mai blochează când o unealtă repornește, iar dacă opriți „Repetă o tastă ținută apăsată”, vă recăpătați propria setare a meniului de accente. Animalul se odihnește cât ecranul e în repaus sau blocat, iar o copie a lui archive.tar.gz se numește acum archive 2.tar.gz.

---

## <a id="v1.32.1"></a>Viteza manuală a ventilatoarelor ține din prima încercare

<sub>1.32.1 · 11 octombrie 2026</sub>

Alegerea Manual la Ventilatoare nu mai revine la Auto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Uneori prima atingere pe Manual readucea ventilatoarele la Auto cu un avertisment de siguranță, iar abia a doua funcționa. Acum Manual rămâne din prima încercare.

Dacă un ventilator iese totuși singur din modul Manual, pikapik îl readuce cu adevărat la Auto, așa că ce vedeți corespunde mereu cu ce face Mac-ul dvs.

Nu trebuie să permiteți nimic din nou. Actualizați și funcționează.

**Încearcă:** Deschideți Setări › Ventilatoare și alegeți Manual.

---

## <a id="v1.32.0"></a>Vezi cât de repede se învârt ventilatoarele

<sub>1.32.0 · 11 octombrie 2026</sub>

O filă nouă, Ventilatoare, arată fiecare ventilator live și te lasă să alegi viteza.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Ventilatoarele au acum o filă a lor în Setări și un rând în meniu. Vezi în timp real cât de repede se învârte fiecare, iar alături se învârte un ventilator mic odată cu el.

Lasă pe Auto și Mac-ul decide singur, ca întotdeauna. Sau alege Manual și trage un singur glisor ca să setezi viteza dorită. Prima dată permiți o singură dată cu parola de administrator, și gata.

Este făcut să fie sigur. Ventilatoarele revin la Auto când închizi pikapik, când Mac-ul intră în repaus, dacă pikapik se oprește din cauza unei erori sau când Mac-ul se încălzește.

**Încearcă:** Deschide Setări › Ventilatoare și urmărește viteza. Alege Manual ca să încerci glisorul.

---

## <a id="v1.31.4"></a>Detalii când ai nevoie

<sub>1.31.4 · 11 octombrie 2026</sub>

O pagină de jocuri mai calmă și o singură căutare.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.4/game-choices-dark.png"><img src="../media/whats-new/1.31.4/game-choices-light.png" width="340" alt=""></picture>

Fiecare mod își explică efectul în lista derulantă. Când lista este închisă, pe pagină rămâne doar numele ales.

Descrierile care repetă numele acțiunii au fost eliminate. Informațiile suplimentare utile rămân.

Căutarea globală găsește acțiuni de sistem după nume, sens și taste. Un rezultat deschide și evidențiază setarea exactă.

**Încearcă:** Găsește o acțiune în căutarea globală și deschide lista modurilor sale.

---

## <a id="v1.31.3"></a>Un stil comun pentru setările de joc

<sub>1.31.3 · 11 octombrie 2026</sub>

Previzualizări uniforme și opțiuni mai clare.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.3/game-preview-dark.png"><img src="../media/whats-new/1.31.3/game-preview-light.png" width="340" alt=""></picture>

Fiecare scurtătură are acum aceeași previzualizare lată ca protecțiile jocului și celelalte pagini de setări. Dedesubt sunt descrierea, comenzile și explicația opțiunii alese.

«Urmează regulile modului de joc». O scurtătură rapidă schimbă limba fără meniu. Tastele de joc ținute apăsate împiedică schimbarea accidentală.

«Dezactivează în jocuri». Această acțiune macOS este dezactivată când jocul este în prim-plan. Când pleci, funcționează ca înainte. «Permite în jocuri». macOS execută acțiunea normal, chiar dacă deschide o fereastră sau mută focalizarea din joc.

**Încearcă:** Deschide setările suplimentare de joc, extinde comenzile sistemului și alege comportamentul unei acțiuni în timpul jocului.

---

## <a id="v1.31.2"></a>Setări de joc mai clare

<sub>1.31.2 · 11 octombrie 2026</sub>

Ajustează protecția și explorează scurtăturile Macului.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.2/game-settings-dark.png"><img src="../media/whats-new/1.31.2/game-settings-light.png" width="340" alt=""></picture>

Opt teme clare înlocuiesc folderele repetate. Fiecare titlu are un nume, o explicație, o pictogramă și un număr. Apasă oriunde pe rând pentru a-l deschide.

Fiecare acțiune își explică rolul lângă previzualizarea animată. Tastele actuale și comportamentul în joc au un rând separat. Căutarea găsește și descrierile.

Tastele neatribuite au un link clar către Configurări sistem. Protecțiile generale ale jocului sunt grupate separat, iar alegerile tale se păstrează.

**Încearcă:** Deschide Mai multe setări de joc, extinde o temă și compară descrierea unei acțiuni cu previzualizarea.

---

## <a id="v1.31.1"></a>Gesturi pentru limbă în jocuri

<sub>1.31.1 · 11 octombrie 2026</sub>

Simplu implicit, cu întregul catalog al sistemului când ai nevoie.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/input-switch-dark.png"><img src="../media/input-switch-light.png" width="340" alt=""></picture>

Gestul de schimbare a limbii din pikapik funcționează în joc chiar dacă scurtăturile de limbă din macOS nu sunt atribuite sau sunt dezactivate.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automat oprește acțiunile care deschid ferestre sau mută focalizarea. O scurtătură de limbă rapidă și intenționată schimbă sursa fără fereastra sistemului. Tastele de mișcare ținute au prioritate, astfel că alergarea și salturile nu schimbă limba accidental.

Fiecare acțiune se poate regla în catalogul cu căutare. Limba poate fi schimbată în fundal; alte acțiuni pot fi oprite sau permise normal. Alegerile se sincronizează. Alte aplicații care urmăresc tastele apar separat. Închiderea forțată rămâne disponibilă.

**Încearcă:** Ține ⌥ și apasă ⇧: limba următoare. Ține ⇧ și apasă ⌥: cea anterioară

---

## <a id="v1.31.0"></a>Modul Joc cunoaște scurtăturile Macului

<sub>1.31.0 · 11 octombrie 2026</sub>

Simplu implicit, cu întregul catalog al sistemului când ai nevoie.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Activează modul Joc și joacă. Configurările suplimentare au catalogul publicat de Mac, tastele actuale și o previzualizare animată pentru fiecare acțiune.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automat oprește acțiunile care deschid ferestre sau mută focalizarea. O scurtătură de limbă rapidă și intenționată schimbă sursa fără fereastra sistemului. Tastele de mișcare ținute au prioritate, astfel că alergarea și salturile nu schimbă limba accidental.

Fiecare acțiune se poate regla în catalogul cu căutare. Limba poate fi schimbată în fundal; alte acțiuni pot fi oprite sau permise normal. Alegerile se sincronizează. Alte aplicații care urmăresc tastele apar separat. Închiderea forțată rămâne disponibilă.

**Încearcă:** Deschide configurările suplimentare, caută o scurtătură de captură sau limbă și compară previzualizarea cu și fără protecție.

---

## <a id="v1.30.14"></a>Linkurile scurtăturilor se deschid fără blocare

<sub>1.30.14 · 11 octombrie 2026</sub>

Apăsarea unei scurtături oprite nu mai închide pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Pe pagina Jocuri poți apăsa pe o scurtătură chiar fără taste alocate. Configurări sistem se deschide în siguranță.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Înainte pikapik putea citi de două ori același rând care se schimba în timp ce se deschidea fereastra. Dacă textul dispărea între citiri, aplicația se bloca.

Fiecare rând este acum citit o dată. Textul lipsă este sărit. Corecția acoperă și linkurile scurtăturilor de pe alte pagini.

**Încearcă:** Apasă pe o scurtătură oprită pe pagina Jocuri.

---

## <a id="v1.30.13"></a>Ține Control apăsat și continuă jocul

<sub>1.30.13 · 10 octombrie 2026</sub>

Control nu mai lasă schimbarea limbii să ia tasta Spațiu din joc.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Ține Control pentru a alerga și apasă Spațiu pentru a sări. În modul Joc, schimbarea limbii cu Control+Spațiu sau Control+Option+Spațiu este oprită temporar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Și alte scurtături macOS cu Control, sau cu Shift și Option fără Command, sunt oprite temporar, inclusiv cele alese de tine. Apăsările, eliberările și tastele ținute ajung împreună la joc.

Gestul de limbă din pikapik și scurtăturile de ieșire cu modificatori de joc nu încurcă nici ele. Când ieși din joc, scurtăturile sistemului revin exact cum erau.

**Încearcă:** Ține Control, mișcă-te și apasă Spațiu de câteva ori. Apoi ieși din joc și schimbă limba ca de obicei.

---

## <a id="v1.30.12"></a>Trage jocul din Monitor activitate

<sub>1.30.12 · 10 octombrie 2026</sub>

Modul Joc acceptă procese trase din Monitor activitate.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Găsește procesul jocului și trage rândul pe Jocurile tale în Configurări → Jocuri.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Jocurile Java funcționează și fără o pictogramă obișnuită în Dock. Înainte, aceste rânduri erau ignorate fiindcă au numărul și numele procesului, nu un fișier.

Jocul rămâne salvat pentru pornirile viitoare. Minecraft apare cu numele său. Numărul și numele trebuie să corespundă unui proces deschis.

**Încearcă:** Trage rândul java al jocului Minecraft deschis pe Jocurile tale.

---

## <a id="v1.30.11"></a>Adaugă jocul cât timp rulează

<sub>1.30.11 · 10 octombrie 2026</sub>

Jocurile deschise apar acum primele când adaugi un joc.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Deschide Configurări → Jocuri → Adaugă un joc și apasă pe jocul pornit. Apar și jocurile care folosesc Java sau alte medii, chiar fără un fișier .app. Minecraft apare ca Minecraft, nu java.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Aplicațiile din Dock au acum o listă separată, care se poate extinde, ca să găsești imediat jocul deschis.

Altele… și tragerea fișierelor acceptă și fișierul executabil al jocului, pe lângă aplicații. După adăugare, modul Joc se activează când treci la joc.

**Încearcă:** Lasă jocul deschis, alege Adaugă un joc și apasă pe pictogramă. Nu mai cauți prin dosare.

---

## <a id="v1.30.10"></a>Animăluțul rămâne la vedere când sare

<sub>1.30.10 · 10 octombrie 2026</sub>

Animăluțul nu mai dispare în spatele ferestrelor când sare pe un ecran fără Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Înainte, dacă Dock-ul era pe alt ecran sau ascuns, animăluțul sărea în spatele ferestrelor și dispărea până ateriza. Acum, imediat ce se desprinde de pământ, apare în fața ferestrelor pe orice ecran, cu sau fără Dock. La fel și mingea.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

O fereastră care doar atinge marginea animăluțului nu-l mai ascunde când sare. Rămâne în spatele unei ferestre doar când fereastra chiar îl acoperă, ca un video pe care îl urmărești.

Pe pământ, animăluțul și mingea lui se plimbă în spatele ferestrelor, ca înainte.

**Încearcă:** Lasă Dock-ul să se ascundă sau mută-l pe alt ecran, apoi apasă Spațiu lângă o fereastră. Animăluțul sare în fața ei.

---

## <a id="v1.30.9"></a>Ecranul complet e al tău, iar mingea joacă cinstit

<sub>1.30.9 · 10 octombrie 2026</sub>

Animăluțul nu mai apare într-un video pe tot ecranul, iar mingea nu se mai lovește de lucruri care nu există.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Înainte, cât te uitai la un video pe tot ecranul, animăluțul mai apărea din când în când. Acum pikapik întreabă direct macOS dacă pe un ecran e deschis ceva pe tot ecranul și mai verifică o dată după ce trecerea se termină. Animăluțul și mingea rămân ascunse până ieși din ecranul complet.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Mingea nu mai ricoșează din aer. Zboară peste Dock în loc să se lovească de un perete invizibil. Mouse-ul lovește acum mingea doar când cursorul o atinge cu adevărat. O atingere ușoară o rostogolește, o mișcare rapidă o trimite în zbor. Iar dacă animăluțul sau mingea se ascund după o fereastră, mouse-ul de deasupra ferestrei îi lasă în pace.

Când tragi un fișier pe desktop, animăluțul nu mai primește o treaptă. Doar un cadru de selecție face asta.

**Încearcă:** Uită-te la un video pe tot ecranul și pune-l pe pauză de câteva ori cu tasta Space. Animăluțul nu apare. Apoi lovește mingea cu o mișcare de mouse.

---

## <a id="v1.30.8"></a>Colțurile ecranului stau liniștite cât joci

<sub>1.30.8 · 10 octombrie 2026</sub>

În Modul Joc, mouse-ul la marginile și în colțurile ecranului nu mai pornește colțurile active și nu mai scoate Dock-ul ascuns.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Înainte, în mijlocul jocului, mouse-ul într-un colț sau la marginea ecranului putea porni un colț activ sau scotea Dock-ul ascuns.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Acum Modul Joc oprește colțurile active și Dock-ul ascuns cât joci. La câteva secunde după ce ieși din joc, sau când închizi pikapik, revin exact cum erau.

Iar cursorul nu se mai poticnește la marginea ecranului cu jocul.

**Încearcă:** Pornește Modul Joc, deschide un joc și du mouse-ul într-un colț al ecranului. Nu apare nimic.

---

## <a id="v1.30.7"></a>Animăluțul nu-ți mai intră în video

<sub>1.30.7 · 10 octombrie 2026</sub>

Când animăluțul sau mingea sunt în spatele unei ferestre, rămân acolo chiar și când sar sau zboară.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Înainte, dacă animăluțul sau mingea se ascundeau în spatele unui video sau joc, o săritură sau un zbor îi putea scoate chiar peste ce te uitai. Și tasta Spațiu pentru pauză scotea animăluțul la vedere.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Acum rămân în spatele ferestrei care îi acoperă, orice ar face. Iar un video pe tot ecranul în Firefox îi ascunde imediat.

În spatele ferestrelor obișnuite se ascund la fel ca înainte.

**Încearcă:** Pornește un video într-o fereastră mare care acoperă partea de jos a ecranului și apasă Spațiu ca să-l pui pe pauză. Animăluțul rămâne în spatele videoului.

---

## <a id="v1.30.6"></a>Pe tot ecranul, animăluțul ia o pauză peste tot

<sub>1.30.6 · 10 octombrie 2026</sub>

Cât orice aplicație e pe tot ecranul, animăluțul și mingea se ascund acum pe toate monitoarele.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Înainte, când deschideai un video sau un joc pe tot ecranul, animăluțul și mingea fugeau uneori pe alt monitor și se jucau acolo.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Acum, cât orice aplicație e pe tot ecranul, se ascund pe toate monitoarele tale. Ieși din ecranul complet și se întorc imediat.

În spatele ferestrelor obișnuite se ascund la fel ca înainte.

**Încearcă:** Dacă ai două monitoare, pune un video pe tot ecranul pe unul dintre ele. Animăluțul și mingea dispar de pe amândouă și se întorc când ieși din ecranul complet.

---

## <a id="v1.30.5"></a>Animăluțul se dă la o parte cât te uiți sau joci

<sub>1.30.5 · 10 octombrie 2026</sub>

Animăluțul și mingea se ascund acum cât o aplicație e pe tot ecranul, inclusiv pe Mac-urile cu notch.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Înainte, pe un Mac cu notch, animăluțul putea rămâne deasupra unui video sau joc pe tot ecranul, iar mingea apărea uneori peste o aplicație pe tot ecranul de pe alt monitor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Acum, cât o aplicație umple tot ecranul, animăluțul și mingea așteaptă deoparte. Ieși din ecranul complet și se întorc imediat.

În spatele ferestrelor obișnuite se ascund la fel ca înainte.

**Încearcă:** Pune un video pe tot ecranul sau pornește un joc. Animăluțul și mingea nu te deranjează până termini.

---

## <a id="v1.30.4"></a>Animăluțul rămâne la vedere când sare sau urcă pe o selecție

<sub>1.30.4 · 10 octombrie 2026</sub>

Animăluțul și mingea nu mai dispar în spatele ferestrelor cât timp sunt în aer.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Înainte, când animăluțul sărea peste cursor sau urca pe un chenar de selecție, o fereastră mărită pe tot ecranul îl acoperea și părea că a dispărut.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Acum, cât timp animăluțul sau mingea sunt mai sus decât Dock-ul, se văd în fața ferestrelor tale. Înapoi pe pământ, trec din nou în spatele lor.

Iar animăluțul poate să se plimbe din nou în spatele Dock-ului, ca înainte.

**Încearcă:** Mărește o fereastră pe tot ecranul, începe un chenar de selecție pe birou lângă Dock, ca animăluțul să urce pe el, și trage-l încet în sus. Animăluțul urcă odată cu el, în fața ferestrei.

---

## <a id="v1.30.3"></a>Animăluțul și mingea nu mai intră sub Dock

<sub>1.30.3 · 9 octombrie 2026</sub>

Animăluțul nu se mai plimbă și nu mai doarme sub Dock, așa că îl vezi mereu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Înainte, animăluțul și mingea se plimbau și se odihneau des chiar sub Dock, unde nu-i vedea nimeni. Cu o fereastră mărită pe tot ecranul părea că animăluțul a dispărut de tot.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Acum Dock-ul e ca un perete pentru ei. Animăluțul se întoarce la marginea lui, iar mingea ricoșează din el.

Așa animăluțul rămâne mereu la vedere lângă Dock, chiar și când o fereastră ocupă tot ecranul.

**Încearcă:** Mărește o fereastră pe tot ecranul și privește câteva minute. Animăluțul se vede mereu în stânga sau în dreapta Dock-ului.

---

## <a id="v1.30.2"></a>Animăluțul nu mai dispare în spatele ferestrelor

<sub>1.30.2 · 9 octombrie 2026</sub>

Chiar și când o fereastră îl acoperă, animăluțul continuă să trăiască și cade pe pământ când eliberezi selecția.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Când ferestrele acopereau toată fâșia în care trăiește animăluțul, pikapik îl punea pe pauză și putea rămâne înțepenit în aer. Acum animăluțul și mingea lui continuă să trăiască în spatele ferestrei: merg, cad și se joacă. Doar desenarea ia o pauză.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Dacă un chenar de selecție ridică animăluțul în spatele unei ferestre, acesta cade imediat ce eliberezi și îl vezi din nou lângă Dock.

Iar un chenar de selecție nu mai ridică animăluțul mai sus de fâșia lui.

**Încearcă:** Mărește o fereastră pe tot ecranul, ridică animăluțul cu un chenar de selecție în spatele ei, apoi eliberează. Animăluțul cade și apare lângă Dock.

---

## <a id="v1.30.1"></a>Selecțiile de pe birou funcționează din nou

<sub>1.30.1 · 9 octombrie 2026</sub>

Animăluțul și mingea lui sar din nou pe chenarele de selecție, iar listele de aplicații se aprind doar pentru aplicații.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Când Dockul sau o aplicație de acces la distanță acoperea tot ecranul, pikapik nu observa chenarul de selecție pe care îl desenezi pe birou. Acum îl observă din nou, iar animăluțul și mingea lui sar pe el ca înainte.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Listele de aplicații din configurări se aprind doar când tragi o aplicație peste ele. Celelalte fișiere sunt ignorate: nu apare niciun chenar și nu se adaugă nimic în plus. Dacă tragi o aplicație împreună cu alte fișiere, se adaugă doar aplicația.

Iar chenarul se stinge imediat ce dai drumul aplicației sau muți cursorul în altă parte.

**Încearcă:** Desenează un chenar de selecție pe birou și privește cum animăluțul sare pe el.

---

## <a id="v1.30.0"></a>Ieși nu mai oprește pikapik

<sub>1.30.0 · 9 octombrie 2026</sub>

Ai apăsat Ieși din obișnuință? Scurtăturile, „Menține activ” și animăluțul tău continuă să meargă.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/keep-awake-dark.png"><img src="../media/keep-awake-light.png" width="340" alt=""></picture>

Când alegi „Ieși”, apeși ⌘Q sau închizi pikapik din Dock, își închide ferestrele și își ascunde pictograma din bara de meniuri, dar continuă să lucreze discret în fundal: scurtăturile, „Menține activ” și animăluțul tău rămân pornite. Ca să readuci pictograma, deschide pur și simplu pikapik din nou.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Vrei să ieși de-adevăratelea? Ține apăsat Option (⌥) și alege „Ieși” sau apasă ⌥⌘Q. Prima dată când pikapik trece în fundal, îți explică ce s-a întâmplat și îți propune să ieși complet chiar atunci.

Preferi cum era înainte? Dezactivează „Rămâne activ în fundal după Ieși” în Configurări › General. Actualizările, schimbarea limbii, deconectarea, repornirea și oprirea închid mereu pikapik complet, așa că nu trebuie să-l aștepte niciodată.

**Încearcă:** Apasă ⌘Q, apoi deschide din nou pikapik ca să-i readuci pictograma.

---

## <a id="v1.29.1"></a>Animăluțul se plimbă pe toate ecranele

<sub>1.29.1 · 9 octombrie 2026</sub>

Ai mai mult de un monitor? Animăluțul și mingea lui merg acum oriunde te uiți și nu se mai pierd niciodată.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Când ajunge la marginea unui ecran, animăluțul trece pur și simplu pe următorul, iar mingea se rostogolește după el. Poți și să iei animăluțul sau mingea cu mouse-ul și să le duci pe orice ecran. Dacă o aplicație trece pe ecran complet, se mută pe alt ecran ca să nu încurce, iar dacă deconectezi un monitor, se întorc pe cel principal.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Mingea nu mai rămâne blocată într-un colț. Animăluțul aleargă la ea, o aruncă înapoi peste cap și se joacă mai departe.

Și animăluțul nu mai dispare. La fiecare două secunde verifică dacă e încă pe ecran, iar dacă ceva n-a mers, după repaus, blocarea Mac-ului, schimbarea biroului sau ecranul complet, se întoarce singur imediat.

**Încearcă:** Du animăluțul pe alt ecran sau rostogolește mingea într-un colț.

**Reparat**

- Un animăluț aruncat nu mai aterizează pe un chenar de selecție mai înalt decât poate sări și nu mai dispare din cauza asta.

---

## <a id="v1.29.0"></a>Animăluțul tău are o minge

<sub>1.29.0 · 9 octombrie 2026</sub>

Acum o mică minge de fotbal se rostogolește pe marginea de jos a ecranului. Animăluțul se joacă cu ea, și poți și tu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Mingea se rostogolește și sare ca una adevărată. Animăluțul fuge după ea, o lovește și o urmărește din nou. Trece repede cursorul peste minge ca s-o lovești tu, sau prinde-o, mut-o și arunc-o, la fel ca pe animăluț.

Un mic truc: dă clic pe un loc gol al biroului și trage ca să desenezi un chenar de selecție, cu sau fără Shift. Cât timp ții apăsat butonul mouse-ului, chenarul devine un raft: animăluțul sare pe el, iar mingea poate ateriza acolo. Dă drumul, și raftul dispare.

Preferi un birou liniștit? Dezactivează Minge în configurările animăluțului, și el se va plimba din nou singur.

**Încearcă:** Configurări › Animăluț › Minge

**Reparat**

- Lângă Dock, animăluțul sare din nou cât de sus vrea. Rămâne jos doar când e chiar deasupra Dockului, așa că nu mai iese niciodată peste el.

---

## <a id="v1.28.0"></a>Adaugi aplicații cu un clic sau trăgându-le

<sub>1.28.0 · 9 octombrie 2026</sub>

Fiecare listă de aplicații din Configurări arată acum ce ai în Dock și ce e deschis acum, iar aplicațiile le poți trage în ea din Finder.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Unele funcții te lasă să alegi aplicații în care se dau la o parte, cum ar fi butonul verde sau Home și End. Înainte, „Adaugă aplicație…” deschidea doar un dosar lung cu tot ce ai. Acum apare un raft cu aplicațiile din Dock și cele deschise chiar acum. Dai clic pe o aplicație ca s-o adaugi, încă un clic ca s-o scoți. Pentru restul există „Altele…”.

Poți și să tragi o aplicație din Finder direct pe o listă. Lista se luminează ca să-ți arate unde ajunge aplicația. Cu jocurile e la fel, cu același raft.

Iar dacă ceva nu merge, formularul pentru raportarea unei erori pe GitHub te lasă acum să alegi versiunea pikapik și macOS dintr-o listă, așa că ne spui mai repede.

**Încearcă:** Configurări › Ferestre, apoi „Adaugă aplicație…”

**Reparat**

- Derularea prin AnyDesk sau altă aplicație de desktop la distanță nu mai e întoarsă de două ori când ambele Mac-uri folosesc direcția clasică. Acum pikapik întoarce doar derularea de la un mouse sau trackpad adevărat. Dacă o aplicație face singură derulare lină, cum ar fi Mos, alege direcția în acea aplicație.
- Animăluțul rămâne în spatele Dock-ului când sare, la fel ca atunci când merge, și revine singur după ce ieși dintr-o aplicație pe tot ecranul sau dintr-un joc.
- Ramele subțiri din jurul imaginilor mici din Configurări nu mai dispar pe ecranele obișnuite, fără Retina.

---

## <a id="v1.27.3"></a>Animăluțul rămâne la vedere, iar ferestrele se deschid gata de lucru

<sub>1.27.3 · 9 octombrie 2026</sub>

Animăluțul nu se mai ascunde după ferestre în mijlocul săriturii, iar ferestrele pikapik se deschid gata de folosit.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Când animăluțul sărea peste cursor sau se dădea de-a berbeleacul, putea să alunece în spatele ferestrelor altor aplicații și să dispară în aer. Acum rămâne în față pe toată durata săriturii și trece înapoi în spatele ferestrelor tale când aterizează.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Când pikapik pornea discret în fundal, la autentificare, după o actualizare sau dintr-un link pikapik://, ferestrele lui se puteau deschide gri și rămâneau în spatele altora până dădeai clic pe ele. Acum Configurările și fereastra Fișier nou vin în față, gata să scrii.

La fel și cu mesajul de după Creează o copie mai mică și cu lista în care alegi o aplicație de adăugat. Nu trebuie să faci nimic.

**Încearcă:** Configurări › Animăluț

---

## <a id="v1.27.2"></a>Fișier nou s-a întors, iar Configurările sunt și mai ușoare

<sub>1.27.2 · 9 octombrie 2026</sub>

Fișier nou e din nou în meniul de clic dreapta din Finder pentru toată lumea, iar Configurările cer și mai puțin de la Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

După ultima actualizare, Finder putea reporni Fișier nou în fundal și uita în ce dosare lucrează, așa că opțiunea dispărea discret din meniul de clic dreapta. Acum Fișier nou îi amintește lui Finder dosarele sale la fiecare pornire, iar pikapik verifică la scurt timp după lansare că Finder le-a reținut. Nu trebuie să faci nimic.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Imaginile animate din Configurări se mișcă acum doar cât timp se vede pe ecran cel puțin jumătate din imagine. În imaginile cu jocuri, micul erou se mișcă tot de 30 de ori pe secundă, iar dealurile și pământul din spatele lui de 15 ori. Așa pagina Jocuri cere mult mai puțin de la Mac. Totul arată la fel.

După o actualizare, pikapik nu își mai adaugă din nou opțiunile în Finder decât dacă aplicația s-a mutat cu adevărat, așa că Finder nu mai trebuie să le reîncarce de fiecare dată.

**Încearcă:** Configurări › Jocuri

---

## <a id="v1.27.1"></a>Mai liniștit, mai ușor și Finder gata imediat

<sub>1.27.1 · 9 octombrie 2026</sub>

Configurările aproape că nu mai încarcă Mac-ul, iar comenzile de clic dreapta din Finder merg imediat după mutarea la pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/wheel-lines-dark.png"><img src="../media/wheel-lines-light.png" width="340" alt=""></picture>

Micile imagini animate din Configurări redesenau toată pagina de multe ori pe secundă, așa că o fereastră deschisă ținea Mac-ul ocupat. Acum fiecare imagine se redesenează doar pe ea însăși, de cel mult 30 de ori pe secundă, și se odihnește când o derulezi din vedere sau ascunzi fereastra. Arată exact la fel.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

După mutarea de la pika-tools la pikapik, Finder putea căuta în continuare aplicația veche, iar „Fișier nou”, „Convertește în” și celelalte comenzi de clic dreapta nu făceau nimic. Acum pikapik observă asta la prima pornire și repornește singur Finder când nu e deschisă nicio fereastră Finder și nu se copiază nimic. Altfel, un rând scurt pe pagina Finder îți oferă butonul „Repornește Finder”.

În Configurări sistem, printre aplicațiile care se deschid la autentificare, aplicația apare acum cu noul nume, pikapik, și rămâne activată.

**Încearcă:** Configurări › Finder

---

## <a id="v1.27.0"></a>Fă cunoștință cu animăluțul de pe birou

<sub>1.27.0 · 9 octombrie 2026</sub>

Jos pe ecran locuiește acum un mic prieten, iar aplicația are un nume nou: pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Pornește-l din Configurări › Animăluț. Se plimbă în spatele ferestrelor și al Dock-ului, sare peste cursor când îi stă în cale și țopăie când apeși Spațiu. Îl poți lua, căra, arunca și prinde din nou în mijlocul săriturii.

Din când în când se așază și spune ceva scurt. Când apare cu adevărat o versiune nouă, îți spune o dată, iar un clic pe el deschide Configurările, unde te așteaptă actualizarea.

pika-tools se numește acum pikapik. Permisiunile, configurările și linkurile din Scurtături rămân cum erau. Dacă ai instalat-o cu Homebrew, rulează o dată `brew update && brew upgrade --cask pikapik`.

**Încearcă:** Configurări › Animăluț

**Reparat**

- Verificarea actualizărilor anunța o versiune nouă chiar dacă aveai deja ultima.
- Pagina Permisiuni ținea Mac-ul ocupat cât era deschisă.

---

## <a id="v1.26.2"></a>Noutăți în limba ta

<sub>1.26.2 · 8 octombrie 2026</sub>

„Noutăți” din configurări deschide acum această pagină, în aceeași limbă ca aplicația.

<img src="../media/icon.png" width="128" height="128" alt="">

Deschide Configurări › Despre și dă clic pe „Noutăți”. Ajungi direct aici, pe pagina cu o imagine pentru fiecare actualizare, în limba în care vorbește pikapik.

Și lista completă a schimbărilor e mai ordonată. Fiecare versiune arată ziua în care a apărut, iar fiecare număr de versiune deschide pagina ei de descărcare.

În felul în care funcționează pikapik nu se schimbă nimic. Actualizările vin ca înainte, singure sau prin Homebrew.

**Încearcă:** Configurări › Despre › Noutăți

**Reparat**

- „Noutăți” deschidea o listă tehnică lungă, în engleză, în loc de această pagină.
- Linkurile din lista schimbărilor care nu duceau nicăieri deschid acum pagina potrivită.

---

## <a id="v1.26.1"></a>Imaginile jocurilor prind viață

<sub>1.26.1 · 8 octombrie 2026</sub>

Imaginile de pe pagina „Jocuri” se mișcă acum, așa că vezi ce oprește fiecare comutator.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.26.1/game-previews-dark.png"><img src="../media/whats-new/1.26.1/game-previews-light.png" width="340" alt=""></picture>

În spatele fiecărui comutator de pe pagina „Jocuri” rulează acum un joc mic. Apar niște taste, sunt apăsate, și vezi ce ar sări peste jocul tău, cum ar fi Spotlight sau Mission Control, în timp ce jocul se oprește. Când comutatorul e pornit, tastele doar strălucesc ușor și jocul merge mai departe. Schimbă un comutator și imaginea arată imediat diferența.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Jocul mic urmează aspectul Mac-ului tău: o zi însorită în modul luminos și o noapte liniștită, cu lună și stele, în modul întunecat.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

În toate imaginile din aplicație, cursorul se mișcă acum ca o mână: pe drumuri lungi își ia puțin mai mult timp, se oprește și abia apoi dă clic. Când o imagine o ia de la capăt, revine lin la început în loc să sară. Imaginile se odihnesc cât fereastra e ascunsă, iar cu „Redu mișcarea” pornit stau pe loc.

**Încearcă:** Configurări › Jocuri

---

## <a id="v1.26.0"></a>O pictogramă nouă și curățenie în permisiunile vechi

<sub>1.26.0 · 8 octombrie 2026</sub>

pikapik are o față nouă și acum șterge permisiunile rămase după aplicațiile șterse.

<img src="../media/icon.png" width="128" height="128" alt="">

Pictograma nouă este semnul pikapik în albastru, violet și coral pe o plăcuță întunecată. Bara de meniu arată aceeași formă, care se potrivește cu o bară deschisă sau închisă. Când toate instrumentele sunt dezactivate, forma devine palidă.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>

Când ștergi o aplicație, macOS păstrează permisiunile pe care i le-ai dat, iar din Configurări sistem nu le poți elimina. Acum pagina „Permisiuni” are o listă numită „Rămase de la aplicații șterse”: fiecare aplicație cu pictograma ei, ce avea voie să facă și când. „Elimină” curăță o aplicație, „Elimină tot” le curăță pe toate, iar o aplicație pe care o instalezi din nou doar va cere din nou. Ca să vezi lista, dă-i lui pikapik acces complet la disc: doar se uită și nu schimbă nimic până nu apeși „Elimină”.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Imaginile de pe paginile „Animații” și „Jocuri” sunt redesenate pentru mărimea lor reală, așa că arată clar. O fereastră se strânge în Dock cu colțurile rotunjite, iar cursorul face clic mai întâi și abia apoi se deschide un meniu. Iar jos, în „Despre”, există acum un rând discret: „Făcut cu grijă · Cumpără-mi o cafea”. Nimic nu apare brusc și nimic nu îți amintește.

**Încearcă:** Configurări › Permisiuni, apoi „Rămase de la aplicații șterse”

**Reparat**

- Un clic pe o scurtătură de sistem deschide direct secțiunea ei din Configurări sistem, cum ar fi Mission Control, nu doar „Tastatură”.
- Sfatul de lângă taste nu mai dispare imediat ce se deschide Configurări sistem.

---

## <a id="v1.25.2"></a>Scurtăturile se deschid acolo unde le schimbi

<sub>1.25.2 · 8 octombrie 2026</sub>

Apasă pe o scurtătură în Configurări, iar Configurări sistem se deschide în locul potrivit.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Înainte, un clic pe o scurtătură, cum ar fi cea pentru Spotlight, ducea mereu la „Taste modificator”. Acum tastele pentru Spotlight deschid direct Spotlight.

Pentru celelalte scurtături, Configurări sistem se deschide la „Tastatură”, iar lângă taste apare un sfat scurt care îți spune unde să apeși: „Scurtături din tastatură…”, apoi „Mission Control” sau altă secțiune.

La fel merge pe pagina Jocuri și pentru „Decupează fișiere în Finder”. Pentru decupare, sfatul te duce la „Scurtături aplicații”.

**Încearcă:** Configurări › Jocuri, apoi apasă pe tastele de lângă „Căutarea nu apare”

**Reparat**

- Un clic pe o scurtătură nu mai deschide „Taste modificator”.

---

## <a id="v1.25.1"></a>Imagini mari și jocuri direct din Dock

<sub>1.25.1 · 8 octombrie 2026</sub>

Fiecare comutator are acum o imagine mare, iar „Adaugă un joc…” arată ce ai în Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

Pe paginile Animații și Jocuri, toate imaginile sunt acum mari, ca cea din partea de sus a paginii. Vezi imediat ce face fiecare comutator, iar imaginile se mișcă în continuare cu viteza pe care ai ales-o.

Apasă „Adaugă un joc…” și îți vezi Dock-ul: aplicațiile pe care le ții acolo și cele deschise acum, în aceeași ordine. Un joc din Dock apare chiar dacă e închis, inclusiv Minecraft. Un clic îl adaugă, iar o bifă arată că e în listă. Mai dă un clic ca să-l scoți.

Poți trage în continuare un joc aici din Finder. Nu mai trebuie să-l scoți din Dock, așa că Dock-ul nu-ți mai propune să-l elimini.

**Încearcă:** Configurări › Jocuri, apoi „Adaugă un joc…”

**Reparat**

- Un joc care stă în Dock, dar e închis, apare acum în lista pentru adăugare.

---

## <a id="v1.25.0"></a>Adaugi un joc dintr-un clic și îți alegi tastele

<sub>1.25.0 · 8 octombrie 2026</sub>

Alege un joc dintre aplicațiile deschise acum și stabilește tu tastele pentru ieșire și închidere.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

Apasă „Adaugă un joc…”, iar aplicațiile deschise acum apar cu pictograme mari, ca în Dock. Un clic adaugă un joc, sau trage pictograma în listă. Poți lăsa un joc și direct din Finder sau din Dock. Acum orice aplicație poate fi un joc, chiar și Minecraft pe Java, iar jocurile adăugate înainte rămân.

Comutatoarele din Modul Joc vorbesc simplu acum, de exemplu „Jocul nu se închide” sau „Căutarea nu apare”, și fiecare are o imagine mică cu ce oprește. Numele din sistem, de exemplu Spotlight, stă alături, în gri.

În Configurări › Ferestre, dă clic pe tastele de lângă „Ieși din aplicație” sau „Închide fereastra” și apasă altele noi. ⌫ aduce înapoi ⇧⌘Q și ⇧⌘W, iar dacă tastele sunt deja folosite, pikapik te întreabă mai întâi. Modul Joc folosește și el tastele tale. Și fiecare scurtătură din Configurări arată acum cum e setată cu adevărat pe Mac-ul tău: tastele tale sau Dezactivat.

**Încearcă:** Configurări › Jocuri, apoi „Adaugă un joc…”

**Reparat**

- Tăierea fișierelor în Finder urmează scurtătura pentru Taie pe care ai setat-o pentru Finder în Configurări sistem.
- Numele aplicațiilor din liste apar fără „.app”.

---

## <a id="v1.24.1"></a>O viteză pe care o vezi imediat

<sub>1.24.1 · 8 octombrie 2026</sub>

Pagina Animații îți spune acum unde se vede o schimbare și îți păstrează valorile tale.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

Dock-ul poate culisa mai repede doar dacă se ascunde. Dacă al tău stă mereu la vedere, comutatorul „Ascunde automat Dock-ul” e acum chiar sub glisorul de viteză.

După o schimbare, un rând din partea de jos a paginii îți spune că aplicațiile o preiau după ce le redeschizi. Finder arată noile viteze pentru Privire rapidă și coloane doar după o repornire, așa că rândul are un buton „Repornește Finder”.

Glisorul nu încetinește niciodată ce ai accelerat deja, de exemplu cu comenzi în Terminal. Iar „Restaurează valorile implicite” sau dezinstalarea pikapik îți aduc înapoi valorile de dinainte, în loc să le șteargă.

**Încearcă:** Configurări › Animații

**Reparat**

- Dock-ul nu mai repornește degeaba când nu se ascunde.

---

## <a id="v1.24.0"></a>Alege cât de repede se mișcă Mac-ul tău

<sub>1.24.0 · 8 octombrie 2026</sub>

Noua pagină Animații stabilește cât de repede se deschid, culisează și apar lucrurile pe Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Un singur glisor face totul. Mută-l, iar Dock-ul ascuns, ferestrele noi, dialogurile de salvare, Privire rapidă și coloanele din Finder se grăbesc toate odată, de la „Ca în macOS” până la „Instantaneu”.

Vrei să reglezi doar un lucru? Fiecare efect are setarea lui, la fel ca efectul de minimizare, pictogramele care sar în Dock și animațiile Finder. Lângă fiecare setare, o imagine mică se mișcă exact cu viteza aleasă de tine.

„Restaurează valorile implicite” readuce doar ce a schimbat pikapik, iar dezinstalarea face la fel. Dacă ai setat cândva singur una dintre aceste valori în Terminal, pikapik o arată așa cum e.

**Încearcă:** Configurări › Animații

---

## <a id="v1.23.2"></a>Un comutator pentru fiecare scurtătură în Modul Joc

<sub>1.23.2 · 8 octombrie 2026</sub>

Acum decizi tu, scurtătură cu scurtătură, ce oprește Modul Joc cât timp joci.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Q și ⌘W au acum comutatoare separate, la fel ca Spotlight, Siri, ⌘Tab, Mission Control, glisările, cursorul, ecranul și restul. Alegerile tale de dinainte rămân.

Fiecare rând arată exact tastele pe care le oprește, așa că știi mereu ce face un comutator.

Setarea limbii tastaturii a ieșit din Modul Joc. ⌃Spațiu și celelalte moduri de a schimba limba merg mereu, chiar și într-un joc.

**Încearcă:** Configurări › Jocuri

**Reparat**

- Tastele aceleiași scurtături stau mai aproape, iar între scurtături diferite e puțin mai mult loc, ca să vezi ușor unde se termină una și unde începe următoarea.

---

## <a id="v1.23.1"></a>Cât de rapid e internetul tău, pe înțelesul tuturor

<sub>1.23.1 · 8 octombrie 2026</sub>

Viteza internetului îți verifică conexiunea și îți spune simplu la ce e bună.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

Apasă „Verifică viteza” și, în vreo jumătate de minut, vezi descărcarea, încărcarea, ping-ul și reactivitatea. Sub cifre, cuvinte simple îți spun dacă ajunge pentru filme 4K, apeluri video, jocuri online și descărcări mari.

Verificarea se face pe serverele Apple, iar ultimul rezultat rămâne până la următorul. Viteza internetului are pagina ei în Configurări, un rând în panoul din bara de meniu și un link pentru aplicația Scurtături: `pikapik://speed-test`.

Modul Joc a învățat două lucruri. Blocarea scurtăturilor cu Control face acum parte din el: în joc, ⌃-clic rămâne un clic și scurtăturile cu ⌃ nu pornesc; în rest, ⌃ merge ca de obicei. Și recunoaște Minecraft: adaugă Minecraft Launcher sau CurseForge la jocurile tale, iar Modul Joc pornește când în față e chiar Minecraft.

**Încearcă:** Configurări › Viteza internetului, apoi „Verifică viteza”

**Reparat**

- Versiunile de test ale pikapik pe care oamenii le construiesc singuri își țin configurările separat în iCloud Drive și nu le mai ating pe ale tale.

---

## <a id="v1.23.0"></a>Modul Joc: joacă fără întreruperi

<sub>1.23.0 · 7 octombrie 2026</sub>

Adaugă-ți jocurile, iar Mac-ul nu te mai scoate din ele.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Cât timp joci, Spotlight, Siri, ⌘Tab, Mission Control și glisările între birouri nu se deschid peste joc. ⌘Q și ⌘W nu îl închid din greșeală, cursorul rămâne pe ecranul jocului, iar ecranul rămâne aprins.

Ca să ieși dintr-un joc, apasă ⇧⌘Q; ca să-i închizi fereastra, ⇧⌘W. ⌥⌘Esc merge mereu. pikapik îți sugerează jocurile pe care le găsește pe Mac. Modul Joc stă oprit până îl pornești tu.

Menține activ te lasă să alegi ce face ecranul: rămâne aprins, fără economizor de ecran și fără ecran de blocare, sau se stinge ca de obicei, în timp ce Mac-ul lucrează mai departe. Noul buton „Stinge ecranul acum” îl stinge pe loc; mișcă mouse-ul sau apasă o tastă ca să revină.

**Încearcă:** Configurări › Jocuri, apoi „Adaugă un joc…”

**Reparat**

- Pe Mac-urile fără capac, Menține activ nu mai arată opțiunile pentru capacul închis.

---

<p align="center"><sub>Versiunile mai vechi sunt în <a href="../../CHANGELOG.md">lista de modificări</a> (în engleză).</sub></p>
