<p align="center"><a href="../readme/README.pl.md"><img src="../media/icon.png" width="96" height="96" alt="pikapik"></a></p>
<h1 align="center">Co nowego w pikapik</h1>
<p align="center">Każda aktualizacja w kilku słowach i na jednym obrazku, od najnowszej.</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <b>Polski</b> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.52.0"></a>Poprawianie słów i boczne przyciski myszy działają teraz w prawie każdej aplikacji

<sub>1.52.0 · 15 października 2026</sub>

Słowa wpisane w złym języku są teraz poprawiane także w Chrome, Slacku i VS Code, a boczne przyciski myszy cofają i przechodzą dalej prawie wszędzie.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/layout-fix-dark.png"><img src="../media/layout-fix-light.png" width="340" alt=""></picture>

W wersji ze strony poprawianie słowa wpisanego w złym języku działa teraz także w Chrome, Slacku, VS Code, Discordzie i innych aplikacjach opartych na Chromium, podczas pisania i skrótem do przepisania, więc „ghbdtn” też tam zamienia się w „привет”. Wyłącz funkcję albo zamknij pikapik, a te aplikacje wrócą do poprzedniego stanu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/side-buttons-dark.png"><img src="../media/side-buttons-light.png" width="340" alt=""></picture>

Przyciski myszy 4 i 5 cofają i przechodzą dalej w prawie każdej aplikacji i znów działają w ustawieniach samego pikapika. pikapik sam naciska pozycję Wstecz lub Dalej w menu albo na pasku narzędzi aplikacji, w dowolnym języku, a aplikacje, które już rozumieją te przyciski, obsługują je dalej same. W wersji z Mac App Store dotyczy to okien pikapika i aplikacji Apple.

Gdy otwarte są dwie kopie pikapika, na przykład ze strony i z App Store, cokolwiek na Macu zmienia tylko ta uruchomiona jako ostatnia, więc ustawienia zawsze pokazują, co naprawdę obowiązuje. Przy zamknięciu wszystko, co zmieniła, wraca na miejsce. Nowe są też, głównie w wersji ze strony: kliknięcie środkowym przyciskiem trzema palcami na gładziku, obrazki pokazujące, co robią Zakończ aplikację i Zamknij okno, ⇧⌘. w wierszu Pokaż ukryte pliki, nazwy grup na pasku bocznym, a w odtwarzaczu klawisze jak w QuickTime, głośność kółkiem, prędkość i wznawianie od miejsca zatrzymania.

**Wypróbuj:** Ustawienia › Klawiatura

**Poprawki**

- Otwórz w programie pokazuje pikapik Player zaraz po aktualizacji, nawet jeśli odtwarzacz nigdy nie był otwierany.
- Głośność aplikacji: po przywróceniu suwaka aplikacji na 100% dźwięk nie kończy się już cichym kliknięciem.
- Gry (wersja ze strony): szybki ruch myszą nie ucieka już na inny ekran, a wskaźnik nie odskakuje z powrotem.

---

## <a id="v1.51.0"></a>Filmy, których QuickTime nie otwiera, teraz się odtwarzają

<sub>1.51.0 · 15 października 2026</sub>

W wersji ze strony pliki wideo MKV, WebM, AVI, WMV, FLV i inne, których QuickTime nie otwiera, odtwarzają się teraz w pikapik Player.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/player-dark.png"><img src="../media/player-light.png" width="340" alt=""></picture>

Kliknij prawym przyciskiem plik wideo i wybierz Otwórz w programie › pikapik Player albo kliknij Otwórz wideo… w Ustawienia › Odtwarzacz. Film odtwarza się we własnym oknie: spacja włącza i wstrzymuje odtwarzanie, ← i → przewijają o 5 sekund, ↑ i ↓ zmieniają głośność, a F włącza pełny ekran.

Odtwarzacz to mała, osobna aplikacja. Widzi tylko pliki wideo, które otworzysz, nie może łączyć się z internetem i nie prosi o żadne uprawnienia. Aplikacja, która domyślnie otwiera Twoje filmy, pozostaje ta sama. Napisy nie są jeszcze obsługiwane.

**Wypróbuj:** Ustawienia › Odtwarzacz

---

## <a id="v1.50.3"></a>Menu aktywnych narożników i wyświetlacza głównego znów działają

<sub>1.50.3 · 15 października 2026</sub>

W wersji ze strony menu Zmień… w wierszu aktywnego narożnika i menu Wyświetlacz główny robią teraz to, co obiecują.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-display-dark.png"><img src="../media/dock-display-light.png" width="340" alt=""></picture>

W wersji 1.50.2 każda opcja w tych dwóch menu pojawiała się trzy razy, a wybranie jednej nic nie zmieniało. Teraz każda opcja pojawia się raz, bieżąca ma znacznik wyboru, a Twój wybór działa od razu. Aktywne narożniki są w Ustawienia › Gry, a Wyświetlacz główny w Trzymaj Dock na jednym ekranie. Przywróć albo wyłączenie przełącznika nadal przywraca wszystko dokładnie tak, jak było.

---

## <a id="v1.50.2"></a>pikapik robi to sam, bez wchodzenia do Ustawień systemowych

<sub>1.50.2 · 15 października 2026</sub>

W wersji ze strony wyłączenie zadania w tle, dodanie układu klawiatury, zmiana aktywnego narożnika i wybór wyświetlacza głównego odbywają się teraz wprost w pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/background-dark.png"><img src="../media/background-light.png" width="340" alt=""></picture>

W Ustawienia › Zadania w tle wyłącz zadanie, a jego wiersz zmieni się od razu. Hasło nie jest potrzebne, a twój wybór zostaje po ponownym uruchomieniu. Włącz ponownie przywraca zadanie. Zadania dla całego Maca i pomocniki dodane przez aplikację we własnym zakresie nadal otwierają Ustawienia systemowe, a linijka pod wierszem mówi dlaczego.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/layout-fix-dark.png"><img src="../media/layout-fix-light.png" width="340" alt=""></picture>

Poprawianie tekstu wpisanego w złym układzie działa, gdy masz co najmniej dwa układy klawiatury. Jeśli masz tylko jeden, notatka w Ustawienia › Klawiatura proponuje teraz układy dla twoich języków. Wybierz jeden w Dodaj układ, a będzie gotowy od razu, bez hasła. Jeśli żaden nie pasuje, Ustawienia klawiatury… nadal tam są.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-display-dark.png"><img src="../media/dock-display-light.png" width="340" alt=""></picture>

W Ustawienia › Gry menu Zmień… w wierszu aktywnego narożnika wybiera inną akcję dla tego narożnika. W Trzymaj Dock na jednym ekranie menu Wyświetlacz główny robi z wybranego wyświetlacza główny, a Dock przechodzi na niego. pikapik pamięta, jak było: Przywróć albo wyłączenie przełącznika przywraca wszystko dokładnie tak jak wcześniej.

**Wypróbuj:** Ustawienia › Zadania w tle

**Poprawki**

- Minimalizuj lub ukrywaj kliknięciem w Docku: jeśli włączyłeś to, gdy kliknięcie minimalizowało okna, po ponownym uruchomieniu nie zmienia się już samo na ukrywanie aplikacji.
- Po otwarciu pikapik sprawdza teraz ustawienia zmienione na twoim drugim Macu, więc Mac, który ominął zmianę, od razu ją nadrabia.
- Bez usypiania mówi teraz, że zostaje włączone, dopóki go nie wyłączysz, a Tryb gry nie podpowiada już gry, którą dodałeś.

---

## <a id="v1.50.0"></a>Więcej pikapik w wersji z Mac App Store

<sub>1.50.0 · 15 października 2026</sub>

Otwieraj archiwa, porządkuj biurko, używaj Home i End i nie tylko, teraz także w wersji z Mac App Store.

**Nowości w wersji z Mac App Store**

- **Otwieraj i twórz archiwa w Finderze.** Kliknij archiwum prawym przyciskiem i wybierz „Wypakuj”. Aby je utworzyć, kliknij pliki prawym przyciskiem i wybierz „Utwórz archiwum…”. Naciśnij spację na archiwum, aby zajrzeć do środka. Hasło można tu ustawić tylko dla ZIP.
- **Czyste biurko.** Włącz „Ukryj ikony na biurku”, a pikapik zakryje ikony Twoją tapetą. Kliknięcia nadal trafiają na biurko, a uprawnienia nie są potrzebne.
- **Home i End znowu działają.** Przenoszą na początek i na koniec wiersza wszędzie poza przeglądarkami, Finderem, Muzyką i TV.
- **Popraw skrótem tekst wpisany w złym układzie.** Zaznacz tekst i naciśnij ⌃⇧Spacja. Włącz „Popraw zaznaczony tekst” w Ustawienia › Klawiatura, gdzie możesz też zmienić klawisze.
- **Wyłącz ekran jednym kliknięciem.** „Wyłącz ekran teraz” ściemnia ekran od razu, a Mac pracuje dalej. Poruszaj myszą, aby go przywrócić.
- **Nic nie przeszkadza w grze.** W „Tryb gry” skróty Maca, takie jak Spotlight, są wstrzymane, gdy gra jest na wierzchu. Wskaźnik trzyma się z dala od rogów ekranu, więc aktywne rogi nie zadziałają.
- **Dane baterii wróciły.** „Bateria” znów pokazuje „Maksymalna pojemność” w macOS 27, a „Temperatura” pokazuje temperaturę baterii.
- **Zobacz, które aplikacje mogą poprosić o uprawnienie.** „Uprawnienia innych aplikacji” w Ustawienia › Uprawnienia pokazuje je z ikonami.
- **Wiesz, gdzie kliknąć.** Gdy macOS nie pozwala aplikacji pikapik zmienić ustawienia, krótka animacja pokazuje, gdzie kliknąć w Ustawieniach systemowych.

**W obu wersjach**

- **Ustaw głośność, zanim aplikacja się włączy.** Aplikacja z ustawioną głośnością zostaje w Ustawienia › Dźwięk ze swoim suwakiem, nawet gdy jest zamknięta, i odzyskuje swój poziom, gdy znów odtwarza dźwięk, także po ponownym uruchomieniu. Kliknij „Dodaj aplikację…” albo przeciągnij aplikację z Findera, żeby ustawić ją z wyprzedzeniem, a ✕ usuwa ją z listy i przywraca pełną głośność.
- **Zobacz, co dodała aktualizacja.** Po aktualizacji mała niebieska kropka oznacza każdą kartę Ustawień z nowością, a etykieta „Nowe” oznacza sekcję. Znikają, gdy już zerkniesz, a same po 21 dniach.
- **Spokojne pierwsze uruchomienie.** Wersja ze strony nie prosi już o uprawnienia przy pierwszym otwarciu. Pyta tylko wtedy, gdy włączasz narzędzie, które ich potrzebuje.
- **Mniejsze kopie filmów.** „Utwórz mniejszą kopię” robi teraz z filmu plik mniej więcej o połowę mniejszy. Wcześniej większość filmów dostawała odpowiedź „Już jest mały”.
- **Dwie kopie nie przeszkadzają sobie.** Jeśli używasz razem wersji z App Store i wersji ze strony, nie cofają już nawzajem swojej pracy. ⇧⌘Q i ⇧⌘W znów działają w grach.
- **Gry wracają po uśpieniu.** „Tryb gry” sam włącza się ponownie, gdy Mac się budzi.
- **„Porty” mówią prawdę.** W macOS 27 port zajęty przez macOS lub innego użytkownika nie jest już uznawany za wolny.
- **Zgłoszenie problemu jest szybsze.** „Zgłoś problem” w Ustawienia › Informacje otwiera formularz z już wybraną wersją.
- **Archiwa bez zacinania.** Pasek postępu rusza się podczas rozpakowywania archiwum, błędne hasło jest zgłaszane od razu, a Mac nie zasypia już w połowie rozpakowywania ani tworzenia archiwum.
- **Spokojniejszy panel na pasku menu.** Rozwinięcie wiersza w panelu, na przykład opcji ekranu pod „Bez usypiania”, nie powoduje już mignięcia paska przewijania. Strzałka obok „Bez usypiania” podpowiada teraz „Ustawienia ekranu”.
- **Porty tłumaczą się same.** Wiersz pod tytułem mówi, czym jest port, a mała animacja pokazuje, że przez jedne drzwi przechodzi tylko jeden program. Twoje programy i te, które lepiej zostawić w spokoju, mają teraz zrozumiałe nazwy.
- **Ustawienia mówią jasno.** Każda karta zaczyna się wierszem o tym, co tam dostajesz, pasek boczny ma odstępy między grupami, a „Bez usypiania”, „Uprawnienia” i „Bateria” mówią dokładnie, co się dzieje. Przycisk „Potrzebne uprawnienia” pojawia się tylko wtedy, gdy włączonemu przez ciebie narzędziu brakuje uprawnienia.

**Poprawione w wersji z Mac App Store**

