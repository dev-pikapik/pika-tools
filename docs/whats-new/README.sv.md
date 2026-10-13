<p align="center"><a href="../readme/README.sv.md"><img src="../media/icon.png" width="96" height="96" alt="pikapik"></a></p>
<h1 align="center">Nytt i pikapik</h1>
<p align="center">Varje uppdatering med några få ord och en bild, den senaste först.</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <b>Svenska</b> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.44.1"></a>VoiceOver öppnar pikapik-menyn igen

<sub>1.44.1 · 13 oktober 2026</sub>

I macOS 27 kan du öppna pikapik-menyn i menyraden med VoiceOver igen.

Tidigare hände ingenting när du aktiverade pikapik-symbolen med VoiceOver eller ett annat hjälpmedel. Nu öppnas menyn, och om du aktiverar symbolen igen stängs den, precis som med ett klick.

---

## <a id="v1.44.0"></a>Se vilket program som tagit en port

<sub>1.44.0 · 13 oktober 2026</sub>

En ny sida i Inställningar, Portar, visar vilket program som håller varje port på din Mac och frigör porten när du behöver den.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/ports-dark.png"><img src="../media/ports-light.png" width="340" alt=""></picture>

När ett program säger att porten redan används öppnar du Inställningar › Portar. Där finns varje program som har tagit en port, med dess symbol, portarna det håller och om andra enheter i ditt nätverk kan ansluta. Skriv ett portnummer för att se vem som håller porten, eller för att se att den är ledig.

Klicka på en rad för att se adresserna som öppnas i en webbläsare, programmets fil, kommandot som startade det, dess mapp och dess processnummer. ”Frigör” ber programmet att avsluta, så att det hinner spara sitt arbete. Om det inte stängs erbjuder pikapik att tvångsavsluta det. Du får frågan före varje steg.

Delar av macOS och program som tillhör andra användare lämnas orörda. För AirPlay-mottagare, Fildelning, Skärmdelning och Fjärrinloggning berättar pikapik vilket reglage i Systeminställningar som frigör porten. I versionen från Mac App Store visar ”Frigör” programmet, kopierar ett kommando som avslutar det i Terminal eller öppnar Aktivitetskontroll.

---

## <a id="v1.43.0"></a>Se vad som körs i bakgrunden

<sub>1.43.0 · 13 oktober 2026</sub>

pikapik visar nu allt som startar av sig självt och vilken app som lade till det, och stänger av dina egna uppgifter utan att radera något.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.43.0/background-dark.png"><img src="../media/whats-new/1.43.0/background-light.png" width="340" alt=""></picture>

Den nya sidan Bakgrundsuppgifter i Inställningar visar appar som öppnas vid inloggning, bakgrundstjänster, hjälpare inuti appar och rester av borttagna appar. Vid varje uppgift ser du vilken app som lade till den, om den körs just nu och var dess fil ligger. Med ett klick visas filen i Finder.

Dina egna uppgifter stänger du av och slår på igen med en knapp. Ingenting raderas. Vid uppgifter för alla användare och för hela Macen öppnar knappen Startobjekt i Systeminställningar.

I versionen från Mac App Store visar sidan uppgifterna, och knapparna öppnar Startobjekt.

---

## <a id="v1.42.0"></a>Se hur varm din Mac är inuti

<sub>1.42.0 · 13 oktober 2026</sub>

En ny sida i Inställningar, Temperatur, visar hur varma processorn, grafiken, minnet, lagringen, batteriet och Wi-Fi är, och berättar med enkla ord om allt är som det ska.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/temperatures-dark.png"><img src="../media/temperatures-light.png" width="340" alt=""></picture>

Öppna Inställningar › Temperatur. Överst sammanfattar ett enda ord läget: ”Normal”, ”Varm”, ”Het” eller ”Mycket het”, och en kort rad under ordet berättar om din Mac går för full fart eller går långsammare för att svalna. Längre ner har varje del som din Mac kan mäta en egen rad med temperaturen och en färgad stapel: grönt betyder att allt är bra, gult att det är varmt och orange att det är hett, utifrån vad som är normalt för just den delen.

Vill du hålla koll på temperaturen? Klicka på pennan längst ner i pikapik-menyn och markera ”Temperatur”. Menyn visar då samma ord och processorns temperatur, och ett klick på raden öppnar sidan.

Temperaturerna uppdateras varannan sekund, men bara medan sidan eller menyn är öppen, så ingenting kontrolleras i bakgrunden. pikapik läser bara av temperaturerna: det behövs inget lösenord och ingenting ändras.

**Åtgärdat**

- Om du har valt vilka rader pikapik-menyn visar dyker raden ”Håll Dock på en skärm” inte längre upp där av sig själv. Vill du visa den klickar du på pennan och markerar den.
- När du stänger Inställningar slutar pikapik nu direkt att kontrollera fläktarna och batteriet i stället för att fortsätta i bakgrunden.

---

## <a id="v1.41.1"></a>Fläktstyrningen frågar inte längre efter ditt lösenord

<sub>1.41.1 · 13 oktober 2026</sub>

Hjälparen som ställer in fläkthastigheten uppdateras nu tillsammans med pikapik, så nya versioner frågar inte längre efter administratörslösenordet.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Den här uppdateringen frågar efter det en sista gång. Om du använder fläktstyrning öppnar du Inställningar › Behörigheter, klickar på ”Tillåt” bredvid ”Fläktstyrning” och anger lösenordet. Därefter uppdaterar pikapik hjälparen själv och godtar bara en hjälpare som verkligen kommer från pikapik.

**Åtgärdat**

- I Systeminställningar › Allmänt › Startobjekt visas fläktarnas hjälpare nu som pikapik, med appens symbol.

---

## <a id="v1.41.0"></a>Se hur batteriet mår

<sub>1.41.0 · 13 oktober 2026</sub>

En ny sida i Inställningar, Batteri, visar hur slitet batteriet är, vad det laddas med och hur du får det att räcka längre.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/battery-dark.png"><img src="../media/battery-light.png" width="340" alt=""></picture>

Öppna Inställningar › Batteri. Där ser du laddningen och vad som händer med batteriet just nu, dess skick, den maximala kapaciteten jämfört med när det var nytt och cykelantalet, alltså hur många cykler det redan har gått igenom av de 1000 det är utformat för.

När din Mac är ansluten visar sidan strömadaptern och dess effekt, och medan den laddar också laddeffekten, alltså hur mycket som går in i batteriet just nu. När din Mac går på batteri visar sidan hur mycket ström den använder just nu.

Tipsen längst ner hjälper batteriet att räcka längre, och ”Batteriinställningar…” öppnar Batteri i Systeminställningar, där du väljer hur macOS laddar det. Sidan ändrar ingenting och behöver ingen behörighet, inte heller i versionen från Mac App Store. Den finns bara på Mac-datorer med batteri.

**Åtgärdat**

- När du tar bort pikapik med Homebrew stängs nu även ”Öppna vid inloggning” av, och systeminställningarna som appen ändrat återställs, till exempel animationer, tangentupprepning och aktiva hörn. Om pikapik har uppdaterat sig själv kör du brew upgrade --cask pikapik en gång innan du tar bort den.

---

## <a id="v1.40.2"></a>Uppdateringar med Homebrew startar inte längre om Dock

<sub>1.40.2 · 13 oktober 2026</sub>

När du uppdaterar pikapik med Homebrew försvinner Dock inte längre en kort stund.

Uppdateringen till den här versionen kan fortfarande starta om Dock en sista gång, eftersom det steget fortfarande görs av versionen du hade innan. Senare uppdateringar lämnar Dock i fred.

---

## <a id="v1.40.1"></a>Ett klick i Dock lägger undan fönstren

<sub>1.40.1 · 13 oktober 2026</sub>

Klicka i Dock på symbolen för appen du arbetar i, så minimeras alla dess fönster till Dock. Klicka igen, så kommer alla tillbaka.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.40.1/dock-minimize-dark.png"><img src="../media/whats-new/1.40.1/dock-minimize-light.png" width="340" alt=""></picture>

Öppna Inställningar › Dock och slå på ”Minimera eller göm med ett klick i Dock”. Fönstren kommer tillbaka i samma ordning, med det du arbetade i överst. Ett klick på en annan app, att hålla ned en symbol för dess meny och att dra symboler fungerar som förut.

Vill du hellre gömma hela appen, som med ⌘H? Ställ in ”Ett klick på symbolen” under reglaget på ”Gömmer appen”. Om du redan gömde appar med ett klick i Dock ändras ingenting för dig. Reglaget kräver behörigheten ”Hjälpmedel”, finns inte i versionen från Mac App Store och är av som standard.

---

