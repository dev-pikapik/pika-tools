<p align="center"><a href="../readme/README.pl.md"><img src="../media/icon.png" width="96" height="96" alt="pika-tools"></a></p>
<h1 align="center">Co nowego w pika-tools</h1>
<p align="center">Każda aktualizacja w kilku słowach i na jednym obrazku, od najnowszej.</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <b>Polski</b> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.26.0"></a>Nowa ikona i porządek ze starymi uprawnieniami

<sub>1.26.0 · 8 października 2026</sub>

pika-tools ma nową twarz i teraz usuwa uprawnienia, które zostają po usuniętych aplikacjach.

<img src="../media/icon.png" width="128" height="128" alt="">

Nowa ikona to znak pikapik w kolorach niebieskim, fioletowym i koralowym na ciemnym kafelku. Pasek menu pokazuje ten sam kształt, który dopasowuje się do jasnego lub ciemnego paska. Gdy wszystkie narzędzia są wyłączone, kształt blednie.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>

Gdy usuwasz aplikację, macOS zachowuje nadane jej uprawnienia, a w Ustawieniach systemowych nie da się ich usunąć. Teraz na stronie „Uprawnienia” jest lista „Pozostałości po usuniętych aplikacjach”: każda aplikacja z ikoną, co mogła robić i kiedy. „Usuń” czyści jedną aplikację, „Usuń wszystkie” wszystkie naraz, a aplikacja zainstalowana ponownie po prostu zapyta jeszcze raz. Żeby zobaczyć listę, daj pika-tools pełny dostęp do dysku: tylko patrzy i niczego nie zmienia, dopóki nie klikniesz „Usuń”.

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

W Ustawienia › Okna kliknij klawisze obok „Zakończ aplikację” lub „Zamknij okno” i naciśnij nowe. ⌫ przywraca ⇧⌘Q i ⇧⌘W, a jeśli klawisze są już zajęte, pika-tools najpierw zapyta. Tryb gry też korzysta z Twoich klawiszy. A każdy skrót w Ustawieniach pokazuje teraz, jak naprawdę jest ustawiony na Twoim Macu: Twoje klawisze albo „Wyłączone”.

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

Suwak nigdy nie spowolni tego, co już było przyspieszone, na przykład Twoimi poleceniami w Terminalu. A „Przywróć domyślne” i odinstalowanie pika-tools przywracają Twoje wcześniejsze wartości, zamiast je kasować.

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

„Przywróć domyślne” cofa tylko zmiany wprowadzone przez pika-tools, i odinstalowanie działa tak samo. Jeśli któraś z tych wartości była wcześniej ustawiona przez Ciebie w Terminalu, pika-tools pokaże ją bez zmian.

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

Pomiar odbywa się na serwerach Apple, a ostatni wynik zostaje do następnego. Test prędkości ma własną stronę w Ustawieniach, wiersz w panelu na pasku menu i link dla aplikacji Skróty: `pika-tools://speed-test`.

Tryb gry nauczył się dwóch rzeczy. Blokowanie skrótów z Control jest teraz jego częścią: w grze ⌃-kliknięcie zostaje zwykłym kliknięciem, a skróty z ⌃ nie działają; poza grą ⌃ działa jak zwykle. Rozpoznaje też Minecrafta: dodaj do gier Minecraft Launcher lub CurseForge, a Tryb gry włączy się, gdy na pierwszym planie będzie sam Minecraft.

**Wypróbuj:** Ustawienia › Test prędkości, potem „Sprawdź prędkość”

**Poprawki**

- Wersje testowe pika-tools budowane samodzielnie trzymają swoje ustawienia osobno w iCloud Drive i nie ruszają już Twoich.

---

## <a id="v1.23.0"></a>Tryb gry: graj bez przerw

<sub>1.23.0 · 7 października 2026</sub>

Dodaj swoje gry, a Mac przestanie Cię z nich wyrywać.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Podczas gry Spotlight, Siri, ⌘Tab, Mission Control i przesunięcia między biurkami nie otwierają się nad grą. ⌘Q i ⌘W nie zamkną jej przypadkiem, wskaźnik zostaje na ekranie gry, a ekran nie gaśnie.

Aby wyjść z gry, naciśnij ⇧⌘Q, a żeby zamknąć jej okno, ⇧⌘W. ⌥⌘Esc działa zawsze. pika-tools podpowiada gry, które znajdzie na Twoim Macu. Tryb gry jest wyłączony, dopóki go nie włączysz.

Narzędzie „Bez usypiania” pozwala teraz wybrać, co robi ekran: zostaje włączony, bez wygaszacza i ekranu blokady, albo gaśnie jak zwykle, a Mac dalej pracuje. Nowy przycisk „Wyłącz ekran teraz” od razu go wygasza; porusz myszą lub naciśnij klawisz, by wrócił.

**Wypróbuj:** Ustawienia › Gry, potem „Dodaj grę…”

**Poprawki**

- Na Macach bez klapy narzędzie „Bez usypiania” nie pokazuje już opcji dla zamkniętej klapy.

---

<p align="center"><sub>Starsze wersje znajdziesz w <a href="../../CHANGELOG.md">liście zmian</a> (po angielsku).</sub></p>