- Po ⌘X skrót ⌘V w Finderze przenosi teraz pliki, tak jak w wersji ze strony. Wcześniej tylko je kopiował.
- „Nowy plik w Finderze”, „Mniejsza kopia w Finderze” i „Konwersja w Finderze” pokazują teraz każdy swój stan. Wcześniej po włączeniu jednego wszystkie trzy wyglądały na włączone.
- Pustej strony „Porty” już nie ma. macOS nie pokazuje tej wersji, który program zajmuje port, więc w Ustawienia › Porty nie było czego pokazać.

---

## <a id="v1.49.0"></a>Jasność dla każdego monitora

<sub>1.49.0 · 13 października 2026</sub>

Przyciemniaj i rozjaśniaj monitor, którego macOS nie umie ustawić, prosto z pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/brightness-dark.png"><img src="../media/brightness-light.png" width="340" alt=""></picture>

macOS ustawia jasność wbudowanego ekranu i monitorów Apple, ale większość innych monitorów słucha tylko własnych przycisków. Teraz każdy z nich ma własny suwak na stronie Ustawienia › Jasność, a wiersz „Jasność” możesz dodać do panelu na pasku menu.

pikapik zmienia jasność samego monitora, tak jak jego przyciski. Jeśli monitor nie reaguje, włącz „Zamiast tego przyciemniaj obraz”: obraz robi się ciemniejszy, ale nigdy czarny. pikapik zapamiętuje jasność każdego monitora i ustawia ją ponownie po uśpieniu.

Włącz „Klawisze jasności”, a klawisze jasności na klawiaturze będą zmieniać jasność monitora, na którym jest wskaźnik, i pokazywać na ekranie mały pasek jasności. Przytrzymaj ⌥⇧, aby zmieniać ją drobniejszymi krokami. Klawisze potrzebują uprawnienia „Dostępność”, które włączasz na stronie „Uprawnienia”.

**Wypróbuj:** Ustawienia › Jasność

**Poprawki**

- Z VoiceOver przełączniki w Ustawieniach można teraz włączać i wyłączać. Wcześniej VoiceOver czytał nazwę każdego przełącznika dwa razy, a naciśnięcie go nic nie dawało.

---

## <a id="v1.48.0"></a>Dock zostaje na swoim ekranie, nieważne, jak szybko ruszasz myszą

<sub>1.48.0 · 13 października 2026</sub>

„Trzymaj Dock na jednym ekranie” korzysta teraz z ustawienia samego Docka, więc Dock nie przechodzi już za wskaźnikiem na inny ekran, nawet przy szybkim ruchu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-display-dark.png"><img src="../media/dock-display-light.png" width="340" alt=""></picture>

Wcześniej pikapik odsuwał wskaźnik od dolnej krawędzi drugiego ekranu, a przy szybkim ruchu myszą Dock i tak mógł przeskoczyć. Teraz przełącznik wyłącza to przechodzenie w samym Docku, a pikapik w ogóle nie dotyka wskaźnika. Dock odczytuje to ustawienie tylko przy uruchamianiu, dlatego po włączeniu lub wyłączeniu przełącznika Dock raz uruchamia się ponownie. Jeśli przełącznik był już włączony, Dock raz uruchomi się ponownie także po aktualizacji.

Aby celowo przenieść Dock, ustaw inny ekran jako główny. Kliknij „Wyświetlacz główny” pod przełącznikiem, aby otworzyć Ustawienia systemowe › Wyświetlacze, kliknij wybrany ekran, a następnie w menu „Używaj jako” wybierz „Wyświetlacz główny”. Dock przejdzie na ten ekran.

Przełącznika „Przywracaj Dock” już nie ma: on też działał, odsuwając wskaźnik, a teraz Dock nie podąża już za wskaźnikiem. „Trzymaj Dock na jednym ekranie” nie wymaga żadnych uprawnień i jest domyślnie wyłączony. Nie ma go w wersji z Mac App Store, bo aplikacje z App Store nie mogą zmieniać ustawień Docka.

**Wypróbuj:** Ustawienia › Dock

---

## <a id="v1.47.0"></a>Czyste biurko jednym kliknięciem

<sub>1.47.0 · 13 października 2026</sub>

Dwa nowe przełączniki w pikapik ukrywają ikony na biurku i pokazują pliki, które macOS chowa.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/desktop-icons-dark.png"><img src="../media/desktop-icons-light.png" width="340" alt=""></picture>

**Ukryj ikony na biurku.** Włącz to przed rozmową, nagrywaniem ekranu albo zrzutem ekranu, a pliki i foldery z biurka znikną. Wyłącz, a wrócą na swoje miejsca. Nic się nie przenosi: pliki zostają w folderze Biurko w Finderze. To ustawienie **Pokaż rzeczy › Na Biurku** w Ustawieniach systemowych › Biurko i Dock, tylko bardziej pod ręką, więc oba zawsze się zgadzają. W wersji z Mac App Store ten wiersz otwiera zamiast tego tę stronę Ustawień systemowych.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/hidden-files-dark.png"><img src="../media/hidden-files-light.png" width="340" alt=""></picture>

**Pokaż ukryte pliki.** Pliki i foldery, które macOS ukrywa, na przykład folder Biblioteki w twoim folderze domowym albo pliki, których nazwa zaczyna się od kropki, pojawią się w Finderze i na biurku jako przygaszone. To to samo co naciśnięcie ⇧⌘. w Finderze, tylko od razu widać, czy jest włączone. Aby zastosować zmianę, Finder na chwilę uruchomi się ponownie i znów otworzy swoje okna i karty. Jeśli Finder właśnie kopiuje lub przenosi pliki, uruchomi się ponownie dopiero, gdy skończy. Oba są w Ustawieniach › Finder. Żeby mieć je w panelu na pasku menu, kliknij przycisk z ołówkiem na dole panelu i zaznacz je. W wersji z Mac App Store Ustawienia › Finder pokazują zamiast tego klawisze ⇧⌘. dla Findera.

---

## <a id="v1.46.1"></a>Strona „Uprawnienia” mówi wszystko

<sub>1.46.1 · 13 października 2026</sub>

Gdy narzędzie wciąż potrzebuje uprawnienia z listy poniżej, strona teraz o tym mówi.

Wcześniej, gdy oba uprawnienia na górze były włączone, strona obiecywała, że wszystkie narzędzia działają, nawet jeśli narzędzie z sekcji „Dla niektórych funkcji” wciąż czekało na swoje uprawnienie. Teraz mówi, że niektóre narzędzia potrzebują też uprawnienia z listy poniżej, a obiecuje, że wszystko działa, dopiero gdy naprawdę tak jest.

**Wypróbuj:** Ustawienia › Uprawnienia

**Poprawki**

- W wersji z Mac App Store sekcja „Podziękuj” na stronie „Informacje” pojawia się dopiero wtedy, gdy napiwki są gotowe do wyboru. Wcześniej podczas ładowania kręciło się kółko, a gdy App Store nie odpowiadał, sekcja znikała.
- Jeśli dysk zapełni się podczas rozpakowywania archiwum, komunikat „Za mało miejsca” pokazuje teraz, ile miejsca jest naprawdę wolne po usunięciu częściowo rozpakowanych plików. Wcześniej mógł podawać, że wolnego miejsca prawie nie ma.

---

## <a id="v1.46.0"></a>Ukryj aplikację na pierwszym planie przyciskiem myszy

<sub>1.46.0 · 13 października 2026</sub>

Naciśnij środkowy albo boczny przycisk, a aplikacja, w której jesteś, usunie się na bok, tak jak skrótem ⌘H.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/hide-app-dark.png"><img src="../media/hide-app-light.png" width="340" alt=""></picture>

Otwórz Ustawienia › Mysz, włącz „Przycisk myszy ukrywa bieżącą aplikację” i naciśnij przycisk, którego chcesz używać. Przyciskiem „Zmień…” wybierzesz później inny. Aplikacja dalej działa, a kliknięcie jej ikony w Docku przywraca ją na ekran. Gdy grasz, a Tryb gry jest włączony, przycisk robi w grze to, co zawsze. Jeśli włączone jest też „Boczne przyciski: wstecz i dalej”, wybrany boczny przycisk zamiast tego ukrywa aplikacje. Funkcja wymaga uprawnienia „Dostępność” i domyślnie jest wyłączona.

W wersji z Mac App Store ⌘X wycina pliki w Finderze: zaznacz pliki, naciśnij ⌘X, otwórz inny folder i wybierz „Przenieś rzeczy tutaj” z menu pikapik albo naciśnij ⌥⌘V. Wracają „Animacje” i „Wyłącz przyspieszenie wskaźnika”, a na stronie „Uprawnienia” jest nowa sekcja „Pozostałości po usuniętych aplikacjach”. Ta wersja nie może sama zmieniać tych ustawień, więc każdy wiersz wyjaśnia, co zmienić, i otwiera właściwe miejsce w Ustawieniach systemowych. Zwierzak chodzi teraz po całej szerokości ekranu nad Dockiem.

**Wypróbuj:** Ustawienia › Mysz › Przycisk myszy ukrywa bieżącą aplikację

**Poprawki**

- Rysunki na stronie „Mysz” znów są ostre.
- Funkcje klawiatury i myszy proszą tylko o uprawnienie, którego naprawdę używają. Większości wystarcza „Dostępność”; wcześniej prosiły też o „Monitorowanie wprowadzania” i bez niego zostawały szare.
- „Zmiana języka” pokazuje, kiedy potrzebuje uprawnienia „Monitorowanie wprowadzania”, a kliknięcie otwiera stronę „Uprawnienia”. Wcześniej zostawała włączona, ale nie działała.
- „Zakończ po zamknięciu ostatniego okna” czeka, aż pozwolisz na „Monitorowanie wprowadzania”, zamiast kazać macOS pytać o nie przy uruchamianiu pikapik.
- W macOS 27 „Dostępność” ma nową nazwę, „Sterowanie urządzeniami i dostęp do danych”, tak samo jak w Ustawieniach systemowych.
- Za pomocą VoiceOver możesz teraz wybierać ubrania i przebrania zwierzaka w sekcjach „Garderoba” i „Przebrania” oraz otwierać jego nagrody w sekcji „Nagrody”. Wcześniej te kafelki nie reagowały.

---

## <a id="v1.45.0"></a>Każda aplikacja ma własną głośność

<sub>1.45.0 · 13 października 2026</sub>

Ścisz głośną rozmowę, wycisz hałaśliwą grę i zostaw muzykę, jak jest.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.45.0/app-volume-dark.png"><img src="../media/whats-new/1.45.0/app-volume-light.png" width="340" alt=""></picture>

Otwórz Ustawienia › Dźwięk i włącz „Głośność aplikacji”. Każda aplikacja, która odtwarza dźwięk, dostaje własny suwak i przycisk wyciszenia, w Ustawieniach i w menu. Głośność Maca i pozostałych aplikacji się nie zmienia, a pikapik zapamiętuje poziom każdej aplikacji. Aplikacji, którą zostawisz na pełnej głośności, nigdy nie rusza.

Aby zmienić głośność aplikacji, pikapik przepuszcza jej dźwięk przez siebie, dlatego potrzebuje uprawnienia „Nagrywanie dźwięku systemowego”, które włączasz na stronie „Uprawnienia”. Dźwięk jest tylko przekazywany dalej: nie jest nagrywany, zapisywany ani nigdzie wysyłany, a mikrofon nie jest używany. Wymaga macOS 14.2 lub nowszego (w macOS 14.0 i 14.1 funkcja jest ukryta) i jest domyślnie wyłączone.

**Wypróbuj:** Ustawienia › Dźwięk › Głośność aplikacji

---

## <a id="v1.44.3"></a>Słowa wpisane w złym układzie poprawiają się same

<sub>1.44.3 · 13 października 2026</sub>

Wpisz słowo w złym układzie klawiatury, naciśnij klawisz Spacja, a pikapik przepisze je we właściwym i sam przełączy układ.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/layout-fix-dark.png"><img src="../media/layout-fix-light.png" width="340" alt=""></picture>

Włącz tę funkcję w Ustawieniach › Klawiatura. Gdy słowo wychodzi jako bełkot, na przykład ghbdtn zamiast привет, pikapik przepisuje je, gdy tylko naciśniesz klawisz Spacja lub Return, i przełącza układ, żeby kolejne słowo wyszło dobrze. Działa to z każdym układem klawiatury dodanym na twoim Macu, w każdym z twoich języków.

Zwykły tekst zostaje dokładnie taki, jak został wpisany. pikapik zmienia słowo tylko wtedy, gdy nie istnieje ono w żadnym z twoich języków, a te same klawisze w innym układzie dają popularne słowo. Imiona, literówki i rzadkie słowa zostają bez zmian, tak samo jak pola haseł, Terminal i wybrane przez ciebie aplikacje.

Jakieś słowo zostało bez poprawki albo chcesz cofnąć poprawkę? Naciśnij ⌃⇧Spacja, aby poprawić ostatnie słowo lub zaznaczony tekst, i naciśnij jeszcze raz, aby wypróbować inne układy. Zaraz po poprawce te same klawisze ją cofają, a pikapik nie będzie już sam poprawiał tego słowa. W wersji z Mac App Store zaznacz tekst i wybierz „Popraw układ klawiatury” z menu Usługi.

