<p align="center"><img src="../media/icon.png" width="128" height="128" alt=""></p>
<h1 align="center">pikapik</h1>
<p align="center">Klavye, fare, pencereler ve Finder için küçük iyileştirmeler, doğrudan Mac’inizin menü çubuğunda.</p>
<p align="center"><sub><a href="../../README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <b>Türkçe</b> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

<p align="center">
<picture>
<source media="(prefers-color-scheme: dark)" srcset="../media/settings-tr-dark.png">
<img src="../media/settings-tr-light.png" alt="pikapik ayarları">
</picture>
</p>

## Kurulum

Terminal’i açın, bu satırı yapıştırın ve Return tuşuna basın:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

Komut, en son sürümü GitHub’dan indirir ve yalnızca geliştiricisi tarafından imzalanmışsa ve Apple’ın kötü amaçlı yazılım denetiminden geçmişse kurar. pikapik ekranın üstündeki menü çubuğunda görünür. Siz açana kadar her şey kapalı kalır.

<details>
<summary>Diğer yollar: Homebrew veya dmg</summary>

Homebrew ile:

```bash
brew install --cask dev-pikapik/pika-tools/pikapik && open -a pikapik
```

Ya da [pikapik.dmg](https://github.com/dev-pikapik/pika-tools/releases/latest/download/pikapik.dmg) dosyasını indirin, açın ve uygulamayı Uygulamalar klasörüne sürükleyin.

Yukarıdaki komut da Homebrew de uygulamayı `/Applications` klasörüne koyar, açar, izinleri ister ve “Girişte Aç” seçeneğini açar. Bundan sonra uygulama kendini güncel tutar, bkz. **Güncellemeler**. Kaldırmak için bkz. **Kaldırma**.

</details>

## Neler yapar

<table>
<tbody><tr>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/keep-awake-dark.png"><img src="../media/keep-awake-light.png" width="340" alt=""></picture>
<br><b>Uyanık Tut</b>
<br>Mac’iniz gerektiği kadar uyanık kalır, kapak kapalıyken bile.
</td>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>
<br><b>Fanlar</b>
<br>Fanlarınızın ne kadar hızlı döndüğünü görün ve hızlarını seçin.
</td>
</tr></tbody>
<tbody><tr>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/command-keys-dark.png"><img src="../media/command-keys-light.png" width="340" alt=""></picture>
<br><b>⌘Q ve ⌘W’yi koruma</b>
<br>Hiçbir şey yanlışlıkla kapanmaz. Gerçekten istediğinizde ⇧ ekleyin.
</td>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/compress-dark.png"><img src="../media/compress-light.png" width="340" alt=""></picture>
<br><b>Küçük Kopya</b>
<br>Bir fotoğrafa, PDF’e ya da videoya sağ tıklayın, yanında daha hafif bir kopya belirsin.
</td>
</tr></tbody>
<tbody><tr>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/convert-dark.png"><img src="../media/convert-light.png" width="340" alt=""></picture>
<br><b>Dönüştürme</b>
<br>Bir resmi, videoyu ya da şarkıyı sağ tıklayarak başka bir biçimde kaydedin.
</td>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/input-switch-dark.png"><img src="../media/input-switch-light.png" width="340" alt=""></picture>
<br><b>Dili değiştir</b>
<br>⌥ tuşunu basılı tutup ⇧ tuşuna dokunun, klavye dili değişsin.
</td>
</tr></tbody>
<tbody><tr>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/quit-on-close-dark.png"><img src="../media/quit-on-close-light.png" width="340" alt=""></picture>
<br><b>Son pencereyle çıkış</b>
<br>Bir uygulamanın son penceresini kapatın, uygulama da kapansın.
</td>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/window-zoom-dark.png"><img src="../media/window-zoom-light.png" width="340" alt=""></picture>
<br><b>Yeşil düğme büyütür</b>
<br>Pencere tam ekrana geçmeden ekranı doldurur.
</td>
</tr></tbody>
<tbody><tr>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>
<br><b>Dock’ta tıklayarak gizleme</b>
<br>Kullandığınız uygulamaya tıklayın, kenara çekilsin.
</td>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>
<br><b>Yeni Dosya</b>
<br>Finder’da sağ tıklayın, bir ad yazın, boş dosya hazır.
</td>
</tr></tbody>
<tbody><tr>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/finder-cut-dark.png"><img src="../media/finder-cut-light.png" width="340" alt=""></picture>
<br><b>⌘X dosyaları taşır</b>
<br>Finder’da dosyaları kesin ve istediğiniz yere yapıştırın.
</td>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/finder-open-dark.png"><img src="../media/finder-open-light.png" width="340" alt=""></picture>
<br><b>Enter dosyaları açar</b>
<br>Finder’da dosyaları seçin ve açmak için Enter’a basın.
</td>
</tr></tbody>
<tbody><tr>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/finder-delete-dark.png"><img src="../media/finder-delete-light.png" width="340" alt=""></picture>
<br><b>Delete ile Çöp Sepeti’ne</b>
<br>Finder’da ⌫ tuşuna basın, seçili dosyalar Çöp Sepeti’ne gitsin.
</td>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>
<br><b>Oyun Modu</b>
<br>Siz oynarken oyunun üstünde hiçbir şey açılmaz, oyunu hiçbir şey kapatmaz.
</td>
</tr></tbody>
<tbody><tr>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>
<br><b>Hız Testi</b>
<br>İnternetiniz ne kadar hızlı ve neye yetiyor.
</td>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/side-buttons-dark.png"><img src="../media/side-buttons-light.png" width="340" alt=""></picture>
<br><b>Yan tuşlar</b>
<br>4 ve 5 numaralı tuşlar, kaydırma hareketi gibi geri ve ileri gider.
</td>
</tr></tbody>
<tbody><tr>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/wheel-lines-dark.png"><img src="../media/wheel-lines-light.png" width="340" alt=""></picture>
<br><b>Satır satır kaydır</b>
<br>Tekerleğin her tıkı, ne kadar hızlı çevirirseniz çevirin aynı miktarda kaydırır.
</td>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/wheel-direction-dark.png"><img src="../media/wheel-direction-light.png" width="340" alt=""></picture>
<br><b>Kaydırma yönü</b>
<br>İzleme dörtgeni için bir yön, fare için başka bir yön.
</td>
</tr></tbody>
<tbody><tr>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/linear-pointer-dark.png"><img src="../media/linear-pointer-light.png" width="340" alt=""></picture>
<br><b>İmleç hızlandırma yok</b>
<br>İmleç tam olarak elinizin gittiği kadar gider.
</td>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/key-repeat-dark.png"><img src="../media/key-repeat-light.png" width="340" alt=""></picture>
<br><b>Basılı tutulan tuşu tekrarla</b>
<br>Bir tuşu basılı tutun, aksan menüsü çıkmadan tekrar tekrar yazsın.
</td>
</tr></tbody>
<tbody><tr>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/home-end-dark.png"><img src="../media/home-end-light.png" width="340" alt=""></picture>
<br><b>Home ve End</b>
<br>Yazarken satırın başına ya da sonuna atlayın.
</td>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>
<br><b>Animasyonlar</b>
<br>Dock’u, pencereleri ve Hızlı Bakış’ı hızlandırın, anında olacak kadar.
</td>
</tr></tbody>
<tbody><tr>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>
<br><b>Silinen uygulamaların izinleri</b>
<br>macOS’in silinmiş uygulamalar için sakladığı izinleri kaldırın.
</td>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>
<br><b>Masaüstünde evcil dost</b>
<br>Küçük bir dost pencerelerinizin arkasında geziniyor. Tutup fırlatın ya da Boşluk tuşuna basın, zıplasın. Onu gardırobundaki kıyafetlerle giydirin ve birlikte oynarken ödüller kazanın. Siz yazarken canlanır, uzaklaştığınızda uyuklar.
</td>
</tr></tbody>
<tbody><tr>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/uninstaller-dark.png"><img src="../media/uninstaller-light.png" width="340" alt=""></picture>
<br><b>Uygulamaları Kaldır</b>
<br>Uygulamayı dosyalarıyla kaldırın. Hepsi geri konabilir.
</td>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>
<br><b>FPS’yi göster</b>
<br>Küçük bir sayaç, seçtiğiniz köşede oyunun ne kadar akıcı çalıştığını gösterir.
</td>
</tr></tbody>
<tbody><tr>
<td width="50%" valign="top">
<picture><source media="(prefers-color-scheme: dark)" srcset="../media/archive-dark.png"><img src="../media/archive-light.png" width="340" alt=""></picture>
<br><b>Arşivler</b>
<br>RAR ve diğer arşivleri açın ya da dosyaları sağ tıklamayla bir ZIP’e toplayın.
</td>
<td width="50%" valign="top"></td>
</tr></tbody>
</table>

## Ayrıntılar

<details>
<summary>İlk açılış</summary>

pikapik’in iki izne ihtiyacı vardır. İlk açılışta ayarlar, sizi adım adım yönlendiren İzinler sayfasında açılır ve macOS kendi uyarılarını gösterir. **Sistem Ayarları › Gizlilik ve Güvenlik** bölümüne gidin ve şu listelerde pikapik’i açın:

- **Erişilebilirlik**: Uygulama bir tuş basışını veya tıklamayı diğer uygulamalara ulaşmadan önce değiştirebilsin diye.
- **Girdi İzleme**: Uygulama tuş basışlarını ve tıklamaları görebilsin diye.

Uygulama değişikliği birkaç saniye içinde fark eder, yeniden başlatmaya gerek yoktur.

Bazı özellikler kullandığınızda ek izin ister: **Fan kontrolü**, **Finder Eklentileri**, **iCloud Drive**, **Tam Disk Erişimi** ve **Ekran Kaydı**. Hepsi ayarlardaki İzinler sayfasında toplanır: her iznin ne işe yaradığını anlatan bir satırı, yeşil bir onay işareti ya da turuncu bir çarpısı ve tek bir düğmesi vardır: izin eksikse **İzin Ver**, açıksa **Kapat**. Böylece herhangi bir izni hemen oradan geri alabilirsiniz.

pikapik yazdığınız veya tıkladığınız hiçbir şeyi kaydetmez, saklamaz ya da göndermez. Olaylar bellekte işlenir ve hemen iletilir. pikapik internete yalnızca güncellemeler için (GitHub’a en son sürümü sorar, güncellemeyi seçerseniz de indirir) ve siz başlattığınızda hız testi için (Apple sunucularını kullanır) bağlanır. Mac App Store sürümünü App Store günceller, hız testi ise Cloudflare kullanır. Evcil dostunuzun ilerlemesi (adımlar, fırlatmalar, ödüller ve benzerleri) yalnızca bu Mac’te sayılır ve hiçbir yere gönderilmez. Ayarlar › Evcil Dost sayfasından silebilirsiniz.

</details>

<details>
<summary>Her araç ayrıntılı olarak</summary>

**⌘Q ve ⌘W’yi koruma.** ⌘Q ve ⌘W tek başına hiçbir şey yapmaz, böylece bir uygulamadan yanlışlıkla çıkmaz ya da bir pencereyi yanlışlıkla kapatmazsınız. Bilerek yapmak için Shift ekleyin: ⇧⌘Q çıkar, ⇧⌘W kapatır. Tüm uygulamalarda çalışır. Her tuşun kendi anahtarı vardır. Varsayılan olarak kapalıdır.

**Option+Shift ile dil değiştirme.** Option’ı basılı tutun ve Shift’e dokunun: macOS bir sonraki girdi kaynağına geçer. Option’ı bırakmadan Shift’e yeniden dokunarak ilerlemeye devam edin. Geri gitmek için Shift’i basılı tutup Option’a dokunun. Arada başka bir tuşa basarsanız, tıklarsanız ya da Command, Control veya Fn eklerseniz dil değişmez, böylece Option+Shift+ok gibi kestirmeler eskisi gibi çalışır. Varsayılan olarak kapalıdır.

**Basılı tutulan tuşu tekrarla.** Bir tuşu basılı tuttuğunuzda aksan menüsü yerine harf tekrar tekrar yazılır. Oyunlarda ve yazarken işe yarar. Zaten açık olan uygulamalar bunu yeniden başlatıldıktan sonra kullanır. Kapattığınızda macOS her zamanki gibi çalışır. Varsayılan olarak kapalıdır.

**Home ve End satır başına ve sonuna gider.** Yazarken Home imleci satırın başına, End ise sonuna taşır; sayfa kaymaz. ⇧ ile oraya kadar seçer, ⌘ ile tüm metnin başına veya sonuna gider. Metin alanlarının dışında ve terminallerde, sanal makinelerde ve uzak masaüstü uygulamalarında tuşlar eskisi gibi çalışır. Her zamanki gibi çalışmaları gereken başka uygulamalar da ekleyebilirsiniz. Varsayılan olarak kapalı.

**İmleç hızlandırmayı kapat.** Fareyi ne kadar hızlı hareket ettirirseniz ettirin, imleç tam olarak fare kadar hareket eder. **İzleme hızı** sürgüsü imlecin ne kadar hızlı gideceğini ayarlar. Yalnızca farelerle çalışır, İzleme Dörtgeni olduğu gibi kalır. Özelliği kapatın ya da pikapik’tan çıkın, macOS kendi ayarlarına geri döner. Varsayılan olarak kapalıdır.

**Satır satır kaydır.** Fare tekerinin her tıkı, ne kadar hızlı çevirirseniz çevirin aynı sayıda satır kaydırır. Tık başına 1 ile 10 arasında satır seçebilirsiniz, varsayılan 3’tür. Doğal Kaydırma, Sistem Ayarları’nda nasıl ayarladıysanız öyle kalır. Yalnızca fareler için çalışır, izleme dörtgeni olduğu gibi kalır. Varsayılan olarak kapalıdır. **Tık başına mesafe** kaydırıcısının yanında küçük bir sayfa seçtiğiniz mesafe kadar kayar, bir nokta da varsayılan değeri gösterir.

Bazı uygulama ve oyunlar kaydırmayı tam piksel olarak sayar: onlar için aynı ayarı piksele çevirin ve tık başına 1 ile 200 piksel arasında seçin, varsayılan 40. Kaydırıcı bunun ekran yüksekliğinin ne kadarı olduğunu da söyler.

**İzleme dörtgeni ve fare için kaydırma yönü.** macOS’te izleme dörtgeni ve fare için ortak tek bir doğal kaydırma anahtarı vardır. Bunu açın ve her biri için bir yön seçin: sayfanın iPhone’daki gibi parmaklarınızı izlediği **Doğal** ya da sayfanın ters yöne gittiği **Klasik**. İzleme dörtgeni seçimi yana kaydırmayı ve parmaklarınızı kaldırdıktan sonraki kaymayı da kapsar. Magic Mouse dokunarak kaydırır, bu yüzden izleme dörtgeni seçimini izler. Tüm Mac’lerinizde aynısını seçin, fareyi Evrensel Denetim ile başka bir Mac’e taşısanız bile kaydırma her yerde aynı olur. Varsayılan olarak kapalı. Açtığınızda ikisi de Sistem Ayarları’ndaki gibi başlar, yani siz başka bir şey seçene kadar hiçbir şey değişmez.

**Yan tuşlarla geri ve ileri.** Farenin 4. ve 5. düğmeleri Finder’da, Safari’de ve diğer Apple uygulamalarında, ayrıca birçok başka uygulamada geri ve ileri gider, tıpkı izleme dörtgeninde kaydırma hareketi gibi. Bu düğmeleri kendisi işleyen uygulamalar onları olduğu gibi alır. Farenizde ters yerdeyseler **Yan tuşların yerini değiştir** seçeneğini açın. Varsayılan olarak kapalıdır.

**Son pencere kapanınca çıkma.** Bir uygulamanın son penceresini kapatın, uygulama kapanır. Finder açık kalır; başka masaüstlerinde veya Dock’ta penceresi olan uygulamalar da açık kalır. Bu şekilde asla kapanmaması gereken uygulamaların listesini oluşturabilirsiniz. Varsayılan olarak kapalıdır.

**Dock’ta tıklayarak gizleme.** Kullandığınız uygulamanın Dock simgesine tıklayın, uygulama gizlenir. Geri getirmek için yeniden tıklayın. Varsayılan olarak kapalıdır.

**Yeşil düğme pencereyi büyütür.** Bir pencerenin yeşil düğmesine tıklayın; pencere tam ekrana geçmeden ekranı doldurur. Önceki boyuta dönmek için yeniden tıklayın. ⌥ tuşunu basılı tutarsanız düğme her zamanki gibi çalışır. Tam ekran, düğmenin menüsünde ve ⌃⌘F ile kullanılabilir kalır. Yeşil düğmenin her zamanki gibi çalışacağı uygulamaları listeleyebilirsiniz. Varsayılan olarak kapalıdır.

**Finder’da Yeni Dosya.** Bir Finder penceresinde ya da masaüstünde sağ tıklayın, **Yeni Dosya**’yı seçin, bir ad yazın; boş bir dosya oluşur. Varsayılan .txt. Varsayılan olarak kapalı.

**Enter, Finder’da dosyaları açar.** Bir Finder penceresinde ya da masaüstünde dosyaları seçip Return veya Enter’a basın; dosyalar açılır. F2 veya fn F2 seçili dosyanın adını değiştirir. Metin alanlarında, örneğin bir ad yazarken, tuşlar her zamanki gibi çalışır. Varsayılan olarak kapalı.

**⌘X, Finder’da dosyaları keser.** Dosyaları seçip ⌘X’e basın, hedef klasörü açıp ⌘V’ye basın; dosyalar kopyalanmak yerine oraya taşınır. ⌘C kesmeyi iptal eder. Varsayılan olarak kapalı.

**Delete, Finder’da dosyaları siler.** Dosyaları seçip ⌫ veya ⌦ tuşuna (dizüstünde fn ⌫) basın; dosyalar ⌘⌫’taki gibi Çöp Sepeti’ne gider. Bir dosyayı yeniden adlandırırken, arama yaparken veya başka bir alana yazarken tuşlar her zamanki gibi harf siler. Varsayılan olarak kapalı.

**Finder’da Küçük Kopya.** Finder’da bir dosyaya sağ tıklayıp **Küçük Kopya Oluştur**’u seçin. Bir fotoğrafın, GIF’in, PDF’in veya videonun genellikle birkaç kat daha küçük bir sürümü hemen yanına kaydedilir. WAV veya AIFF gibi sıkıştırılmamış ses, kompakt bir M4A olur. Dosya daha fazla küçülemiyorsa kopya oluşturulmaz ve pikapik bunu size söyler. Orijinal olduğu gibi kalır ve hiçbir şey Mac’inizden çıkmaz. Varsayılan olarak kapalı.

**Finder’da Dönüştürme.** Finder’da bir dosyaya sağ tıklayıp **Dönüştür**’ü seçin; dosya başka bir biçimde kaydedilir: resim JPEG, PNG, HEIC, GIF, TIFF veya PDF, video MP4, MOV ya da yalnızca ses, müzik M4A, WAV veya AIFF olarak. Orijinal olduğu gibi kalır ve hiçbir şey Mac’inizden çıkmaz. Küçük Kopya’dan ayrı açılıp kapanır. Varsayılan olarak kapalı.

**Finder’da Arşivler.** Finder’da bir arşive sağ tıklayıp **Arşivden Çıkar**’ı seçin; dosyaları hemen yanında belirir. Başka bir dosyaya veya klasöre sağ tıklayıp **Arşiv Oluştur…** komutunu seçin; ZIP, 7Z, TAR.GZ veya TAR.XZ elde edersiniz. ZIP ve 7Z parolalı olabilir, her arşiv de parçalara bölünebilir; örneğin e-posta için 15 MB’lık, USB bellek için 4 GB’lık parçalar. Parolayı iki kez yazarsınız, böylece bir yazım hatası sizi kendi dosyalarınızın dışında bırakmaz. Bu şekilde hazırlanan bir ZIP’te sistemin eklediği gizli dosyalar olmaz, her dildeki dosya adları okunur kalır ve 4 GB’tan büyük dosyalar da sorunsuz işlenir. Varsayılan olarak kapalı. Mac App Store sürümünde yok.

pikapik, macOS’un açamadıklarını da açar: birkaç parçaya bölünmüş olsa bile RAR, parolayla korunan 7Z, .001, .z01, .r00 ve .part1.rar gibi parça kümeleri, ayrıca ZIPX, CAB, LZH, ARJ, ZST, LZMA, WIM ve daha fazlası. Çift tıklayınca pikapik’te açılırlar. Eski ZIP’lerdeki dosya adları, örneğin Kiril, Japonca veya Çince olanlar, okunur çıkar. Ayarlar › Finder’daki **Arşivleri bu uygulamayla aç** anahtarı ZIP ve 7Z’yi de pikapik’e verir; TAR ve GZ ise bunları zaten iyi işleyen yerleşik arşiv uygulamasında kalır. pikapik RAR’ı açabilir ama oluşturamaz: RAR lisansı yalnızca arşivden çıkarmaya izin verir.

Bir pencere parolayı sorar, **Durdur** her işi iptal eder ve hasarlı ya da eksik bir arşivden pikapik hâlâ okunabilen her şeyi çıkarır. Devasa bir boyuta şişecek bir arşivi çıkarmadan önce sorar, disk dolacaksa zamanında durur ve kendi klasörünün dışına yazmaya çalışan arşivleri engeller. Finder’da bir arşivi seçip Boşluk tuşuna basarak içindekileri önizleyebilirsiniz.

**Oyun Modu.** Oyunlarınızı ekleyin; siz oynarken Mac sizi oyundan koparmaz. Spotlight, Siri, ⌘Tab, Mission Control ve masaüstleri arasında kaydırma oyunun üstünde açılmaz, ⌘Q ve ⌘W oyunu yanlışlıkla kapatmaz, imleç Dock’a, menü çubuğuna ya da başka bir ekrana kaymaz ve ekran açık kalır. Bunların her birinin Oyunlar sayfasında kendi anahtarı vardır; pikapik ayrıca Mac’inizde bulduğu oyunları önerir. Oyunda Control-tıklama normal bir tıklama olarak kalır, Control ile ok tuşları masaüstünü değiştirmez. Minecraft da tanınır: Minecraft Launcher’ı ya da CurseForge’u ekleyin, mod Minecraft’ın içinde açılır. Oyundan çıkmak için ⇧⌘Q’ya, penceresini kapatmak için ⇧⌘W’ye basın. ⌥⌘Esc her zaman çalışır. Oyundan çıktığınız anda her şey her zamanki gibi çalışır. Varsayılan olarak kapalı.

Oyun Modu’nu aç ve oyna. Diğer oyun ayarları, Mac’in yayımladığı kataloğu, güncel tuşları ve her eylem için animasyonlu önizlemeyi içerir.

Otomatik, pencere açan veya odağı değiştiren eylemleri duraklatır. Hızlı ve kasıtlı dil kısayolu sistem penceresi olmadan kaynağı değiştirir. Basılı hareket tuşları önceliklidir; koşmak ve zıplamak yanlışlıkla dili değiştirmez.

Ayarlar → Oyunlar → Diğer oyun ayarları altında “Fare ve izleme dörtgeni” adlı bir grup var. Yalnızca Mac’inizde macOS’ta açık olanları, Apple’ın kendi adlarıyla ve her biri için küçük bir çizimle gösterir: fare düğmesindeki kısayollar, masaüstleri ve tam ekran uygulamalar arasında kaydırma, Mission Control ve App Exposé, uygulamalar için kıstırma ve masaüstü için parmakları açma, Bildirim Merkezi için sağ kenardan kaydırma ve her etkin köşe ile yaptığı eylem. Bir oyun öndeyken bunlar duraklatılır; böylece yanlışlıkla yapılan bir kaydırma ya da ekran köşesine değen imleç sizi oyundan çıkaramaz. Oyunun içindeki hareketler çalışmaya devam eder. Her biri her zamanki gibi çalışacak şekilde ayarlanabilir.

Ayarlar → Oyunlar → Oyun Ekle bölümünü aç ve çalışan oyununa tıkla. Java ve diğer ortamlarla çalışan oyunlar, .app dosyası olmasa da burada görünür. Minecraft, java yerine Minecraft adıyla görünür. Oyunun işlemini bul ve satırını Ayarlar → Oyunlar içindeki Oyunların alanına sürükle.

**FPS’yi göster.** FPS, saniyedeki kare sayısı demektir: oyunun her saniye kaç resim çizdiği. Oyunlar sayfasında **FPS’yi göster** seçeneğini açın; Oyun Modu açıkken herhangi bir oyunun bir köşesinde bu sayıyı gösteren küçük, koyu bir etiket görünür. Köşeyi, anahtarın üstündeki resimde tıklayarak seçersiniz. Tire, ilk karelerin henüz gelmediği anlamına gelir; soluk bir 0 ise oyunun çizmeyi bıraktığı anlamına gelir. macOS 27’de oyunların çoğunu macOS kendisi sayar, izin gerekmez. macOS’un sayamadığı bir oyun, çoğunlukla eski bir oyun, ekran kaydı üzerinden sayılır: İzinler sayfasında **Ekran Kaydı** satırı belirir, pikapik oyun sırasında asla izin istemez ve sayı ekranın yenileme hızını aşamaz. macOS 14–26’da ve Mac App Store sürümünde tüm oyunlar bu şekilde sayılır; bu yüzden satır, **FPS’yi göster** açılır açılmaz belirir ve anahtarın altındaki **İzin Ver** düğmesi sizi oraya götürür. Hiçbir görüntü saklanmaz veya gönderilmez. Varsayılan olarak kapalıdır.

**Evcil dostun gardırobu ve ödüller.** Evcil dostunuzu giydirmek için Ayarlar › Evcil Dost sayfasını açın: şapkalardan gözlüklere, pelerinlerden kanatlara 30’dan fazla parça ve büyücü, korsan ya da astronot gibi hazır kombinler. Birkaç parça en baştan ücretsizdir. Gerisi birlikte oynarken gelen ödüllerdir: evcil dostunuzu tutup fırlatın, topu tekmeleyin, pencerelere tırmanışını ve konuşmasını izleyin ya da günden güne yalnızca ona eşlik edin. Yeni bir ödül kazandığınızda evcil dostunuz size söyler.

Ödülün ne zaman geldiğini bilmek için pikapik yalnızca sizin ve evcil dostunuzun yaptıklarını sayar: adımlar, onu kaç kez tutup fırlattığınız, zıplamalar, tırmanışlar, top oyunları ve sohbetler, birlikte geçen günler, sabahın erken saatlerinde, gece yarısından sonra ya da hafta sonu birlikte olup olmadığınız, açtığınız Ayarlar sayfaları ve denediğiniz parçalar. Mac App Store dışındaki sürümde pikapik, Ayarlar’dan GitHub sayfamızı açıp açmadığınızı da not eder. Bu sayılar, her ödülün tarihi ve evcil dostunuzun üzerindekiler yalnızca bu Mac’te kalır. Hiçbir yere gönderilmez ve hiçbiri dışa aktarılan ayar dosyasına ya da iCloud eşitlemesine girmez. Hepsini istediğiniz zaman Ayarlar › Evcil Dost sayfasından silebilirsiniz; evcil dostunuz baştan başlar.

**Uygulamaları Kaldır.** Ayarlar › Uygulamaları Kaldır sayfasını açın, listeden bir uygulama seçin ya da bir uygulamayı resmin üzerine bırakın; pikapik o uygulamanın Mac’inizde sakladığı her şeyi gösterir: uygulamanın kendisi, kayıtlı verileri, ayarları, geçici dosyaları, arka plan yardımcıları ve daha fazlası; her biri listede olma nedeniyle birlikte. Açıkça uygulamaya ait olan dosyalar işaretlidir, yalnızca ilgili olabilecek dosyalar işaretli değildir, başka uygulamaların da kullandığı dosyalar ise etiketlenir. Kaldırılacakları seçin ve **Çöp Sepeti’ne taşı** düğmesine tıklayın. Hiçbir şey kalıcı olarak silinmez: her şey Çöp Sepeti’ne gider. Uygulama açıksa pikapik önce ondan kapanmasını ister; bazı dosyalar yönetici gerektiriyorsa Mac’iniz parolanızı yalnızca bir kez sorar.

Fikrinizi mi değiştirdiniz? **Geri koy** düğmesine tıklayın; her şey eski yerine döner ve arka plan yardımcıları yeniden başlar. Son on kaldırma, dosyaları Çöp Sepeti’nde durduğu sürece “Son kaldırılanlar” bölümünde bekler. **Uygulamayı sıfırla** uygulamayı olduğu gibi bırakır, yalnızca kayıtlı verilerini, ayarlarını ve geçici dosyalarını kaldırır; bir uygulama düzgün çalışmadığında işe yarayabilir. Çöp Sepeti’ne kendiniz taşıdığınız uygulamalar, geride bıraktıkları dosyalarla birlikte “Çöp Sepeti’nde” bölümünde görünür; “Kaldırılan uygulamaların kalıntıları” ise artık olmayan uygulamaların dosyalarını bulur. “Bir uygulama Çöp Sepeti’ne gidince temizlik öner” anahtarı varsayılan olarak kapalıdır ve siz seçmeden hiçbir şey kaldırılmaz. Bir uygulamanın sakladığı her şeyi görmek için sayfanın **Tam Disk Erişimi** iznine ihtiyacı vardır. Bu araç Mac App Store sürümünde yoktur.

Her aracın menüde ve ayarlarda kendi anahtarı vardır.

Menü çubuğu simgesi durumu bir bakışta gösterir: araçlar çalışırken pikapik işareti, her şey kapalıyken aynı işaretin soluk hâli, bir araç açık ama izinler eksikken bir uyarı üçgeni.

Menü çubuğu paneli başta yalnızca birkaç satırla açılır. Hangi satırların görüneceğini sen seçersin: alttaki kalem düğmesine tıkla, görmek istediğin satırları işaretle ve **Bitti**'ye tıkla. Gizlenen satırlar çalışmaya devam eder ve Ayarlar'da kalır. Panel ekrana sığmazsa kaydırılır.

Uygulama sistem dilini ya da ayarlarda seçtiğiniz dili kullanır. Bu sayfanın başındaki listede yer alan 23 dilin tümü desteklenir.

</details>

<details>
<summary>Uyanık Tut</summary>

Siz klavyenin başında değilken Mac’inizin uyku moduna geçmesini engeller: 1 saniyeden 365 güne kadar istediğiniz süre boyunca ya da siz kapatana kadar. Menüden açın, süreyi ayarlarda belirleyin: gün, saat, dakika ve saniyeyi yazın, ↑ ve ↓ tuşlarını kullanın ya da 15 dakikadan 8 saate kadar hazır bir seçeneğe tıklayın. Menü ne kadar süre kaldığını ve ne zaman biteceğini gösterir. **Ekran** için iki seçenek var. **Her zaman açık**: kapanmaz, ekran koruyucu ya da kilit ekranı çıkmaz. **Her zamanki gibi kapanır**: kendi zamanlayıcısıyla kapanır, Mac’iniz çalışmaya devam eder. **Ekranı şimdi kapat** (menüde de var) ekranı hemen kapatır, Mac çalışmaya devam eder: geri getirmek için fareyi oynatın ya da bir tuşa basın. pikapik’ten çıkınca Uyanık Tut da sona erer.

MacBook’ta **Kapak kapalıyken çalış** seçeneğini de açabilirsiniz. macOS’te bunun için bir ayar yoktur, bu yüzden pikapik `pmset -a disablesleep 1` komutunu çalıştırır ve yönetici parolası ister: Mac’in nasıl uyuyacağını yalnızca bir yönetici değiştirebilir. Ayar; Uyanık Tut bittiğinde, uygulamadan çıktığınızda ya da uygulama çöktüğünde kendiliğinden normale döner. Parolayı girmezseniz hiçbir şey değişmez. Kapak kapalıyken Mac’in iyi havalandığından emin olun. **Pil %20’nin altına düşünce durdur** seçeneği oturumu pil bitmeden sonlandırır.

Keep Awake, ekran ve kapak kapalı modları, Kestirmeler uygulamasıyla Denetim Merkezi’nde, menü çubuğunda ya da masaüstü widget’ında bir düğmeye konabilir; bağlantıları Ayarlar › Uyanık Tut bölümünden kopyalarsın.

</details>

<details>
<summary>Hız Testi</summary>

İnternetinin şu anda ne kadar hızlı olduğunu gösterir. Ayarlar › Hız Testi’nde **Hızı Ölç**’e ya da satırı kalem düğmesiyle menüye eklediysen oradaki **Ölç**’e tıkla. Yaklaşık yarım dakikada indirme ve yükleme hızını, ping’i ve tepki hızını görürsün: bağlantı meşgulken her şeyin ne kadar çabuk tepki verdiği. Altında sade bir dille neye yettiği yazar: 4K filmler, görüntülü aramalar, çevrim içi oyunlar ve büyük indirmeler. Ölçüm, macOS’taki networkQuality aracını ve Apple sunucularını kullanır. Son sonuç bir sonraki ölçüme kadar kalır; Kestirmeler için bir bağlantı ölçümü Denetim Merkezi’nden başlatır.

</details>

<details>
<summary>Ayarlar</summary>

Ayarları menüden **Ayarlar…** ile ya da ⌘, ile açın veya pikapik’i Finder, Launchpad ya da Spotlight’tan yeniden başlatın. Pencere açıkken uygulama Dock’ta ve ⌘Tab’de görünür.

- **Genel**: girişte açma, görünüm (Sistem, Açık veya Koyu), dil, güncellemeler ve yedekleme: ayarları dosya olarak dışa ve içe aktarma ya da iCloud Drive ile eşzamanlama.
- **Uyanık Tut**: süre, ekran ve kapak seçenekleri.
- **Fanlar**: her fanın hızı, Fan kontrolüne izin verildiğinde Otomatik veya elle seçilen hız.
- **Hız Testi**: internet hızını ölçer ve neye yettiğini gösterir.
- **Klavye**: dil değiştirme, tuş tekrarı, Home ve End.
- **Fare**: imleç ivmesi ve izleme hızı, satır satır kaydırma, kaydırma yönü, yan düğmeler.
- **Pencereler**: yeşil düğmeyle pencereyi büyütme (istisna listesiyle), ⌘Q ve ⌘W koruması ve son pencerede çıkma (istisna listesiyle).
- **Dock**: Dock’ta tıklayarak gizleme.
- **Finder**: yeni dosya, küçük kopya, dönüştürme ve arşivler, Return ile açma, ⌘X ile kesme ve ⌫ ile silme.
- **Uygulamaları Kaldır**: bir uygulamayı dosyalarıyla kaldırın, sonra hepsini geri koyun ve kaldırılan uygulamaların geride bıraktıklarını temizleyin.
- **Oyunlar**: oyun listeniz ve Oyun Modu seçenekleri.
- **Evcil Dost**: açıp kapatma, sohbet, ritminize uyma ve top, gardırop ve ödüller.
- **İzinler**: pikapik’in kullandığı tüm izinler; her birinin durumu ve izin vermek ya da kapatmak için bir düğmesi. Bir izni eksik olan araç yarı soluk gri görünür; üzerine tıklamak bu sayfayı doğru satırda açar.
- **Hakkında**: sürüm, değişiklik günlüğü bağlantısı ve sorun bildirme bağlantısı.

Birçok ayarın, ne yaptığını gösteren küçük bir resmi vardır; örneğin uyumayan bir Mac ya da Dock’un arkasına saklanan bir pencere. Resim, anahtarla birlikte değişir ve Sistem Ayarları’nda “Hareketi Azalt” açıksa hareketsiz kalır.

Her sayfanın altında bir **Saptanmışlara Dön…** düğmesi vardır. Önce onay ister, ardından o sayfadaki araçları kapatır ve seçeneklerini geri alır; sanki pikapik onlara hiç dokunmamış gibi.

**Ayarları iCloud ile eşzamanla** pikapik’i tüm Mac’lerinizde aynı tutar. Ayarlar iCloud Drive’daki pikapik klasöründe durur ve en son değişiklik geçerli olur. Varsayılan olarak kapalıdır ve iCloud Drive’ın açık olması gerekir. İzinler eşzamanlanmaz: her Mac kendi izinlerini kendisi ister.

</details>

<details>
<summary>Güncellemeler</summary>

pikapik açılışta ve her 6 saatte bir yeni sürüm olup olmadığını denetler. Bunu Ayarlar › Genel bölümünden kapatabilirsiniz. Yeni bir sürüm çıktığında menüde **… sürümüne güncelle** düğmesi görünür: tek tıklamayla uygulama güncellemeyi indirir, yükler ve yeniden başlar. Ayarlar › Genel bölümündeki **Şimdi Denetle** ile elle de denetleyebilirsiniz.

Homebrew kullanıyorsanız `brew upgrade --cask pikapik` komutunu da çalıştırabilirsiniz.

1.3 sürümünden itibaren izinler güncellemelerden sonra yerinde kalır.

</details>

<details>
<summary>Kaldırma</summary>

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

Homebrew ile kurduysanız: `brew uninstall --cask --zap pikapik`.

İkisi de uygulamadan çıkar, onu giriş öğelerinden kaldırır ve siler. Betik ayrıca uygulamanın izinlerini sıfırlar.

</details>

<details>
<summary>Sık sorulan sorular</summary>

**Neden iki izin gerekiyor?**
macOS klavye ve fare erişimini ikiye ayırır. Girdi İzleme uygulamanın olayları görmesini, Erişilebilirlik ise onları değiştirmesini sağlar. Bir kestirmeyi engellemek için ikisi de gerekir.

**macOS uygulamanın tanımlanmamış bir geliştiriciden geldiğini söylüyor.**
pikapik, geliştiricisi tarafından imzalanmıştır ve Apple’ın kötü amaçlı yazılım denetiminden geçer, bu yüzden bu uyarının görünmemesi gerekir. Yine de görünürse **Sistem Ayarları › Gizlilik ve Güvenlik** bölümünü açıp **Yine de Aç** düğmesine tıklayın.

**Intel işlemcili Mac’lerde çalışır mı?**
Evet. Apple Silicon ve Intel için evrensel bir uygulamadır, macOS 14 Sonoma veya sonrası gerekir.

**İzin açık ama hiçbir şey çalışmıyor.**
**Sistem Ayarları › Gizlilik ve Güvenlik** bölümünde pikapik’i − düğmesiyle iki listeden de kaldırın, sonra yeniden ekleyin. Ya da bunu pikapik içinde yapın: İzinler sayfasında her izin için **Kapat**’a, ardından yeniden **İzin Ver**’e tıklayın.

</details>

<p align="center">☕ pikapik’i seviyorsanız bana <a href="https://buymeacoffee.com/pikapik">bir kahve ısmarlayabilirsiniz</a>; hepsi uygulamanın geliştirilmesine ve desteğine gider.</p>

<p align="center"><sub><a href="../whats-new/README.tr.md">Yenilikler</a> · <a href="https://github.com/dev-pikapik/homebrew-pika-tools">Homebrew tap’i</a> · <a href="../../CONTRIBUTING.md">Kendiniz derleyin</a> · <a href="../../LICENSE">MIT Lisansı</a> · © 2026 pikapik</sub></p>