## <a id="v1.40.0"></a>Dock stannar på en skärm

<sub>1.40.0 · 13 oktober 2026</sub>

Dock hoppar inte längre över till en annan skärm när pekaren trycker mot den skärmens kant, utan stannar där du har den.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-display-dark.png"><img src="../media/dock-display-light.png" width="340" alt=""></picture>

Öppna Inställningar › Dock och slå på ”Håll Dock på en skärm”. Sedan stannar Dock på sin skärm, nere eller på sidan, och aktiva hörn fortsätter att fungera. Ingen behörighet behövs, inte heller i versionen från Mac App Store.

Vill du flytta Dock med flit, håll ned ⌥ och tryck pekaren mot kanten av den andra skärmen. Dock flyttar då dit och blir kvar på den skärmen.

Ett andra reglage, ”Ta tillbaka Dock”, för automatiskt tillbaka Dock till sin skärm efter vila eller när skärmar ändras. Det kräver behörigheten ”Hjälpmedel” och finns inte i versionen från Mac App Store. Båda reglagen är av som standard.

---

## <a id="v1.39.4"></a>Den röda knappen stoppar inte längre arkiven

<sub>1.39.4 · 13 oktober 2026</sub>

Om du stängde lösenordsfönstret med den röda knappen slutade pikapik att öppna och skapa arkiv tills du startade om appen. Det är åtgärdat.

Den röda knappen i lösenordsfönstret och i fönstret för ett nytt arkiv fungerar nu precis som ”Avbryt”, och nästa arkiv öppnas direkt. VoiceOver läser nu upp uppdateringsknappen i Inställningar › Om med dess eget namn.

---

## <a id="v1.39.3"></a>Ditt husdjur följer din rytm

<sub>1.39.3 · 13 oktober 2026</sub>

Medan du skriver piggnar husdjuret till och travar runt med fjädrande steg. Går du ifrån din Mac blir det sömnigt, sätter sig och slumrar till.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.3/pet-rhythm-dark.png"><img src="../media/whats-new/1.39.3/pet-rhythm-light.png" width="340" alt=""></picture>

Efter ungefär 40 sekunder utan att du rör tangentbordet eller musen blir ögonlocken tunga, och efter en och en halv minut sover det som en stock medan små z svävar uppåt. Tryck på en tangent eller flytta musen, så vaknar det, reser sig och går vidare. Medan det tar en tupplur är det tyst och drar mindre energi.

pikapik tittar aldrig på vad du skriver, utan kollar bara hur lång tid som har gått sedan du senast tryckte på en tangent eller rörde musen, precis som macOS gör innan skärmen dimmas. Därför behövs inga behörigheter. Vill du hellre att husdjuret alltid är pigg? Stäng av ”Följer din rytm” i husdjurets inställningar.

**Prova:** Inställningar › Husdjur › Följer din rytm

---

## <a id="v1.39.2"></a>Synkade inställningar ligger nu i en mapp som heter pikapik

<sub>1.39.2 · 13 oktober 2026</sub>

Om du synkar inställningarna med iCloud ligger de nu i iCloud Drive i en mapp som heter pikapik i stället för pika-tools, och pikapik flyttar dem dit själv.

<img src="../media/icon.png" width="128" height="128" alt="">

Du behöver inte göra något: inställningarna är desamma, och den gamla mappen försvinner när de har flyttats. Om du har lagt egna filer i den ligger den kvar. Om du synkar flera Mac-datorer, uppdatera pikapik på var och en så att de fortsätter dela inställningar.

**Åtgärdat**

- När du tar bort pikapik helt med Homebrew (brew uninstall --zap) raderas nu även listan över nyligen borttagna appar.
- Äldre inlägg på den här sidan kallar nu appen pikapik.

---

## <a id="v1.39.1"></a>Den vanliga namnlisten i arkivfönstren

<sub>1.39.1 · 13 oktober 2026</sub>

Arkivfönstren har åter den vanliga namnlisten i macOS, med tre runda knappar till vänster.

Du kan dra ett fönster i överkanten, precis som överallt på Mac. I fönstret för ett nytt arkiv och i lösenordsfönstret stänger den röda knappen fönstret utan att skapa eller packa upp något. Knappar som inte behövs i ett fönster är grå. Fönstret som visar förloppet när en mindre kopia skapas eller en fil konverteras har nu också samma knappar. Reglaget ”Öppna arkiv med den här appen” kommer nu ihåg vilken app som öppnade ZIP- och 7Z-filer tidigare och ger tillbaka dem till den när du stänger av det.

---

## <a id="v1.39.0"></a>Nya arkivfönster, och lösenordet skrivs två gånger

<sub>1.39.0 · 13 oktober 2026</sub>

När du skyddar ett nytt arkiv med lösenord skriver du det nu två gånger, så att ett stavfel inte låser ute dig från dina egna filer.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.0/archive-password-dark.png"><img src="../media/whats-new/1.39.0/archive-password-light.png" width="340" alt=""></picture>

Under fälten visas en grön rad när lösenorden stämmer överens, eller en röd när de inte gör det, och ”Skapa” väntar tills de är lika.

Alla arkivfönster har fått ett nytt utseende: en stor symbol, ett enda reglage för lösenordet och en kort rad som berättar om filnamnen förblir synliga, som i ZIP, eller också döljs, som i 7Z. I macOS 26 är knapparna gjorda av Liquid Glass.

Installationen är också enklare: kommandot överst på pikapiks sida på GitHub behöver inget annat på din Mac. Det installerar pikapik bara om nedladdningen är signerad av utvecklaren och har klarat Apples kontroll av skadlig kod.

---

## <a id="v1.38.2"></a>Säkrare uppdateringar bredvid versionen från App Store

<sub>1.38.2 · 12 oktober 2026</sub>

Om du också har pikapik från App Store på din Mac uppdateras GitHub-versionen nu på plats, och versionen från App Store lämnas ifred.

Förut installerades uppdateringen inte om GitHub-versionen fortfarande hade sitt gamla namn, pika-tools, och inte var installerad med Homebrew. I stället öppnades versionen från App Store, och att pikapik öppnas vid inloggning stängdes av.

---

## <a id="v1.38.1"></a>En stabilare Finder-meny

<sub>1.38.1 · 12 oktober 2026</sub>

pikapiks alternativ i högerklicksmenyn i Finder försvinner inte längre när du ansluter en skiva, öppnar en skivavbild, väcker din Mac ur vila eller byter till Finder.

I sällsynta fall avslutades hjälpprogrammet som visar dem just då.

---

## <a id="v1.38.0"></a>Öppna och skapa arkiv i Finder

<sub>1.38.0 · 12 oktober 2026</sub>

Nya ”Arkiv i Finder” öppnar RAR och andra arkiv som macOS inte kan öppna, och skapar ZIP och 7Z från högerklicksmenyn.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/archive-dark.png"><img src="../media/archive-light.png" width="340" alt=""></picture>

Öppna Inställningar › Finder och slå på ”Arkiv i Finder”. Högerklicka på ett arkiv och välj ”Packa upp”, så dyker filerna upp bredvid det. Högerklicka på en annan fil eller mapp och välj ”Skapa arkiv…” för att göra en ZIP, 7Z, TAR.GZ eller TAR.XZ. ZIP och 7Z kan ha lösenord, och varje arkiv kan delas upp i delar, till exempel på 15 MB för e-post. En ZIP som görs så har inga dolda filer som systemet lägger till och behåller namn på alla språk läsbara.

pikapik öppnar också sådant som macOS inte kan: RAR, även uppdelat på flera filer, 7Z med lösenord, ZIPX, CAB, LZH, ARJ, ZST, WIM och fler. Dubbelklicka så öppnas de i pikapik. Filnamn i gamla ZIP-filer, till exempel på kyrilliska, japanska eller kinesiska, blir läsbara. Med reglaget ”Öppna arkiv med den här appen” tar pikapik också över ZIP och 7Z, medan TAR och GZ stannar hos den inbyggda arkivappen, som redan hanterar dem bra.

Ett fönster frågar efter lösenordet, ”Stoppa” avbryter vilket jobb som helst, och ur ett skadat arkiv plockar pikapik ut det som fortfarande går att läsa. Det frågar innan ett arkiv packas upp som skulle svälla till en enorm storlek, och blockerar arkiv som försöker skriva utanför sin egen mapp. Finns inte i versionen från Mac App Store. Markera ett arkiv och tryck på mellanslag för att se vad som finns i det.

---

## <a id="v1.37.3"></a>FPS-etiketten frågar nu på rätt ställe

<sub>1.37.3 · 12 oktober 2026</sub>

Skärminspelning för FPS-etiketten tillåter du nu på sidan Behörigheter, tillsammans med alla andra behörigheter.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

