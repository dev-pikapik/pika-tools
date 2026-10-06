# pika-tools

[English](../../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [Română](README.ro.md) · **Polski** · [Türkçe](README.tr.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Čeština](README.cs.md) · [繁體中文](README.zh-Hant.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Tiếng Việt](README.vi.md) · [ไทย](README.th.md)

[![Najnowsze wydanie](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![Licencja: MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](../../LICENSE)
[![Pobrania](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

Mała aplikacja na pasek menu w macOS, która poprawia działanie klawiszy, okien i Docka: blokuje skróty z Control, chroni przed ⌘Q i ⌘W, przełącza język skrótem Option+Shift tak jak Alt+Shift w Windows, wyłącza przyspieszenie myszy, przewija kółko myszy wierszami jak w Windows, sprawia, że boczne przyciski myszy cofają i przechodzą dalej, zamyka aplikacje po zamknięciu ich ostatniego okna, ukrywa aplikację kliknięciem w Docku i nie pozwala Macowi zasnąć.

## Instalacja

Przez [Homebrew](https://brew.sh):

```bash
brew install --cask dev-pikapik/pika-tools/pika-tools && open -a pika-tools
```

Bez Homebrew: otwórz Terminal, wklej ten wiersz i naciśnij Return:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

Możesz też pobrać [pika-tools.dmg](https://github.com/dev-pikapik/pika-tools/releases/latest/download/pika-tools.dmg), otworzyć go i przeciągnąć aplikację do folderu Aplikacje.

Zarówno Homebrew, jak i skrypt umieszczają aplikację w `/Applications`, uruchamiają ją, proszą o uprawnienia i włączają otwieranie po zalogowaniu. Potem aplikacja uaktualnia się sama, zobacz [Uaktualnienia](#uaktualnienia). Jak ją usunąć, opisano w sekcji [Odinstalowanie](#odinstalowanie).

## Pierwsze uruchomienie

pika-tools potrzebuje dwóch uprawnień. Przy pierwszym uruchomieniu otwiera ustawienia na stronie Uprawnienia, która prowadzi krok po kroku, a macOS pokazuje własne prośby. Przejdź do **Ustawienia systemowe › Prywatność i ochrona** i włącz pika-tools w sekcjach:

- **Dostępność**, aby aplikacja mogła zmienić naciśnięcie klawisza lub kliknięcie, zanim dotrze ono do innych aplikacji.
- **Monitorowanie wprowadzania**, aby aplikacja w ogóle widziała naciśnięcia klawiszy i kliknięcia.

Aplikacja zauważy zmianę w ciągu kilku sekund, bez ponownego uruchamiania.

pika-tools nie nagrywa, nie przechowuje i nie wysyła niczego, co piszesz lub klikasz. Zdarzenia są obsługiwane w pamięci i od razu przekazywane dalej. Jedyne połączenie z siecią to sprawdzanie uaktualnień, które pyta GitHub o najnowsze wydanie.

## Funkcje

**Blokowanie skrótów z Control.** Control staje się zwykłym klawiszem. Aplikacje nadal widzą, że jest wciśnięty, ale macOS nie zamienia go już w skróty: Control+Spacja nie zmienia źródła wprowadzania, Control+strzałki nie przełączają biurek, a Control-kliknięcie to zwykłe kliknięcie zamiast menu podręcznego. Kliknięcie prawym przyciskiem i stuknięcie dwoma palcami działają jak zwykle. Przydaje się w grach i podczas sesji zdalnego pulpitu, gdzie Control ma własne zadanie.

**Ochrona ⌘Q i ⌘W.** Same ⌘Q i ⌘W nic nie robią, więc nie zamkniesz przypadkiem aplikacji ani okna. Dodaj Shift, aby zrobić to celowo: ⇧⌘Q kończy aplikację, ⇧⌘W zamyka okno. Działa we wszystkich aplikacjach. Każdy klawisz ma własny przełącznik. Domyślnie wyłączone.

**Zmiana języka skrótem Option+Shift.** Przytrzymaj Option i stuknij Shift: macOS przełączy na następne źródło wprowadzania. Trzymaj dalej Option i stuknij Shift ponownie, aby przejść dalej. Przytrzymaj Shift i stuknij Option, aby wrócić. Jeśli w międzyczasie naciśniesz inny klawisz, klikniesz lub dodasz Command, Control albo Fn, nic się nie przełączy, więc skróty takie jak Option+Shift+strzałka działają jak wcześniej. Domyślnie wyłączone.

**Wyłącz przyspieszenie wskaźnika.** Wskaźnik przesuwa się dokładnie o tyle, o ile mysz, niezależnie od tego, jak szybko nią ruszasz, jak w LinearMouse. Suwak **Szybkość ruchu** ustala, jak szybko się porusza. Działa tylko z myszami, gładzik zostaje bez zmian. Wyłącz tę funkcję lub zakończ pika-tools, a macOS odzyska własne ustawienia. Domyślnie wyłączone.

**Przewijaj o wiersze.** Każde kliknięcie kółka myszy przewija tyle samo wierszy, bez względu na to, jak szybko nim kręcisz, tak jak w Windows. Wybierz od 1 do 10 wierszy na kliknięcie, domyślnie 3. Naturalne przewijanie zostaje takie, jakie ustawisz w Ustawieniach systemowych. Działa tylko dla myszy, gładzik zostaje bez zmian. Domyślnie wyłączone.

**Boczne przyciski: wstecz i dalej.** Przyciski myszy 4 i 5 cofają i przechodzą dalej w Safari, Finderze i innych aplikacjach Apple oraz w Firefoksie, Operze i ForkLifcie, tak jak machnięcie na gładziku. Inne aplikacje, na przykład środowiska JetBrains, dostają przyciski bez zmian i obsługują je po swojemu. Jeśli twoja mysz ma je odwrotnie, włącz **Zamień boczne przyciski**. Domyślnie wyłączone.

**Zakończenie po zamknięciu ostatniego okna.** Zamknij ostatnie okno aplikacji, a aplikacja się zakończy, tak jak w Windows. Finder pozostaje otwarty, podobnie jak aplikacje z oknami na innych biurkach lub w Docku. Możesz utworzyć listę aplikacji, które nigdy nie mają się tak kończyć. Domyślnie wyłączone.

**Ukrywanie kliknięciem w Docku.** Kliknij ikonę w Docku aplikacji, której używasz, a zostanie ukryta. Kliknij ponownie, aby ją przywrócić. Domyślnie wyłączone.

Każde narzędzie ma własny przełącznik w menu i w ustawieniach. Potrzebujesz z powrotem zwykłego Control+C? Wyłącz to narzędzie.

Ikona na pasku menu od razu pokazuje stan: strzałka z kliknięciem, gdy narzędzia działają, przekreślona strzałka, gdy wszystko jest wyłączone, i trójkąt ostrzegawczy, gdy narzędzie jest włączone, ale brakuje uprawnień.

Aplikacja używa języka systemu lub tego, który wybierzesz w ustawieniach. Dostępne są wszystkie 23 języki z listy na początku tej strony.

## Nie usypiaj

Nie pozwala Macowi przejść w stan uśpienia, gdy nie ma Cię przy klawiaturze: na dowolny czas od 1 minuty do 12 miesięcy lub do momentu wyłączenia. Włącz to w menu, a czas trwania ustaw w ustawieniach w minutach, godzinach, dniach, tygodniach lub miesiącach. Menu pokazuje, ile czasu zostało i kiedy się skończy. **Nie wyłączaj ekranu** sprawia też, że ekran nie przygasa. Zakończenie pika-tools kończy także Nie usypiaj.

Na MacBooku możesz też włączyć **Pracuj z zamkniętą pokrywą**. macOS nie ma takiego przełącznika, więc pika-tools uruchamia `pmset -a disablesleep 1` i prosi o hasło administratora: tylko administrator może zmienić sposób usypiania Maca. Ustawienie samo wraca do normy, gdy Nie usypiaj się skończy, gdy zakończysz aplikację lub gdy ta ulegnie awarii. Jeśli nie podasz hasła, nic się nie zmieni. Zadbaj o dobrą wentylację Maca z zamkniętą pokrywą. **Zatrzymaj, gdy bateria spadnie poniżej 20%** kończy sesję, zanim bateria się wyczerpie.

## Ustawienia

Otwórz ustawienia z menu poleceniem **Ustawienia…** lub skrótem ⌘, albo po prostu uruchom pika-tools ponownie z Findera, Launchpada lub Spotlight. Gdy okno jest otwarte, aplikacja pojawia się w Docku i w ⌘Tab.

- **Ogólne**: otwieranie po zalogowaniu, wygląd (Systemowy, Jasny lub Ciemny), język, uaktualnienia i kopia zapasowa: eksport i import ustawień jako pliku albo synchronizacja przez iCloud Drive.
- **Klawiatura**: skróty z Control, ⌘Q i ⌘W, zmiana języka.
- **Mysz**: przyspieszenie wskaźnika i szybkość ruchu, przewijanie o wiersze, boczne przyciski.
- **Okna i aplikacje**: zakończenie po ostatnim oknie z listą wyjątków oraz ukrywanie kliknięciem w Docku.
- **Nie usypiaj**: czas trwania, opcje ekranu i pokrywy.
- **Uprawnienia**: stan obu uprawnień, a przy włączonej synchronizacji także iCloud Drive, z przyciskami, które otwierają właściwe miejsce w Ustawieniach systemowych.
- **Informacje**: wersja, łącza do listy zmian i do zgłaszania problemów.

Na dole każdej strony jest przycisk **Przywróć domyślne…**. Najpierw pyta o potwierdzenie, potem wyłącza narzędzia z tej strony i przywraca ich opcje, jakby pika-tools nigdy ich nie dotykał.

**Synchronizuj ustawienia przez iCloud** sprawia, że pika-tools jest taki sam na wszystkich twoich Macach. Ustawienia leżą w folderze pika-tools w iCloud Drive, a wygrywa ostatnia zmiana. Domyślnie wyłączone i wymaga włączonego iCloud Drive. Uprawnienia nie są synchronizowane: każdy Mac prosi o nie osobno.

## Uaktualnienia

pika-tools sprawdza nowe wersje przy uruchomieniu i co 6 godzin. Możesz to wyłączyć w Ustawienia › Ogólne. Gdy pojawi się nowa wersja, w menu pokaże się przycisk **Uaktualnij do …**: jedno kliknięcie i aplikacja pobierze uaktualnienie, zainstaluje je i uruchomi się ponownie. Możesz też sprawdzić ręcznie przyciskiem **Sprawdź teraz** w Ustawienia › Ogólne.

Z Homebrew możesz też uruchomić `brew upgrade --cask pika-tools`.

Od wersji 1.3 uprawnienia zostają zachowane po uaktualnieniach.

## Odinstalowanie

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

Jeśli instalacja była przez Homebrew: `brew uninstall --cask --zap pika-tools`.

Oba sposoby kończą aplikację, usuwają ją z rzeczy otwieranych podczas logowania i kasują. Skrypt dodatkowo resetuje jej uprawnienia.

## Najczęstsze pytania

**Dlaczego potrzebne są dwa uprawnienia?**
macOS dzieli dostęp do klawiatury i myszy na dwie części. Monitorowanie wprowadzania pozwala aplikacji widzieć zdarzenia, a Dostępność pozwala je zmieniać. Do zablokowania skrótu potrzebne są oba.

**macOS informuje, że aplikacja pochodzi od niezidentyfikowanego dewelopera.**
pika-tools jest podpisana, ale nie jest poświadczona przez Apple. Homebrew i skrypt instalacyjny załatwiają to za Ciebie. Jeśli korzystasz z pliku dmg, otwórz **Ustawienia systemowe › Prywatność i ochrona** i kliknij **Otwórz mimo to** lub uruchom:

```bash
xattr -dr com.apple.quarantine /Applications/pika-tools.app
```

**Czy działa na Macach z procesorem Intel?**
Tak. To aplikacja uniwersalna dla Apple Silicon i Intel, wymaga macOS 14 Sonoma lub nowszego.

**Uprawnienie jest włączone, ale nic nie działa.**
W **Ustawieniach systemowych › Prywatność i ochrona** usuń pika-tools z obu list przyciskiem −, a potem dodaj ją ponownie. Na stronie Uprawnienia w ustawieniach pika-tools są przyciski, które otwierają właściwe miejsce.

## Współtworzenie

Budowanie ze źródeł i publikowanie wydań opisano w [CONTRIBUTING.md](../../CONTRIBUTING.md). Zmiany są wymienione w [CHANGELOG.md](../../CHANGELOG.md).

## Licencja

MIT, © 2026 pikapik. Zobacz [LICENSE](../../LICENSE).