**Wypróbuj:** Ustawienia › Klawiatura › Poprawiaj słowa wpisane w złym układzie

---

## <a id="v1.44.2"></a>VoiceOver znowu otwiera menu pikapik

<sub>1.44.2 · 13 października 2026</sub>

W macOS 27 menu pikapik na pasku menu znowu otworzysz za pomocą VoiceOver.

Wcześniej aktywowanie ikony pikapik za pomocą VoiceOver lub innej funkcji dostępności nic nie dawało. Teraz menu się otwiera, a ponowne aktywowanie ikony je zamyka, tak jak kliknięcie.

---

## <a id="v1.44.0"></a>Zobacz, kto zajął port

<sub>1.44.0 · 13 października 2026</sub>

Nowa strona Porty w Ustawieniach pokazuje, który program zajmuje każdy port na twoim Macu, i zwalnia port, gdy go potrzebujesz.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/ports-dark.png"><img src="../media/ports-light.png" width="340" alt=""></picture>

Gdy program pisze, że jego port jest już zajęty, otwórz Ustawienia › Porty. Znajdziesz tam każdy program, który zajął port, z jego ikoną, portami, które trzyma, i informacją, czy mogą się z nim łączyć inne urządzenia w twojej sieci. Wpisz numer portu, aby sprawdzić, kto go trzyma, albo upewnić się, że jest wolny.

Kliknij wiersz, aby zobaczyć adresy, które otworzysz w przeglądarce, plik programu, polecenie, które go uruchomiło, jego folder i numer procesu. „Zwolnij port” prosi program o zakończenie, żeby zdążył zapisać swoją pracę. Jeśli się nie zamknie, pikapik proponuje wymuszenie zakończenia. Przed każdym krokiem pikapik pyta cię o zgodę.

Części macOS i programy innych użytkowników pozostają nietknięte. Przy usługach „Odbiornik AirPlay”, „Udostępnianie plików”, „Udostępnianie ekranu” i „Zdalne logowanie” pikapik podpowiada, który przełącznik w Ustawieniach systemowych zwalnia port. W wersji z Mac App Store przycisk „Zwolnij port” pokazuje program, kopiuje polecenie, które zakończy go w Terminalu, albo otwiera Monitor aktywności.

---

## <a id="v1.43.0"></a>Zobacz, co działa w tle

<sub>1.43.0 · 13 października 2026</sub>

pikapik pokazuje teraz wszystko, co uruchamia się samo, i która aplikacja to dodała, a twoje własne zadania wyłącza, niczego nie usuwając.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.43.0/background-dark.png"><img src="../media/whats-new/1.43.0/background-light.png" width="340" alt=""></picture>

Nowa strona Zadania w tle w Ustawieniach pokazuje aplikacje otwierane po zalogowaniu, usługi w tle, pomocników ukrytych w aplikacjach i pozostałości po usuniętych aplikacjach. Przy każdym zadaniu widać, która aplikacja je dodała, czy działa w tej chwili i gdzie leży jego plik. Jedno kliknięcie pokazuje plik w Finderze.

Własne zadania wyłączasz i włączasz z powrotem jednym przyciskiem. Nic nie jest usuwane. Przy zadaniach dla wszystkich użytkowników i dla całego Maca przycisk otwiera Rzeczy otwierane podczas logowania w Ustawieniach systemowych.

W wersji z Mac App Store strona pokazuje zadania, a jej przyciski otwierają Rzeczy otwierane podczas logowania.

---

## <a id="v1.42.0"></a>Zobacz, jak bardzo Mac nagrzał się w środku

<sub>1.42.0 · 13 października 2026</sub>

Nowa strona Temperatura w Ustawieniach pokazuje, jak bardzo nagrzały się procesor, grafika, pamięć, dysk, bateria i Wi-Fi, i prostymi słowami mówi, czy wszystko jest w porządku.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/temperatures-dark.png"><img src="../media/temperatures-light.png" width="340" alt=""></picture>

Otwórz Ustawienia › Temperatura. Na górze jedno słowo podsumowuje wszystko: „W normie”, „Ciepło”, „Gorąco” albo „Bardzo gorąco”, a krótki wiersz pod nim mówi, czy Mac działa z pełną prędkością, czy zwalnia, aby ostygnąć. Niżej każda część, którą Mac potrafi zmierzyć, ma swój wiersz z temperaturą i kolorowym paskiem: zielony oznacza, że wszystko gra, żółty, że jest ciepło, a pomarańczowy, że gorąco, zależnie od tego, co jest normalne dla danej części.

Chcesz mieć temperaturę zawsze na oku? Kliknij ołówek na dole menu pikapik i zaznacz pole „Temperatura”. Menu pokaże wtedy to samo słowo i temperaturę procesora, a kliknięcie wiersza otworzy stronę.

Temperatury odświeżają się co dwie sekundy, ale tylko wtedy, gdy strona albo menu są otwarte, więc w tle nic nie jest sprawdzane. pikapik tylko odczytuje temperatury: nie potrzebuje hasła i niczego nie zmienia.

**Poprawki**

- Jeśli menu pikapik pokazuje wybrane przez ciebie wiersze, wiersz „Trzymaj Dock na jednym ekranie” nie pojawia się już w nim sam. Aby go pokazać, kliknij ołówek i zaznacz go.
- Gdy zamykasz Ustawienia, pikapik od razu przestaje sprawdzać wentylatory i baterię, zamiast robić to dalej w tle.

---

## <a id="v1.41.1"></a>Sterowanie wentylatorami nie prosi już o hasło

<sub>1.41.1 · 13 października 2026</sub>

Pomocnik, który ustawia prędkość wentylatorów, aktualizuje się teraz razem z pikapik, więc nowe wersje nie proszą już o hasło administratora.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Ta aktualizacja poprosi o hasło po raz ostatni. Jeśli używasz sterowania wentylatorami, otwórz Ustawienia › Uprawnienia, kliknij „Zezwól” obok „Sterowanie wentylatorami” i wpisz hasło. Od tej pory pikapik sam aktualizuje pomocnika i przyjmuje tylko pomocnika, który naprawdę pochodzi od pikapik.

**Poprawki**

- W Ustawieniach systemowych › Ogólne › Rzeczy otwierane podczas logowania pomocnik wentylatorów wyświetla się teraz jako pikapik, z ikoną aplikacji.

---

## <a id="v1.41.0"></a>Zobacz, jak się miewa bateria

<sub>1.41.0 · 13 października 2026</sub>

Nowa strona Bateria w Ustawieniach pokazuje, jak zużyta jest bateria, czym się ładuje i jak sprawić, by działała dłużej.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/battery-dark.png"><img src="../media/battery-light.png" width="340" alt=""></picture>

Otwórz Ustawienia › Bateria. Zobaczysz poziom naładowania i to, co się teraz dzieje z baterią, jej stan, maksymalną pojemność w porównaniu z nową baterią oraz liczbę cykli, czyli ile z 1000, na jakie ją zaprojektowano, już zużyła.

Gdy Mac jest podłączony do prądu, strona pokazuje zasilacz i jego moc, a podczas ładowania także moc ładowania, czyli to, co teraz trafia do baterii. Gdy Mac działa na baterii, strona pokazuje, ile energii zużywa w tej chwili.

Wskazówki na dole pomagają baterii działać dłużej, a „Ustawienia baterii…” otwiera sekcję Bateria w Ustawieniach systemowych, gdzie wybierasz, jak macOS ją ładuje. Strona niczego nie zmienia i nie wymaga żadnych uprawnień, także w wersji z Mac App Store. Pojawia się tylko na komputerach Mac z baterią.

**Poprawki**

- Usunięcie pikapik przez Homebrew wyłącza teraz także „Otwórz przy logowaniu” i przywraca ustawienia systemowe zmienione przez aplikację, takie jak animacje, powtarzanie klawiszy i aktywne rogi. Jeśli pikapik aktualizował się sam, przed usunięciem uruchom raz brew upgrade --cask pikapik.

---

## <a id="v1.40.2"></a>Aktualizacje przez Homebrew już nie restartują Docka

<sub>1.40.2 · 13 października 2026</sub>

Gdy aktualizujesz pikapik przez Homebrew, Dock już nie znika na chwilę.

Aktualizacja do tej wersji może jeszcze ostatni raz zrestartować Docka, bo ten krok nadal wykonuje poprzednia wersja. Kolejne aktualizacje już go nie ruszają.

---

## <a id="v1.40.1"></a>Jedno kliknięcie w Docku chowa okna

<sub>1.40.1 · 13 października 2026</sub>

Kliknij w Docku ikonę aplikacji, w której pracujesz, a wszystkie jej okna zminimalizują się do Docka. Kliknij ponownie, a wszystkie wrócą.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.40.1/dock-minimize-dark.png"><img src="../media/whats-new/1.40.1/dock-minimize-light.png" width="340" alt=""></picture>

Otwórz Ustawienia › Dock i włącz „Minimalizuj lub ukrywaj kliknięciem w Docku”. Okna wracają w tej samej kolejności, a ostatnio używane okno ląduje na wierzchu. Kliknięcie innej aplikacji, przytrzymanie ikony, by otworzyć jej menu, i przeciąganie ikon działają tak jak wcześniej.

Wolisz ukryć całą aplikację, jak skrótem ⌘H? Pod przełącznikiem ustaw „Kliknięcie ikony” na „Ukrywa aplikację”. Jeśli już ukrywasz aplikacje kliknięciem w Docku, nic się dla ciebie nie zmienia. Przełącznik wymaga uprawnienia „Dostępność”, nie ma go w wersji z Mac App Store i domyślnie jest wyłączony.

---

## <a id="v1.40.0"></a>Dock zostaje na jednym ekranie

<sub>1.40.0 · 13 października 2026</sub>

Dock nie przeskakuje już na inny ekran, gdy wskaźnik zacznie napierać na krawędź tego ekranu, i zostaje tam, gdzie go ustawisz.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-display-dark.png"><img src="../media/dock-display-light.png" width="340" alt=""></picture>

Otwórz Ustawienia › Dock i włącz „Trzymaj Dock na jednym ekranie”. Dock zostaje wtedy na swoim ekranie, na dole lub z boku, a aktywne rogi dalej działają. Nie są potrzebne żadne uprawnienia, także w wersji z Mac App Store.

Aby celowo przenieść Dock, przytrzymaj ⌥ i dociśnij wskaźnik do krawędzi drugiego ekranu. Dock przejdzie na ten ekran i od tej pory zostanie na nim.

Drugi przełącznik, „Przywracaj Dock”, sam odsyła Dock na jego ekran po uśpieniu lub zmianie ekranów. Wymaga uprawnienia „Dostępność” i nie ma go w wersji z Mac App Store. Oba przełączniki są domyślnie wyłączone.

---

## <a id="v1.39.4"></a>Czerwony przycisk już nie zatrzymuje archiwów

<sub>1.39.4 · 13 października 2026</sub>

Wcześniej po zamknięciu okna hasła czerwonym przyciskiem pikapik aż do ponownego uruchomienia nie otwierał ani nie tworzył archiwów. To już naprawione.

Czerwony przycisk w oknie hasła i w oknie nowego archiwum działa teraz dokładnie tak jak „Anuluj”, a kolejne archiwum otwiera się od razu. VoiceOver odczytuje teraz przycisk aktualizacji na karcie „Informacje” w Ustawieniach jego własną nazwą.

---

## <a id="v1.39.3"></a>Zwierzak żyje w twoim rytmie

<sub>1.39.3 · 13 października 2026</sub>

Kiedy piszesz, zwierzak się ożywia i drepcze sprężystym krokiem. Gdy odejdziesz od Maca, zrobi się senny, usiądzie i zapadnie w drzemkę.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.3/pet-rhythm-dark.png"><img src="../media/whats-new/1.39.3/pet-rhythm-light.png" width="340" alt=""></picture>

Gdy przez mniej więcej 40 sekund nie dotykasz klawiatury ani myszy, powieki mu ciężeją, a po półtorej minucie śpi już jak suseł i unoszą się nad nim małe literki z. Naciśnij dowolny klawisz albo rusz myszą, a obudzi się, wstanie i pójdzie dalej. Kiedy drzemie, siedzi cicho i zużywa mniej energii.

pikapik nigdy nie podgląda, co piszesz. Sprawdza tylko, ile czasu minęło od ostatniego naciśnięcia klawisza lub ruchu myszy, tak samo jak macOS przed przyciemnieniem ekranu, więc nie potrzebuje żadnych uprawnień. Wolisz, żeby zwierzak zawsze był żwawy? Wyłącz „Żyje w twoim rytmie” w ustawieniach zwierzaka.

**Wypróbuj:** Ustawienia › Zwierzak › Żyje w twoim rytmie

---

## <a id="v1.39.2"></a>Synchronizowane ustawienia są teraz w folderze pikapik

<sub>1.39.2 · 13 października 2026</sub>

Jeśli synchronizujesz ustawienia przez iCloud, są one teraz w iCloud Drive, w folderze pikapik zamiast pika-tools, a pikapik sam je tam przenosi.

