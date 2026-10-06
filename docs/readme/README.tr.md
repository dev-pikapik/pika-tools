# pika-tools

[English](../../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [Română](README.ro.md) · [Polski](README.pl.md) · **Türkçe** · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Čeština](README.cs.md) · [繁體中文](README.zh-Hant.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Tiếng Việt](README.vi.md) · [ไทย](README.th.md)

[![Son sürüm](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![Lisans: MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](../../LICENSE)
[![İndirmeler](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

Tuşları, pencereleri ve Dock’u daha kullanışlı hâle getiren küçük bir macOS menü çubuğu uygulaması: Control kestirmelerini engeller, ⌘Q ve ⌘W’yi korur, Windows’taki Alt+Shift gibi Option+Shift ile dili değiştirir, son penceresini kapattığınızda uygulamadan çıkar, Dock’ta bir tıklamayla uygulamayı gizler ve Mac’inizi uyanık tutar.

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

**Control kestirmelerini engelleme.** Control sıradan bir tuşa dönüşür. Uygulamalar basılı tutulduğunu görmeye devam eder, ancak macOS onu artık kestirmelere çevirmez: Control+Boşluk girdi kaynağını değiştirmez, Control+oklar masaüstünü değiştirmez ve Control-tıklama, içerik menüsü yerine normal bir tıklama olur. Sağ tıklama ve iki parmakla dokunma her zamanki gibi çalışır. Control’ün kendine ait bir görevi olduğu oyunlarda ve uzak masaüstü oturumlarında işe yarar.

**⌘Q ve ⌘W’yi koruma.** ⌘Q ve ⌘W tek başına hiçbir şey yapmaz, böylece bir uygulamadan yanlışlıkla çıkmaz ya da bir pencereyi yanlışlıkla kapatmazsınız. Bilerek yapmak için Shift ekleyin: ⇧⌘Q çıkar, ⇧⌘W kapatır. Tüm uygulamalarda çalışır. Her tuşun kendi anahtarı vardır. Varsayılan olarak kapalıdır.

**Option+Shift ile dil değiştirme.** Option’ı basılı tutun ve Shift’e dokunun: macOS bir sonraki girdi kaynağına geçer. Option’ı bırakmadan Shift’e yeniden dokunarak ilerlemeye devam edin. Geri gitmek için Shift’i basılı tutup Option’a dokunun. Arada başka bir tuşa basarsanız, tıklarsanız ya da Command, Control veya Fn eklerseniz dil değişmez, böylece Option+Shift+ok gibi kestirmeler eskisi gibi çalışır. Varsayılan olarak kapalıdır.

**Son pencere kapanınca çıkma.** Bir uygulamanın son penceresini kapatın, uygulama Windows’taki gibi kapanır. Finder açık kalır; başka masaüstlerinde veya Dock’ta penceresi olan uygulamalar da açık kalır. Bu şekilde asla kapanmaması gereken uygulamaların listesini oluşturabilirsiniz. Varsayılan olarak kapalıdır.

**Dock’ta tıklayarak gizleme.** Kullandığınız uygulamanın Dock simgesine tıklayın, uygulama gizlenir. Geri getirmek için yeniden tıklayın. Varsayılan olarak kapalıdır.

Her aracın menüde ve ayarlarda kendi anahtarı vardır. Normal Control+C’ye mi ihtiyacınız var? O aracı kapatın.

Menü çubuğu simgesi durumu bir bakışta gösterir: araçlar çalışırken tıklama işaretli bir ok, her şey kapalıyken üstü çizili bir ok, bir araç açık ama izinler eksikken bir uyarı üçgeni.

Uygulama sistem dilini ya da ayarlarda seçtiğiniz dili kullanır. Bu sayfanın başındaki listede yer alan 23 dilin tümü desteklenir.

## Uyanık Tut

Siz klavyenin başında değilken Mac’inizin uyku moduna geçmesini engeller: 1 dakikadan 12 aya kadar istediğiniz süre boyunca ya da siz kapatana kadar. Menüden açın, süreyi ayarlarda dakika, saat, gün, hafta veya ay olarak belirleyin. Menü ne kadar süre kaldığını ve ne zaman biteceğini gösterir. **Ekranı açık tut** ekranın kararmasını da engeller. pika-tools’tan çıkınca Uyanık Tut da sona erer.

MacBook’ta **Kapak kapalıyken çalış** seçeneğini de açabilirsiniz. macOS’te bunun için bir ayar yoktur, bu yüzden pika-tools `pmset -a disablesleep 1` komutunu çalıştırır ve yönetici parolası ister: Mac’in nasıl uyuyacağını yalnızca bir yönetici değiştirebilir. Ayar; Uyanık Tut bittiğinde, uygulamadan çıktığınızda ya da uygulama çöktüğünde kendiliğinden normale döner. Parolayı girmezseniz hiçbir şey değişmez. Kapak kapalıyken Mac’in iyi havalandığından emin olun. **Pil %20’nin altına düşünce durdur** seçeneği oturumu pil bitmeden sonlandırır.

## Ayarlar

Ayarları menüden **Ayarlar…** ile ya da ⌘, ile açın veya pika-tools’u Finder, Launchpad ya da Spotlight’tan yeniden başlatın. Pencere açıkken uygulama Dock’ta ve ⌘Tab’de görünür.

- **Genel**: girişte açma, görünüm (Sistem, Açık veya Koyu), dil ve güncellemeler.
- **Klavye ve Fare**: Control kestirmeleri, ⌘Q ve ⌘W, dil değiştirme.
- **Pencereler ve Uygulamalar**: istisna listesiyle birlikte son pencerede çıkma ve Dock’ta tıklayarak gizleme.
- **Uyanık Tut**: süre, ekran ve kapak seçenekleri.
- **İzinler**: iki iznin durumu ve Sistem Ayarları’nda doğru yeri açan düğmeler.
- **Hakkında**: sürüm, değişiklik günlüğü bağlantısı ve sorun bildirme bağlantısı.

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
