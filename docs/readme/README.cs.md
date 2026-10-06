# pika-tools

[English](../../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [Română](README.ro.md) · [Polski](README.pl.md) · [Türkçe](README.tr.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · **Čeština** · [繁體中文](README.zh-Hant.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Tiếng Việt](README.vi.md) · [ไทย](README.th.md)

[![Nejnovější verze](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![Licence: MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](../../LICENSE)
[![Stažení](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

Malá aplikace pro řádek nabídek v macOS, která vylepšuje klávesy, okna a Dock: blokuje zkratky s Controlem, chrání před ⌘Q a ⌘W, přepíná jazyk pomocí Option+Shift stejně jako Alt+Shift ve Windows, opakuje drženou klávesu jako Windows, vypne zrychlení myši, posouvá kolečko myši po řádcích jako Windows, naučí boční tlačítka myši chodit zpět a vpřed, ukončí aplikaci po zavření jejího posledního okna, skryje aplikaci kliknutím v Docku a nedovolí Macu usnout.

## Instalace

Pomocí [Homebrew](https://brew.sh):

```bash
brew install --cask dev-pikapik/pika-tools/pika-tools && open -a pika-tools
```

Bez Homebrew: otevřete Terminál, vložte tento řádek a stiskněte Return:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

Nebo si stáhněte [pika-tools.dmg](https://github.com/dev-pikapik/pika-tools/releases/latest/download/pika-tools.dmg), otevřete ho a přetáhněte aplikaci do složky Aplikace.

Homebrew i skript uloží aplikaci do `/Applications`, spustí ji, požádají o oprávnění a zapnou otevírání po přihlášení. Potom se aplikace aktualizuje sama, viz [Aktualizace](#aktualizace). Jak ji odstranit, najdete v části [Odinstalace](#odinstalace).

## První spuštění

pika-tools potřebuje dvě oprávnění. Při prvním spuštění otevře nastavení na stránce Oprávnění, která vás provede krok za krokem, a macOS zobrazí vlastní dotazy. Přejděte do **Nastavení systému › Soukromí a zabezpečení** a zapněte pika-tools v seznamech:

- **Zpřístupnění**, aby aplikace mohla změnit stisk klávesy nebo kliknutí dřív, než se dostane k jiným aplikacím.
- **Sledování vstupu**, aby aplikace vůbec viděla stisky kláves a kliknutí.

Aplikace změnu zaznamená během pár sekund, restart není potřeba.

pika-tools nenahrává, neukládá ani neodesílá nic z toho, co píšete nebo na co klikáte. Události se zpracovávají v paměti a hned se předávají dál. Jediný síťový požadavek je kontrola aktualizací, která se GitHubu ptá na nejnovější verzi.

## Funkce

**Blokování zkratek s Controlem.** Control se stane obyčejnou klávesou. Aplikace stále vidí, že je stisknutý, ale macOS z něj už nedělá zkratky: Control+mezerník nepřepíná zdroj vstupu, Control+šipky nepřepínají plochy a kliknutí s Controlem je obyčejné kliknutí místo kontextové nabídky. Kliknutí pravým tlačítkem a klepnutí dvěma prsty fungují jako obvykle. Hodí se ve hrách a při práci se vzdálenou plochou, kde má Control vlastní úlohu.

**Ochrana ⌘Q a ⌘W.** Samotné ⌘Q a ⌘W nic nedělají, takže omylem neukončíte aplikaci ani nezavřete okno. Přidejte Shift, když to chcete udělat záměrně: ⇧⌘Q ukončí, ⇧⌘W zavře. Funguje ve všech aplikacích. Každá klávesa má vlastní přepínač. Ve výchozím stavu vypnuto.

**Přepínání jazyka pomocí Option+Shift.** Podržte Option a ťukněte na Shift: macOS přepne na další zdroj vstupu. Držte dál Option a znovu ťukněte na Shift, chcete-li pokračovat. Podržte Shift a ťukněte na Option, chcete-li se vrátit. Když mezitím stisknete jinou klávesu, kliknete nebo přidáte Command, Control či Fn, nic se nepřepne, takže zkratky jako Option+Shift+šipka fungují jako dřív. Ve výchozím stavu vypnuto.

**Opakovat drženou klávesu.** Podržte klávesu a písmeno se píše znovu a znovu, jako ve Windows, místo aby se ukázala nabídka akcentů. Hodí se ve hrách i při psaní. Už otevřené aplikace to převezmou po restartu. Když to vypnete, macOS se chová jako obvykle. Ve výchozím stavu vypnuto.

**Vypnout zrychlení ukazatele.** Ukazatel se posune přesně tolik jako myš, ať s ní pohybujete jakkoli rychle, stejně jako v LinearMouse. Jezdec **Rychlost ukazatele** určuje, jak rychle se pohybuje. Funguje jen s myší, trackpad zůstane, jak je. Vypněte funkci nebo ukončete pika-tools a macOS dostane zpět svoje vlastní nastavení. Ve výchozím stavu vypnuto.

**Posouvat po řádcích.** Každé cvaknutí kolečka myši posune stejný počet řádků, ať kolečkem točíte jakkoli rychle, jako ve Windows. Vyberte 1 až 10 řádků na cvaknutí, ve výchozím stavu 3. Přirozené posouvání zůstane tak, jak jste ho nastavili v Nastavení systému. Funguje jen pro myš, trackpad zůstává beze změny. Ve výchozím stavu vypnuto.

Některé aplikace a hry počítají posouvání v přesných pixelech: pro ně přepněte stejné nastavení na pixely a vyberte 1 až 200 pixelů na cvaknutí, výchozí je 40.

**Boční tlačítka pro zpět a vpřed.** Tlačítka myši 4 a 5 fungují jako zpět a vpřed v Safari, ve Finderu a dalších aplikacích Apple, ve Firefoxu, Opeře a ForkLiftu, stejně jako přejetí po trackpadu. Ostatní aplikace, například vývojová prostředí JetBrains, dostanou tlačítka beze změny a zpracují je po svém. Pokud je má vaše myš obráceně, zapněte **Prohodit boční tlačítka**. Ve výchozím stavu vypnuto.

**Ukončení po zavření posledního okna.** Zavřete poslední okno aplikace a aplikace se ukončí, stejně jako ve Windows. Finder zůstane otevřený, stejně jako aplikace s okny na jiných plochách nebo v Docku. Můžete si sestavit seznam aplikací, které se tímto způsobem nikdy ukončit nemají. Ve výchozím stavu vypnuto.

**Skrytí kliknutím v Docku.** Klikněte v Docku na ikonu aplikace, se kterou právě pracujete, a skryje se. Dalším kliknutím ji vrátíte. Ve výchozím stavu vypnuto.

**Zelené tlačítko zvětší okno.** Klikněte na zelené tlačítko okna a okno se zvětší tak, aby vyplnilo obrazovku, aniž by přešlo do režimu celé obrazovky. Dalším kliknutím se vrátí původní velikost. S podrženým ⌥ tlačítko funguje jako vždy. Celá obrazovka zůstává v nabídce tlačítka a na ⌃⌘F. Můžete sestavit seznam aplikací, ve kterých má zelené tlačítko fungovat jako obvykle. Ve výchozím stavu vypnuto.

**Nový soubor ve Finderu.** Klikněte pravým v okně Finderu nebo na ploše, vyberte **Nový soubor**, napište název a objeví se prázdný soubor, jako Nový › Textový dokument ve Windows. Standardně .txt. Ve výchozím stavu vypnuto.

**Enter otevírá soubory ve Finderu.** Vyberte soubory v okně Finderu nebo na ploše a stiskněte Return nebo Enter, soubory se otevřou, stejně jako ve Windows. F2 nebo fn F2 přejmenuje vybraný soubor. V textových polích, například když píšete název, klávesy fungují jako obvykle. Ve výchozím stavu vypnuto.

**⌘X vyjímá soubory ve Finderu.** Vyberte soubory a stiskněte ⌘X, otevřete cílovou složku a stiskněte ⌘V: soubory se tam přesunou místo zkopírování, jako Vyjmout a Vložit ve Windows. ⌘C vyjmutí zruší. Ve výchozím stavu vypnuto.

Každý nástroj má vlastní přepínač v nabídce i v nastavení. Potřebujete zpátky obyčejné Control+C? Vypněte ten nástroj.

Ikona v řádku nabídek ukazuje stav na první pohled: šipka s kliknutím, když nástroje fungují, přeškrtnutá šipka, když je vše vypnuté, a výstražný trojúhelník, když je nástroj zapnutý, ale chybí oprávnění.

Panel v řádku nabídek začíná jen s několika řádky. Které řádky ukazuje, si vyberete sami: klikněte na tlačítko s tužkou dole, zaškrtněte, co chcete vidět, a klikněte na **Hotovo**. Skryté řádky dál fungují a zůstávají v Nastavení. Když se panel na obrazovku nevejde, dá se posouvat.

Aplikace používá jazyk systému nebo ten, který vyberete v nastavení. K dispozici je všech 23 jazyků ze seznamu na začátku této stránky.

## Nespat

Nedovolí Macu přejít do režimu spánku, když nejste u klávesnice: na libovolnou dobu od 1 sekundy do 365 dnů, nebo dokud to nevypnete. Zapněte to v nabídce a délku nastavte v nastavení: zadejte dny, hodiny, minuty a sekundy, použijte ↑ a ↓ nebo klikněte na hotovou volbu od 15 minut do 8 hodin. Nabídka ukazuje, kolik času zbývá a kdy to skončí. **Nechat displej zapnutý** zabrání i ztmavení obrazovky. Ukončením pika-tools skončí i Nespat.

Na MacBooku můžete zapnout také **Pracovat se zavřeným víkem**. macOS na to nemá přepínač, proto pika-tools spustí `pmset -a disablesleep 1` a požádá o heslo správce: měnit, jak Mac usíná, může jen správce. Nastavení se samo vrátí do normálu, když Nespat skončí, když aplikaci ukončíte nebo když spadne. Pokud heslo nezadáte, nic se nezmění. Se zavřeným víkem dbejte na dobré větrání Macu. **Zastavit, když baterie klesne pod 20 %** ukončí relaci dřív, než se baterie vybije.

Keep Awake, režimy displeje a zavřeného víka lze dát na tlačítko v Ovládacím centru, v panelu nabídek nebo na widget na ploše přes aplikaci Zkratky, s odkazy zkopírovanými z Nastavení › Bez spánku.

## Nastavení

Nastavení otevřete z nabídky položkou **Nastavení…** nebo zkratkou ⌘, případně pika-tools znovu spusťte z Finderu, Launchpadu nebo Spotlightu. Dokud je okno otevřené, aplikace se zobrazuje v Docku a v ⌘Tab.

- **Obecné**: otevírání po přihlášení, vzhled (Systém, Světlý nebo Tmavý), jazyk, aktualizace a zálohování: export a import nastavení jako souboru nebo synchronizace přes iCloud Drive.
- **Bez spánku**: délka, volby pro displej a víko.
- **Klávesnice**: zkratky s Controlem, přepínání jazyka, opakování kláves.
- **Myš**: zrychlení ukazatele a rychlost ukazatele, posouvání po řádcích, boční tlačítka.
- **Okna**: zvětšení okna zeleným tlačítkem (se seznamem výjimek), ochrana ⌘Q a ⌘W a ukončení po posledním okně (se seznamem výjimek).
- **Dock**: skrytí kliknutím v Docku.
- **Finder**: nový soubor, otevírání klávesou Enter a vyjmutí pomocí ⌘X.
- **Oprávnění**: stav obou oprávnění a iCloud Drive, když je zapnutá synchronizace, s tlačítky, která otevřou správné místo v Nastavení systému.
- **O aplikaci**: verze, odkazy na seznam změn a na nahlášení problému.

Mnoho nastavení má malý obrázek, který ukazuje, co dělají, třeba Mac, který neusíná, nebo okno schované za Dockem. Obrázek se mění spolu s přepínačem a stojí, když je v Nastavení systému zapnuté „Omezit pohyb“.

Na každé stránce je dole tlačítko **Obnovit výchozí…**. Nejdřív se zeptá, pak vypne nástroje na dané stránce a vrátí jejich volby, jako by se jich pika-tools nikdy nedotkl.

**Synchronizovat nastavení přes iCloud** udrží pika-tools stejné na všech vašich Macích. Nastavení jsou ve složce pika-tools na iCloud Drive a vyhrává poslední změna. Ve výchozím stavu je vypnuto a vyžaduje zapnutý iCloud Drive. Oprávnění se nesynchronizují: každý Mac si o ně řekne sám.

## Aktualizace

pika-tools hledá nové verze při spuštění a každých 6 hodin. Můžete to vypnout v Nastavení › Obecné. Když vyjde nová verze, v nabídce se objeví tlačítko **Aktualizovat na …**: jedno kliknutí a aplikace stáhne aktualizaci, nainstaluje ji a restartuje se. Ručně můžete zkontrolovat tlačítkem **Zkontrolovat** v Nastavení › Obecné.

S Homebrew můžete také spustit `brew upgrade --cask pika-tools`.

Od verze 1.3 zůstávají oprávnění po aktualizacích zachována.

## Odinstalace

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

Pokud jste instalovali přes Homebrew: `brew uninstall --cask --zap pika-tools`.

Oba způsoby aplikaci ukončí, odeberou ji z položek po přihlášení a smažou ji. Skript navíc obnoví její oprávnění.

## Časté dotazy

**Proč potřebuje dvě oprávnění?**
macOS dělí přístup ke klávesnici a myši na dvě části. Sledování vstupu aplikaci dovolí události vidět, Zpřístupnění jí dovolí je měnit. K zablokování zkratky jsou potřeba obě.

**macOS hlásí, že aplikace je od neidentifikovaného vývojáře.**
pika-tools je podepsaná, ale není ověřená (notarizovaná) společností Apple. Homebrew a instalační skript to vyřeší za vás. Pokud jste použili dmg, otevřete **Nastavení systému › Soukromí a zabezpečení** a klikněte na **Přesto otevřít**, nebo spusťte:

```bash
xattr -dr com.apple.quarantine /Applications/pika-tools.app
```

**Funguje na Macích s Intelem?**
Ano. Je to univerzální aplikace pro Apple Silicon i Intel, pro macOS 14 Sonoma nebo novější.

**Oprávnění je zapnuté, ale nic nefunguje.**
V **Nastavení systému › Soukromí a zabezpečení** odeberte pika-tools z obou seznamů tlačítkem − a pak ji přidejte znovu. Na stránce Oprávnění v nastavení pika-tools jsou tlačítka, která otevřou správné místo.

## Přispívání

Jak sestavit aplikaci ze zdrojového kódu a vydat novou verzi, popisuje [CONTRIBUTING.md](../../CONTRIBUTING.md). Změny jsou uvedené v [CHANGELOG.md](../../CHANGELOG.md).

## Licence

MIT, © 2026 pikapik. Viz [LICENSE](../../LICENSE).