<img src="../media/icon.png" width="128" height="128" alt="">

Nie musisz nic robić: Twoje ustawienia pozostają takie same, a stary folder znika, gdy zostaną przeniesione. Jeśli są w nim Twoje własne pliki, zostaje na miejscu. Jeśli synchronizujesz kilka Maców, zaktualizuj pikapik na każdym z nich, żeby dalej dzieliły się ustawieniami.

**Poprawki**

- Całkowite usunięcie pikapik przez Homebrew (brew uninstall --zap) kasuje teraz także listę ostatnio usuniętych aplikacji.
- Starsze wpisy na tej stronie nazywają teraz aplikację pikapik.

---

## <a id="v1.39.1"></a>Zwykły pasek tytułu w oknach archiwów

<sub>1.39.1 · 13 października 2026</sub>

Okna archiwów znów mają zwykły pasek tytułu macOS z trzema okrągłymi przyciskami po lewej.

Okno można przeciągnąć za górną część, jak wszędzie na Macu. W oknie nowego archiwum i w oknie hasła czerwony przycisk zamyka okno, niczego nie tworząc ani nie rozpakowując. Przyciski, które w oknie są niepotrzebne, są szare. Te same przyciski ma teraz także okno, które pokazuje postęp tworzenia mniejszej kopii lub konwersji pliku. Przełącznik „Otwieraj archiwa w tej aplikacji” zapamiętuje teraz, która aplikacja otwierała wcześniej pliki ZIP i 7Z, i po wyłączeniu oddaje je tej aplikacji.

---

## <a id="v1.39.0"></a>Nowe okna archiwów i hasło wpisywane dwa razy

<sub>1.39.0 · 13 października 2026</sub>

Gdy zabezpieczasz nowe archiwum hasłem, wpisujesz je teraz dwa razy, więc literówka nie odetnie cię od własnych plików.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.0/archive-password-dark.png"><img src="../media/whats-new/1.39.0/archive-password-light.png" width="340" alt=""></picture>

Pod polami pojawia się zielony wiersz, gdy hasła się zgadzają, albo czerwony, gdy nie, a „Utwórz” czeka, aż będą takie same.

Wszystkie okna archiwów mają nowy wygląd: dużą ikonę, jeden przełącznik do hasła i krótki wiersz, który mówi, czy nazwy plików zostaną widoczne, jak w ZIP, czy też zostaną ukryte, jak w 7Z. W macOS 26 przyciski są z Liquid Glass.

Instalacja też jest prostsza: polecenie na początku strony pikapik na GitHubie nie potrzebuje niczego więcej na twoim Macu. Instaluje pikapik tylko wtedy, gdy pobrany plik jest podpisany przez twórcę i przeszedł kontrolę Apple pod kątem złośliwego oprogramowania.

---

## <a id="v1.38.2"></a>Bezpieczniejsze aktualizacje obok wersji z App Store

<sub>1.38.2 · 12 października 2026</sub>

Jeśli na Macu jest też pikapik z App Store, wersja z GitHuba aktualizuje się teraz w miejscu i nie rusza wersji z App Store.

Wcześniej, gdy wersja z GitHuba miała jeszcze starą nazwę pika-tools i nie była zainstalowana przez Homebrew, aktualizacja się nie instalowała, zamiast niej otwierała się wersja z App Store, a otwieranie aplikacji pikapik przy logowaniu było wyłączane.

---

## <a id="v1.38.1"></a>Bardziej niezawodne menu Findera

<sub>1.38.1 · 12 października 2026</sub>

Polecenia pikapik w menu pod prawym przyciskiem myszy w Finderze nie znikają już po podłączeniu dysku, otwarciu obrazu dysku, wybudzeniu Maca ani po przejściu do Findera.

W rzadkich przypadkach program pomocniczy, który je wyświetla, zamykał się właśnie w tym momencie.

---

## <a id="v1.38.0"></a>Otwieraj i twórz archiwa w Finderze

<sub>1.38.0 · 12 października 2026</sub>

Nowe „Archiwa w Finderze” otwierają archiwa RAR i inne, których macOS nie potrafi otworzyć, a z menu pod prawym przyciskiem myszy tworzą ZIP i 7Z.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/archive-dark.png"><img src="../media/archive-light.png" width="340" alt=""></picture>

Otwórz Ustawienia › Finder i włącz „Archiwa w Finderze”. Kliknij archiwum prawym przyciskiem i wybierz „Wypakuj”, a jego pliki pojawią się obok. Kliknij prawym przyciskiem dowolny inny plik lub folder i wybierz „Utwórz archiwum…”, aby powstał ZIP, 7Z, TAR.GZ lub TAR.XZ. ZIP i 7Z mogą mieć hasło, a każde archiwum można podzielić na części, na przykład po 15 MB do poczty. ZIP zrobiony w ten sposób nie zawiera ukrytych plików dodawanych przez system i zachowuje czytelne nazwy w każdym języku.

pikapik otwiera też to, czego nie otworzy macOS: RAR, nawet podzielony na kilka plików, 7Z zabezpieczony hasłem, ZIPX, CAB, LZH, ARJ, ZST, WIM i inne. Po dwukrotnym kliknięciu otwiera je pikapik. Nazwy plików w starych archiwach ZIP, na przykład zapisane cyrylicą, po japońsku lub po chińsku, wyświetlają się czytelnie. Przełącznik „Otwieraj archiwa w tej aplikacji” sprawia, że pikapik przejmuje także ZIP i 7Z, a TAR i GZ zostają przy wbudowanej aplikacji do archiwów, która już dobrze sobie z nimi radzi.

Okno pyta o hasło, „Zatrzymaj” przerywa każde zadanie, a z uszkodzonego archiwum pikapik wyciąga to, co da się jeszcze odczytać. Pyta, zanim wypakuje archiwum, które rozrosłoby się do ogromnego rozmiaru, i blokuje archiwa próbujące zapisywać poza własnym folderem. Nie ma tego w wersji z Mac App Store. Zaznacz archiwum i naciśnij spację, aby podejrzeć, co jest w środku.

---

## <a id="v1.37.3"></a>Plakietka FPS prosi o zgodę we właściwym miejscu

<sub>1.37.3 · 12 października 2026</sub>

Zgodę na nagrywanie ekranu dla plakietki FPS dajesz teraz na stronie Uprawnienia, razem ze wszystkimi innymi uprawnieniami.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Żeby policzyć klatki gry, „Pokaż FPS” może potrzebować nagrywania ekranu. Wcześniej pikapik prosił o nie wprost na stronie Gry. Teraz jest ono razem ze wszystkimi innymi uprawnieniami: gdy „Pokaż FPS” go potrzebuje, na stronie Uprawnienia w Ustawieniach pojawia się wiersz „Nagrywanie ekranu”, a ty klikasz w nim „Zezwól”.

Na stronie Gry zostaje teraz tylko zwykły wiersz pod przełącznikiem: „Wymaga uprawnienia. Kliknij, aby je nadać.” Jego przycisk „Zezwól” prowadzi prosto do wiersza „Nagrywanie ekranu”. Włączenie „Pokaż FPS” nie wyświetla już samo pytania, a pikapik nadal o nic nie prosi w trakcie gry.

---

## <a id="v1.37.2"></a>Sprawdzone przez Apple

<sub>1.37.2 · 12 października 2026</sub>

pikapik jest teraz podpisany przez zweryfikowanego programistę Apple i sprawdzony przez Apple. Dlatego macOS nie ostrzega już przy pierwszym otwarciu.

Po tej aktualizacji macOS może ponownie zapytać o uprawnienia nadane pikapik, na przykład Dostępność, Monitorowanie wejścia lub Pełny dostęp do dysku. Zezwól na nie jeszcze raz w Ustawieniach systemowych › Prywatność i ochrona. Jeśli używasz sterowania wentylatorami, zezwól na nie ponownie w ustawieniach pikapik, a macOS raz zapyta o hasło.

---

## <a id="v1.37.1"></a>Plakietka FPS nadąża za twoją grą

<sub>1.37.1 · 12 października 2026</sub>

Przesuń okno gry, a plakietka FPS przesunie się teraz razem z nim.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Wcześniej plakietka doganiała przesuwane okno tylko mniej więcej raz na sekundę, więc zostawała w tyle. Teraz sprawdza okno przy każdej klatce ekranu i nigdy nie spóźnia się o więcej niż kilka tysięcznych sekundy. Gdy okno stoi w miejscu, sprawdza je rzadziej, dzięki czemu podczas gry prawie nie obciąża twojego Maca. Nie przeskakuje też już w inne miejsce, gdy część okna wychodzi poza krawędź ekranu.

Jeśli spokojna gra, taka jak szachy, pokazuje 0, wszystko jest w porządku: takie gry rysują nowy obraz tylko wtedy, gdy coś się porusza. Liczba rośnie, gdy figura się przesuwa, i wraca do 0, gdy na szachownicy wszystko zamiera.

---

## <a id="v1.37.0"></a>Zobacz, jak płynnie działa twoja gra

<sub>1.37.0 · 12 października 2026</sub>

Nowe „Pokaż FPS” umieszcza w rogu gry mały licznik, dzięki czemu od razu widzisz, jak płynnie ona działa.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Otwórz Ustawienia › Gry i włącz „Pokaż FPS”. Gdy Tryb gry jest włączony, w rogu każdej gry pojawia się mała ciemna plakietka z liczbą. FPS to klatki na sekundę: ile obrazów gra rysuje w ciągu sekundy, a im większa liczba, tym płynniejsza gra. Aby wybrać róg, kliknij go na obrazku nad przełącznikiem.

Kliknięcia przechodzą przez plakietkę, a ona podąża za oknem gry. Kreska oznacza, że pierwsze klatki jeszcze nie dotarły, a przygaszone 0 — że gra przestała rysować. Opcja „Pokaż FPS” jest wyłączona, dopóki jej nie włączysz.

W macOS 27 większość gier liczy sam macOS, więc nie potrzeba żadnego uprawnienia. Niektóre gry, głównie starsze, można policzyć tylko przez nagrywanie ekranu, a wtedy liczba nie może być wyższa niż częstotliwość odświeżania ekranu. W macOS 14–26 i w wersji z Mac App Store każda gra jest liczona w ten sposób, dlatego po włączeniu „Pokaż FPS” pikapik prosi o uprawnienie „Nagrywanie ekranu”. Żaden obraz nie jest zapisywany ani wysyłany.

---

## <a id="v1.36.0"></a>Usuwaj aplikacje bez obaw

<sub>1.36.0 · 12 października 2026</sub>

Nowe Usuwanie aplikacji usuwa aplikację razem ze wszystkimi plikami i przywraca wszystko, jeśli zmienisz zdanie.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/uninstaller-dark.png"><img src="../media/uninstaller-light.png" width="340" alt=""></picture>

Otwórz Ustawienia › Usuwanie aplikacji i wybierz aplikację albo upuść ją na obrazek. pikapik pokaże wszystko, co aplikacja trzyma na twoim Macu, i powód, dla którego każdy plik jest na liście. Pliki, które wyraźnie należą do aplikacji, są zaznaczone, a te tylko możliwe powiązane nie są. Kliknij „Przenieś do Kosza”, a wszystko trafi do Kosza, więc nic nie jest kasowane na zawsze.

Zmieniasz zdanie? Kliknij „Przywróć”, a wszystko wróci na swoje miejsce. Ostatnie dziesięć usunięć czeka w sekcji „Ostatnio usunięte”, dopóki ich pliki są w Koszu. „Zresetuj aplikację” zostawia aplikację i usuwa tylko jej zapisane dane, ustawienia i pliki tymczasowe, na wypadek gdyby szwankowała.

Przenosisz aplikacje do Kosza ręcznie? Strona pokaże też takie aplikacje razem z plikami, które po sobie zostawiły, a specjalny przełącznik będzie proponował sprzątanie za każdym razem, gdy aplikacja trafi do Kosza. Nic nie jest usuwane, dopóki nie wybierzesz. Żeby zobaczyć wszystko, strona potrzebuje uprawnienia „Pełny dostęp do dysku”.

---

## <a id="v1.35.0"></a>Ubierz swojego zwierzaka

<sub>1.35.0 · 12 października 2026</sub>

Zwierzak ma już garderobę, a nowe rzeczy zdobywasz, kiedy bawicie się razem.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.35.0/wardrobe-dark.png"><img src="../media/whats-new/1.35.0/wardrobe-light.png" width="340" alt=""></picture>

Otwórz Ustawienia › Zwierzak i wybierz, co ma nosić zwierzak: kapelusze, okulary, szaliki, koszulki, buty, peleryny, a nawet skrzydła. Ubiera to od razu. Kilka rzeczy jest za darmo, a reszta to nagrody, które przychodzą podczas wspólnej zabawy: podnieś zwierzaka i rzuć nim, pokop piłkę, patrz, jak wspina się na okna i gada, albo po prostu dotrzymuj mu towarzystwa dzień po dniu. Kiedy zdobędziesz nagrodę, zwierzak ci o tym powie.