För att räkna bilderna i ett spel kan ”Visa FPS” behöva Skärminspelning. Tidigare frågade pikapik efter den direkt på sidan Spel. Nu finns den bland alla andra behörigheter: när ”Visa FPS” behöver den dyker raden ”Skärminspelning” upp i Inställningar › Behörigheter, och där klickar du på ”Tillåt”.

På sidan Spel ser du nu bara den vanliga raden under reglaget: ”Behöver en behörighet. Klicka för att tillåta den.” Knappen ”Tillåt” i den tar dig rakt till raden ”Skärminspelning”. När du slår på ”Visa FPS” dyker ingen fråga upp av sig själv längre, och pikapik frågar fortfarande aldrig medan du spelar.

---

## <a id="v1.37.2"></a>Kontrollerad av Apple

<sub>1.37.2 · 12 oktober 2026</sub>

pikapik är nu signerad av en verifierad Apple-utvecklare och kontrollerad av Apple. Därför varnar macOS inte längre när du öppnar den första gången.

Efter den här uppdateringen kan macOS fråga om de behörigheter du gav pikapik igen, till exempel Hjälpmedel, Inmatningsövervakning eller Full diskåtkomst. Tillåt dem en gång till i Systeminställningar › Integritet och säkerhet. Om du använder fläktstyrningen, tillåt den igen i pikapiks inställningar, så frågar macOS efter ditt lösenord en gång.

---

## <a id="v1.37.1"></a>FPS-etiketten hänger med i ditt spel

<sub>1.37.1 · 12 oktober 2026</sub>

Flytta spelfönstret, så följer FPS-etiketten nu med direkt.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Tidigare kom etiketten ikapp ett fönster i rörelse bara ungefär en gång i sekunden och släpade därför efter. Nu kontrollerar den fönstret vid varje bildruta på skärmen och ligger högst några tusendels sekund efter. När fönstret står still kontrollerar den mer sällan, så den belastar knappt din Mac medan du spelar. Den hoppar inte heller iväg längre när en del av fönstret hamnar utanför skärmkanten.

Om ett lugnt spel som schack visar 0 är allt som det ska: sådana spel ritar en ny bild bara när något rör sig. Siffran stiger medan en pjäs glider och sjunker tillbaka till 0 när brädet står still.

---

## <a id="v1.37.0"></a>Se hur smidigt ditt spel går

<sub>1.37.0 · 12 oktober 2026</sub>

Nya Visa FPS lägger en liten räknare i ett hörn av spelet, så att du ser hur smidigt det går.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Öppna Inställningar › Spel och slå på ”Visa FPS”. Så länge Spelläge är på visas en liten mörk etikett med ett tal i ett hörn av alla spel. FPS betyder bilder per sekund: hur många bilder spelet ritar varje sekund, och ju högre tal, desto smidigare går spelet. Välj hörn genom att klicka på det i bilden ovanför reglaget.

Klick går rakt igenom etiketten, som följer spelfönstret. Ett streck betyder att de första bilderna inte har kommit ännu, och en blek 0 att spelet har slutat rita. ”Visa FPS” är av tills du slår på det.

På macOS 27 räknar macOS själv de flesta spel, så ingen behörighet behövs. Några spel, mest äldre, går bara att räkna via skärminspelning, och då kan siffran inte bli högre än skärmens uppdateringsfrekvens. På macOS 14–26 och i versionen från Mac App Store räknas alla spel så, och därför ber pikapik om ”Skärminspelning” när du slår på ”Visa FPS”. Ingen bild sparas eller skickas.

---

## <a id="v1.36.0"></a>Ta bort appar utan oro

<sub>1.36.0 · 12 oktober 2026</sub>

Nya Ta bort appar tar bort en app med alla dess filer och lägger tillbaka allt om du ångrar dig.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/uninstaller-dark.png"><img src="../media/uninstaller-light.png" width="340" alt=""></picture>

Öppna Inställningar › Ta bort appar och välj en app, eller släpp en på bilden. pikapik visar allt som appen sparar på din Mac, med skälet till varje fil. Filer som tydligt hör till appen är ikryssade, och filer som bara kanske hör ihop med den är det inte. Klicka på ”Flytta till papperskorgen”, så hamnar allt i papperskorgen och inget raderas för gott.

Ångrade du dig? Klicka på ”Lägg tillbaka”, så hamnar allt där det låg. De tio senaste borttagningarna väntar under ”Nyligen borttagna” så länge deras filer ligger kvar i papperskorgen. ”Återställ appen” behåller appen och tar bara bort dess sparade data, inställningar och tillfälliga filer, om den skulle krångla.

Har du själv lagt en app i papperskorgen? Sidan visar sådana appar och filerna de lämnade kvar, och med ett reglage kan pikapik erbjuda städning varje gång en app hamnar i papperskorgen. Inget tas bort förrän du väljer. För att se allt behöver sidan Full skivåtkomst.

---

## <a id="v1.35.0"></a>Klä på ditt husdjur

<sub>1.35.0 · 12 oktober 2026</sub>

Ditt husdjur har fått en garderob, och när ni leker tillsammans vinner du nya plagg.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.35.0/wardrobe-dark.png"><img src="../media/whats-new/1.35.0/wardrobe-light.png" width="340" alt=""></picture>

Öppna Inställningar › Husdjur och välj vad ditt husdjur ska ha på sig: hattar, glasögon, halsdukar, tröjor, skor, kappor och till och med vingar. Det tar på sig plagget direkt. Några plagg är gratis, resten är utmärkelser som kommer medan ni leker tillsammans: lyft upp husdjuret och kasta det, sparka runt bollen, titta på när det klättrar på fönster och pratar, eller håll det helt enkelt sällskap dag efter dag. När du har fått en utmärkelse säger husdjuret till.

Färdiga outfits klär på husdjuret från topp till tå med ett klick: trollkarl, pirat, astronaut, superhjälte, kung och fler. En outfit är klar när du har fått alla dess delar.

Bara enkla siffror sparas, som steg, kast och dagar tillsammans. De stannar på din Mac, ingenting skickas någonstans och du kan radera dem när som helst i Inställningar › Husdjur.

---

## <a id="v1.34.0"></a>Mus och styrplatta i spel

<sub>1.34.0 · 12 oktober 2026</sub>

Svep, nyp och aktiva hörn tar dig inte längre ut ur spelet, precis som kortkommandon.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.34.0/pointer-shortcuts-dark.png"><img src="../media/whats-new/1.34.0/pointer-shortcuts-light.png" width="340" alt=""></picture>

Under Inställningar › Spel › Fler spelinställningar finns gruppen ”Mus och styrplatta”. Den visar bara det som är aktiverat i macOS på din Mac, med Apples egna namn och en liten teckning för varje: kortkommandon på en musknapp, svep mellan skrivbord och appar i helskärm, Mission Control och App Exposé, nyp för appar och sprid fingrarna för skrivbordet, svep från högerkanten för Aviseringscenter och varje aktivt hörn med sin åtgärd. Medan ett spel är i förgrunden är de pausade, så ett oavsiktligt svep eller en snabb beröring av ett skärmhörn tar dig inte ut ur spelet. Gester inne i spelet fungerar som vanligt. Var och en kan ställas in så att den fungerar som vanligt.

---

## <a id="v1.33.2"></a>Genvägsgrupper öppnas direkt

<sub>1.33.2 · 11 oktober 2026</sub>

Även den längsta gruppen systemgenvägar öppnas med en gång, och varje rad har ett tydligt namn.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Tidigare hakade inställningsfönstret upp sig en stund när en grupp med dussintals rader öppnades, eftersom alla rader och deras animerade förhandsvisningar byggdes på en gång. Nu byggs bara de rader som syns och några i närheten. Raderna ”Systemåtgärd” med ett nummer är också borta: Diktering, Siri och tangenterna för ljusstyrka och zoom visar sina riktiga namn, och åtgärder som macOS inte namnger döljs men pausas fortfarande i spel precis som förut.

---

## <a id="v1.33.1"></a>Grupper med kortkommandon öppnas utan att hacka

<sub>1.33.1 · 11 oktober 2026</sub>

Sidan Spel förblir smidig när en lång lista med förhandsvisningar fälls ut.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Att fälla ut en grupp med systemets kortkommandon fick inställningsfönstret att frysa i upp till tre sekunder, eftersom varje rad med sin förhandsvisning beräknades flera gånger. Nu beräknas varje rad bara en gång, så grupperna öppnas nästan direkt.

---

## <a id="v1.33.0"></a>Alla behörigheter på ett ställe

<sub>1.33.0 · 11 oktober 2026</sub>

