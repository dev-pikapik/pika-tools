# pika-tools

[English](../../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [Română](README.ro.md) · [Polski](README.pl.md) · **Türkçe** · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Čeština](README.cs.md) · [繁體中文](README.zh-Hant.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Tiếng Việt](README.vi.md) · [ไทย](README.th.md)

[![Son sürüm](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![Lisans: MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](../../LICENSE)
[![İndirmeler](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

Tuşları, pencereleri ve Dock’u daha kullanışlı hâle getiren küçük bir macOS menü çubuğu uygulaması: Control kestirmelerini engeller, ⌘Q ve ⌘W’yi korur, Windows’taki Alt+Shift gibi Option+Shift ile dili değiştirir, Windows’taki gibi basılı tutulan tuşu tekrarlar, fare ivmesini kapatır, fare tekerini Windows’taki gibi satır satır kaydırır, farenin yan düğmeleriyle geri ve ileri gitmenizi sağlar, son penceresini kapattığınızda uygulamadan çıkar, Dock’ta bir tıklamayla uygulamayı gizler ve Mac’inizi uyanık tutar.

## Kurulum

[Homebrew](https://brew.sh) ile:

```bash
brew install --cask dev-pikapik/pika-tools/pika-tools && open -a pika-tools
```

Homebrew olmadan: Terminal’i açın, bu satırı yapıştırın ve Return tuşuna basın:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

Ya da [pika-tools.dmg](https://github.com/dev-pikapik/pika-tools/releases/latest/download/pika-tools.dmg) dosyasını indirin, açın ve uygulamayı Uygulamalar klasörüne sürükleyin.

Homebrew de betik de uygulamayı `/Applications` klasörüne koyar, açar, izinleri ister ve “Girişte Aç” seçeneğini açar. Bundan sonra uygulama kendini güncel tutar, bkz. [Güncellemeler](#güncellemeler). Kaldırmak için bkz. [Kaldırma](#kaldırma).

## İlk açılış

pika-tools’un iki izne ihtiyacı vardır. İlk açılışta ayarlar, sizi adım adım yönlendiren İzinler sayfasında açılır ve macOS kendi uyarılarını gösterir. **Sistem Ayarları › Gizlilik ve Güvenlik** bölümüne gidin ve şu listelerde pika-tools’u açın:

- **Erişilebilirlik**: Uygulama bir tuş basışını veya tıklamayı diğer uygulamalara ulaşmadan önce değiştirebilsin diye.
- **Girdi İzleme**: Uygulama tuş basışlarını ve tıklamaları görebilsin diye.

Uygulama değişikliği birkaç saniye içinde fark eder, yeniden başlatmaya gerek yoktur.

pika-tools yazdığınız veya tıkladığınız hiçbir şeyi kaydetmez, saklamaz ya da göndermez. Olaylar bellekte işlenir ve hemen iletilir. Tek ağ isteği güncelleme denetimidir: GitHub’a en son sürüm sorulur.

## Özellikler

**Control kestirmelerini engelleme.** Control sıradan bir tuşa dönüşür. Uygulamalar basılı tutulduğunu görmeye devam eder, ancak macOS onu artık kestirmelere çevirmez: Control+Boşluk girdi kaynağını değiştirmez, Control+oklar masaüstünü değiştirmez ve Control-tıklama, içerik menüsü yerine normal bir tıklama olur. Sağ tıklama ve iki parmakla dokunma her zamanki gibi çalışır. Control’ün kendine ait bir görevi olduğu oyunlarda ve uzak masaüstü oturumlarında işe yarar. Control’ün her zamanki gibi çalışacağı uygulamaları listeleyebilirsiniz, örneğin bir uzak masaüstü uygulaması: engelleme onlara uygulanmaz.

**⌘Q ve ⌘W’yi koruma.** ⌘Q ve ⌘W tek başına hiçbir şey yapmaz, böylece bir uygulamadan yanlışlıkla çıkmaz ya da bir pencereyi yanlışlıkla kapatmazsınız. Bilerek yapmak için Shift ekleyin: ⇧⌘Q çıkar, ⇧⌘W kapatır. Tüm uygulamalarda çalışır. Her tuşun kendi anahtarı vardır. Varsayılan olarak kapalıdır.

**Option+Shift ile dil değiştirme.** Option’ı basılı tutun ve Shift’e dokunun: macOS bir sonraki girdi kaynağına geçer. Option’ı bırakmadan Shift’e yeniden dokunarak ilerlemeye devam edin. Geri gitmek için Shift’i basılı tutup Option’a dokunun. Arada başka bir tuşa basarsanız, tıklarsanız ya da Command, Control veya Fn eklerseniz dil değişmez, böylece Option+Shift+ok gibi kestirmeler eskisi gibi çalışır. Varsayılan olarak kapalıdır.

**Basılı tutulan tuşu tekrarla.** Bir tuşu basılı tuttuğunuzda aksan menüsü yerine Windows’taki gibi harf tekrar tekrar yazılır. Oyunlarda ve yazarken işe yarar. Zaten açık olan uygulamalar bunu yeniden başlatıldıktan sonra kullanır. Kapattığınızda macOS her zamanki gibi çalışır. Varsayılan olarak kapalıdır.

**İmleç hızlandırmayı kapat.** Fareyi ne kadar hızlı hareket ettirirseniz ettirin, imleç tam olarak fare kadar hareket eder, LinearMouse’taki gibi. **İzleme hızı** sürgüsü imlecin ne kadar hızlı gideceğini ayarlar. Yalnızca farelerle çalışır, İzleme Dörtgeni olduğu gibi kalır. Özelliği kapatın ya da pika-tools’tan çıkın, macOS kendi ayarlarına geri döner. Varsayılan olarak kapalıdır.

**Satır satır kaydır.** Fare tekerinin her tıkı, ne kadar hızlı çevirirseniz çevirin aynı sayıda satır kaydırır, tıpkı Windows’ta olduğu gibi. Tık başına 1 ile 10 arasında satır seçebilirsiniz, varsayılan 3’tür. Doğal Kaydırma, Sistem Ayarları’nda nasıl ayarladıysanız öyle kalır. Yalnızca fareler için çalışır, izleme dörtgeni olduğu gibi kalır. Varsayılan olarak kapalıdır. **Tık başına mesafe** kaydırıcısının yanında küçük bir sayfa seçtiğiniz mesafe kadar kayar, bir nokta da varsayılan değeri gösterir.

Bazı uygulama ve oyunlar kaydırmayı tam piksel olarak sayar: onlar için aynı ayarı piksele çevirin ve tık başına 1 ile 200 piksel arasında seçin, varsayılan 40. Kaydırıcı bunun ekran yüksekliğinin ne kadarı olduğunu da söyler.

**İzleme dörtgeni ve fare için kaydırma yönü.** macOS’te izleme dörtgeni ve fare için ortak tek bir doğal kaydırma anahtarı vardır. Bunu açın ve her biri için bir yön seçin: sayfanın iPhone’daki gibi parmaklarınızı izlediği **Doğal** ya da Windows’taki gibi **Klasik**. İzleme dörtgeni seçimi yana kaydırmayı ve parmaklarınızı kaldırdıktan sonraki kaymayı da kapsar. Magic Mouse dokunarak kaydırır, bu yüzden izleme dörtgeni seçimini izler. Tüm Mac’lerinizde aynısını seçin, fareyi Evrensel Denetim ile başka bir Mac’e taşısanız bile kaydırma her yerde aynı olur. Varsayılan olarak kapalı. Açtığınızda ikisi de Sistem Ayarları’ndaki gibi başlar, yani siz başka bir şey seçene kadar hiçbir şey değişmez.

**Yan tuşlarla geri ve ileri.** Farenin 4. ve 5. düğmeleri Safari’de, Finder’da ve diğer Apple uygulamalarında, Firefox’ta, Opera’da ve ForkLift’te geri ve ileri gider, tıpkı izleme dörtgeninde kaydırma hareketi gibi. JetBrains IDE’leri gibi diğer uygulamalar düğmeleri olduğu gibi alır ve kendi yöntemleriyle ele alır. Farenizde ters yerdeyseler **Yan tuşların yerini değiştir** seçeneğini açın. Varsayılan olarak kapalıdır.

**Son pencere kapanınca çıkma.** Bir uygulamanın son penceresini kapatın, uygulama Windows’taki gibi kapanır. Finder açık kalır; başka masaüstlerinde veya Dock’ta penceresi olan uygulamalar da açık kalır. Bu şekilde asla kapanmaması gereken uygulamaların listesini oluşturabilirsiniz. Varsayılan olarak kapalıdır.

**Dock’ta tıklayarak gizleme.** Kullandığınız uygulamanın Dock simgesine tıklayın, uygulama gizlenir. Geri getirmek için yeniden tıklayın. Varsayılan olarak kapalıdır.

**Yeşil düğme pencereyi büyütür.** Bir pencerenin yeşil düğmesine tıklayın; pencere tam ekrana geçmeden ekranı doldurur. Önceki boyuta dönmek için yeniden tıklayın. ⌥ tuşunu basılı tutarsanız düğme her zamanki gibi çalışır. Tam ekran, düğmenin menüsünde ve ⌃⌘F ile kullanılabilir kalır. Yeşil düğmenin her zamanki gibi çalışacağı uygulamaları listeleyebilirsiniz. Varsayılan olarak kapalıdır.

**Finder’da Yeni Dosya.** Bir Finder penceresinde ya da masaüstünde sağ tıklayın, **Yeni Dosya**’yı seçin, bir ad yazın; Windows’taki Yeni › Metin Belgesi gibi boş bir dosya oluşur. Varsayılan .txt. Varsayılan olarak kapalı.

**Enter, Finder’da dosyaları açar.** Bir Finder penceresinde ya da masaüstünde dosyaları seçip Return veya Enter’a basın; dosyalar açılır, tıpkı Windows’taki gibi. F2 veya fn F2 seçili dosyanın adını değiştirir. Metin alanlarında, örneğin bir ad yazarken, tuşlar her zamanki gibi çalışır. Varsayılan olarak kapalı.

**⌘X, Finder’da dosyaları keser.** Dosyaları seçip ⌘X’e basın, hedef klasörü açıp ⌘V’ye basın; dosyalar kopyalanmak yerine oraya taşınır, tıpkı Windows’taki Kes ve Yapıştır gibi. ⌘C kesmeyi iptal eder. Varsayılan olarak kapalı.

**Finder’da Küçük Kopya.** Finder’da bir dosyaya sağ tıklayıp **Küçük Kopya Oluştur**’u seçin. Bir fotoğrafın, GIF’in, PDF’in veya videonun genellikle birkaç kat daha küçük bir sürümü hemen yanına kaydedilir. WAV veya AIFF gibi sıkıştırılmamış ses, kompakt bir M4A olur. Dosya daha fazla küçülemiyorsa kopya oluşturulmaz ve pika-tools bunu size söyler. Orijinal olduğu gibi kalır ve hiçbir şey Mac’inizden çıkmaz. Varsayılan olarak kapalı.

**Finder’da Dönüştürme.** Finder’da bir dosyaya sağ tıklayıp **Dönüştür**’ü seçin; dosya başka bir biçimde kaydedilir: resim JPEG, PNG, HEIC, GIF, TIFF veya PDF, video MP4, MOV ya da yalnızca ses, müzik M4A, WAV veya AIFF olarak. Orijinal olduğu gibi kalır ve hiçbir şey Mac’inizden çıkmaz. Küçük Kopya’dan ayrı açılıp kapanır. Varsayılan olarak kapalı.

Her aracın menüde ve ayarlarda kendi anahtarı vardır. Normal Control+C’ye mi ihtiyacınız var? O aracı kapatın.

Menü çubuğu simgesi durumu bir bakışta gösterir: araçlar çalışırken tıklama işaretli bir ok, her şey kapalıyken üstü çizili bir ok, bir araç açık ama izinler eksikken bir uyarı üçgeni.

Menü çubuğu paneli başta yalnızca birkaç satırla açılır. Hangi satırların görüneceğini sen seçersin: alttaki kalem düğmesine tıkla, görmek istediğin satırları işaretle ve **Bitti**'ye tıkla. Gizlenen satırlar çalışmaya devam eder ve Ayarlar'da kalır. Panel ekrana sığmazsa kaydırılır.

Uygulama sistem dilini ya da ayarlarda seçtiğiniz dili kullanır. Bu sayfanın başındaki listede yer alan 23 dilin tümü desteklenir.

## Uyanık Tut

Siz klavyenin başında değilken Mac’inizin uyku moduna geçmesini engeller: 1 saniyeden 365 güne kadar istediğiniz süre boyunca ya da siz kapatana kadar. Menüden açın, süreyi ayarlarda belirleyin: gün, saat, dakika ve saniyeyi yazın, ↑ ve ↓ tuşlarını kullanın ya da 15 dakikadan 8 saate kadar hazır bir seçeneğe tıklayın. Menü ne kadar süre kaldığını ve ne zaman biteceğini gösterir. **Ekranı açık tut** ekranın kararmasını da engeller. pika-tools’tan çıkınca Uyanık Tut da sona erer.

MacBook’ta **Kapak kapalıyken çalış** seçeneğini de açabilirsiniz. macOS’te bunun için bir ayar yoktur, bu yüzden pika-tools `pmset -a disablesleep 1` komutunu çalıştırır ve yönetici parolası ister: Mac’in nasıl uyuyacağını yalnızca bir yönetici değiştirebilir. Ayar; Uyanık Tut bittiğinde, uygulamadan çıktığınızda ya da uygulama çöktüğünde kendiliğinden normale döner. Parolayı girmezseniz hiçbir şey değişmez. Kapak kapalıyken Mac’in iyi havalandığından emin olun. **Pil %20’nin altına düşünce durdur** seçeneği oturumu pil bitmeden sonlandırır.

Keep Awake, ekran ve kapak kapalı modları, Kestirmeler uygulamasıyla Denetim Merkezi’nde, menü çubuğunda ya da masaüstü widget’ında bir düğmeye konabilir; bağlantıları Ayarlar › Uyanık Tut bölümünden kopyalarsın.

## Ayarlar

Ayarları menüden **Ayarlar…** ile ya da ⌘, ile açın veya pika-tools’u Finder, Launchpad ya da Spotlight’tan yeniden başlatın. Pencere açıkken uygulama Dock’ta ve ⌘Tab’de görünür.

- **Genel**: girişte açma, görünüm (Sistem, Açık veya Koyu), dil, güncellemeler ve yedekleme: ayarları dosya olarak dışa ve içe aktarma ya da iCloud Drive ile eşzamanlama.
- **Uyanık Tut**: süre, ekran ve kapak seçenekleri.
- **Klavye**: Control kestirmeleri, dil değiştirme, tuş tekrarı.
- **Fare**: imleç ivmesi ve izleme hızı, satır satır kaydırma, kaydırma yönü, yan düğmeler.
- **Pencereler**: yeşil düğmeyle pencereyi büyütme (istisna listesiyle), ⌘Q ve ⌘W koruması ve son pencerede çıkma (istisna listesiyle).
- **Dock**: Dock’ta tıklayarak gizleme.
- **Finder**: yeni dosya, küçük kopya ve dönüştürme, Return ile açma ve ⌘X ile kesme.
- **İzinler**: iki iznin durumu, eşzamanlama açıkken iCloud Drive’ın durumu ve Sistem Ayarları’nda doğru yeri açan düğmeler.
- **Hakkında**: sürüm, değişiklik günlüğü bağlantısı ve sorun bildirme bağlantısı.

Birçok ayarın, ne yaptığını gösteren küçük bir resmi vardır; örneğin uyumayan bir Mac ya da Dock’un arkasına saklanan bir pencere. Resim, anahtarla birlikte değişir ve Sistem Ayarları’nda “Hareketi Azalt” açıksa hareketsiz kalır.

Her sayfanın altında bir **Saptanmışlara Dön…** düğmesi vardır. Önce onay ister, ardından o sayfadaki araçları kapatır ve seçeneklerini geri alır; sanki pika-tools onlara hiç dokunmamış gibi.

**Ayarları iCloud ile eşzamanla** pika-tools’u tüm Mac’lerinizde aynı tutar. Ayarlar iCloud Drive’daki pika-tools klasöründe durur ve en son değişiklik geçerli olur. Varsayılan olarak kapalıdır ve iCloud Drive’ın açık olması gerekir. İzinler eşzamanlanmaz: her Mac kendi izinlerini kendisi ister.

## Güncellemeler

pika-tools açılışta ve her 6 saatte bir yeni sürüm olup olmadığını denetler. Bunu Ayarlar › Genel bölümünden kapatabilirsiniz. Yeni bir sürüm çıktığında menüde **… sürümüne güncelle** düğmesi görünür: tek tıklamayla uygulama güncellemeyi indirir, yükler ve yeniden başlar. Ayarlar › Genel bölümündeki **Şimdi Denetle** ile elle de denetleyebilirsiniz.

Homebrew kullanıyorsanız `brew upgrade --cask pika-tools` komutunu da çalıştırabilirsiniz.

1.3 sürümünden itibaren izinler güncellemelerden sonra yerinde kalır.

## Kaldırma

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

Homebrew ile kurduysanız: `brew uninstall --cask --zap pika-tools`.

İkisi de uygulamadan çıkar, onu giriş öğelerinden kaldırır ve siler. Betik ayrıca uygulamanın izinlerini sıfırlar.

## Sık sorulan sorular

**Neden iki izin gerekiyor?**
macOS klavye ve fare erişimini ikiye ayırır. Girdi İzleme uygulamanın olayları görmesini, Erişilebilirlik ise onları değiştirmesini sağlar. Bir kestirmeyi engellemek için ikisi de gerekir.

**macOS uygulamanın tanımlanmamış bir geliştiriciden geldiğini söylüyor.**
pika-tools imzalıdır, ancak Apple tarafından onaylanmamıştır (notarize edilmemiştir). Homebrew ve kurulum betiği bunu sizin yerinize halleder. dmg kullandıysanız **Sistem Ayarları › Gizlilik ve Güvenlik** bölümünü açıp **Yine de Aç** düğmesine tıklayın ya da şunu çalıştırın:

```bash
xattr -dr com.apple.quarantine /Applications/pika-tools.app
```

**Intel işlemcili Mac’lerde çalışır mı?**
Evet. Apple Silicon ve Intel için evrensel bir uygulamadır, macOS 14 Sonoma veya sonrası gerekir.

**İzin açık ama hiçbir şey çalışmıyor.**
**Sistem Ayarları › Gizlilik ve Güvenlik** bölümünde pika-tools’u − düğmesiyle iki listeden de kaldırın, sonra yeniden ekleyin. pika-tools ayarlarındaki İzinler sayfasında doğru yeri açan düğmeler vardır.

## Katkıda bulunma

Kaynaktan derleme ve sürüm yayımlama [CONTRIBUTING.md](../../CONTRIBUTING.md) dosyasında anlatılır. Değişiklikler [CHANGELOG.md](../../CHANGELOG.md) dosyasında listelenir.

## Lisans

MIT, © 2026 pikapik. Bkz. [LICENSE](../../LICENSE).