Gotowe przebrania ubierają zwierzaka od stóp do głów jednym kliknięciem: czarodziej, pirat, astronauta, superbohater, król i inne. Przebranie jest gotowe, gdy zdobędziesz wszystkie jego części.

Zapisywane są tylko proste liczby, jak kroki, rzuty i wspólne dni. Zostają na twoim Macu, nic nie jest nigdzie wysyłane, a wymazać je możesz w każdej chwili w Ustawieniach › Zwierzak.

---

## <a id="v1.34.0"></a>Mysz i gładzik w grach

<sub>1.34.0 · 12 października 2026</sub>

Przesunięcia, szczypnięcia i aktywne rogi nie wyrzucają już z gry, tak jak skróty klawiszowe.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.34.0/pointer-shortcuts-dark.png"><img src="../media/whats-new/1.34.0/pointer-shortcuts-light.png" width="340" alt=""></picture>

W ustawieniach (Ustawienia › Gry › Więcej ustawień gry) jest grupa „Mysz i gładzik”. Pokazuje tylko to, co jest włączone w macOS na twoim Macu, z nazwami od Apple i małym rysunkiem przy każdej pozycji: skróty na przycisku myszy, przesuwanie między biurkami i aplikacjami pełnoekranowymi, Mission Control i App Exposé, szczypnięcie dla aplikacji i rozsunięcie palców dla biurka, przesunięcie od prawej krawędzi dla Centrum powiadomień i każdy aktywny róg z jego działaniem. Gdy gra jest na wierzchu, wszystko to jest wstrzymane, więc przypadkowe przesunięcie palców albo muśnięcie rogu ekranu nie wyrzuci cię z gry. Gesty w samej grze nadal działają. Każdą pozycję można ustawić tak, by działała jak zwykle.

---

## <a id="v1.33.2"></a>Grupy skrótów otwierają się natychmiast

<sub>1.33.2 · 11 października 2026</sub>

Nawet najdłuższa grupa skrótów systemowych otwiera się od razu, a każdy wiersz ma czytelną nazwę.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Wcześniej okno ustawień na chwilę się zacinało, gdy otwierała się grupa z dziesiątkami wierszy, bo wszystkie wiersze z animowanymi podglądami powstawały naraz. Teraz powstają tylko wiersze widoczne na ekranie i kilka sąsiednich. Zniknęły też wiersze „Działanie systemowe” z numerem: Dyktowanie, Siri oraz klawisze jasności i powiększenia pokazują prawdziwe nazwy, a działania, którym macOS nie nadaje nazwy, są ukryte, ale w grach nadal są wstrzymywane jak dotąd.

---

## <a id="v1.33.1"></a>Grupy skrótów otwierają się bez zacięć

<sub>1.33.1 · 11 października 2026</sub>

Strona Gry działa płynnie, gdy rozwija się długa lista podglądów.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Rozwinięcie grupy systemowych skrótów klawiaturowych zamrażało okno ustawień nawet na trzy sekundy, bo każdy wiersz z podglądem był obliczany kilka razy. Teraz każdy wiersz jest obliczany tylko raz, więc grupy otwierają się niemal od razu.

---

## <a id="v1.33.0"></a>Wszystkie uprawnienia w jednym miejscu

<sub>1.33.0 · 11 października 2026</sub>

Ustawienia › Uprawnienia pokazują teraz wszystko, czego używa pikapik, i pozwalają cofnąć każde uprawnienie.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.33.0/permissions-dark.png"><img src="../media/whats-new/1.33.0/permissions-light.png" width="340" alt=""></picture>

Ustawienia › Uprawnienia pokazują teraz każde uprawnienie, którego używa pikapik: od Dostępności i Monitorowania wprowadzania po Sterowanie wentylatorami, Rozszerzenia Findera, iCloud Drive i Pełny dostęp do dysku. Każdy wiersz jednym zdaniem mówi, do czego służy, a zielony ptaszek oznacza, że jest włączone, pomarańczowy krzyżyk — że brakuje.

Każdy wiersz ma jeden przycisk: Zezwól, gdy uprawnienia brakuje, Wyłącz, gdy jest włączone. Dzięki temu cofniesz dowolne uprawnienie od razu na miejscu, bez szukania w Ustawieniach systemowych. Przy Dostępności i Monitorowaniu wprowadzania pikapik najpierw pyta, a potem uruchamia się ponownie bez nich.

Narzędzie, które potrzebuje nienadanego jeszcze uprawnienia, wygląda na wyszarzone. Kliknij je, a otworzą się Uprawnienia z podświetlonym właściwym wierszem, gotowe na jedno kliknięcie w Zezwól.

**Wypróbuj:** Otwórz Ustawienia › Uprawnienia i przyjrzyj się każdemu wierszowi. Kliknij wyszarzone narzędzie, żeby od razu przejść do uprawnienia, którego potrzebuje.

---

## <a id="v1.32.2"></a>Bezpieczniejsza instalacja, a aktualizacje nie gubią aplikacji

<sub>1.32.2 · 11 października 2026</sub>

Seria poprawek, które czynią instalację, aktualizację i usuwanie bezpieczniejszymi.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Pomocnik wentylatorów jest teraz instalowany staranniej i sprawdzany przed uruchomieniem. Jeśli aktualizacji nie da się skopiować, obecny pikapik zostaje na miejscu. Przy odinstalowaniu usuwany jest też pomocnik wentylatorów, a Twoje ustawienie powtarzania klawiszy, rogi Docka i skróty systemowe wracają do poprzedniego stanu.

Przytrzymane klawisze nie zacinają się już, gdy narzędzie się restartuje, a po wyłączeniu „Powtarzaj przytrzymany klawisz” wraca Twoje własne ustawienie menu akcentów. Zwierzak odpoczywa, gdy ekran śpi lub jest zablokowany, a kopia archive.tar.gz nazywa się teraz archive 2.tar.gz.

---

## <a id="v1.32.1"></a>Ręczna prędkość wentylatorów działa już za pierwszym razem

<sub>1.32.1 · 11 października 2026</sub>

Wybranie Ręcznie w Wentylatorach nie wraca już do Auto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Czasem pierwsze dotknięcie Ręcznie przywracało wentylatory do Auto z ostrzeżeniem o bezpieczeństwie i dopiero drugie działało. Teraz Ręcznie trzyma od pierwszej próby.

Jeśli wentylator sam wyjdzie z trybu ręcznego, pikapik naprawdę przywróci go do Auto, więc to, co widzisz, zawsze zgadza się z tym, co robi Twój Mac.

Nie musisz niczego zezwalać ponownie. Zaktualizuj i działa.

**Wypróbuj:** Otwórz Ustawienia › Wentylatory i wybierz Ręcznie.

---

## <a id="v1.32.0"></a>Zobacz, jak szybko kręcą się wentylatory

<sub>1.32.0 · 11 października 2026</sub>

Nowa karta Wentylatory pokazuje każdy wentylator na żywo i pozwala wybrać jego prędkość.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Wentylatory mają teraz własną kartę w Ustawieniach i wiersz w menu. Widzisz w czasie rzeczywistym, jak szybko kręci się każdy z nich, a obok kręci się mały wentylator.

Zostaw Auto, a Mac zdecyduje sam, jak zawsze. Albo wybierz Ręcznie i jednym suwakiem ustaw prędkość, jaką chcesz. Za pierwszym razem zezwalasz na to jednorazowo hasłem administratora i to wszystko.

Całość zaprojektowano z myślą o bezpieczeństwie. Wentylatory wracają do Auto, gdy zamykasz pikapik, gdy Mac przechodzi w stan uśpienia, gdy pikapik zakończy działanie awaryjnie albo gdy Mac się nagrzeje.

**Wypróbuj:** Otwórz Ustawienia › Wentylatory i zobacz prędkość. Wybierz Ręcznie, aby wypróbować suwak.

---

## <a id="v1.31.4"></a>Szczegóły wtedy, gdy ich potrzebujesz

<sub>1.31.4 · 11 października 2026</sub>

Spokojniejsza strona gier i jedno wyszukiwanie.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.4/game-choices-dark.png"><img src="../media/whats-new/1.31.4/game-choices-light.png" width="340" alt=""></picture>

Każdy tryb wyjaśnia swoje działanie na liście rozwijanej. Po jej zamknięciu na stronie zostaje tylko wybrana nazwa.

Usunięto opisy powtarzające nazwę działania. Przydatne dodatkowe informacje pozostają.

Wyszukiwanie globalne znajduje działania systemowe według nazwy, znaczenia i klawiszy. Wynik otwiera i wyróżnia konkretne ustawienie.

**Wypróbuj:** Znajdź działanie w wyszukiwaniu globalnym i otwórz listę jego trybów.

---

## <a id="v1.31.3"></a>Jednolity wygląd ustawień gry

<sub>1.31.3 · 11 października 2026</sub>

Spójne podglądy i bardziej zrozumiałe opcje skrótów.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.3/game-preview-dark.png"><img src="../media/whats-new/1.31.3/game-preview-light.png" width="340" alt=""></picture>

Każdy skrót ma teraz taki sam szeroki podgląd jak ochrona gry i pozostałe strony ustawień. Pod nim znajdują się opis, elementy sterujące i wyjaśnienie wybranej opcji.

«Według reguł trybu gry». Krótkie naciśnięcie zmienia język bez menu. Przytrzymywane klawisze gry zapobiegają przypadkowej zmianie.

«Wyłącz w grach». To działanie macOS jest wyłączone, gdy gra jest na pierwszym planie. Po jej opuszczeniu działa jak wcześniej. «Zezwól w grach». macOS wykonuje działanie normalnie, nawet jeśli otwiera okno lub przenosi fokus z gry.

**Wypróbuj:** Otwórz dodatkowe ustawienia gry, rozwiń funkcje systemu i wybierz zachowanie działania podczas gry.

---

## <a id="v1.31.2"></a>Czytelniejsze ustawienia gry

<sub>1.31.2 · 11 października 2026</sub>

Dostosuj ochronę i poznaj skróty swojego Maca.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.2/game-settings-dark.png"><img src="../media/whats-new/1.31.2/game-settings-light.png" width="340" alt=""></picture>

Osiem jasnych tematów zastępuje powtarzające się foldery. Każdy nagłówek ma nazwę, opis, ikonę i licznik. Kliknij dowolne miejsce w wierszu, aby go otworzyć.

Każde działanie objaśnia swój cel obok animowanego podglądu. Aktualne klawisze i zachowanie w grze mają osobny wiersz. Wyszukiwanie obejmuje również opisy.

Nieprzypisane klawisze mają czytelny link do Ustawień systemowych. Ogólne zabezpieczenia gry są w osobnej sekcji, a Twoje wybory zostają zachowane.

**Wypróbuj:** Otwórz dodatkowe ustawienia gry, rozwiń temat i porównaj opis działania z podglądem.

---

## <a id="v1.31.1"></a>Gest zmiany języka w grze

<sub>1.31.1 · 11 października 2026</sub>

Domyślnie prosto, z pełnym katalogiem systemowym w razie potrzeby.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/input-switch-dark.png"><img src="../media/input-switch-light.png" width="340" alt=""></picture>

Gest zmiany języka pikapik działa w grze nawet wtedy, gdy skróty językowe macOS nie są przypisane lub są wyłączone.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automatycznie wstrzymuje akcje otwierające okna lub przenoszące fokus. Krótki, celowy skrót języka zmienia źródło bez okna systemowego. Trzymane klawisze ruchu mają priorytet, więc bieganie i skoki nie zmieniają języka przypadkiem.

Każdą akcję można ustawić w przeszukiwanym katalogu. Język może zmieniać się w tle; inne akcje można wstrzymać lub pozwolić im działać normalnie. Wybory się synchronizują. Inne aplikacje obserwujące klawisze są osobno, a Wymuś koniec pozostaje dostępne.

**Wypróbuj:** Przytrzymaj ⌥ i naciśnij ⇧: następny język. Przytrzymaj ⇧ i naciśnij ⌥: poprzedni

---

## <a id="v1.31.0"></a>Tryb gry zna skróty Twojego Maca

<sub>1.31.0 · 11 października 2026</sub>

Domyślnie prosto, z pełnym katalogiem systemowym w razie potrzeby.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Włącz tryb gry i graj. Więcej ustawień gry zawiera katalog publikowany przez Maca, bieżące klawisze i animowany podgląd każdej akcji.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automatycznie wstrzymuje akcje otwierające okna lub przenoszące fokus. Krótki, celowy skrót języka zmienia źródło bez okna systemowego. Trzymane klawisze ruchu mają priorytet, więc bieganie i skoki nie zmieniają języka przypadkiem.

Każdą akcję można ustawić w przeszukiwanym katalogu. Język może zmieniać się w tle; inne akcje można wstrzymać lub pozwolić im działać normalnie. Wybory się synchronizują. Inne aplikacje obserwujące klawisze są osobno, a Wymuś koniec pozostaje dostępne.

**Wypróbuj:** Otwórz dodatkowe ustawienia, wyszukaj skrót zrzutu lub języka i porównaj podgląd z ochroną i bez niej.

---

## <a id="v1.30.14"></a>Linki skrótów otwierają się bez awarii