Inställningar › Behörigheter visar nu allt som pikapik använder och låter dig ta tillbaka vilken behörighet som helst.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.33.0/permissions-dark.png"><img src="../media/whats-new/1.33.0/permissions-light.png" width="340" alt=""></picture>

Inställningar › Behörigheter visar nu varje behörighet som pikapik använder, från Hjälpmedel och Övervakning av inmatning till Fläktstyrning, Finder-tillägg, iCloud Drive och Full skivåtkomst. Varje rad förklarar med en mening vad den är till för, med en grön bock när den är på och ett orange kryss när den saknas.

Varje rad har en enda knapp: Tillåt när behörigheten saknas, Stäng av när den är på. Så du kan ta tillbaka vilken behörighet som helst direkt där, utan att leta i Systeminställningar. För Hjälpmedel och Övervakning av inmatning frågar pikapik först och startar sedan om utan dem.

Ett verktyg som behöver en behörighet du inte har gett ser halvgrått ut. Klicka på det, så öppnas Behörigheter med rätt rad markerad, redo för ett klick på Tillåt.

**Prova:** Öppna Inställningar › Behörigheter och titta på varje rad. Klicka på ett grått verktyg för att hoppa direkt till den behörighet det behöver.

---

## <a id="v1.32.2"></a>Säkrare installation, och uppdateringar tappar aldrig appen

<sub>1.32.2 · 11 oktober 2026</sub>

En omgång rättningar som gör installation, uppdatering och avinstallation säkrare.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Fläkthjälpen installeras nu försiktigare och kontrolleras innan den startar. Om en uppdatering inte kan kopieras ligger din nuvarande pikapik kvar. Vid avinstallation tas fläkthjälpen också bort, och din inställning för tangentupprepning, Dock-hörnen och systemgenvägarna återställs.

Nedhållna tangenter fastnar inte längre när ett verktyg startar om, och när du stänger av ”Upprepa en nedhållen tangent” får du tillbaka din egen inställning för accentmenyn. Husdjuret vilar medan skärmen sover eller är låst, och en kopia av archive.tar.gz heter nu archive 2.tar.gz.

---

## <a id="v1.32.1"></a>Manuell fläkthastighet fungerar redan första gången

<sub>1.32.1 · 11 oktober 2026</sub>

Att välja Manuell under Fläktar hoppar inte längre tillbaka till Auto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Ibland skickade första trycket på Manuell tillbaka fläktarna till Auto med en säkerhetsvarning, och först andra trycket fungerade. Nu ligger Manuell kvar redan från första försöket.

Om en fläkt ändå lämnar Manuell av sig själv sätter pikapik den på riktigt tillbaka till Auto, så det du ser stämmer alltid med vad din Mac gör.

Du behöver inte tillåta något igen. Uppdatera så fungerar det.

**Prova:** Öppna Inställningar › Fläktar och välj Manuell.

---

## <a id="v1.32.0"></a>Se hur fort dina fläktar snurrar

<sub>1.32.0 · 11 oktober 2026</sub>

En ny flik, Fläktar, visar varje fläkt live och låter dig välja hastighet.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Fläktarna har nu en egen flik i Inställningar och en rad i menyn. Du ser i realtid hur fort varje fläkt snurrar just nu, med en liten fläkt som snurrar med bredvid.

Låt den stå på Auto så bestämmer din Mac själv, som vanligt. Eller välj Manuell och dra i ett enda reglage för att ställa in den hastighet du vill. Första gången tillåter du det en gång med ditt administratörslösenord, sedan är det klart.

Det är byggt för att vara säkert. Fläktarna går tillbaka till Auto när du avslutar pikapik, när din Mac går i vila, om pikapik kraschar eller när din Mac blir varm.

**Prova:** Öppna Inställningar › Fläktar och titta på hastigheten. Välj Manuell för att prova reglaget.

---

## <a id="v1.31.4"></a>Detaljer när du behöver dem

<sub>1.31.4 · 11 oktober 2026</sub>

En lugnare spelsida och en enda sökning.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.4/game-choices-dark.png"><img src="../media/whats-new/1.31.4/game-choices-light.png" width="340" alt=""></picture>

Varje läge förklarar sin funktion i rullgardinslistan. När den är stängd finns bara det valda namnet kvar på sidan.

Beskrivningar som upprepar åtgärdens namn har tagits bort. Användbar extra information finns kvar.

Den globala sökningen hittar systemåtgärder efter namn, betydelse och tangenter. Ett resultat öppnar och markerar exakt den inställningen.

**Prova:** Hitta en åtgärd i den globala sökningen och öppna dess lägeslista.

---

## <a id="v1.31.3"></a>Enhetliga spelinställningar

<sub>1.31.3 · 11 oktober 2026</sub>

Likadana förhandsvisningar och tydligare kortkommandon.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.3/game-preview-dark.png"><img src="../media/whats-new/1.31.3/game-preview-light.png" width="340" alt=""></picture>

Varje kortkommando har nu samma breda förhandsvisning som spelskyddet och de andra inställningssidorna. Beskrivning, reglage och förklaring av det valda alternativet finns under den.

«Följ spellägets regler». Ett kort kommando byter språk utan meny. Nedtryckta speltangenter förhindrar oavsiktliga språkbyten.

«Inaktivera i spel». Denna macOS-åtgärd är avstängd när spelet är i förgrunden. När du lämnar spelet fungerar den som förut. «Tillåt i spel». macOS utför åtgärden normalt, även om den öppnar ett fönster eller flyttar fokus från spelet.

**Prova:** Öppna fler spelinställningar, fäll ut systemkontroller och välj hur en åtgärd fungerar medan du spelar.

---

## <a id="v1.31.2"></a>Tydligare spelinställningar

<sub>1.31.2 · 11 oktober 2026</sub>

Anpassa skyddet och utforska kortkommandona på din Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.2/game-settings-dark.png"><img src="../media/whats-new/1.31.2/game-settings-light.png" width="340" alt=""></picture>

Åtta tydliga ämnen ersätter upprepade mappar. Varje rubrik har namn, förklaring, symbol och antal. Klicka var som helst på raden för att öppna den.

Varje åtgärd förklarar vad den gör bredvid den animerade förhandsvisningen. Aktuella tangenter och beteendet i spel har en egen rad. Sökningen hittar även beskrivningar.

Tangenter utan tilldelning har en tydlig länk till Systeminställningar. Allmänna spelskydd samlas separat och dina val behålls.

**Prova:** Öppna Fler spelinställningar, fäll ut ett ämne och jämför en åtgärds beskrivning med förhandsvisningen.

---

## <a id="v1.31.1"></a>Språkgester i spel

<sub>1.31.1 · 11 oktober 2026</sub>

Enkelt som standard, med hela systemkatalogen när du behöver den.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/input-switch-dark.png"><img src="../media/input-switch-light.png" width="340" alt=""></picture>

Språkgesten i pikapik fungerar i spelet även när macOS språkkortkommandon saknar tilldelning eller är avstängda.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automatiskt pausar åtgärder som öppnar fönster eller flyttar fokus. En kort avsiktlig språkgenväg byter källa utan systemfönster. Nedhållna rörelsetangenter går först, så att springa och hoppa inte byter språk av misstag.

Varje åtgärd kan ändras i den sökbara katalogen. Språk kan bytas i bakgrunden; andra åtgärder kan pausas eller tillåtas normalt. Valen synkroniseras. Andra appar som bevakar tangenter visas separat. Tvångsavsluta är fortfarande tillgängligt.

**Prova:** Håll ned ⌥ och tryck på ⇧: nästa språk. Håll ned ⇧ och tryck på ⌥: föregående

---

## <a id="v1.31.0"></a>Spelläge känner till Macens genvägar

<sub>1.31.0 · 11 oktober 2026</sub>

Enkelt som standard, med hela systemkatalogen när du behöver den.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Slå på Spelläge och spela. Fler spelinställningar innehåller Macens katalog med aktuella tangenter och en animerad förhandsvisning för varje åtgärd.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automatiskt pausar åtgärder som öppnar fönster eller flyttar fokus. En kort avsiktlig språkgenväg byter källa utan systemfönster. Nedhållna rörelsetangenter går först, så att springa och hoppa inte byter språk av misstag.

Varje åtgärd kan ändras i den sökbara katalogen. Språk kan bytas i bakgrunden; andra åtgärder kan pausas eller tillåtas normalt. Valen synkroniseras. Andra appar som bevakar tangenter visas separat. Tvångsavsluta är fortfarande tillgängligt.

**Prova:** Öppna extra inställningar, sök en skärmfoto- eller språkgenväg och jämför förhandsvisningen med och utan skydd.

---

## <a id="v1.30.14"></a>Genvägslänkar öppnas utan krasch

