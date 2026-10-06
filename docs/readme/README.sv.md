# pika-tools

[English](../../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [Română](README.ro.md) · [Polski](README.pl.md) · [Türkçe](README.tr.md) · [Nederlands](README.nl.md) · **Svenska** · [Čeština](README.cs.md) · [繁體中文](README.zh-Hant.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Tiếng Việt](README.vi.md) · [ไทย](README.th.md)

[![Senaste versionen](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![Licens: MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](../../LICENSE)
[![Hämtningar](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

En liten app för menyraden i macOS som gör tangenter, fönster och Dock smidigare: den blockerar kortkommandon med kontroll, skyddar ⌘Q och ⌘W, byter språk med alternativ+skift på samma sätt som Alt+Skift i Windows, upprepar en nedhållen tangent som i Windows, stänger av musacceleration, rullar mushjulet per rad som i Windows, låter musens sidoknappar gå bakåt och framåt, avslutar appar när du stänger deras sista fönster, gömmer en app med ett klick i Dock och håller din Mac vaken.

## Installera

Med [Homebrew](https://brew.sh):

```bash
brew install --cask dev-pikapik/pika-tools/pika-tools && open -a pika-tools
```

Utan Homebrew: öppna Terminal, klistra in den här raden och tryck på returtangenten:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

Eller hämta [pika-tools.dmg](https://github.com/dev-pikapik/pika-tools/releases/latest/download/pika-tools.dmg), öppna filen och dra appen till mappen Program.

Både Homebrew och skriptet lägger appen i `/Applications`, öppnar den, ber om behörigheterna och slår på ”Öppna vid inloggning”. Därefter uppdaterar appen sig själv, se [Uppdateringar](#uppdateringar). Hur du tar bort den står under [Avinstallera](#avinstallera).

## Första start

pika-tools behöver två behörigheter. Första gången öppnas inställningarna på sidan Behörigheter, som guidar dig steg för steg, och macOS visar sina egna frågor. Gå till **Systeminställningar › Integritet och säkerhet** och slå på pika-tools under:

- **Hjälpmedel**, så att appen kan ändra en tangenttryckning eller ett klick innan det når andra appar.
- **Indataövervakning**, så att appen över huvud taget kan se tangenttryckningar och klick.

Appen märker ändringen inom ett par sekunder, ingen omstart behövs.

pika-tools spelar inte in, sparar inte och skickar inte något av det du skriver eller klickar på. Händelser hanteras i minnet och skickas vidare direkt. Den enda nätverksförfrågan är sökningen efter uppdateringar, som frågar GitHub efter den senaste versionen.

## Funktioner

**Blockera kortkommandon med kontroll.** Kontroll blir en vanlig tangent. Appar ser fortfarande att den hålls ned, men macOS gör inte längre om den till kortkommandon: kontroll+mellanslag byter inte inmatningskälla, kontroll+piltangenter byter inte skrivbord och kontroll-klick är ett vanligt klick i stället för en kontextmeny. Högerklick och tvåfingerstryck fungerar som vanligt. Praktiskt i spel och vid fjärrskrivbordssessioner, där kontroll har en egen uppgift.

**Skydda ⌘Q och ⌘W.** ⌘Q och ⌘W ensamma gör ingenting, så du avslutar inte en app eller stänger ett fönster av misstag. Lägg till skift för att göra det med flit: ⇧⌘Q avslutar, ⇧⌘W stänger. Fungerar i alla appar. Varje tangent har en egen reglage. Av som standard.

**Byt språk med alternativ+skift.** Håll ned alternativ och tryck på skift: macOS går till nästa inmatningskälla. Fortsätt hålla ned alternativ och tryck på skift igen för att gå vidare. Håll ned skift och tryck på alternativ för att gå tillbaka. Om du under tiden trycker på en annan tangent, klickar eller lägger till kommando, kontroll eller Fn byts inget språk, så kortkommandon som alternativ+skift+pil fungerar som förut. Av som standard.

**Upprepa en nedhållen tangent.** Håll ned en tangent så skrivs bokstaven om och om igen, som i Windows, i stället för att accentmenyn visas. Smidigt i spel och när du skriver. Appar som redan är öppna använder det efter en omstart. Stänger du av det fungerar macOS som vanligt igen. Av som standard.

**Stäng av pekaracceleration.** Pekaren rör sig exakt lika långt som musen, hur snabbt du än rör den, precis som LinearMouse. Reglaget **Pekarhastighet** ställer in hur snabbt pekaren rör sig. Fungerar bara med möss, styrplattan förblir som den är. Stäng av funktionen eller avsluta pika-tools så får macOS tillbaka sina egna inställningar. Av som standard.

**Rulla per rad.** Varje klick med mushjulet rullar lika många rader, hur snabbt du än snurrar på det, som i Windows. Välj från 1 till 10 rader per klick, 3 som standard. Naturlig rullning är kvar som du ställt in den i Systeminställningar. Fungerar bara för möss, styrplattan förblir som den är. Av som standard.

Vissa appar och spel räknar rullning i exakta pixlar: för dem byter du samma inställning till pixlar och väljer 1 till 200 pixlar per klick, 40 som standard.

**Sidoknapparna går bakåt och framåt.** Musknapp 4 och 5 går bakåt och framåt i Safari, Finder och andra Apple-appar, i Firefox, Opera och ForkLift, som en svepning på styrplattan. Andra appar, till exempel JetBrains IDE:er, får knapparna som de är och hanterar dem på sitt eget sätt. Sitter de åt andra hållet på din mus slår du på **Byt plats på sidoknapparna**. Av som standard.

**Avsluta när det sista fönstret stängs.** Stäng det sista fönstret i en app så avslutas appen, precis som i Windows. Finder förblir öppen, liksom appar med fönster på andra skrivbord eller i Dock. Du kan lista appar som aldrig ska avslutas på det här sättet. Av som standard.

**Göm med ett klick i Dock.** Klicka på Dock-symbolen för appen du använder så göms den. Klicka igen för att ta fram den. Av som standard.

**Ny fil i Finder.** Högerklicka i ett Finder-fönster eller på skrivbordet, välj **Ny fil**, skriv ett namn och en tom fil dyker upp, som Nytt › Textdokument i Windows. .txt som standard. Av som standard.

Varje verktyg har ett eget reglage i menyn och i inställningarna. Behöver du ett vanligt kontroll+C igen? Stäng av det verktyget.

Symbolen i menyraden visar läget med en blick: en pil med ett klick när verktygen arbetar, en överstruken pil när allt är avstängt och en varningstriangel när ett verktyg är på men behörigheter saknas.

Du väljer själv vilka rader panelen i menyraden visar: klicka på **Anpassa…**, avmarkera det du inte behöver och klicka på **Klar**. Dolda rader fortsätter fungera och finns kvar i Inställningar. Om panelen inte ryms på skärmen går den att scrolla.

Appen följer systemets språk eller det språk du väljer i inställningarna. Appen finns på alla 23 språk i listan högst upp på den här sidan.

## Håll vaken

Hindrar din Mac från att gå i vila medan du är borta från tangentbordet: under valfri tid från 1 minut till 12 månader, eller tills du stänger av det. Slå på det i menyn och ställ in tiden i inställningarna i minuter, timmar, dagar, veckor eller månader. Menyn visar hur lång tid som är kvar och när det tar slut. **Håll skärmen på** hindrar också skärmen från att dämpas. När du avslutar pika-tools avslutas även Håll vaken.

På en MacBook kan du också slå på **Arbeta med locket stängt**. macOS har inget reglage för det, så pika-tools kör `pmset -a disablesleep 1` och ber om ett administratörslösenord: bara en administratör kan ändra hur datorn går i vila. Inställningen återställs automatiskt när Håll vaken tar slut, när du avslutar appen eller om den kraschar. Om du inte anger lösenordet ändras ingenting. Se till att datorn har god ventilation med locket stängt. **Stoppa när batteriet är under 20 %** avslutar sessionen innan batteriet tar slut.

Keep Awake, skärmläget och läget med stängt lock kan läggas på en knapp i Kontrollcenter, menyraden eller en widget på skrivbordet via appen Genvägar, med länkar du kopierar från Inställningar › Håll vaken.

## Inställningar

Öppna inställningarna från menyn med **Inställningar…** eller ⌘, eller starta pika-tools igen från Finder, Launchpad eller Spotlight. Medan fönstret är öppet syns appen i Dock och i ⌘Tab.

- **Allmänt**: öppna vid inloggning, utseende (System, Ljust eller Mörkt), språk, uppdateringar och säkerhetskopia: exportera och importera inställningar som en fil, eller synkronisera dem via iCloud Drive.
- **Tangentbord**: kortkommandon med kontroll, ⌘Q och ⌘W, byte av språk.
- **Mus**: pekaracceleration och hastighet, rullning per rad, sidoknappar.
- **Fönster och appar**: avsluta vid sista fönstret, med en lista över undantag, och göm med ett klick i Dock.
- **Håll vaken**: tid, alternativ för skärm och lock.
- **Behörigheter**: status för båda behörigheterna, och för iCloud Drive när synkronisering är på, med knappar som öppnar rätt ställe i Systeminställningar.
- **Om**: version, länkar till ändringsloggen och för att rapportera ett problem.

Varje sida har knappen **Återställ förval…** längst ned. Den frågar först, stänger sedan av verktygen på sidan och återställer deras alternativ, som om pika-tools aldrig hade rört dem.

**Synkronisera inställningar med iCloud** håller pika-tools likadant på alla dina Mac-datorer. Inställningarna ligger i mappen pika-tools i iCloud Drive, och den senaste ändringen gäller. Av som standard, och iCloud Drive måste vara på. Behörigheter synkroniseras inte: varje Mac frågar efter dem själv.

## Uppdateringar

pika-tools söker efter nya versioner vid start och var 6:e timme. Du kan stänga av det under Inställningar › Allmänt. När en ny version finns visas knappen **Uppdatera till …** i menyn: ett klick så hämtar appen uppdateringen, installerar den och startar om. Du kan också söka själv med **Sök nu** under Inställningar › Allmänt.

Med Homebrew kan du också köra `brew upgrade --cask pika-tools`.

Sedan version 1.3 finns behörigheterna kvar efter uppdateringar.

## Avinstallera

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

Om du installerade med Homebrew: `brew uninstall --cask --zap pika-tools`.

Båda avslutar appen, tar bort den från inloggningsobjekten och raderar den. Skriptet återställer även appens behörigheter.

## Vanliga frågor

**Varför behövs två behörigheter?**
macOS delar upp åtkomsten till tangentbord och mus i två delar. Indataövervakning låter appen se händelser och Hjälpmedel låter den ändra dem. För att blockera ett kortkommando behövs båda.

**macOS säger att appen kommer från en oidentifierad utvecklare.**
pika-tools är signerad men inte notariserad av Apple. Homebrew och installationsskriptet tar hand om det åt dig. Om du använde dmg-filen öppnar du **Systeminställningar › Integritet och säkerhet** och klickar på **Öppna ändå**, eller kör:

```bash
xattr -dr com.apple.quarantine /Applications/pika-tools.app
```

**Fungerar den på Mac-datorer med Intel?**
Ja. Det är en universell app för Apple Silicon och Intel, för macOS 14 Sonoma eller senare.

**Behörigheten är på, men ingenting fungerar.**
Ta bort pika-tools från båda listorna i **Systeminställningar › Integritet och säkerhet** med knappen − och lägg sedan till den igen. På sidan Behörigheter i pika-tools inställningar finns knappar som öppnar rätt ställe.

## Bidra

Hur du bygger från källkoden och ger ut versioner beskrivs i [CONTRIBUTING.md](../../CONTRIBUTING.md). Ändringar listas i [CHANGELOG.md](../../CHANGELOG.md).

## Licens

MIT, © 2026 pikapik. Se [LICENSE](../../LICENSE).