<sub>1.30.14 · 11 października 2026</sub>

Kliknięcie wyłączonego skrótu nie zamyka już pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Na stronie Gry można kliknąć skrót nawet bez przypisanych klawiszy. Ustawienia systemowe otwierają się bezpiecznie.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Wcześniej pikapik mógł dwa razy odczytać ten sam zmieniający się wiersz podczas otwierania okna. Jeśli tekst znikał między odczytami, aplikacja ulegała awarii.

Każdy wiersz jest teraz czytany raz. Brakujący tekst jest pomijany. Poprawka obejmuje też linki skrótów na innych stronach.

**Wypróbuj:** Kliknij wyłączony skrót na stronie Gry.

---

## <a id="v1.30.13"></a>Trzymaj Control i graj dalej

<sub>1.30.13 · 10 października 2026</sub>

Control nie pozwala już zmianie języka zabrać Spacji grze.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Trzymaj Control, aby biec, i naciskaj Spację, aby skakać. W trybie gry zmiana języka przez Control+Spacja i Control+Option+Spacja jest wstrzymana.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Inne skróty macOS z Control lub z Shift i Option bez Command też są wstrzymane, również własne ustawienia. Naciśnięcia, puszczanie i trzymane klawisze trafiają razem do gry.

Gest zmiany języka pikapik i skróty wyjścia z modyfikatorami gry też nie przeszkadzają. Po wyjściu z gry skróty systemu wracają dokładnie do wcześniejszego stanu.

**Wypróbuj:** Trzymaj Control, poruszaj się i kilka razy naciśnij Spację. Wyjdź z gry i zmień język jak zwykle.

---

## <a id="v1.30.12"></a>Przeciągnij grę z Monitora aktywności

<sub>1.30.12 · 10 października 2026</sub>

Tryb gry przyjmuje procesy przeciągnięte z Monitora aktywności.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Znajdź proces gry i przeciągnij jego wiersz na Twoje gry w Ustawieniach → Gry.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Gry Java działają też bez zwykłej ikony w Docku. Wcześniej te wiersze były ignorowane, bo zawierają numer i nazwę procesu zamiast pliku.

Gra zostaje zapisana na kolejne uruchomienia. Minecraft ma własną nazwę. Numer i nazwa muszą pasować do uruchomionego procesu.

**Wypróbuj:** Przeciągnij wiersz java uruchomionego Minecrafta na Twoje gry.

---

## <a id="v1.30.11"></a>Dodaj grę, kiedy jest uruchomiona

<sub>1.30.11 · 10 października 2026</sub>

Otwarte gry są teraz widoczne jako pierwsze podczas dodawania gry.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Otwórz Ustawienia → Gry → Dodaj grę i kliknij uruchomioną grę. Gry korzystające z Javy i innych środowisk też się pojawiają, nawet bez pliku .app. Minecraft ma nazwę Minecraft zamiast java.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Aplikacje z Docka mają osobną rozwijaną listę, dzięki czemu od razu znajdziesz uruchomioną grę.

Inne… oraz przeciąganie przyjmują też plik wykonywalny gry, oprócz aplikacji. Po dodaniu tryb gry włącza się, gdy przejdziesz do gry.

**Wypróbuj:** Zostaw grę otwartą, wybierz Dodaj grę i kliknij jej ikonę. Bez szukania folderów.

---

## <a id="v1.30.10"></a>Zwierzak nie znika, gdy skacze

<sub>1.30.10 · 10 października 2026</sub>

Zwierzak nie chowa się już za oknami, gdy skacze na ekranie bez Docka.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Wcześniej, gdy Dock był na innym ekranie albo się ukrywał, zwierzak skakał za oknami i znikał aż do lądowania. Teraz, gdy tylko oderwie się od ziemi, widać go przed oknami na każdym ekranie, z Dockiem i bez. Piłka tak samo.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Okno, które tylko dotyka krawędzi zwierzaka, nie chowa go już w czasie skoku. Zwierzak zostaje za oknem tylko wtedy, gdy okno naprawdę go zasłania, na przykład film, który oglądasz.

Na ziemi zwierzak i jego piłka spacerują za Twoimi oknami, tak jak wcześniej.

**Wypróbuj:** Włącz automatyczne ukrywanie Docka albo przenieś go na inny ekran i naciśnij spację obok okna. Zwierzak podskoczy przed nim.

---

## <a id="v1.30.9"></a>Pełny ekran jest twój, a piłka gra uczciwie

<sub>1.30.9 · 10 października 2026</sub>

Zwierzak nie wyskakuje już w filmie na pełnym ekranie, a piłka nie obija się o rzeczy, których nie ma.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Wcześniej podczas oglądania filmu na pełnym ekranie zwierzak czasem się pojawiał. Teraz pikapik pyta macOS wprost, czy na ekranie jest coś otwarte na pełnym ekranie, i sprawdza jeszcze raz, gdy przełączanie się skończy. Zwierzak i piłka zostają ukryte, dopóki nie wyjdziesz z pełnego ekranu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Piłka nie odbija się już od pustego powietrza. Przelatuje nad Dockiem, zamiast uderzać w niewidzialną ścianę. Mysz trafia teraz w piłkę tylko wtedy, gdy kursor naprawdę jej dotyka. Lekkie dotknięcie ją toczy, szybki ruch posyła ją w powietrze. A jeśli zwierzak lub piłka chowają się za oknem, mysz nad tym oknem zostawia je w spokoju.

Przeciąganie pliku po biurku nie buduje już zwierzakowi stopnia. Robi to tylko ramka zaznaczenia.

**Wypróbuj:** Obejrzyj film na pełnym ekranie i kilka razy zatrzymaj go spacją. Zwierzak się nie pokaże. Potem machnij myszą w piłkę.

---

## <a id="v1.30.8"></a>Rogi ekranu milczą, gdy grasz

<sub>1.30.8 · 10 października 2026</sub>

W trybie gry mysz przy krawędziach i w rogach ekranu nie uruchamia już aktywnych narożników ani nie wysuwa ukrytego Docka.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Wcześniej w środku rozgrywki mysz w rogu albo przy krawędzi ekranu mogła uruchomić aktywny narożnik albo wysunąć ukryty Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Teraz tryb gry wyłącza aktywne narożniki i ukryty Dock na czas gry. Kilka sekund po wyjściu z gry albo po zamknięciu pikapik wracają dokładnie takie, jakie były.

A wskaźnik nie szarpie już przy krawędzi ekranu z grą.

**Wypróbuj:** Włącz tryb gry, uruchom grę i przesuń mysz w róg ekranu. Nic nie wyskoczy.

---

## <a id="v1.30.7"></a>Zwierzak nie wchodzi już w kadr

<sub>1.30.7 · 10 października 2026</sub>

Gdy zwierzak albo piłka są za oknem, zostają tam, nawet gdy skaczą lub latają.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Wcześniej, gdy zwierzak albo piłka chowali się za filmem lub grą, skok czy lot mógł ich wynieść prosto nad to, co oglądasz. Spacja do pauzowania filmu też wywabiała zwierzaka.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Teraz zostają za oknem, które ich zasłania, cokolwiek robią. A film na pełnym ekranie w Firefoksie chowa ich od razu.

Za zwykłymi oknami nadal chowają się tak jak wcześniej.

**Wypróbuj:** Włącz film w dużym oknie, które zasłania dół ekranu, i naciśnij spację, żeby go zatrzymać. Zwierzak zostanie za filmem.

---

## <a id="v1.30.6"></a>Na pełnym ekranie zwierzak odpoczywa wszędzie

<sub>1.30.6 · 10 października 2026</sub>

Gdy dowolna aplikacja działa na pełnym ekranie, zwierzak i piłka chowają się teraz na wszystkich monitorach.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Wcześniej, gdy włączałeś film albo grę na pełnym ekranie, zwierzak i piłka czasem uciekali na inny monitor i tam bawili się dalej.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Teraz, gdy dowolna aplikacja jest na pełnym ekranie, chowają się na wszystkich twoich monitorach. Wyjdź z pełnego ekranu, a od razu wrócą.

Za zwykłymi oknami nadal chowają się tak jak wcześniej.

**Wypróbuj:** Jeśli masz dwa monitory, włącz film na pełnym ekranie na jednym z nich. Zwierzak i piłka znikną z obu i wrócą, gdy wyjdziesz z pełnego ekranu.

---

## <a id="v1.30.5"></a>Zwierzak schodzi z drogi, gdy oglądasz albo grasz

<sub>1.30.5 · 10 października 2026</sub>

Zwierzak i piłka chowają się teraz, gdy aplikacja działa na pełnym ekranie, także na Macach z notchem.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Wcześniej na Macu z notchem zwierzak potrafił zostać na wierzchu filmu lub gry na pełnym ekranie, a piłka czasem wyskakiwała nad aplikacją na pełnym ekranie na innym monitorze.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Teraz, gdy aplikacja zajmuje cały ekran, zwierzak i piłka czekają poza zasięgiem wzroku. Wyjdź z pełnego ekranu, a od razu wrócą.

Za zwykłymi oknami nadal chowają się tak jak wcześniej.

**Wypróbuj:** Włącz film na pełnym ekranie albo uruchom grę. Zwierzak i piłka nie przeszkadzają, dopóki nie skończysz.

---

## <a id="v1.30.4"></a>Zwierzaka widać, gdy skacze albo jedzie na zaznaczeniu

<sub>1.30.4 · 10 października 2026</sub>

Zwierzak i piłka nie znikają już za oknami, gdy są w powietrzu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Wcześniej, gdy zwierzak przeskakiwał nad kursorem albo wjeżdżał w górę na ramce zaznaczenia, zasłaniało go okno powiększone na cały ekran i wyglądało, jakby zniknął.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Teraz, dopóki zwierzak albo piłka są wyżej niż Dock, pokazują się przed oknami. Po powrocie na ziemię znów chowają się za nimi.

A zwierzak znów może spacerować za Dockiem, tak jak dawniej.

**Wypróbuj:** Powiększ okno na cały ekran, zacznij ramkę zaznaczenia na biurku obok Docka, żeby zwierzak na nią wszedł, i powoli ciągnij ją w górę. Zwierzak jedzie na niej przed oknem.

---

## <a id="v1.30.3"></a>Zwierzak i piłka nie chowają się już pod Dockiem

<sub>1.30.3 · 9 października 2026</sub>

Zwierzak nie spaceruje ani nie śpi już pod Dockiem, więc zawsze go widać.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Wcześniej zwierzak i piłka często spacerowali i odpoczywali tuż pod Dockiem, gdzie nikt ich nie widział. Przy oknie powiększonym na cały ekran wyglądało, jakby zwierzak zniknął na dobre.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Teraz Dock jest dla nich jak ściana. Zwierzak zawraca przy jego krawędzi, a piłka się od niego odbija.

Dzięki temu zwierzaka zawsze widać obok Docka, nawet gdy okno zajmuje cały ekran.

**Wypróbuj:** Powiększ okno na cały ekran i popatrz przez kilka minut. Zwierzaka cały czas widać po lewej albo po prawej stronie Docka.

---

## <a id="v1.30.2"></a>Zwierzak nie znika już za oknami

<sub>1.30.2 · 9 października 2026</sub>

Nawet gdy zasłoni go okno, zwierzak dalej żyje i spada na ziemię, gdy puścisz zaznaczenie.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Gdy okna zasłaniały cały pasek, na którym mieszka zwierzak, pikapik go wstrzymywał i mógł zastygnąć w powietrzu. Teraz zwierzak i jego piłka żyją dalej za oknem: chodzą, spadają i się bawią. Odpoczywa tylko rysowanie.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Jeśli ramka zaznaczenia podniesie zwierzaka za oknem, spadnie on, gdy tylko ją puścisz, i znów zobaczysz go przy Docku.

A ramka zaznaczenia nie podnosi już zwierzaka wyżej niż jego pasek.

**Wypróbuj:** Powiększ okno na cały ekran, podnieś zwierzaka ramką zaznaczenia za oknem i puść. Zwierzak spadnie i pojawi się przy Docku.

---

## <a id="v1.30.1"></a>Zaznaczanie na biurku znów działa

<sub>1.30.1 · 9 października 2026</sub>

Zwierzak i jego piłka znów wskakują na ramki zaznaczenia, a listy aplikacji podświetlają się tylko dla aplikacji.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Gdy Dock albo aplikacja do zdalnego pulpitu zakrywała cały ekran, pikapik nie zauważał ramki zaznaczenia, którą rysujesz na biurku. Teraz znów ją zauważa, a zwierzak i piłka wskakują na nią jak dawniej.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Listy aplikacji w ustawieniach podświetlają się tylko wtedy, gdy przeciągasz nad nie aplikację. Inne pliki są pomijane: ramka się nie pojawia i nic zbędnego nie zostaje dodane. Jeśli przeciągniesz aplikację razem z innymi plikami, dodana zostanie tylko aplikacja.

A ramka gaśnie, gdy tylko upuścisz aplikację albo odsuniesz kursor.

**Wypróbuj:** Narysuj ramkę zaznaczenia na biurku i zobacz, jak zwierzak na nią wskakuje.