<sub>1.30.14 · 11 oktober 2026</sub>

Att klicka på en avstängd genväg stänger inte längre pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

På Spel-sidan kan du klicka på en genväg utan tilldelade tangenter. Systeminställningar öppnas säkert.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Tidigare kunde pikapik läsa samma ändrade rad två gånger medan fönstret öppnades. Om texten försvann mellan läsningarna kraschade appen.

Varje rad läses nu en gång. Saknad text hoppas över. Fixen gäller även genvägslänkar på andra sidor.

**Prova:** Klicka på en avstängd genväg på Spel-sidan.

---

## <a id="v1.30.13"></a>Håll Control nere och fortsätt spela

<sub>1.30.13 · 10 oktober 2026</sub>

Control låter inte längre språkbytet ta mellanslag från ditt spel.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Håll Control för att springa och tryck på mellanslag för att hoppa. I Spelläge pausas språkbyte med Control+mellanslag och Control+Option+mellanslag.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Andra macOS-genvägar med Control, eller Shift och Option utan Command, pausas också, inklusive dina egna val. Tryck, släpp och nedhållna tangenter når spelet tillsammans.

pikapiks språkrörelse och avslutningsgenvägar med spelmodifierare stör inte heller. När du lämnar spelet återgår systemgenvägarna precis som de var.

**Prova:** Håll Control, rör dig och tryck på mellanslag några gånger. Lämna sedan spelet och byt språk som vanligt.

---

## <a id="v1.30.12"></a>Dra ditt spel från Aktivitetskontroll

<sub>1.30.12 · 10 oktober 2026</sub>

Spelläge tar emot processer som dras från Aktivitetskontroll.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Hitta spelets process och dra raden till Dina spel i Inställningar → Spel.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Java-spel fungerar även utan en vanlig ikon i Dock. Tidigare ignorerades dessa rader eftersom de innehåller processnummer och namn i stället för en fil.

Spelet sparas för nästa start. Minecraft visas med sitt eget namn. Nummer och namn måste passa en process som körs.

**Prova:** Dra java-raden för ditt öppna Minecraft till Dina spel.

---

## <a id="v1.30.11"></a>Lägg till ditt spel medan det körs

<sub>1.30.11 · 10 oktober 2026</sub>

Dina öppna spel visas nu först när du lägger till ett spel.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Öppna Inställningar → Spel → Lägg till ett spel och klicka på spelet som körs. Spel via Java och andra miljöer visas också, även utan en .app-fil. Minecraft heter Minecraft i stället för java.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Apparna i Dock har nu en egen utfällbar lista, så du hittar ditt öppna spel direkt.

Annat… och dra och släpp tar även emot spelets körbara fil, utöver appar. När spelet är tillagt startar Spelläge när du växlar till det.

**Prova:** Låt spelet vara öppet, välj Lägg till ett spel och klicka på dess ikon. Du behöver inte leta i mappar.

---

## <a id="v1.30.10"></a>Ditt husdjur syns när det hoppar

<sub>1.30.10 · 10 oktober 2026</sub>

Ditt husdjur försvinner inte längre bakom fönster när det hoppar på en skärm utan Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Förut, om Dock låg på en annan skärm eller var dold, hoppade ditt husdjur bakom dina fönster och syntes inte förrän det landade. Nu syns det framför dina fönster så fort det lämnar marken, på alla skärmar, med eller utan Dock. Bollen likaså.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Ett fönster som bara nuddar kanten på ditt husdjur döljer det inte längre när det hoppar. Ditt husdjur stannar bakom ett fönster bara när fönstret verkligen täcker det, som en video du tittar på.

På marken går ditt husdjur och dess boll bakom dina fönster, precis som förut.

**Prova:** Låt Dock döljas automatiskt eller flytta den till en annan skärm, och tryck på mellanslag bredvid ett fönster. Ditt husdjur hoppar framför det.

---

## <a id="v1.30.9"></a>Helskärmen är din, och bollen spelar schysst

<sub>1.30.9 · 10 oktober 2026</sub>

Ditt husdjur smyger inte längre in i en video i helskärm, och bollen krockar inte med saker som inte finns.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Förut kunde ditt husdjur dyka upp ibland medan du tittade på en video i helskärm. Nu frågar pikapik macOS direkt om en skärm visar något i helskärm och kollar en gång till när bytet är klart. Ditt husdjur och bollen håller sig gömda tills du lämnar helskärm.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Bollen studsar inte längre mot tom luft. Den flyger över Dock i stället för att slå i en osynlig vägg. Musen träffar nu bollen bara när pekaren verkligen nuddar den. En lätt beröring får den att rulla, ett snabbt svep får den att flyga. Och om ditt husdjur eller bollen gömmer sig bakom ett fönster låter musen över det fönstret dem vara.

Att dra en fil över skrivbordet bygger inte längre ett trappsteg åt ditt husdjur. Det gör bara en markeringsram.

**Prova:** Titta på en video i helskärm och pausa den några gånger med mellanslag. Ditt husdjur syns inte. Svep sedan med musen mot bollen.

---

## <a id="v1.30.8"></a>Skärmens hörn håller tyst medan du spelar

<sub>1.30.8 · 10 oktober 2026</sub>

I Spelläge sätter musen vid skärmens kanter och hörn inte längre igång aktiva hörn och drar inte fram en dold Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Förut kunde musen i ett hörn eller vid skärmkanten sätta igång ett aktivt hörn eller dra fram en dold Dock mitt i spelet.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Nu stänger Spelläge av aktiva hörn och den dolda Docken medan du spelar. Några sekunder efter att du lämnat spelet, eller när du avslutar pikapik, kommer de tillbaka precis som de var.

Och pekaren hackar inte längre vid kanten av skärmen med spelet.

**Prova:** Slå på Spelläge, starta ett spel och för musen till ett hörn av skärmen. Inget dyker upp.

---

## <a id="v1.30.7"></a>Ditt husdjur håller sig borta från din video

<sub>1.30.7 · 10 oktober 2026</sub>

När ditt husdjur eller bollen är bakom ett fönster stannar de där, även när de hoppar eller flyger.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Förut kunde ett hopp eller en flygtur få ditt husdjur eller bollen att dyka upp rakt över det du tittade på, fast de gömde sig bakom en video eller ett spel. Att trycka på mellanslag för att pausa en video lockade också fram husdjuret.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Nu stannar de bakom fönstret som täcker dem, vad de än gör. Och en video i helskärm i Firefox gömmer dem direkt.

Bakom vanliga fönster gömmer de sig precis som förut.

**Prova:** Spela upp en video i ett stort fönster som täcker skärmens nederkant och tryck på mellanslag för att pausa. Ditt husdjur stannar bakom videon.

---

## <a id="v1.30.6"></a>I helskärm tar ditt husdjur paus överallt

<sub>1.30.6 · 10 oktober 2026</sub>

Medan någon app är i helskärm gömmer sig ditt husdjur och bollen nu på alla skärmar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Förut, när du öppnade en video eller ett spel i helskärm, sprang ditt husdjur och bollen ibland över till en annan skärm och fortsatte leka där.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Nu gömmer de sig på alla dina skärmar så länge någon app är i helskärm. Lämna helskärm, så är de tillbaka direkt.

Bakom vanliga fönster gömmer de sig precis som förut.

**Prova:** Har du två skärmar, visa en video i helskärm på den ena. Ditt husdjur och bollen försvinner från båda och kommer tillbaka när du lämnar helskärm.

---

## <a id="v1.30.5"></a>Ditt husdjur kliver åt sidan medan du tittar eller spelar

<sub>1.30.5 · 10 oktober 2026</sub>

Ditt husdjur och bollen gömmer sig nu medan en app är i helskärm, även på Mac med notch.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Förut kunde ditt husdjur på en Mac med notch ligga kvar ovanpå en video eller ett spel i helskärm, och bollen dök ibland upp över en helskärmsapp på en annan skärm.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Nu väntar ditt husdjur och bollen utom synhåll så länge en app fyller hela skärmen. Lämna helskärm, så är de tillbaka direkt.

Bakom vanliga fönster gömmer de sig precis som förut.

**Prova:** Visa en video i helskärm eller starta ett spel. Ditt husdjur och bollen håller sig undan tills du är klar.

---

## <a id="v1.30.4"></a>Ditt husdjur syns när det hoppar eller åker med en markering

<sub>1.30.4 · 10 oktober 2026</sub>

Ditt husdjur och bollen försvinner inte längre bakom fönster medan de är i luften.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Förut, när ditt husdjur hoppade över pekaren eller åkte upp på en markeringsruta, täcktes det av ett fullstort fönster, och det såg ut som om husdjuret var borta.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Nu syns husdjuret och bollen framför dina fönster så länge de är högre än Dock. Tillbaka på marken går de bakom fönstren igen.

Och husdjuret kan gå bakom Dock igen, precis som förut.

**Prova:** Gör ett fönster fullstort, börja en markeringsruta på skrivbordet bredvid Dock så att husdjuret klättrar upp, och dra den sakta uppåt. Husdjuret åker med framför fönstret.

---

## <a id="v1.30.3"></a>Ditt husdjur och bollen hamnar inte längre under Dock

<sub>1.30.3 · 9 oktober 2026</sub>

Ditt husdjur går och sover inte längre under Dock, så du ser det alltid.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Förut gick och vilade ditt husdjur och bollen ofta precis under Dock, där ingen kunde se dem. Med ett fullstort fönster såg det ut som om husdjuret var borta för gott.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Nu är Dock som en vägg för dem. Husdjuret vänder vid kanten, och bollen studsar mot den.

Så syns husdjuret alltid bredvid Dock, även när ett fönster fyller hela skärmen.

**Prova:** Gör ett fönster fullstort och titta i ett par minuter. Husdjuret syns hela tiden till vänster eller höger om Dock.

---

## <a id="v1.30.2"></a>Ditt husdjur försvinner inte längre bakom fönster

<sub>1.30.2 · 9 oktober 2026</sub>

Även när ett fönster täcker ditt husdjur lever det vidare och faller ner när du släpper markeringen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

När fönster täckte hela remsan där ditt husdjur bor pausade pikapik det, och det kunde frysa mitt i luften. Nu lever husdjuret och dess boll vidare bakom fönstret: de går, faller och leker. Bara ritandet tar en paus.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Om en markeringsruta lyfter ditt husdjur bakom ett fönster faller det ner så fort du släpper, och du ser det vid Dock igen.

Och en markeringsruta lyfter inte längre husdjuret högre än dess remsa.

**Prova:** Gör ett fönster fullstort, lyft ditt husdjur med en markeringsruta bakom det och släpp. Husdjuret faller och syns vid Dock.

---

## <a id="v1.30.1"></a>Markeringar på skrivbordet fungerar igen

<sub>1.30.1 · 9 oktober 2026</sub>

Ditt husdjur och dess boll hoppar upp på markeringsrutor igen, och applistor lyser bara upp för appar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

När Dock eller en app för fjärrskrivbord täckte hela skärmen märkte pikapik inte markeringsrutan du drar upp på skrivbordet. Nu gör den det igen, och ditt husdjur och dess boll hoppar upp på den precis som förut.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Applistorna i inställningarna lyser bara upp när du drar en app över dem. Andra filer ignoreras: ingen ram visas och inget extra läggs till. Drar du en app tillsammans med andra filer läggs bara appen till.

Och ramen släcks så fort du släpper appen eller flyttar pekaren därifrån.

**Prova:** Dra upp en markeringsruta på skrivbordet och se hur ditt husdjur hoppar upp på den.

---

## <a id="v1.30.0"></a>Avsluta stänger inte längre av pikapik

<sub>1.30.0 · 9 oktober 2026</sub>

Valde du Avsluta av gammal vana? Dina kortkommandon, ”Håll vaken” och ditt husdjur fortsätter ändå att fungera.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/keep-awake-dark.png"><img src="../media/keep-awake-light.png" width="340" alt=""></picture>

När du väljer ”Avsluta”, trycker på ⌘Q eller avslutar pikapik från Dock stänger det sina fönster och döljer symbolen i menyraden, men fortsätter tyst i bakgrunden: kortkommandon, ”Håll vaken” och ditt husdjur är kvar. Vill du få tillbaka symbolen öppnar du bara pikapik igen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Vill du avsluta på riktigt? Håll ned Alternativ (⌥) och välj ”Avsluta”, eller tryck på ⌥⌘Q. Första gången pikapik går till bakgrunden förklarar det vad som hände och låter dig avsluta helt direkt.

Föredrar du det gamla sättet? Stäng av ”Fortsätt i bakgrunden efter Avsluta” i Inställningar › Allmänt. Uppdateringar, byte av språk, utloggning, omstart och avstängning avslutar alltid pikapik helt, så de behöver aldrig vänta på det.

**Prova:** Tryck på ⌘Q och öppna sedan pikapik igen för att få tillbaka symbolen.

---

## <a id="v1.29.1"></a>Ditt husdjur promenerar över alla skärmar

<sub>1.29.1 · 9 oktober 2026</sub>

Har du mer än en skärm? Ditt husdjur och dess boll följer nu med dit du tittar, och kommer aldrig bort.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

När husdjuret kommer till kanten av en skärm går det helt enkelt över till nästa, och bollen rullar efter. Du kan också ta husdjuret eller bollen med musen och bära dem till vilken skärm som helst. Om en app går till helskärm flyttar de till en annan skärm så att de inte är i vägen, och om du kopplar ur en skärm kommer de tillbaka till huvudskärmen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Bollen fastnar inte längre i ett hörn. Husdjuret springer dit, skyfflar den bakåt över huvudet och fortsätter leka.

Och husdjuret försvinner inte längre. Varannan sekund kollar det att det fortfarande syns, och om något gick fel, efter vila, när Macen låstes, vid byte av skrivbord eller helskärm, kommer det genast tillbaka av sig självt.

**Prova:** Bär husdjuret till en annan skärm, eller rulla bollen in i ett hörn.

**Åtgärdat**

- Ett kastat husdjur landar inte längre på en markeringsruta som ligger högre än det kan hoppa, och försvinner inte längre på grund av det.

---

## <a id="v1.29.0"></a>Ditt husdjur har fått en boll

<sub>1.29.0 · 9 oktober 2026</sub>

Nu rullar en liten fotboll längs skärmens nederkant. Husdjuret leker med den, och det kan du också.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Bollen rullar och studsar som en riktig. Husdjuret springer efter den, sparkar iväg den och jagar den igen. Dra pekaren snabbt mot bollen för att sparka den själv, eller ta upp den, bär den och kasta den, precis som husdjuret.

Ett litet trick: klicka på en tom plats på skrivbordet och dra för att rita en markeringsram, med eller utan Skift. Så länge du håller ner musknappen blir ramen en hylla: husdjuret hoppar upp på den, och bollen kan också landa där. Släpp, så försvinner hyllan.

Vill du hellre ha lugnt på skrivbordet? Stäng av Boll i husdjurets inställningar, så går det runt på egen hand igen.

**Prova:** Inställningar › Husdjur › Boll

**Åtgärdat**

- Bredvid Dock hoppar husdjuret återigen så högt det vill. Det håller sig lågt bara när det är precis ovanför Dock, så det sticker aldrig upp ovanför den.

---

## <a id="v1.28.0"></a>Lägg till appar med ett klick eller genom att dra

<sub>1.28.0 · 9 oktober 2026</sub>

Varje lista med appar i Inställningar visar nu vad som finns i Dock och vad som är öppet just nu, och du kan dra appar dit från Finder.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

En del funktioner låter dig välja appar där de håller sig undan, som den gröna knappen eller Home och End. Förut öppnade ”Lägg till app…” bara en lång mapp med allt du har. Nu dyker en hylla upp med apparna i din Dock och de som är öppna just nu. Klicka på en app för att lägga till den och klicka igen för att ta bort den. För allt annat finns ”Annat…”.

Du kan också dra en app från Finder direkt till en lista. Listan lyser upp och visar var appen hamnar. Dina spel fungerar likadant, med samma hylla.

Och om något går fel kan du nu välja din version av pikapik och macOS i en lista i formuläret för felrapporter på GitHub, så går det fortare att berätta för oss.

**Prova:** Inställningar › Fönster, sedan ”Lägg till app…”

**Åtgärdat**

- Rullning via AnyDesk eller en annan app för fjärrskrivbord vänds inte längre två gånger när båda Mac-datorerna använder den klassiska riktningen. pikapik vänder nu bara rullning från en riktig mus eller styrplatta. Om en app gör sin egen mjuka rullning, som Mos, ställer du in riktningen i den appen.
- Husdjuret stannar bakom Dock när det hoppar, precis som när det går, och kommer tillbaka av sig självt när du lämnar en app i helskärm eller ett spel.
- De tunna ramarna runt de små bilderna i Inställningar försvinner inte längre på vanliga skärmar utan Retina.

---

## <a id="v1.27.3"></a>Husdjuret syns alltid, och fönster öppnas redo

<sub>1.27.3 · 9 oktober 2026</sub>

Husdjuret gömmer sig inte längre bakom fönster mitt i ett hopp, och pikapiks fönster öppnas redo att använda.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