---

## <a id="v1.30.0"></a>Zakończ już nie wyłącza pikapik

<sub>1.30.0 · 9 października 2026</sub>

Wybrałeś Zakończ z przyzwyczajenia? Skróty, „Bez usypiania” i Twój zwierzak nadal działają.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/keep-awake-dark.png"><img src="../media/keep-awake-light.png" width="340" alt=""></picture>

Gdy wybierzesz „Zakończ”, naciśniesz ⌘Q albo zakończysz pikapik z Docka, zamyka on swoje okna i chowa ikonę z paska menu, ale dalej cicho działa w tle: skróty, „Bez usypiania” i zwierzak zostają włączone. Aby przywrócić ikonę, po prostu otwórz pikapik jeszcze raz.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Chcesz naprawdę zakończyć? Przytrzymaj Option (⌥) i wybierz „Zakończ” albo naciśnij ⌥⌘Q. Gdy pikapik pierwszy raz przechodzi w tło, wyjaśnia, co się stało, i od razu proponuje zakończenie całkowite.

Wolisz po staremu? Wyłącz „Działaj w tle po zakończeniu” w Ustawieniach › Ogólne. Aktualizacje, zmiana języka, wylogowanie, ponowne uruchomienie i wyłączenie komputera zawsze kończą pikapik całkowicie, więc nigdy nie muszą na niego czekać.

**Wypróbuj:** Naciśnij ⌘Q, a potem otwórz pikapik jeszcze raz, aby przywrócić ikonę.

---

## <a id="v1.29.1"></a>Zwierzak spaceruje po wszystkich ekranach

<sub>1.29.1 · 9 października 2026</sub>

Masz więcej niż jeden monitor? Zwierzak i jego piłka są teraz wszędzie, gdzie spojrzysz, i nigdy się nie gubią.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Gdy zwierzak dojdzie do krawędzi ekranu, po prostu przechodzi na sąsiedni, a piłka toczy się za nim. Możesz też wziąć zwierzaka albo piłkę myszą i przenieść na dowolny ekran. Gdy aplikacja przejdzie na pełny ekran, przenoszą się na inny ekran, żeby nie przeszkadzać, a gdy odłączysz monitor, wracają na główny.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Piłka już nie utyka w rogu. Zwierzak podbiega, podrzuca ją do tyłu nad głową i bawi się dalej.

I zwierzak już nie znika. Co dwie sekundy sprawdza, czy jest na ekranie, a jeśli coś poszło nie tak, po uśpieniu, zablokowaniu Maca, zmianie biurka albo pełnym ekranie, sam od razu wraca.

**Wypróbuj:** Przenieś zwierzaka na inny ekran albo wtocz piłkę do rogu.

**Poprawki**

- Rzucony zwierzak nie ląduje już na ramce zaznaczenia, która jest wyżej, niż może skoczyć, i przez to nie znika.

---

## <a id="v1.29.0"></a>Twój zwierzak ma piłkę

<sub>1.29.0 · 9 października 2026</sub>

Na dole ekranu toczy się teraz mała piłka do nogi. Zwierzak się nią bawi, a ty też możesz.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Piłka toczy się i odbija jak prawdziwa. Zwierzak biegnie za nią, kopie ją i znowu goni. Przesuń szybko wskaźnik po piłce, żeby kopnąć ją samemu, albo złap ją, przenieś i rzuć, tak jak zwierzaka.

Mały trik: kliknij puste miejsce na biurku i przeciągnij, żeby narysować ramkę zaznaczenia, z Shift albo bez. Dopóki trzymasz przycisk myszy, ramka staje się półką: zwierzak na nią wskakuje, a piłka też może na niej wylądować. Puść przycisk, a półka zniknie.

Wolisz spokój na biurku? Wyłącz Piłkę w ustawieniach zwierzaka, a znowu będzie spacerował sam.

**Wypróbuj:** Ustawienia › Zwierzak › Piłka

**Poprawki**

- Obok Docka zwierzak znowu skacze tak wysoko, jak chce. Nisko trzyma się tylko wtedy, gdy jest dokładnie nad Dockiem, więc nigdy nie wystaje ponad niego.

---

## <a id="v1.28.0"></a>Aplikacje dodasz jednym kliknięciem albo przeciągając

<sub>1.28.0 · 9 października 2026</sub>

Każda lista aplikacji w Ustawieniach pokazuje teraz to, co masz w Docku i co jest właśnie otwarte, a aplikacje możesz przeciągać na nią z Findera.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Przy niektórych funkcjach wybierasz aplikacje, w których mają się nie wtrącać, na przykład przy zielonym przycisku albo Home i End. Wcześniej „Dodaj aplikację…” otwierało tylko długi folder ze wszystkim. Teraz pojawia się półka z aplikacjami z Docka i tymi, które są teraz otwarte. Kliknij aplikację, żeby ją dodać, i jeszcze raz, żeby ją zabrać. Wszystko inne znajdziesz w „Inne…”.

Możesz też przeciągnąć aplikację z Findera prosto na listę. Lista podświetli się i pokaże, gdzie aplikacja trafi. Z grami jest tak samo, z tą samą półką.

A gdy coś pójdzie nie tak, w formularzu zgłaszania błędu na GitHubie wybierzesz teraz wersję pikapik i macOS z listy, więc opowiesz nam o tym szybciej.

**Wypróbuj:** Ustawienia › Okna, potem „Dodaj aplikację…”

**Poprawki**

- Przewijanie przez AnyDesk lub inną aplikację pulpitu zdalnego nie jest już odwracane dwa razy, gdy na obu Macach ustawiony jest klasyczny kierunek. Teraz pikapik odwraca tylko przewijanie z prawdziwej myszy lub gładzika. Jeśli aplikacja sama robi płynne przewijanie, jak Mos, ustaw kierunek w niej.
- Zwierzak zostaje za Dockiem, gdy skacze, tak samo jak gdy chodzi, i sam wraca, gdy wyjdziesz z aplikacji na pełnym ekranie albo z gry.
- Cienkie ramki wokół małych obrazków w Ustawieniach nie znikają już na zwykłych ekranach bez Retina.

---

## <a id="v1.27.3"></a>Zwierzak zawsze na widoku, a okna otwierają się gotowe

<sub>1.27.3 · 9 października 2026</sub>

Zwierzak nie chowa się już za oknami w połowie skoku, a okna pikapik otwierają się od razu gotowe do pracy.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Gdy zwierzak przeskakiwał nad kursorem albo fikał koziołka, mógł wślizgnąć się za okna innych aplikacji i zniknąć w powietrzu. Teraz przez cały skok zostaje z przodu, a po wylądowaniu wraca za Twoje okna.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Gdy pikapik uruchamiał się po cichu w tle, przy logowaniu, po aktualizacji albo z linku pikapik://, jego okna mogły otwierać się szare i zostawać za innymi, dopóki ich nie kliknąłeś. Teraz Ustawienia i okienko Nowy plik wychodzą na wierzch i od razu można pisać.

Tak samo jest z komunikatem po Utwórz mniejszą kopię i z listą, w której wybierasz aplikację do dodania. Nie musisz nic robić.

**Wypróbuj:** Ustawienia › Zwierzak

---

## <a id="v1.27.2"></a>Nowy plik wrócił, a Ustawienia są jeszcze lżejsze

<sub>1.27.2 · 9 października 2026</sub>

Nowy plik znów jest w menu prawego kliknięcia w Finderze u wszystkich, a Ustawienia jeszcze mniej obciążają Maca.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Po ostatniej aktualizacji Finder mógł po cichu uruchomić Nowy plik od nowa i zapomnieć, w których folderach działa, więc pozycja znikała z menu prawego kliknięcia. Teraz Nowy plik przy każdym starcie przypomina Finderowi o swoich folderach, a pikapik chwilę po uruchomieniu sprawdza, czy Finder je zapamiętał. Nie musisz nic robić.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Ruchome obrazki w Ustawieniach poruszają się teraz tylko wtedy, gdy widać na ekranie co najmniej połowę obrazka. Na obrazkach z grami mały bohater nadal porusza się 30 razy na sekundę, a wzgórza i ziemia za nim 15 razy. Dzięki temu strona Gry dużo mniej obciąża Maca. Wszystko wygląda tak samo.

Po aktualizacji pikapik nie dodaje już na nowo swoich pozycji w Finderze, chyba że aplikacja naprawdę zmieniła miejsce, więc Finder nie musi ich za każdym razem wczytywać od nowa.

**Wypróbuj:** Ustawienia › Gry

---

## <a id="v1.27.1"></a>Ciszej, lżej i Finder gotowy od razu

<sub>1.27.1 · 9 października 2026</sub>

Ustawienia prawie nie obciążają Maca, a polecenia z prawego kliknięcia w Finderze działają zaraz po przeprowadzce do pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/wheel-lines-dark.png"><img src="../media/wheel-lines-light.png" width="340" alt=""></picture>

Małe ruchome obrazki w Ustawieniach rysowały wcześniej całą stronę od nowa wiele razy na sekundę, więc samo otwarte okno zajmowało Maca. Teraz każdy obrazek rysuje od nowa tylko siebie, najwyżej 30 razy na sekundę, i odpoczywa, gdy go przewiniesz albo ukryjesz okno. Wyglądają dokładnie tak samo.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Po przeprowadzce z pika-tools do pikapik Finder mógł dalej szukać starej aplikacji, a „Nowy plik”, „Konwertuj na” i inne polecenia z prawego kliknięcia nic nie robiły. Teraz pikapik zauważa to przy pierwszym uruchomieniu i sam uruchamia Findera ponownie, gdy nie ma otwartych okien Findera i nic się nie kopiuje. W przeciwnym razie na stronie Finder pojawi się krótka linijka z przyciskiem „Uruchom ponownie Findera”.

W Ustawieniach systemowych, wśród aplikacji otwieranych przy logowaniu, aplikacja ma teraz nową nazwę, pikapik, i zostaje włączona.

**Wypróbuj:** Ustawienia › Finder

---

## <a id="v1.27.0"></a>Poznaj zwierzaka na biurku

<sub>1.27.0 · 9 października 2026</sub>

Na dole ekranu mieszka teraz mały przyjaciel, a aplikacja ma nową nazwę: pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Włącz go w Ustawienia › Zwierzak. Spaceruje za oknami i Dockiem, przeskakuje wskaźnik, gdy ten stoi mu na drodze, i podskakuje, gdy naciśniesz spację. Możesz go podnieść, przenieść, rzucić i złapać w połowie skoku.

Czasem siada i mówi coś krótkiego. Gdy naprawdę wyjdzie nowa wersja, powie ci o tym raz, a kliknięcie w niego otworzy Ustawienia, gdzie czeka uaktualnienie.

pika-tools nazywa się teraz pikapik. Uprawnienia, ustawienia i linki w Skrótach zostają bez zmian. Jeśli instalujesz przez Homebrew, uruchom raz `brew update && brew upgrade --cask pikapik`.

**Wypróbuj:** Ustawienia › Zwierzak

**Poprawki**

- Sprawdzanie uaktualnień zgłaszało nową wersję, nawet gdy miałeś już najnowszą.
- Strona Uprawnienia obciążała Maca, dopóki była otwarta.

---

## <a id="v1.26.2"></a>„Co nowego” w Twoim języku

<sub>1.26.2 · 8 października 2026</sub>

„Co nowego” w ustawieniach otwiera teraz tę stronę, w tym samym języku co aplikacja.

<img src="../media/icon.png" width="128" height="128" alt="">

Otwórz Ustawienia › Informacje i kliknij „Co nowego”. Trafiasz prosto tutaj, na stronę z obrazkiem do każdej aktualizacji, w języku, którym mówi pikapik.

Pełna lista zmian też jest bardziej uporządkowana. Każda wersja pokazuje dzień wydania, a każdy numer wersji otwiera jej stronę pobierania.

W działaniu pikapik nic się nie zmienia. Aktualizacje przychodzą jak dotąd, same albo przez Homebrew.

**Wypróbuj:** Ustawienia › Informacje › Co nowego

**Poprawki**

- „Co nowego” otwierało długą techniczną listę po angielsku zamiast tej strony.
- Linki na liście zmian, które prowadziły donikąd, otwierają teraz właściwą stronę.

---

## <a id="v1.26.1"></a>Obrazki gier ożyły

<sub>1.26.1 · 8 października 2026</sub>

Obrazki na stronie „Gry” teraz się ruszają, więc widać, co zatrzymuje każdy przełącznik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.26.1/game-previews-dark.png"><img src="../media/whats-new/1.26.1/game-previews-light.png" width="340" alt=""></picture>