När husdjuret hoppade över pekaren eller slog en kullerbytta kunde det glida in bakom andra appars fönster och försvinna mitt i luften. Nu stannar det framför under hela hoppet och går tillbaka bakom dina fönster när det landar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

När pikapik startade tyst i bakgrunden, vid inloggning, efter en uppdatering eller från en pikapik://-länk, kunde fönstren öppnas grå och ligga kvar bakom andra fönster tills du klickade på dem. Nu kommer Inställningar och fönstret Ny fil fram, redo för att skriva.

Samma sak gäller meddelandet efter Skapa mindre kopia och listan där du väljer en app att lägga till. Du behöver inte göra något.

**Prova:** Inställningar › Husdjur

---

## <a id="v1.27.2"></a>Ny fil är tillbaka, och Inställningar är ännu lättare

<sub>1.27.2 · 9 oktober 2026</sub>

Ny fil finns åter i Finders högerklicksmeny för alla, och Inställningar kräver ännu mindre av din Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Efter förra uppdateringen kunde Finder starta om Ny fil i bakgrunden och glömma vilka mappar den arbetar i, så att alternativet tyst försvann från högerklicksmenyn. Nu påminner Ny fil Finder om sina mappar varje gång den startar, och pikapik kontrollerar strax efter start att Finder har kommit ihåg dem. Du behöver inte göra något.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

De rörliga bilderna i Inställningar spelas nu bara när minst halva bilden syns på skärmen. I spelbilderna rör sig den lilla hjälten fortfarande 30 gånger i sekunden, och kullarna och marken bakom 15 gånger. Därför kräver sidan Spel mycket mindre av din Mac. Allt ser likadant ut.

Efter en uppdatering lägger pikapik bara till sina Finder-alternativ igen om appen verkligen har flyttats, så att Finder inte behöver läsa in dem på nytt varje gång.

**Prova:** Inställningar › Spel

---

## <a id="v1.27.1"></a>Tystare, lättare och Finder redo direkt

<sub>1.27.1 · 9 oktober 2026</sub>

Inställningar belastar knappt din Mac längre, och högerklicksalternativen i Finder fungerar direkt efter flytten till pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/wheel-lines-dark.png"><img src="../media/wheel-lines-light.png" width="340" alt=""></picture>

De små rörliga bilderna i Inställningar ritade förut om hela sidan många gånger i sekunden, så ett öppet fönster höll din Mac sysselsatt. Nu ritar varje bild bara om sig själv, högst 30 gånger i sekunden, och vilar när du rullar förbi den eller gömmer fönstret. De ser precis likadana ut.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Efter flytten från pika-tools till pikapik kunde Finder fortsätta leta efter den gamla appen, och ”Ny fil”, ”Konvertera till” och de andra högerklicksalternativen gjorde ingenting. Nu märker pikapik det vid första starten och startar om Finder av sig själv när inga Finder-fönster är öppna och inget kopieras. Annars erbjuder en kort rad på Finder-sidan knappen ”Starta om Finder”.

I Systeminställningar, bland apparna som öppnas vid inloggning, syns appen nu med sitt nya namn, pikapik, och förblir påslagen.

**Prova:** Inställningar › Finder

---

## <a id="v1.27.0"></a>Möt ditt husdjur på skrivbordet

<sub>1.27.0 · 9 oktober 2026</sub>

Längst ner på skärmen bor nu en liten vän, och appen har ett nytt namn: pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Slå på det i Inställningar › Husdjur. Det promenerar bakom dina fönster och Dock, hoppar över pekaren när den står i vägen och skuttar när du trycker på mellanslag. Du kan lyfta upp det, bära det, kasta det och fånga det mitt i ett hopp.

Då och då sätter det sig och säger något kort. När en ny version verkligen kommer berättar det det en gång, och ett klick på det öppnar Inställningar, där uppdateringen väntar.

pika-tools heter nu pikapik. Dina behörigheter, inställningar och länkar i Genvägar är kvar som förut. Om du installerade appen med Homebrew kör du `brew update && brew upgrade --cask pikapik` en gång.

**Prova:** Inställningar › Husdjur

**Åtgärdat**

- Uppdateringskollen sa att en ny version fanns fast du redan hade den senaste.
- Sidan Behörigheter höll din Mac sysselsatt så länge den var öppen.

---

## <a id="v1.26.2"></a>Nyheter på ditt språk

<sub>1.26.2 · 8 oktober 2026</sub>

”Nyheter” i inställningarna öppnar nu den här sidan, på samma språk som appen.

<img src="../media/icon.png" width="128" height="128" alt="">

Öppna Inställningar › Om och klicka på ”Nyheter”. Du hamnar direkt här, på sidan med en bild till varje uppdatering, på det språk som pikapik talar.

Den fullständiga listan över ändringar är också prydligare. Varje version visar dagen den kom ut, och varje versionsnummer öppnar sin nedladdningssida.

Inget ändras i hur pikapik fungerar. Uppdateringar kommer som förut, av sig själva eller via Homebrew.

**Prova:** Inställningar › Om › Nyheter

**Åtgärdat**

- ”Nyheter” öppnade en lång teknisk lista på engelska i stället för den här sidan.
- Länkar i listan över ändringar som inte ledde någonstans öppnar nu rätt sida.

---

## <a id="v1.26.1"></a>Spelbilderna får liv

<sub>1.26.1 · 8 oktober 2026</sub>

Bilderna på sidan ”Spel” rör sig nu, så du ser vad varje reglage stoppar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.26.1/game-previews-dark.png"><img src="../media/whats-new/1.26.1/game-previews-light.png" width="340" alt=""></picture>

Bakom varje reglage på sidan ”Spel” pågår nu ett litet spel. Tangenter dyker upp och trycks ned, och du ser vad som skulle hoppa upp över ditt spel, som Spotlight eller Mission Control, medan spelet stannar. När reglaget är på lyser tangenterna bara mjukt och spelet fortsätter. Slå om ett reglage så visar bilden skillnaden direkt.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Det lilla spelet följer utseendet på din Mac: en solig dag i ljust läge och en lugn natt med måne och stjärnor i mörkt läge.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

I alla bilder i appen rör sig pekaren nu som en hand: långa sträckor får ta lite längre tid, den stannar till och klickar först sedan. När en bild börjar om glider den mjukt tillbaka till början i stället för att hoppa. Bilderna vilar när fönstret är dolt, och med ”Minska rörelse” på står de still.

**Prova:** Inställningar › Spel

---

## <a id="v1.26.0"></a>En ny symbol och rent bord för gamla behörigheter

<sub>1.26.0 · 8 oktober 2026</sub>

pikapik har fått ett nytt ansikte och rensar nu behörigheterna som raderade appar lämnar kvar.

<img src="../media/icon.png" width="128" height="128" alt="">

Den nya symbolen är pikapik-märket i blått, violett och korall på en mörk platta. Menyraden visar samma form, som följer en ljus eller mörk menyrad. När alla verktyg är avstängda bleknar formen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>

När du raderar en app behåller macOS behörigheterna du gav den, och i Systeminställningar går de inte att ta bort. Nu har sidan ”Behörigheter” en lista som heter ”Kvar efter raderade appar”: varje app med sin symbol, vad den fick göra och när. ”Ta bort” rensar en app, ”Ta bort alla” rensar alla, och en app du installerar igen frågar helt enkelt på nytt. För att se listan ger du pikapik full skivåtkomst: den tittar bara och ändrar ingenting förrän du trycker på ”Ta bort”.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Bilderna på sidorna ”Animationer” och ”Spel” är ritade på nytt för sin riktiga storlek, så de är skarpa. Ett fönster krymper in i Dock med rundade hörn, och pekaren klickar först och sedan öppnas en meny. Och längst ned i ”Om” finns nu en stilla rad: ”Gjord med omsorg · Bjud mig på kaffe”. Inget dyker upp och inget påminner dig.

**Prova:** Inställningar › Behörigheter, sedan ”Kvar efter raderade appar”

**Åtgärdat**

- Ett klick på ett systemkortkommando öppnar direkt dess avsnitt i Systeminställningar, som Mission Control, och inte bara ”Tangentbord”.
- Tipset bredvid tangenterna försvinner inte längre så fort Systeminställningar öppnas.

---

## <a id="v1.25.2"></a>Kortkommandon öppnas där du ändrar dem

<sub>1.25.2 · 8 oktober 2026</sub>

Klicka på ett kortkommando i Inställningar, så öppnas Systeminställningar på rätt ställe.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Förut ledde ett klick på ett kortkommando, till exempel det för Spotlight, alltid till ”Specialtangenter”. Nu tar tangenterna för Spotlight dig direkt till Spotlight.

För andra kortkommandon öppnas Systeminställningar på ”Tangentbord”, och ett kort tips bredvid tangenterna säger var du ska klicka: ”Kortkommandon…”, sedan ”Mission Control” eller en annan del.

Det fungerar likadant på sidan Spel och för ”Klipp ut filer i Finder”. När du klipper ut filer leder tipset till ”Appkortkommandon”.

**Prova:** Inställningar › Spel, klicka sedan på tangenterna bredvid ”Sökningen dyker inte upp”

**Åtgärdat**

- Ett klick på ett kortkommando öppnar inte längre ”Specialtangenter”.

---

## <a id="v1.25.1"></a>Stora bilder, och spel direkt från Dock

<sub>1.25.1 · 8 oktober 2026</sub>

Varje reglage har nu en stor bild, och ”Lägg till spel…” visar det som finns i din Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

På sidorna Animationer och Spel är alla bilder nu stora, precis som den högst upp på sidan. Du ser direkt vad varje reglage gör, och bilderna rör sig fortfarande i den takt du har valt.

Klicka på ”Lägg till spel…” så ser du din Dock: apparna du har där och de som är öppna just nu, i samma ordning. Ett spel från Dock syns även när det är stängt, Minecraft också. Ett klick lägger till det, och en bock visar att det finns i listan. Klicka igen för att ta bort det.

Du kan fortfarande dra hit ett spel från Finder. Du behöver inte längre dra ut det ur Dock, så Dock erbjuder sig inte heller att ta bort det.

**Prova:** Inställningar › Spel, sedan ”Lägg till spel…”

**Åtgärdat**

- Ett spel som ligger i Dock men är stängt visas nu i listan för att lägga till.

---

## <a id="v1.25.0"></a>Lägg till ett spel med ett klick, och välj egna tangenter

<sub>1.25.0 · 8 oktober 2026</sub>

Välj ett spel bland det som är öppet just nu, och bestäm själv tangenterna för att avsluta och stänga.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

Klicka på ”Lägg till spel…”, så visas apparna som är öppna just nu med stora symboler, som i Dock. Ett klick lägger till ett spel, eller dra symbolen till listan. Du kan också släppa ett spel direkt från Finder eller Dock. Vilken app som helst kan nu vara ett spel, till och med Minecraft som körs på Java, och dina tidigare spel följer med.

Reglagen i Spelläge talar nu klarspråk, som ”Spelet stängs inte” eller ”Sökningen dyker inte upp”, och vart och ett har en liten bild av det som stoppas. Namnet i systemet, som Spotlight, står bredvid i grått.

I Inställningar › Fönster klickar du på tangenterna bredvid ”Avsluta app” eller ”Stäng fönster” och trycker på nya. ⌫ tar tillbaka ⇧⌘Q och ⇧⌘W, och om tangenterna redan används frågar pikapik först. Spelläge använder också dina tangenter. Och varje kortkommando i Inställningar visar nu hur det verkligen är inställt på din Mac: dina tangenter, eller Av.

**Prova:** Inställningar › Spel, sedan ”Lägg till spel…”

**Åtgärdat**

- Att klippa ut filer i Finder följer kortkommandot för Klipp ut som du har ställt in för Finder i Systeminställningar.
- Appnamn i listor visas utan ”.app”.

---

## <a id="v1.24.1"></a>Fartändringar du ser direkt

<sub>1.24.1 · 8 oktober 2026</sub>

Sidan Animationer berättar nu var en ändring syns, och den skyddar dina egna värden.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

Dock kan bara glida fram snabbare om den göms. Om din alltid syns ligger reglaget ”Göm och visa Dock automatiskt” nu precis under skjutreglaget för hastighet.

Efter en ändring säger en rad längst ned på sidan att appar tar till sig den när du öppnar dem igen. Finder visar nya hastigheter för Snabbtitt och kolumner först efter en omstart, så raden har en knapp, ”Starta om Finder”.

Skjutreglaget gör aldrig något långsammare som du redan hade snabbat upp, till exempel med kommandon i Terminal. Och ”Återställ förval” eller att avinstallera pikapik ger tillbaka värdena du hade innan, i stället för att radera dem.

**Prova:** Inställningar › Animationer

**Åtgärdat**

- Dock startar inte längre om i onödan när den inte göms.

---

## <a id="v1.24.0"></a>Välj hur snabbt din Mac rör sig

<sub>1.24.0 · 8 oktober 2026</sub>

Den nya sidan Animationer bestämmer hur snabbt saker öppnas, glider och dyker upp på din Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Ett skjutreglage räcker. Dra i det, så blir dold Dock, nya fönster, spara-dialoger, Snabbtitt och kolumner i Finder snabbare tillsammans, från ”Som i macOS” till ”Direkt”.

Vill du bara justera en sak? Varje effekt har en egen inställning, och det har även minimeringseffekten, studsande symboler i Dock och Finder-animationer. Bredvid varje inställning rör sig en liten bild i exakt den hastighet du valt.

”Återställ förval” återställer bara det som pikapik har ändrat, och avinstallation gör samma sak. Om du någon gång själv har ställt in ett av värdena i Terminal visar pikapik det som det är.

**Prova:** Inställningar › Animationer

---

## <a id="v1.23.2"></a>Ett reglage för varje kortkommando i Spelläge

<sub>1.23.2 · 8 oktober 2026</sub>

Nu bestämmer du, ett kortkommando i taget, vad Spelläge tystar medan du spelar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Q och ⌘W har egna reglage nu, och det har även Spotlight, Siri, ⌘Tab, Mission Control, svep, pekaren, skärmen och resten. Dina tidigare val följer med.

Varje rad visar exakt vilka tangenter den stoppar, så du vet alltid vad ett reglage gör.

Inställningen för tangentbordsspråk har lämnat Spelläge. ⌃Mellanslag och andra sätt att byta språk fungerar alltid, även i ett spel.

**Prova:** Inställningar › Spel

**Åtgärdat**

- Tangenterna i ett kortkommando sitter tätare ihop, och det är lite mer luft mellan olika kortkommandon, så det är lätt att se var ett slutar och nästa börjar.

---

## <a id="v1.23.1"></a>Hur snabbt ditt internet är, i enkla ord

<sub>1.23.1 · 8 oktober 2026</sub>

Hastighetstest kollar din anslutning och berättar enkelt vad den räcker till.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

Klicka på ”Testa hastigheten”, så ser du efter ungefär en halv minut nedladdning, uppladdning, ping och responsivitet. Under siffrorna står det i enkla ord om det räcker för 4K-filmer, videosamtal, onlinespel och stora nedladdningar.

Mätningen görs på Apples servrar, och det senaste resultatet ligger kvar till nästa. Hastighetstest har en egen sida i Inställningar, en rad i menyradspanelen och en länk för appen Genvägar: `pikapik://speed-test`.

Spelläge har lärt sig två saker. Att blockera kontroll-kortkommandon ingår nu i det: i ett spel förblir ⌃-klick ett klick och kortkommandon med ⌃ gör ingenting; överallt annars fungerar ⌃ som vanligt. Och det känner igen Minecraft: lägg till Minecraft Launcher eller CurseForge bland dina spel, så slås Spelläge på när själva Minecraft ligger överst.

**Prova:** Inställningar › Hastighetstest, sedan ”Testa hastigheten”

**Åtgärdat**

- Testversioner av pikapik som folk bygger själva håller sina inställningar för sig i iCloud Drive och rör inte längre dina.

---

## <a id="v1.23.0"></a>Spelläge: spela utan avbrott

<sub>1.23.0 · 7 oktober 2026</sub>

Lägg till dina spel, så slutar din Mac att dra ut dig ur dem.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Medan du spelar öppnas inte Spotlight, Siri, ⌘Tab, Mission Control och svep mellan skrivbord ovanpå spelet. ⌘Q och ⌘W stänger det inte av misstag, pekaren stannar på spelets skärm och skärmen förblir på.

Tryck på ⇧⌘Q för att lämna ett spel och på ⇧⌘W för att stänga dess fönster. ⌥⌘Esc fungerar alltid. pikapik föreslår spel som det hittar på din Mac. Spelläge är avstängt tills du slår på det.

Med Håll vaken väljer du nu vad skärmen gör: förblir på, utan skärmsläckare eller låsskärm, eller släcks som vanligt medan din Mac fortsätter arbeta. Den nya knappen ”Stäng av skärmen nu” släcker den direkt; rör musen eller tryck på en tangent för att få tillbaka den.

**Prova:** Inställningar › Spel, sedan ”Lägg till spel…”

**Åtgärdat**

- På Mac-datorer utan lock visar Håll vaken inte längre alternativen för stängt lock.

---

<p align="center"><sub>Äldre versioner finns i <a href="../../CHANGELOG.md">ändringsloggen</a> (på engelska).</sub></p>