Za każdym przełącznikiem na stronie „Gry” toczy się teraz mała gra. Pojawiają się klawisze, zostają naciśnięte i widać, co wyskoczyłoby nad grą, na przykład Spotlight albo Mission Control, a gra staje. Gdy przełącznik jest włączony, klawisze tylko łagodnie się rozświetlają, a gra toczy się dalej. Przestaw przełącznik, a obrazek od razu pokaże różnicę.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Mała gra dopasowuje się do wyglądu Maca: w trybie jasnym to słoneczny dzień, a w ciemnym spokojna noc z księżycem i gwiazdami.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Na wszystkich obrazkach w aplikacji wskaźnik porusza się teraz jak ręka: na dłuższą drogę daje sobie trochę więcej czasu, zatrzymuje się i dopiero wtedy klika. Gdy obrazek zaczyna się od nowa, płynnie wraca na początek zamiast skakać. Gdy okno jest zasłonięte, obrazki odpoczywają, a z włączonym „Ogranicz ruch” stoją w miejscu.

**Wypróbuj:** Ustawienia › Gry

---

## <a id="v1.26.0"></a>Nowa ikona i porządek ze starymi uprawnieniami

<sub>1.26.0 · 8 października 2026</sub>

pikapik ma nową twarz i teraz usuwa uprawnienia, które zostają po usuniętych aplikacjach.

<img src="../media/icon.png" width="128" height="128" alt="">

Nowa ikona to znak pikapik w kolorach niebieskim, fioletowym i koralowym na ciemnym kafelku. Pasek menu pokazuje ten sam kształt, który dopasowuje się do jasnego lub ciemnego paska. Gdy wszystkie narzędzia są wyłączone, kształt blednie.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>

Gdy usuwasz aplikację, macOS zachowuje nadane jej uprawnienia, a w Ustawieniach systemowych nie da się ich usunąć. Teraz na stronie „Uprawnienia” jest lista „Pozostałości po usuniętych aplikacjach”: każda aplikacja z ikoną, co mogła robić i kiedy. „Usuń” czyści jedną aplikację, „Usuń wszystkie” wszystkie naraz, a aplikacja zainstalowana ponownie po prostu zapyta jeszcze raz. Żeby zobaczyć listę, daj pikapik pełny dostęp do dysku: tylko patrzy i niczego nie zmienia, dopóki nie klikniesz „Usuń”.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Obrazki na stronach „Animacje” i „Gry” są narysowane od nowa w swoim prawdziwym rozmiarze, więc są ostre. Okno zmniejsza się do Docka z zaokrąglonymi rogami, a kursor najpierw klika i dopiero potem otwiera się menu. A na dole „Informacji” jest teraz cicha linijka: „Zrobione z sercem · Postaw mi kawę”. Nic nie wyskakuje i o niczym nie przypomina.

**Wypróbuj:** Ustawienia › Uprawnienia, potem „Pozostałości po usuniętych aplikacjach”

**Poprawki**

- Kliknięcie skrótu systemowego otwiera od razu jego sekcję w Ustawieniach systemowych, na przykład Mission Control, a nie tylko „Klawiaturę”.
- Wskazówka obok klawiszy nie znika już w chwili, gdy otwierają się Ustawienia systemowe.

---

## <a id="v1.25.2"></a>Skróty otwierają się tam, gdzie je zmieniasz

<sub>1.25.2 · 8 października 2026</sub>

Kliknij skrót w Ustawieniach, a Ustawienia systemowe otworzą się we właściwym miejscu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Wcześniej kliknięcie skrótu, na przykład dla Spotlight, zawsze prowadziło do „Klawisze modyfikujące”. Teraz klawisze Spotlight otwierają od razu Spotlight.

Przy innych skrótach Ustawienia systemowe otwierają się na „Klawiatura”, a obok klawiszy pojawia się krótka wskazówka, gdzie kliknąć: „Skróty klawiszowe…”, a potem „Mission Control” albo inną sekcję.

Tak samo działa strona Gry i „Wycinanie plików w Finderze”. Przy wycinaniu plików wskazówka prowadzi do „Skróty aplikacji”.

**Wypróbuj:** Ustawienia › Gry, potem kliknij klawisze obok „Wyszukiwanie nie wyskakuje”

**Poprawki**

- Kliknięcie skrótu nie otwiera już „Klawisze modyfikujące”.

---

## <a id="v1.25.1"></a>Duże obrazki i gry prosto z Docka

<sub>1.25.1 · 8 października 2026</sub>

Każdy przełącznik ma teraz duży obrazek, a „Dodaj grę…” pokazuje to, co masz w Docku.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

Na stronach Animacje i Gry wszystkie obrazki są teraz duże, tak jak ten na górze strony. Od razu widać, co robi każdy przełącznik, a obrazki nadal ruszają się w tempie, które wybierzesz.

Kliknij „Dodaj grę…”, a zobaczysz swój Dock: aplikacje, które tam trzymasz, i te otwarte teraz, w tej samej kolejności. Gra z Docka pojawia się nawet wtedy, gdy jest zamknięta, Minecraft też. Jedno kliknięcie ją dodaje, a znaczek pokazuje, że jest już na liście. Kliknij jeszcze raz, żeby ją usunąć.

Grę nadal możesz przeciągnąć tutaj z Findera. Nie trzeba już wyciągać jej z Docka, więc Dock nie zaproponuje jej usunięcia.

**Wypróbuj:** Ustawienia › Gry, potem „Dodaj grę…”

**Poprawki**

- Gra, która leży w Docku, ale jest zamknięta, pojawia się teraz na liście do dodania.

---

## <a id="v1.25.0"></a>Gra dodana jednym kliknięciem i własne klawisze

<sub>1.25.0 · 8 października 2026</sub>

Wybierz grę spośród otwartych aplikacji i ustal własne klawisze do kończenia i zamykania.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

Kliknij „Dodaj grę…”, a otwarte teraz aplikacje pojawią się jako duże ikony, jak w Docku. Jedno kliknięcie dodaje grę, możesz też przeciągnąć jej ikonę na listę. Grę da się upuścić także prosto z Findera lub Docka. Teraz grą może być każda aplikacja, nawet Minecraft na Javie, a gry dodane wcześniej zostają.

Przełączniki Trybu gry mówią teraz prosto, na przykład „Gra się nie zamyka” albo „Wyszukiwanie nie wyskakuje”, a każdy ma mały obrazek tego, co zatrzymuje. Nazwa systemowa, na przykład Spotlight, stoi obok na szaro.

W Ustawienia › Okna kliknij klawisze obok „Zakończ aplikację” lub „Zamknij okno” i naciśnij nowe. ⌫ przywraca ⇧⌘Q i ⇧⌘W, a jeśli klawisze są już zajęte, pikapik najpierw zapyta. Tryb gry też korzysta z Twoich klawiszy. A każdy skrót w Ustawieniach pokazuje teraz, jak naprawdę jest ustawiony na Twoim Macu: Twoje klawisze albo „Wyłączone”.

**Wypróbuj:** Ustawienia › Gry, potem „Dodaj grę…”

**Poprawki**

- Wycinanie plików w Finderze korzysta ze skrótu Wytnij, który ustawiono dla Findera w Ustawieniach systemowych.
- Nazwy aplikacji na listach są pokazywane bez „.app”.

---

## <a id="v1.24.1"></a>Przyspieszenie widać od razu

<sub>1.24.1 · 8 października 2026</sub>

Strona Animacje mówi teraz, gdzie zobaczysz zmianę, i chroni Twoje własne wartości.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

Dock może wysuwać się szybciej tylko wtedy, gdy się ukrywa. Jeśli Twój zawsze stoi na miejscu, przełącznik „Automatycznie ukrywaj Dock” jest teraz tuż pod suwakiem szybkości.

Po zmianie na dole strony pojawia się wiersz: aplikacje ją przejmą, gdy otworzysz je ponownie. Finder pokazuje nową szybkość Szybkiego przeglądu i kolumn dopiero po ponownym uruchomieniu, dlatego w tym wierszu jest przycisk „Uruchom ponownie Findera”.

Suwak nigdy nie spowolni tego, co już było przyspieszone, na przykład Twoimi poleceniami w Terminalu. A „Przywróć domyślne” i odinstalowanie pikapik przywracają Twoje wcześniejsze wartości, zamiast je kasować.

**Wypróbuj:** Ustawienia › Animacje

**Poprawki**

- Dock nie uruchamia się już ponownie bez powodu, gdy się nie ukrywa.

---

## <a id="v1.24.0"></a>Wybierz, jak szybko porusza się Twój Mac

<sub>1.24.0 · 8 października 2026</sub>

Nowa strona Animacje ustala, jak szybko wszystko na Macu się otwiera, wysuwa i pojawia.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Wystarczy jeden suwak. Przesuń go, a ukryty Dock, nowe okna, okna zapisywania, Szybki przegląd i kolumny w Finderze przyspieszą razem, od „Jak w macOS” do „Natychmiast”.

Chcesz dostroić tylko jedną rzecz? Każdy efekt ma własne ustawienie, tak samo jak efekt minimalizowania, podskakujące ikony w Docku i animacje Findera. Obok każdego ustawienia mały obrazek porusza się dokładnie z wybraną przez Ciebie szybkością.

„Przywróć domyślne” cofa tylko zmiany wprowadzone przez pikapik, i odinstalowanie działa tak samo. Jeśli któraś z tych wartości była wcześniej ustawiona przez Ciebie w Terminalu, pikapik pokaże ją bez zmian.

**Wypróbuj:** Ustawienia › Animacje

---

## <a id="v1.23.2"></a>Osobny przełącznik dla każdego skrótu w Trybie gry

<sub>1.23.2 · 8 października 2026</sub>

Teraz to Ty decydujesz, skrót po skrócie, co Tryb gry wycisza podczas gry.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Q i ⌘W mają teraz osobne przełączniki, podobnie jak Spotlight, Siri, ⌘Tab, Mission Control, przesunięcia, wskaźnik, ekran i cała reszta. Twoje wcześniejsze wybory zostają.

Każdy wiersz pokazuje dokładnie klawisze, które zatrzymuje, więc zawsze wiesz, co robi dany przełącznik.

Ustawienie języka klawiatury zniknęło z Trybu gry. ⌃Spacja i inne sposoby zmiany języka działają zawsze, nawet w grze.

**Wypróbuj:** Ustawienia › Gry

**Poprawki**

- Klawisze jednego skrótu stoją bliżej siebie, a między różnymi skrótami jest trochę więcej miejsca, więc łatwo zobaczyć, gdzie jeden się kończy, a drugi zaczyna.

---

## <a id="v1.23.1"></a>Jak szybki jest Twój internet, prostymi słowami

<sub>1.23.1 · 8 października 2026</sub>

Test prędkości sprawdza połączenie i po prostu mówi, do czego ono wystarczy.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

Kliknij „Sprawdź prędkość”, a po mniej więcej pół minuty zobaczysz pobieranie, wysyłanie, ping i responsywność. Pod liczbami proste słowa mówią, czy to wystarczy na filmy 4K, rozmowy wideo, gry online i duże pobierania.

Pomiar odbywa się na serwerach Apple, a ostatni wynik zostaje do następnego. Test prędkości ma własną stronę w Ustawieniach, wiersz w panelu na pasku menu i link dla aplikacji Skróty: `pikapik://speed-test`.

Tryb gry nauczył się dwóch rzeczy. Blokowanie skrótów z Control jest teraz jego częścią: w grze ⌃-kliknięcie zostaje zwykłym kliknięciem, a skróty z ⌃ nie działają; poza grą ⌃ działa jak zwykle. Rozpoznaje też Minecrafta: dodaj do gier Minecraft Launcher lub CurseForge, a Tryb gry włączy się, gdy na pierwszym planie będzie sam Minecraft.

**Wypróbuj:** Ustawienia › Test prędkości, potem „Sprawdź prędkość”

**Poprawki**

- Wersje testowe pikapik budowane samodzielnie trzymają swoje ustawienia osobno w iCloud Drive i nie ruszają już Twoich.

---

## <a id="v1.23.0"></a>Tryb gry: graj bez przerw

<sub>1.23.0 · 7 października 2026</sub>

Dodaj swoje gry, a Mac przestanie Cię z nich wyrywać.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Podczas gry Spotlight, Siri, ⌘Tab, Mission Control i przesunięcia między biurkami nie otwierają się nad grą. ⌘Q i ⌘W nie zamkną jej przypadkiem, wskaźnik zostaje na ekranie gry, a ekran nie gaśnie.

Aby wyjść z gry, naciśnij ⇧⌘Q, a żeby zamknąć jej okno, ⇧⌘W. ⌥⌘Esc działa zawsze. pikapik podpowiada gry, które znajdzie na Twoim Macu. Tryb gry jest wyłączony, dopóki go nie włączysz.

Narzędzie „Bez usypiania” pozwala teraz wybrać, co robi ekran: zostaje włączony, bez wygaszacza i ekranu blokady, albo gaśnie jak zwykle, a Mac dalej pracuje. Nowy przycisk „Wyłącz ekran teraz” od razu go wygasza; porusz myszą lub naciśnij klawisz, by wrócił.

**Wypróbuj:** Ustawienia › Gry, potem „Dodaj grę…”

**Poprawki**

- Na Macach bez klapy narzędzie „Bez usypiania” nie pokazuje już opcji dla zamkniętej klapy.

---

<p align="center"><sub>Starsze wersje znajdziesz w <a href="../../CHANGELOG.md">liście zmian</a> (po angielsku).</sub></p>
