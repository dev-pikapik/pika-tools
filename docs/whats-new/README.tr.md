<p align="center"><a href="../readme/README.tr.md"><img src="../media/icon.png" width="96" height="96" alt="pikapik"></a></p>
<h1 align="center">pikapik’teki yenilikler</h1>
<p align="center">Her güncelleme birkaç kelime ve bir resimle, en yenisi en üstte.</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <b>Türkçe</b> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.47.0"></a>Tek tıkla tertemiz masaüstü

<sub>1.47.0 · 13 Ekim 2026</sub>

pikapik’teki iki yeni anahtar, masaüstündeki simgeleri gizler ve macOS’un sakladığı dosyaları gösterir.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/desktop-icons-dark.png"><img src="../media/desktop-icons-light.png" width="340" alt=""></picture>

**Masaüstü simgelerini gizle.** Bir görüşmeden, ekran kaydından ya da ekran görüntüsünden önce açın, masaüstündeki dosya ve klasörler kaybolsun. Kapatın, aynı yerlerine geri dönsünler. Hiçbir şey taşınmaz: dosyalar Finder’da Masaüstü klasöründe kalır. Bu, Sistem Ayarları › Masaüstü ve Dock’taki **Öğeleri göster › Masaüstünde** ayarının ta kendisi, sadece daha el altında, bu yüzden ikisi her zaman aynıdır. Mac App Store sürümünde bu satır onun yerine Sistem Ayarları’nın o sayfasını açar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/hidden-files-dark.png"><img src="../media/hidden-files-light.png" width="340" alt=""></picture>

**Gizli dosyaları göster.** macOS’un gizlediği dosya ve klasörler, örneğin ev klasörünüzdeki Kitaplık ya da adı noktayla başlayan dosyalar, Finder’da ve masaüstünde soluk görünür. Finder’da ⇧⌘. tuşlarına basmakla aynıdır, sadece açık olup olmadığını bir bakışta görürsünüz. Değişikliğin uygulanması için Finder kısa bir süreliğine yeniden başlatılır ve pencerelerini ve sekmelerini tekrar açar. Finder dosya kopyalıyor veya taşıyorsa, bu iş bitince yeniden başlatılır. İkisi de Ayarlar › Finder’da. Onları menü çubuğu panelinde görmek için panelin altındaki kalem düğmesine tıklayın ve işaretleyin. Mac App Store sürümünde Ayarlar › Finder bunun yerine ⇧⌘. tuşlarını gösterir.

---

## <a id="v1.46.1"></a>“İzinler” sayfası durumu olduğu gibi söylüyor

<sub>1.46.1 · 13 Ekim 2026</sub>

Bir aracın aşağıdaki listeden hâlâ bir izne ihtiyacı varsa sayfa artık bunu söylüyor.

Önceden, üstteki iki izin de açıldığında, “Bazı özellikler için” bölümündeki bir araç hâlâ iznini bekliyor olsa bile sayfa tüm araçların çalıştığını söylüyordu. Artık bazı araçların aşağıdaki listeden bir izne de ihtiyaç duyduğunu söylüyor ve her şeyin çalıştığını yalnızca gerçekten öyle olduğunda söylüyor.

**Deneyin:** Ayarlar › İzinler

**Düzeltilenler**

- Mac App Store sürümünde, “Hakkında” sayfasındaki “Teşekkür et” bölümü yalnızca bahşişler seçilmeye hazır olduğunda görünüyor. Önceden yüklenirken dönen bir simge çıkıyor, App Store yanıt vermezse bölüm kayboluyordu.
- Bir arşiv açılırken disk dolarsa, “Yeterli yer yok” artık yarım açılmış dosyalar silindikten sonra gerçekten ne kadar boş yer kaldığını gösteriyor. Önceden neredeyse hiç boş yer olmadığını söyleyebiliyordu.

---

## <a id="v1.46.0"></a>Öndeki uygulamayı bir fare düğmesiyle gizleyin

<sub>1.46.0 · 13 Ekim 2026</sub>

Orta düğmeye ya da bir yan tuşa basın, içinde olduğunuz uygulama tıpkı ⌘H’deki gibi kenara çekilsin.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/hide-app-dark.png"><img src="../media/hide-app-light.png" width="340" alt=""></picture>

Ayarlar › Fare sayfasına gidin, “Fare düğmesiyle geçerli uygulamayı gizle” anahtarını açın ve kullanmak istediğiniz düğmeye basın. Sonradan “Değiştir…” ile başka bir düğme seçebilirsiniz. Uygulama çalışmaya devam eder, Dock’taki simgesine tıklamak onu geri getirir. Oyun Modu açıkken oynadığınızda düğme oyunda her zamanki işini yapar. “Yan tuşlarla geri ve ileri” de açıksa seçtiğiniz yan tuş bunun yerine uygulamaları gizler. “Erişilebilirlik” izni gerektirir ve varsayılan olarak kapalıdır.

Mac App Store sürümünde ⌘X, Finder’da dosyaları keser: dosyaları seçin, ⌘X’e basın, başka bir klasör açın, ardından pikapik menüsünden “Öğeleri Buraya Taşı” öğesini seçin ya da ⌥⌘V’ye basın. “Animasyonlar” ve “İmleç hızlandırmayı kapat” geri döndü, “İzinler” sayfasında da yeni bir bölüm var: “Silinen uygulamalardan kalanlar”. Bu sürüm bu ayarları kendisi değiştiremez; bu yüzden her satır neyi değiştirmeniz gerektiğini açıklar ve Sistem Ayarları’nda doğru yeri açar. Evcil dostunuz artık Dock’un üstünde ekranın bir ucundan öbür ucuna yürüyor.

**Deneyin:** Ayarlar › Fare › Fare düğmesiyle geçerli uygulamayı gizle

**Düzeltilenler**

- “Fare” sayfasındaki çizimler yeniden net.
- Klavye ve fare özellikleri yalnızca gerçekten kullandıkları izni istiyor. Çoğuna yalnızca “Erişilebilirlik” yetiyor; önceden “Giriş İzleme” iznini de istiyor ve o olmadan gri kalıyorlardı.
- “Dili değiştir”, “Giriş İzleme” iznine ihtiyaç duyduğunda bunu gösteriyor ve ona tıklamak “İzinler” sayfasını açıyor. Önceden açık kalıyor ama çalışmıyordu.
- “Son pencere kapanınca çık”, pikapik açılırken macOS’un bu izni istemesine yol açmak yerine siz “Giriş İzleme” iznini verene kadar bekliyor.
- macOS 27’de “Erişilebilirlik”, Sistem Ayarları’ndaki gibi yeni adıyla, “Aygıt Denetimi ve Veri Erişimi” olarak görünüyor.
- VoiceOver ile artık “Gardırop” ve “Kombinler” bölümlerinde evcil dostunuzun kıyafetlerini ve kombinlerini seçebilir, “Ödüller” bölümünde ödüllerini açabilirsiniz. Önceden bu kutucuklar tepki vermiyordu.

---

## <a id="v1.45.0"></a>Her uygulamanın kendi ses düzeyi var

<sub>1.45.0 · 13 Ekim 2026</sub>

Yüksek sesli görüşmeyi kısın, gürültülü oyunu sessize alın, müziğe dokunmayın.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.45.0/app-volume-dark.png"><img src="../media/whats-new/1.45.0/app-volume-light.png" width="340" alt=""></picture>

Ayarlar › Ses sayfasına gidin ve “Uygulama Sesi” anahtarını açın. Ses çalan her uygulama kendi sürgüsünü ve bir sessize alma düğmesini alır, hem Ayarlar’da hem menüde. Mac’inizin ve diğer uygulamaların ses düzeyi değişmez, pikapik de her uygulamanın düzeyini hatırlar. Tam sesle bıraktığınız uygulamaya hiç dokunulmaz.

Bir uygulamanın ses düzeyini değiştirmek için pikapik onun sesini kendi içinden geçirir, bu yüzden “İzinler” sayfasında verdiğiniz “Sistem Sesi Kaydı” iznine ihtiyaç duyar. Ses yalnızca aktarılır: kaydedilmez, saklanmaz, hiçbir yere gönderilmez ve mikrofon kullanılmaz. macOS 14.2 veya sonrasını gerektirir (macOS 14.0 ve 14.1’de gizlidir) ve varsayılan olarak kapalıdır.

**Deneyin:** Ayarlar › Ses › Uygulama Sesi

---

## <a id="v1.44.3"></a>Yanlış klavye düzeninde yazılan sözcükler kendiliğinden düzelir

<sub>1.44.3 · 13 Ekim 2026</sub>

Bir sözcüğü yanlış klavye düzeninde yazıp Boşluk tuşuna bastığınızda pikapik onu doğru düzende yeniden yazar ve düzeni sizin yerinize değiştirir.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/layout-fix-dark.png"><img src="../media/layout-fix-light.png" width="340" alt=""></picture>

Bu özelliği Ayarlar › Klavye bölümünden açın. Bir sözcük anlamsız harflere dönüştüğünde, örneğin привет yerine ghbdtn çıktığında, Boşluk veya Return tuşuna bastığınız anda pikapik onu yeniden yazar ve sonraki sözcük doğru çıksın diye düzeni değiştirir. Mac’inize eklediğiniz tüm klavye düzenleriyle, tüm dillerinizde çalışır.

Normal metin tam yazdığınız gibi kalır. pikapik bir sözcüğü yalnızca dillerinizin hiçbirinde böyle bir sözcük yoksa ve aynı tuşlar başka bir düzende sık kullanılan bir sözcük veriyorsa değiştirir. Adlar, yazım hataları ve nadir sözcükler olduğu gibi kalır. Parola alanlarına, Terminal’e ve seçtiğiniz uygulamalara da dokunulmaz.

Bir sözcük gözden mi kaçtı, yoksa birini eski hâline mi döndürmek istiyorsunuz? Son sözcüğü ya da seçili metni düzeltmek için ⌃⇧Boşluk tuşlarına basın, diğer düzenlerinizi denemek için yeniden basın. Bir düzeltmenin hemen ardından aynı tuşlar onu geri alır ve pikapik o sözcüğü bir daha kendiliğinden düzeltmez. Mac App Store sürümünde metni seçin ve Servisler menüsünden “Klavye Düzenini Düzelt” öğesini seçin.

**Deneyin:** Ayarlar › Klavye › Yanlış klavye düzeninde yazılan sözcükleri düzelt

---

## <a id="v1.44.2"></a>VoiceOver pikapik menüsünü yeniden açıyor

<sub>1.44.2 · 13 Ekim 2026</sub>

macOS 27’de menü çubuğundaki pikapik menüsünü VoiceOver ile yeniden açabilirsiniz.

Önceden pikapik simgesini VoiceOver veya başka bir erişilebilirlik özelliğiyle etkinleştirdiğinizde hiçbir şey olmuyordu. Artık menü açılıyor ve simgeyi yeniden etkinleştirdiğinizde, tıklamada olduğu gibi kapanıyor.

---

## <a id="v1.44.0"></a>Bir portu hangi programın tuttuğunu görün

<sub>1.44.0 · 13 Ekim 2026</sub>

Ayarlar’daki yeni Portlar sayfası, Mac’inizdeki her portu hangi programın tuttuğunu gösterir ve gerektiğinde portu serbest bırakır.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/ports-dark.png"><img src="../media/ports-light.png" width="340" alt=""></picture>

Bir program portunun zaten kullanımda olduğunu söylediğinde Ayarlar › Portlar sayfasını açın. Port tutan her program burada simgesi, tuttuğu portlar ve ağınızdaki diğer aygıtların ona bağlanıp bağlanamayacağı bilgisiyle birlikte görünür. Bir port numarası yazarak o portu kimin tuttuğunu bulun ya da portun boş olduğunu görün.

Bir satıra tıkladığınızda tarayıcıda açabileceğiniz adresler, programın dosyası, onu başlatan komut, klasörü ve işlem numarası görünür. “Serbest Bırak” önce programdan kapanmasını ister, böylece program işini kaydedebilir. Kapanmazsa pikapik onu çıkmaya zorlamayı önerir. Her adımdan önce size sorulur.

macOS’un parçalarına ve başka kullanıcıların programlarına dokunulmaz. AirPlay Alıcı, Dosya Paylaşma, Ekran Paylaşma ve Uzaktan Oturum Açma için pikapik, portu Sistem Ayarları’ndaki hangi anahtarın serbest bıraktığını söyler. Mac App Store sürümünde “Serbest Bırak” programı gösterir, onu Terminal’de kapatan bir komutu kopyalar ya da Etkinlik Monitörü’nü açar.

---

## <a id="v1.43.0"></a>Arka planda neyin çalıştığını görün

<sub>1.43.0 · 13 Ekim 2026</sub>

pikapik artık kendiliğinden başlayan her şeyi ve onu hangi uygulamanın eklediğini gösteriyor, kendi görevlerinizi de hiçbir şeyi silmeden kapatıyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.43.0/background-dark.png"><img src="../media/whats-new/1.43.0/background-light.png" width="340" alt=""></picture>

Ayarlar’daki yeni Arka Plan Görevleri sayfası girişte açılan uygulamaları, arka plan hizmetlerini, uygulamaların içindeki yardımcıları ve silinmiş uygulamaların kalıntılarını listeler. Her görevde onu hangi uygulamanın eklediği, şu anda çalışıp çalışmadığı ve dosyasının nerede olduğu görünür. Tek tıklamayla dosya Finder’da gösterilir.

Kendi görevlerinizi tek düğmeyle kapatıp yeniden açarsınız. Hiçbir şey silinmez. Tüm kullanıcılar ve tüm Mac için olan görevlerde düğme, Sistem Ayarları’nda Giriş Öğeleri’ni açar.

Mac App Store sürümünde sayfa görevleri gösterir, düğmeleri de Giriş Öğeleri’ni açar.

---

## <a id="v1.42.0"></a>Mac’inizin içinin ne kadar ısındığını görün

<sub>1.42.0 · 13 Ekim 2026</sub>

Ayarlar’daki yeni Sıcaklık sayfası işlemcinin, grafiğin, belleğin, depolamanın, pilin ve Wi-Fi’ın ne kadar ısındığını gösterir ve her şeyin yolunda olup olmadığını sade bir dille söyler.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/temperatures-dark.png"><img src="../media/temperatures-light.png" width="340" alt=""></picture>

Ayarlar › Sıcaklık sayfasını açın. En üstte tek bir kelime durumu özetler: “Normal”, “Ilık”, “Sıcak” ya da “Çok sıcak”. Altındaki kısa satır, Mac’inizin tam hızda mı çalıştığını yoksa soğumak için mi yavaşladığını söyler. Aşağıda, Mac’inizin ölçebildiği her parça için sıcaklık ve renkli bir çubuk görünür: yeşil her şey yolunda, sarı ılık, turuncu sıcak demektir. Renkler her parçanın normal aralığına göre belirlenir.

Sıcaklığı hep göz önünde tutmak mı istiyorsunuz? pikapik menüsünün altındaki kaleme tıklayın ve “Sıcaklık” seçeneğini işaretleyin. Menü bundan sonra aynı kelimeyi ve işlemcinin sıcaklığını gösterir, satıra tıklamak da sayfayı açar.

Sıcaklıklar iki saniyede bir güncellenir, ama yalnızca sayfa ya da menü açıkken; yani arka planda hiçbir şey denetlenmez. pikapik sıcaklıkları yalnızca okur: parola istemez ve hiçbir şeyi değiştirmez.

**Düzeltilenler**

- pikapik menüsünde hangi satırların görüneceğini seçtiyseniz “Dock’u tek ekranda tut” satırı artık orada kendiliğinden belirmiyor. Göstermek için kaleme tıklayın ve onu işaretleyin.
- Ayarlar’ı kapattığınızda pikapik artık fanları ve pili kontrol etmeyi hemen bırakıyor, arka planda devam etmiyor.

---

## <a id="v1.41.1"></a>Fan kontrolü artık parolanızı sormuyor

<sub>1.41.1 · 13 Ekim 2026</sub>

Fan hızını ayarlayan yardımcı artık pikapik ile birlikte güncelleniyor, bu yüzden yeni sürümler yönetici parolasını sormuyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Bu güncelleme parolayı son bir kez soracak. Fan kontrolünü kullanıyorsanız Ayarlar › İzinler sayfasını açın, “Fan kontrolü” öğesinin yanındaki “İzin Ver” düğmesine tıklayın ve parolayı girin. Bundan sonra pikapik yardımcıyı kendisi günceller ve yalnızca gerçekten pikapik’ten gelen bir yardımcıyı kabul eder.

**Düzeltilenler**

- Sistem Ayarları › Genel › Giriş Öğeleri’nde fan yardımcısı artık uygulamanın simgesiyle birlikte pikapik olarak görünüyor.

---

## <a id="v1.41.0"></a>Pilinizin durumunu görün

<sub>1.41.0 · 13 Ekim 2026</sub>

Ayarlar’daki yeni Pil sayfası, pilin ne kadar yıprandığını, neyle şarj olduğunu ve ömrünün nasıl uzatılacağını gösterir.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/battery-dark.png"><img src="../media/battery-light.png" width="340" alt=""></picture>

Ayarlar › Pil sayfasını açın. Şarj düzeyini ve pilin şu anda ne yaptığını, durumunu, yeni haline göre maksimum kapasitesini ve devir sayısını, yani tasarlandığı 1.000 devirden kaçını kullandığını görürsünüz.

Mac’iniz prize takılıyken sayfa güç adaptörünü ve gücünü gösterir; şarj olurken ayrıca şarj gücünü, yani şu anda pile giren gücü de gösterir. Mac’iniz pille çalışırken ise sayfa şu anda ne kadar güç kullandığını gösterir.

Sayfanın altındaki ipuçları pilin daha uzun dayanmasına yardım eder; “Pil Ayarları…” ise Sistem Ayarları’nda Pil bölümünü açar, macOS’un pili nasıl şarj edeceğini orada seçersiniz. Sayfa hiçbir şeyi değiştirmez ve hiçbir izin gerektirmez, Mac App Store sürümünde de. Yalnızca pili olan Mac’lerde görünür.

**Düzeltilenler**

- pikapik’i Homebrew ile kaldırdığınızda artık “Girişte Aç” da kapanıyor ve uygulamanın değiştirdiği animasyonlar, tuş tekrarı ve etkin köşeler gibi sistem ayarları eski hâline dönüyor. pikapik kendini güncellediyse, kaldırmadan önce bir kez brew upgrade --cask pikapik komutunu çalıştırın.

---

## <a id="v1.40.2"></a>Homebrew ile güncelleme artık Dock’u yeniden başlatmıyor

<sub>1.40.2 · 13 Ekim 2026</sub>

Homebrew ile pikapik’i güncellediğinizde Dock artık bir anlığına kaybolmuyor.

Bu sürüme yapılan güncelleme Dock’u son bir kez daha yeniden başlatabilir, çünkü bu adımı hâlâ önceki sürüm yapıyor. Sonraki güncellemeler Dock’a dokunmuyor.

---

## <a id="v1.40.1"></a>Dock’ta tek tıklama pencereleri kaldırır

<sub>1.40.1 · 13 Ekim 2026</sub>

Çalıştığınız uygulamanın Dock’taki simgesine tıklayın, tüm pencereleri Dock’a küçülsün. Bir kez daha tıklayın, hepsi geri gelsin.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.40.1/dock-minimize-dark.png"><img src="../media/whats-new/1.40.1/dock-minimize-light.png" width="340" alt=""></picture>

Ayarlar › Dock sayfasını açın ve “Dock’ta tıklayarak küçült veya gizle” anahtarını açın. Pencereler aynı sırayla geri gelir, üzerinde çalıştığınız pencere en üstte olur. Başka bir uygulamaya tıklamak, menüsünü açmak için bir simgeyi basılı tutmak ve simgeleri sürüklemek eskisi gibi çalışır.

Uygulamanın tamamını ⌘H’deki gibi gizlemeyi mi tercih edersiniz? Anahtarın altında “Simgeye tıklayınca” seçeneğini “Uygulamayı gizler” yapın. Uygulamaları zaten Dock’ta tıklayarak gizliyorsanız sizin için hiçbir şey değişmez. Anahtar “Erişilebilirlik” izni gerektirir, Mac App Store sürümünde yoktur ve varsayılan olarak kapalıdır.

---

## <a id="v1.40.0"></a>Dock tek ekranda kalıyor

<sub>1.40.0 · 13 Ekim 2026</sub>

İmleç başka bir ekranın kenarına dayandığında Dock artık o ekrana atlamıyor, bıraktığınız yerde kalıyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-display-dark.png"><img src="../media/dock-display-light.png" width="340" alt=""></picture>

Ayarlar › Dock sayfasını açın ve “Dock’u tek ekranda tut” anahtarını açın. Dock artık altta da olsa yanda da olsa kendi ekranında kalır ve etkin köşeler çalışmaya devam eder. Hiçbir izin gerekmez, Mac App Store sürümünde de.

Dock’u bilerek taşımak için ⌥ tuşunu basılı tutun ve imleci diğer ekranın kenarına doğru itin. Dock o ekrana geçer ve bundan sonra orada kalır.

İkinci anahtar olan “Dock’u geri getir”, uykudan sonra veya ekranlar değişince Dock’u kendiliğinden kendi ekranına geri götürür. “Erişilebilirlik” izni gerektirir ve Mac App Store sürümünde yoktur. İki anahtar da varsayılan olarak kapalıdır.

---

## <a id="v1.39.4"></a>Kırmızı düğme artık arşivleri durdurmuyor

<sub>1.39.4 · 13 Ekim 2026</sub>

Önceden parola penceresi kırmızı düğmeyle kapatıldığında pikapik, yeniden başlatılana kadar arşiv açmıyor ve oluşturmuyordu. Bu sorun giderildi.

Parola penceresindeki ve yeni arşiv penceresindeki kırmızı düğme artık tam olarak “Vazgeç” gibi çalışıyor ve sonraki arşiv hemen açılıyor. VoiceOver artık Ayarlar › Hakkında bölümündeki güncelleme düğmesini kendi adıyla okuyor.

---

## <a id="v1.39.3"></a>Evcil dostunuz ritminize uyuyor

<sub>1.39.3 · 13 Ekim 2026</sub>

Siz yazarken evcil dostunuz canlanır ve kıvrak adımlarla tıpış tıpış yürür. Mac’inizden uzaklaştığınızda uykusu gelir, oturur ve uyuklar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.3/pet-rhythm-dark.png"><img src="../media/whats-new/1.39.3/pet-rhythm-light.png" width="340" alt=""></picture>

Klavyeye de fareye de yaklaşık 40 saniye dokunmadığınızda göz kapakları ağırlaşır, bir buçuk dakika sonra da mışıl mışıl uyur ve üstünden küçük z harfleri süzülerek yükselir. Bir tuşa basın ya da fareyi oynatın; uyanır, kalkar ve yoluna devam eder. Kestirirken sessiz kalır ve daha az enerji harcar.

pikapik ne yazdığınıza asla bakmaz. Yalnızca bir tuşa en son basıldığından ya da farenin en son kıpırdadığından bu yana ne kadar zaman geçtiğini kontrol eder, tıpkı macOS’un ekranı karartmadan önce yaptığı gibi. Bu yüzden hiçbir izin gerekmez. Evcil dostunuz hep canlı kalsın mı istiyorsunuz? Evcil dost ayarlarında “Ritminize uyar” anahtarını kapatın.

**Deneyin:** Ayarlar › Evcil Dost › Ritminize uyar

---

## <a id="v1.39.2"></a>Eşzamanlanan ayarlar artık pikapik klasöründe

<sub>1.39.2 · 13 Ekim 2026</sub>

Ayarlarınızı iCloud ile eşzamanlıyorsanız, artık iCloud Drive’da pika-tools yerine pikapik adlı klasörde duruyorlar ve pikapik onları oraya kendisi taşıyor.

<img src="../media/icon.png" width="128" height="128" alt="">

Hiçbir şey yapmanıza gerek yok: ayarlarınız olduğu gibi kalır ve taşındıktan sonra eski klasör kaybolur. İçine kendi dosyalarınızı koyduysanız klasör yerinde kalır. Birden fazla Mac’i eşzamanlıyorsanız, ayarları paylaşmaya devam etmeleri için her birinde pikapik’i güncelleyin.

**Düzeltilenler**

- pikapik’i Homebrew ile tamamen kaldırmak (brew uninstall --zap) artık son kaldırılan uygulamaların listesini de siliyor.
- Bu sayfadaki eski yazılar artık uygulamayı pikapik olarak anıyor.

---

## <a id="v1.39.1"></a>Arşiv pencerelerinde alışık olduğunuz başlık çubuğu

<sub>1.39.1 · 13 Ekim 2026</sub>

Arşiv pencerelerinde yine macOS’in alışık olduğunuz başlık çubuğu ve solda üç yuvarlak düğme var.

Mac’in her yerinde olduğu gibi bir pencereyi üst kısmından sürükleyebilirsiniz. Yeni arşiv penceresinde ve parola penceresinde kırmızı düğme, hiçbir şey oluşturmadan ya da açmadan pencereyi kapatır. Pencerede işe yaramayan düğmeler gri görünür. Küçük kopya oluşturma ya da dosya dönüştürme sırasında ilerlemeyi gösteren pencerede de artık aynı düğmeler var. “Arşivleri bu uygulamayla aç” anahtarı artık ZIP ve 7Z dosyalarını daha önce hangi uygulamanın açtığını hatırlıyor ve kapattığınızda dosyaları o uygulamaya geri veriyor.

---

## <a id="v1.39.0"></a>Yeni arşiv pencereleri ve iki kez yazılan parola

<sub>1.39.0 · 13 Ekim 2026</sub>

Yeni bir arşive parola koyduğunuzda artık onu iki kez yazıyorsunuz; böylece bir yazım hatası sizi kendi dosyalarınızın dışında bırakmaz.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.0/archive-password-dark.png"><img src="../media/whats-new/1.39.0/archive-password-light.png" width="340" alt=""></picture>

Parolalar eşleşince alanların altında yeşil, eşleşmeyince kırmızı bir satır belirir ve “Oluştur” onlar aynı olana kadar bekler.

Tüm arşiv pencerelerinin görünümü yenilendi: büyük bir simge, parola için tek bir anahtar ve dosya adlarının ZIP’teki gibi görünür mü kalacağını, yoksa 7Z’deki gibi onların da mı gizleneceğini söyleyen kısa bir satır. macOS 26’da düğmeler Liquid Glass’tan yapılmıştır.

Kurulum da kolaylaştı: GitHub’daki pikapik sayfasının başındaki komut, Mac’inizde başka hiçbir şeye ihtiyaç duymuyor. pikapik’i yalnızca indirilen dosya geliştiricisi tarafından imzalanmışsa ve Apple’ın kötü amaçlı yazılım denetiminden geçmişse kurar.

---

## <a id="v1.38.2"></a>App Store sürümünün yanında daha güvenli güncellemeler

<sub>1.38.2 · 12 Ekim 2026</sub>

Mac’inizde App Store’dan yüklenmiş pikapik de varsa, GitHub sürümü artık olduğu yerde güncellenir ve App Store sürümüne dokunmaz.

Önceden, GitHub sürümü hâlâ eski adını (pika-tools) taşıyorsa ve Homebrew ile kurulmadıysa güncelleme kurulmuyor, bunun yerine App Store sürümü açılıyor ve pikapik’in girişte açılması kapatılıyordu.

---

## <a id="v1.38.1"></a>Daha sağlam bir Finder menüsü

<sub>1.38.1 · 12 Ekim 2026</sub>

pikapik’in Finder’daki sağ tık menüsü öğeleri artık bir disk bağladığınızda, bir disk görüntüsü açtığınızda, Mac’inizi uykudan uyandırdığınızda ya da Finder’a geçtiğinizde kaybolmuyor.

Nadir durumlarda, bu öğeleri gösteren yardımcı program tam o anda kapanıyordu.

---

## <a id="v1.38.0"></a>Arşivler artık Finder’da açılıyor ve oluşturuluyor

<sub>1.38.0 · 12 Ekim 2026</sub>

Yeni “Finder’da Arşivler”, macOS’un açamadığı RAR gibi arşivleri açar ve sağ tık menüsünden ZIP ile 7Z oluşturur.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/archive-dark.png"><img src="../media/archive-light.png" width="340" alt=""></picture>

Ayarlar › Finder sayfasını açın ve “Finder’da Arşivler” anahtarını açın. Bir arşive sağ tıklayıp “Arşivden Çıkar” komutunu seçin; dosyaları hemen yanında belirir. Başka bir dosyaya veya klasöre sağ tıklayıp “Arşiv Oluştur…” komutunu seçin; ZIP, 7Z, TAR.GZ veya TAR.XZ elde edersiniz. ZIP ve 7Z parolalı olabilir, her arşiv de parçalara bölünebilir; örneğin e-posta için 15 MB’lık parçalar. Bu şekilde hazırlanan bir ZIP’te sistemin eklediği gizli dosyalar olmaz ve her dildeki dosya adları okunur kalır.

pikapik, macOS’un açamadıklarını da açar: birkaç dosyaya bölünmüş olsa bile RAR, parolayla korunan 7Z, ZIPX, CAB, LZH, ARJ, ZST, WIM ve daha fazlası. Çift tıklayınca pikapik’te açılırlar. Eski ZIP’lerdeki dosya adları, örneğin Kiril, Japonca veya Çince olanlar, okunur çıkar. “Arşivleri bu uygulamayla aç” anahtarı ZIP ve 7Z’yi de pikapik’e verir; TAR ve GZ ise bunları zaten iyi işleyen yerleşik arşiv uygulamasında kalır.

Bir pencere parolayı sorar, “Durdur” her işi iptal eder ve hasarlı bir arşivden pikapik hâlâ okunabilen her şeyi çıkarır. Devasa bir boyuta şişecek bir arşivi çıkarmadan önce sorar, kendi klasörünün dışına yazmaya çalışan arşivleri de engeller. Mac App Store sürümünde yoktur. Bir arşivi seçip Boşluk tuşuna basarak içindekileri önizleyebilirsiniz.

---

## <a id="v1.37.3"></a>FPS etiketi izni doğru yerde istiyor

<sub>1.37.3 · 12 Ekim 2026</sub>

FPS etiketi için Ekran Kaydı artık diğer tüm izinlerle birlikte İzinler sayfasında verilir.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Bir oyunun karelerini saymak için “FPS’yi göster” Ekran Kaydı iznine ihtiyaç duyabilir. Eskiden pikapik bunu doğrudan Oyunlar sayfasında isterdi. Şimdi öbür izinlerin yanında duruyor: “FPS’yi göster” buna ihtiyaç duyduğunda Ayarlar’daki İzinler sayfasında “Ekran Kaydı” satırı belirir ve orada “İzin Ver”e tıklarsınız.

Oyunlar sayfasında artık anahtarın altında yalnızca her zamanki satır görünür: “İzin gerekiyor. İzin vermek için tıklayın.” Satırdaki “İzin Ver” düğmesi sizi doğrudan “Ekran Kaydı” satırına götürür. “FPS’yi göster” açıldığında artık kendiliğinden soru çıkmaz, oyun sırasında da pikapik yine hiçbir şey istemez.

---

## <a id="v1.37.2"></a>Apple tarafından doğrulandı

<sub>1.37.2 · 12 Ekim 2026</sub>

pikapik artık doğrulanmış bir Apple geliştiricisi tarafından imzalandı ve Apple tarafından kontrol edildi. Bu yüzden macOS ilk açılışta artık uyarı vermez.

Bu güncellemeden sonra macOS, pikapik’e verdiğiniz izinleri, örneğin Erişilebilirlik, Girdi İzleme veya Tam Disk Erişimi’ni yeniden isteyebilir. Sistem Ayarları › Gizlilik ve Güvenlik bölümünden bir kez daha izin verin. Fan kontrolünü kullanıyorsanız pikapik ayarlarından yeniden izin verin; macOS parolanızı bir kez sorar.

---

## <a id="v1.37.1"></a>FPS etiketi oyununuzdan geri kalmıyor

<sub>1.37.1 · 12 Ekim 2026</sub>

Oyun penceresini taşıyın; FPS etiketi artık onunla birlikte hareket ediyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Eskiden etiket, hareket eden bir pencereye yaklaşık saniyede bir kez yetişiyor ve geride kalıyordu. Artık pencereyi ekranın her karesinde kontrol ediyor ve en fazla saniyenin birkaç binde biri kadar geride kalıyor. Pencere dururken daha seyrek kontrol ediyor, bu yüzden oyun sırasında Mac’inizi neredeyse hiç yormuyor. Ayrıca pencerenin bir kısmı ekranın kenarından taştığında artık başka bir yere atlamıyor.

Satranç gibi sakin bir oyun 0 gösteriyorsa sorun yok: Bu tür oyunlar yalnızca bir şey hareket ettiğinde yeni bir resim çizer. Bir taş kayarken sayı yükselir, tahta durunca yeniden 0’a döner.

---

## <a id="v1.37.0"></a>Oyununuzun akıcılığını görün

<sub>1.37.0 · 12 Ekim 2026</sub>

Yeni “FPS’yi göster” anahtarı, oyununuzun bir köşesine küçük bir sayaç koyar; oyunun ne kadar akıcı çalıştığını hemen görürsünüz.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Ayarlar › Oyunlar sayfasına gidin ve “FPS’yi göster” anahtarını açın. Oyun Modu açıkken herhangi bir oyunun bir köşesinde sayı gösteren küçük, koyu bir etiket görünür. FPS, saniyedeki kare sayısı demektir: oyunun her saniye kaç resim çizdiği; sayı ne kadar yüksekse oyun o kadar akıcıdır. Etiketin yerini seçmek için anahtarın üstündeki resimde bir köşeye tıklayın.

Tıklamalar etiketin içinden geçer ve etiket oyun penceresini takip eder. Tire, ilk karelerin henüz gelmediği anlamına gelir; soluk bir 0 ise oyunun çizmeyi bıraktığı anlamına gelir. “FPS’yi göster” siz açana kadar kapalıdır.

macOS 27’de oyunların çoğunu macOS kendisi sayar, bu yüzden izin gerekmez. Bazı oyunlar, çoğunlukla eskiler, yalnızca ekran kaydı üzerinden sayılabilir ve bu durumda sayı ekranın yenileme hızını aşamaz. macOS 14–26’da ve Mac App Store sürümünde tüm oyunlar bu şekilde sayılır; bu yüzden “FPS’yi göster” açıldığında pikapik “Ekran Kaydı” izni ister. Hiçbir görüntü saklanmaz veya gönderilmez.

---

## <a id="v1.36.0"></a>Uygulamaları tasasızca kaldırın

<sub>1.36.0 · 12 Ekim 2026</sub>

Yeni Uygulamaları Kaldır sayfası, bir uygulamayı tüm dosyalarıyla kaldırır; fikrinizi değiştirirseniz hepsini geri koyar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/uninstaller-dark.png"><img src="../media/uninstaller-light.png" width="340" alt=""></picture>

Ayarlar › Uygulamaları Kaldır sayfasını açın ve bir uygulama seçin ya da bir uygulamayı resmin üzerine bırakın. pikapik, uygulamanın Mac’inizde sakladığı her şeyi, her dosyanın listede olma nedeniyle birlikte gösterir. Açıkça uygulamaya ait olan dosyalar işaretlidir, yalnızca ilgili olabilecekler değildir. “Çöp Sepeti’ne taşı” düğmesine tıklayın; her şey Çöp Sepeti’ne gider, yani hiçbir şey kalıcı olarak silinmez.

Fikrinizi mi değiştirdiniz? “Geri koy” düğmesine tıklayın, her şey eski yerine döner. Son on kaldırma, dosyaları Çöp Sepeti’nde durduğu sürece “Son kaldırılanlar” bölümünde bekler. “Uygulamayı sıfırla” uygulamayı bırakır; yalnızca kayıtlı verilerini, ayarlarını ve geçici dosyalarını kaldırır, uygulama düzgün çalışmazsa işe yarar.

Bir uygulamayı Çöp Sepeti’ne kendiniz mi taşıdınız? Sayfa bu uygulamaları ve bıraktıkları dosyaları da listeler; bir anahtarı açarsanız pikapik, bir uygulama Çöp Sepeti’ne her gittiğinde temizlik önerir. Siz seçmeden hiçbir şey kaldırılmaz. Her şeyi görmek için sayfanın Tam Disk Erişimi iznine ihtiyacı vardır.

---

## <a id="v1.35.0"></a>Evcil dostunuzu giydirin

<sub>1.35.0 · 12 Ekim 2026</sub>

Evcil dostunuzun artık bir gardırobu var, birlikte oynadıkça giyecek yeni şeyler kazanıyorsunuz.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.35.0/wardrobe-dark.png"><img src="../media/whats-new/1.35.0/wardrobe-light.png" width="340" alt=""></picture>

Ayarlar › Evcil Dost sayfasını açın ve evcil dostunuzun neler giyeceğini seçin: şapkalar, gözlükler, atkılar, tişörtler, ayakkabılar, pelerinler ve hatta kanatlar. Evcil dostunuz hemen giyer. Birkaç parça ücretsizdir, gerisi birlikte oynarken gelen ödüllerdir: evcil dostunuzu tutup fırlatın, topu tekmeleyin, pencerelere tırmanışını ve konuşmasını izleyin ya da günden güne yalnızca ona eşlik edin. Bir ödül kazandığınızda evcil dostunuz size söyler.

Hazır kombinler evcil dostunuzu tek tıkla baştan aşağı giydirir: büyücü, korsan, astronot, süper kahraman, kral ve daha fazlası. Bir kombinin tüm parçalarını kazandığınızda o kombin hazır olur.

Yalnızca adımlar, fırlatmalar ve birlikte geçen günler gibi basit sayılar tutulur. Bunlar Mac’inizde kalır, hiçbir yere gönderilmez ve istediğiniz zaman Ayarlar › Evcil Dost sayfasından silebilirsiniz.

---

## <a id="v1.34.0"></a>Oyunlarda fare ve izleme dörtgeni

<sub>1.34.0 · 12 Ekim 2026</sub>

Kaydırmalar, kıstırma hareketleri ve etkin köşeler artık klavye kısayolları gibi sizi oyundan çıkarmıyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.34.0/pointer-shortcuts-dark.png"><img src="../media/whats-new/1.34.0/pointer-shortcuts-light.png" width="340" alt=""></picture>

Ayarlar › Oyunlar › Diğer oyun ayarları altında “Fare ve izleme dörtgeni” adlı bir grup var. Yalnızca Mac’inizde macOS’ta açık olanları, Apple’ın kendi adlarıyla ve her biri için küçük bir çizimle gösterir: fare düğmesindeki kısayollar, masaüstleri ve tam ekran uygulamalar arasında kaydırma, Mission Control ve App Exposé, uygulamalar için kıstırma ve masaüstü için parmakları açma, Bildirim Merkezi için sağ kenardan kaydırma ve her etkin köşe ile yaptığı eylem. Bir oyun öndeyken bunlar duraklatılır; böylece yanlışlıkla yapılan bir kaydırma ya da ekran köşesine değen imleç sizi oyundan çıkaramaz. Oyunun içindeki hareketler çalışmaya devam eder. Her biri her zamanki gibi çalışacak şekilde ayarlanabilir.

---

## <a id="v1.33.2"></a>Kısayol grupları anında açılıyor

<sub>1.33.2 · 11 Ekim 2026</sub>

En uzun sistem kısayolu grubu bile hemen açılıyor ve her satırın anlaşılır bir adı var.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Eskiden onlarca satırlık bir grup açıldığında ayarlar penceresi bir an donuyordu, çünkü tüm satırlar ve hareketli önizlemeleri aynı anda oluşturuluyordu. Artık yalnızca ekranda görünen satırlar ve yakınındaki birkaç satır oluşturuluyor. “Sistem eylemi” ve bir sayıdan oluşan satırlar da kalktı: Dikte, Siri, parlaklık ve büyütme tuşları gerçek adlarıyla görünüyor; macOS’un ad vermediği eylemler gizleniyor ama oyunlarda eskisi gibi duraklatılmaya devam ediyor.

---

## <a id="v1.33.1"></a>Kısayol grupları takılmadan açılıyor

<sub>1.33.1 · 11 Ekim 2026</sub>

Önizlemelerle dolu uzun bir liste açıldığında Oyunlar sayfası akıcı kalıyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Bir sistem klavye kısayolları grubunu açmak, her satır ve önizlemesi birkaç kez hesaplandığı için ayarlar penceresini üç saniyeye kadar donduruyordu. Artık her satır yalnızca bir kez hesaplanıyor; gruplar neredeyse anında açılıyor.

---

## <a id="v1.33.0"></a>Tüm izinler tek yerde

<sub>1.33.0 · 11 Ekim 2026</sub>

Ayarlar › İzinler artık pikapik’in kullandığı her şeyi listeliyor ve istediğiniz izni geri almanızı sağlıyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.33.0/permissions-dark.png"><img src="../media/whats-new/1.33.0/permissions-light.png" width="340" alt=""></picture>

Ayarlar › İzinler artık pikapik’in kullandığı her izni gösteriyor: Erişilebilirlik ve Girdi İzleme’den Fan kontrolü, Finder Eklentileri, iCloud Drive ve Tam Disk Erişimi’ne kadar. Her satır ne işe yaradığını tek cümleyle anlatır; açıksa yeşil bir onay işareti, eksikse turuncu bir çarpı görünür.

Her satırda tek bir düğme var: izin eksikse İzin Ver, açıksa Kapat. Böylece herhangi bir izni Sistem Ayarları’nda aranmadan hemen oradan geri alabilirsiniz. Erişilebilirlik ve Girdi İzleme için pikapik önce sorar, sonra bu izinler olmadan yeniden başlar.

Henüz vermediğiniz bir izne ihtiyaç duyan araç soluk, gri görünür. Üzerine tıkladığınızda İzinler, doğru satır vurgulanmış olarak açılır; geriye tek bir İzin Ver tıklaması kalır.

**Deneyin:** Ayarlar › İzinler’i açıp her satıra göz atın. Gri bir araca tıklayarak ihtiyaç duyduğu izne doğrudan geçebilirsiniz.

---

## <a id="v1.32.2"></a>Daha güvenli kurulum, güncellemeler uygulamayı asla kaybetmez

<sub>1.32.2 · 11 Ekim 2026</sub>

Kurulumu, güncellemeyi ve kaldırmayı daha güvenli yapan bir dizi düzeltme.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Fan yardımcısı artık daha özenle kuruluyor ve başlamadan önce doğrulanıyor. Bir güncelleme kopyalanamazsa mevcut pikapik olduğu gibi kalır. Kaldırırken fan yardımcısı da silinir; tuş tekrarı ayarınız, Dock köşeleri ve sistem kısayolları eski haline döner.

Bir araç yeniden başladığında basılı tutulan tuşlar artık takılı kalmaz; “Basılı tutulan tuşu tekrarla” kapatılınca kendi vurgu menüsü ayarınız geri gelir. Ekran uykudayken veya kilitliyken evcil hayvan dinlenir; archive.tar.gz kopyası artık archive 2.tar.gz adını alır.

---

## <a id="v1.32.1"></a>Elle fan hızı ilk denemede tutuyor

<sub>1.32.1 · 11 Ekim 2026</sub>

Fanlar bölümünde Manuel seçmek artık Otomatik'e geri dönmüyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Bazen Manuel'e ilk dokunuş, fanları bir güvenlik uyarısıyla Otomatik'e döndürüyordu ve ancak ikinci dokunuş işe yarıyordu. Artık Manuel ilk denemeden itibaren tutuyor.

Bir fan yine de kendiliğinden Manuel'den çıkarsa pikapik onu gerçekten Otomatik'e alır; yani gördüğünüz her zaman Mac'inizin yaptığıyla aynıdır.

Yeniden izin vermeniz gerekmez. Güncelleyin, hemen çalışır.

**Deneyin:** Ayarlar › Fanlar'ı açın ve Manuel'i seçin.

---

## <a id="v1.32.0"></a>Fanlarınızın ne kadar hızlı döndüğünü görün

<sub>1.32.0 · 11 Ekim 2026</sub>

Yeni Fanlar sekmesi her fanı canlı gösterir ve hızını seçmenizi sağlar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Fanların artık Ayarlar’da kendi sekmesi ve menüde kendi satırı var. Her fanın şu an ne kadar hızlı döndüğünü gerçek zamanlı görürsünüz, yanında da onunla birlikte dönen küçük bir fan vardır.

Otomatik’te bırakırsanız Mac’iniz her zamanki gibi kendisi karar verir. Ya da Elle’yi seçip tek bir kaydırıcıyla istediğiniz hızı ayarlayın. İlk seferde yönetici parolanızla bir kez izin vermeniz yeterli.

Güvenli olacak şekilde tasarlandı. pikapik’ten çıktığınızda, Mac’iniz uykuya geçtiğinde, pikapik beklenmedik şekilde kapandığında ya da Mac’iniz ısındığında fanlar Otomatik’e döner.

**Deneyin:** Ayarlar › Fanlar’ı açıp hıza bakın. Kaydırıcıyı denemek için Elle’yi seçin.

---

## <a id="v1.31.4"></a>Ayrıntılar gerektiğinde

<sub>1.31.4 · 11 Ekim 2026</sub>

Daha sade bir oyun sayfası ve tek bir arama.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.4/game-choices-dark.png"><img src="../media/whats-new/1.31.4/game-choices-light.png" width="340" alt=""></picture>

Her mod ne yaptığını açılır listede açıklar. Liste kapandığında sayfada yalnızca seçilen ad kalır.

Eylem adını tekrarlayan açıklamalar kaldırıldı. Yararlı ek bilgiler korundu.

Genel arama sistem eylemlerini ad, anlam ve tuşlara göre bulur. Bir sonuç tam olarak o ayarı açar ve vurgular.

**Deneyin:** Genel aramada bir eylem bulun ve mod listesini açın.

---

## <a id="v1.31.3"></a>Oyun ayarlarında ortak görünüm

<sub>1.31.3 · 11 Ekim 2026</sub>

Tutarlı önizlemeler ve daha açık kısayol seçenekleri.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.3/game-preview-dark.png"><img src="../media/whats-new/1.31.3/game-preview-light.png" width="340" alt=""></picture>

Her kısayol artık oyun korumaları ve diğer ayar sayfalarıyla aynı geniş önizlemeyi kullanır. Altında açıklama, kontroller ve seçilen seçeneğin açıklaması bulunur.

«Oyun Modu kurallarına uy». Kısa bir kısayol dili menüsüz değiştirir. Basılı oyun tuşları yanlışlıkla dil değiştirmeyi önler.

«Oyunlarda devre dışı bırak». Oyun öndeyken bu macOS eylemi devre dışıdır. Oyundan ayrılınca eskisi gibi çalışır. «Oyunlarda izin ver». macOS eylemi normal şekilde çalıştırır; pencere açsa veya odağı oyundan alsa bile.

**Deneyin:** Ek oyun ayarlarını açın, sistem kontrollerini genişletin ve oynarken bir eylemin nasıl çalışacağını seçin.

---

## <a id="v1.31.2"></a>Daha anlaşılır oyun ayarları

<sub>1.31.2 · 11 Ekim 2026</sub>

Korumayı ayarlayın ve Mac’inizin kısayollarını keşfedin.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.2/game-settings-dark.png"><img src="../media/whats-new/1.31.2/game-settings-light.png" width="340" alt=""></picture>

Tekrarlanan klasörler yerine sekiz anlaşılır konu var. Her başlıkta ad, açıklama, simge ve sayı bulunur. Açmak için satırın herhangi bir yerine tıklayın.

Her eylem, animasyonlu önizlemenin yanında ne yaptığını açıklar. Geçerli tuşlar ve oyunlardaki davranış ayrı bir satırda yer alır. Arama açıklamaları da bulur.

Atanmamış tuşlar için Sistem Ayarları’na açık bir bağlantı bulunur. Genel oyun korumaları ayrı bir bölümde toplanır ve seçimleriniz korunur.

**Deneyin:** Diğer oyun ayarlarını açın, bir konuyu genişletin ve eylemin açıklamasını önizlemeyle karşılaştırın.

---

## <a id="v1.31.1"></a>Oyunlarda dil hareketleri

<sub>1.31.1 · 11 Ekim 2026</sub>

Varsayılan olarak sade, gerektiğinde tüm sistem kataloğu yanında.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/input-switch-dark.png"><img src="../media/input-switch-light.png" width="340" alt=""></picture>

macOS dil kısayolları atanmamış veya kapatılmış olsa bile pikapik dil hareketi oyunda çalışır.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Otomatik, pencere açan veya odağı değiştiren eylemleri duraklatır. Hızlı ve kasıtlı dil kısayolu sistem penceresi olmadan kaynağı değiştirir. Basılı hareket tuşları önceliklidir; koşmak ve zıplamak yanlışlıkla dili değiştirmez.

Her eylem aranabilir katalogda ayarlanabilir. Dil arka planda değişebilir; diğer eylemler duraklatılabilir veya normal çalışabilir. Seçimler eşitlenir. Tuşları izleyen diğer uygulamalar ayrı gösterilir. Çıkmaya Zorla kullanılabilir kalır.

**Deneyin:** ⌥ basılıyken ⇧ tuşuna basın: sonraki dil. ⇧ basılıyken ⌥ tuşuna basın: önceki dil

---

## <a id="v1.31.0"></a>Oyun Modu Mac’inin kısayollarını biliyor

<sub>1.31.0 · 11 Ekim 2026</sub>

Varsayılan olarak sade, gerektiğinde tüm sistem kataloğu yanında.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Oyun Modu’nu aç ve oyna. Diğer oyun ayarları, Mac’in yayımladığı kataloğu, güncel tuşları ve her eylem için animasyonlu önizlemeyi içerir.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Otomatik, pencere açan veya odağı değiştiren eylemleri duraklatır. Hızlı ve kasıtlı dil kısayolu sistem penceresi olmadan kaynağı değiştirir. Basılı hareket tuşları önceliklidir; koşmak ve zıplamak yanlışlıkla dili değiştirmez.

Her eylem aranabilir katalogda ayarlanabilir. Dil arka planda değişebilir; diğer eylemler duraklatılabilir veya normal çalışabilir. Seçimler eşitlenir. Tuşları izleyen diğer uygulamalar ayrı gösterilir. Çıkmaya Zorla kullanılabilir kalır.

**Deneyin:** Ek ayarları aç, ekran görüntüsü veya dil kısayolunu ara ve koruma açıkken ve kapalıyken önizlemeyi karşılaştır.

---

## <a id="v1.30.14"></a>Kısayol bağlantıları çökmeden açılıyor

<sub>1.30.14 · 11 Ekim 2026</sub>

Kapalı bir kısayola tıklamak artık pikapik’i kapatmıyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Oyunlar sayfasında tuş atanmamış bir kısayola da tıklayabilirsin. Sistem Ayarları güvenle açılır.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Önceden pencere açılırken pikapik değişen aynı satırı iki kez okuyabiliyordu. Metin iki okuma arasında kaybolursa uygulama çöküyordu.

Her satır artık bir kez okunur. Eksik metin atlanır. Düzeltme diğer sayfalardaki kısayol bağlantılarını da kapsar.

**Deneyin:** Oyunlar sayfasında kapalı bir kısayola tıkla.

---

## <a id="v1.30.13"></a>Control’ü basılı tut ve oynamaya devam et

<sub>1.30.13 · 10 Ekim 2026</sub>

Control artık dil değişiminin oyundaki Boşluk tuşunu almasına izin vermiyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Koşmak için Control’ü basılı tut ve zıplamak için Boşluk’a bas. Oyun Modu’nda Control+Boşluk ve Control+Option+Boşluk ile dil değiştirme duraklatılır.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Control kullanan veya Command olmadan Shift ve Option kullanan diğer macOS kısayolları, kendi atadıkların da dahil, duraklatılır. Basılan, bırakılan ve basılı tutulan tuşlar oyuna birlikte ulaşır.

pikapik’in dil hareketi ve oyun değiştiricilerini kullanan çıkış kısayolları da karışmaz. Oyundan çıkınca sistem kısayolları eski haline döner.

**Deneyin:** Control’ü basılı tut, hareket et ve Boşluk’a birkaç kez bas. Sonra oyundan çıkıp dili normal şekilde değiştir.

---

## <a id="v1.30.12"></a>Oyununu Etkinlik Monitörü’nden sürükle

<sub>1.30.12 · 10 Ekim 2026</sub>

Oyun Modu Etkinlik Monitörü’nden sürüklenen işlemleri kabul ediyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Oyunun işlemini bul ve satırını Ayarlar → Oyunlar içindeki Oyunların alanına sürükle.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Dock’ta normal simgesi olmayan Java oyunları da çalışır. Önceden bu satırlar dosya yerine işlem numarası ve adı içerdiği için yok sayılıyordu.

Oyun sonraki açılışlar için kaydedilir. Minecraft kendi adıyla görünür. Numara ve ad çalışan bir işlemle eşleşmelidir.

**Deneyin:** Açık Minecraft’ın java satırını Oyunların alanına sürükle.

---

## <a id="v1.30.11"></a>Oyununu çalışırken ekle

<sub>1.30.11 · 10 Ekim 2026</sub>

Oyun eklerken açık oyunlar artık ilk sırada görünüyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Ayarlar → Oyunlar → Oyun Ekle bölümünü aç ve çalışan oyununa tıkla. Java ve diğer ortamlarla çalışan oyunlar, .app dosyası olmasa da burada görünür. Minecraft, java yerine Minecraft adıyla görünür.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Dock’taki uygulamaların artık ayrı bir açılır listesi var. Böylece açık oyununu hemen bulabilirsin.

Diğer… ve sürükleyip bırakma, uygulamaların yanında oyunun çalıştırılabilir dosyasını da kabul eder. Ekledikten sonra oyuna geçtiğinde Oyun Modu açılır.

**Deneyin:** Oyununu açık bırak, Oyun Ekle’yi seç ve simgesine tıkla. Klasör aramana gerek yok.

---

## <a id="v1.30.10"></a>Evcil dostun zıplarken görünür kalıyor

<sub>1.30.10 · 10 Ekim 2026</sub>

Evcil dostun, Dock olmayan bir ekranda zıpladığında artık pencerelerin arkasında kaybolmuyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Eskiden Dock başka bir ekrandaysa ya da gizliyse, evcil dostun pencerelerin arkasına zıplıyor ve yere inene kadar görünmüyordu. Artık yerden ayrıldığı anda, Dock olsun olmasın her ekranda pencerelerin önünde görünüyor. Top da öyle.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Evcil dostunun yalnızca kenarına değen bir pencere artık onu zıplarken gizlemiyor. Evcil dostun bir pencerenin arkasında yalnızca pencere onu gerçekten örttüğünde kalıyor, izlediğin bir video gibi.

Yerde ise evcil dostun ve topu, eskisi gibi pencerelerinin arkasında dolaşıyor.

**Deneyin:** Dock’u otomatik gizlenecek şekilde ayarla ya da başka bir ekrana taşı, sonra bir pencerenin yanında Boşluk tuşuna bas. Evcil dostun pencerenin önünde zıplar.

---

## <a id="v1.30.9"></a>Tam ekran senin, top da kurallara uyuyor

<sub>1.30.9 · 10 Ekim 2026</sub>

Evcil dostun artık tam ekran videoya karışmıyor, top da orada olmayan şeylere çarpmıyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Eskiden tam ekran video izlerken evcil dostun arada bir ortaya çıkabiliyordu. Artık pikapik bir ekranın tam ekranda olup olmadığını doğrudan macOS’e soruyor ve geçiş bitince bir kez daha bakıyor. Tam ekrandan çıkana kadar evcil dostun ve topu saklı kalıyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Top artık boşluktan sekmiyor. Dock’un üstündeki görünmez bir duvara çarpmak yerine üzerinden uçup geçiyor. Fare artık topa yalnızca imleç ona gerçekten dokunduğunda vuruyor. Hafif bir dokunuş topu yuvarlıyor, hızlı bir hamle onu uçuruyor. Evcil dostun ya da topu bir pencerenin arkasına saklandıysa, o pencerenin üstündeki fare onlara dokunmuyor.

Masaüstünde bir dosyayı sürüklemek artık evcil dostuna basamak kurmuyor. Bunu yalnızca bir seçim çerçevesi yapıyor.

**Deneyin:** Tam ekran bir video izle ve birkaç kez boşluk tuşuyla durdur. Evcil dostun görünmeyecek. Sonra fareyle topa hızlıca vur.

---

## <a id="v1.30.8"></a>Oyun oynarken ekran köşeleri sessiz kalıyor

<sub>1.30.8 · 10 Ekim 2026</sub>

Oyun Modu’nda fareyi ekranın kenarlarına ve köşelerine götürmek artık etkin köşeleri tetiklemiyor ve gizli Dock’u çıkarmıyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Önceden oyunun ortasında fare ekranın bir köşesine ya da kenarına gidince etkin bir köşe tetiklenebiliyor ya da gizli Dock açılabiliyordu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Artık Oyun Modu, sen oynarken etkin köşeleri ve gizli Dock’u kapatıyor. Oyundan çıktıktan birkaç saniye sonra ya da pikapik’i kapattığında tam eskisi gibi geri geliyorlar.

Üstelik imleç oyunun olduğu ekranın kenarında artık takılmıyor.

**Deneyin:** Oyun Modu’nu aç, bir oyun başlat ve fareyi ekranın bir köşesine götür. Hiçbir şey açılmaz.

---

## <a id="v1.30.7"></a>Evcil dostun artık videonun önüne çıkmıyor

<sub>1.30.7 · 10 Ekim 2026</sub>

Evcil dostun ya da topu bir pencerenin arkasındaysa, zıplasa ya da uçsa bile orada kalıyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Önceden evcil dostun ya da topu bir videonun veya oyunun arkasına saklanmışken bir zıplama ya da uçuş onu tam izlediğin şeyin üstüne çıkarabiliyordu. Videoyu duraklatmak için Boşluk tuşuna basmak da evcil dostunu ortaya çıkarıyordu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Artık ne yaparlarsa yapsınlar, onları örten pencerenin arkasında kalıyorlar. Firefox’ta tam ekran video da onları hemen saklıyor.

Sıradan pencerelerin arkasına ise eskisi gibi saklanıyorlar.

**Deneyin:** Ekranın altını kaplayan büyük bir pencerede video aç ve duraklatmak için Boşluk tuşuna bas. Evcil dostun videonun arkasında kalır.

---

## <a id="v1.30.6"></a>Tam ekranda evcil dostun her yerde mola veriyor

<sub>1.30.6 · 10 Ekim 2026</sub>

Herhangi bir uygulama tam ekrandayken evcil dostun ve topu artık tüm ekranlarda saklanıyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Önceden bir videoyu ya da oyunu tam ekran açtığında evcil dostun ve topu bazen başka bir ekrana kaçıp orada oynamaya devam ediyordu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Artık herhangi bir uygulama tam ekrandayken tüm ekranlarında saklanıyorlar. Tam ekrandan çıkınca hemen geri geliyorlar.

Sıradan pencerelerin arkasına ise eskisi gibi saklanıyorlar.

**Deneyin:** İki ekranın varsa birinde bir videoyu tam ekran aç. Evcil dostun ve topu ikisinden de kaybolur, tam ekrandan çıkınca geri gelir.

---

## <a id="v1.30.5"></a>Video izlerken ya da oyun oynarken evcil dostun kenara çekiliyor

<sub>1.30.5 · 10 Ekim 2026</sub>

Bir uygulama tam ekrandayken evcil dostun ve topu artık saklanıyor, çentikli Mac’lerde de.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Önceden çentikli bir Mac’te evcil dostun tam ekran bir videonun ya da oyunun üstünde kalabiliyordu, top da bazen başka bir ekrandaki tam ekran uygulamanın üstünde beliriyordu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Artık bir uygulama tüm ekranı kapladığı sürece evcil dostun ve topu gözden uzakta bekliyor. Tam ekrandan çıkınca hemen geri geliyorlar.

Sıradan pencerelerin arkasına ise eskisi gibi saklanıyorlar.

**Deneyin:** Bir videoyu tam ekran aç ya da bir oyun başlat. İşin bitene kadar evcil dostun ve topu seni rahatsız etmez.

---

## <a id="v1.30.4"></a>Evcil dostun zıplarken ya da seçim kutusuyla yükselirken hep görünüyor

<sub>1.30.4 · 10 Ekim 2026</sub>

Evcil dostun ve topu havadayken artık pencerelerin arkasında kaybolmuyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Önceden evcil dostun imlecin üzerinden atladığında ya da bir seçim kutusuyla yukarı çıktığında tam boyutlu bir pencere onu kapatıyordu ve sanki kaybolmuş gibi görünüyordu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Artık evcil dostun ya da topu Dock’tan yüksekteyken pencerelerinin önünde görünüyor. Yere dönünce yeniden pencerelerin arkasına geçiyorlar.

Ve evcil dostun yine eskisi gibi Dock’un arkasında gezebiliyor.

**Deneyin:** Bir pencereyi tam boyuta getir, evcil dostun üstüne çıksın diye masaüstünde Dock’un yanında bir seçim kutusu çizmeye başla ve onu yavaşça yukarı sürükle. Evcil dostun kutunun üstünde pencerenin önünden yukarı çıkıyor.

---

## <a id="v1.30.3"></a>Evcil dostun ve topu artık Dock’un altına girmiyor

<sub>1.30.3 · 9 Ekim 2026</sub>

Evcil dostun artık Dock’un altında yürümüyor ya da uyumuyor, yani onu hep görüyorsun.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Önceden evcil dostun ve topu, kimsenin göremediği Dock’un tam altında sık sık yürüyüp dinleniyordu. Tam boyutlu bir pencereyle evcil dostun tamamen kaybolmuş gibi görünüyordu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Artık Dock onlar için bir duvar gibi. Evcil dostun Dock’un kenarında geri dönüyor, top da ona çarpıp sekiyor.

Böylece bir pencere tüm ekranı kaplasa bile evcil dostun hep Dock’un yanında görünüyor.

**Deneyin:** Bir pencereyi tam boyuta getir ve birkaç dakika izle. Evcil dostun hep Dock’un solunda ya da sağında görünüyor.

---

## <a id="v1.30.2"></a>Evcil dostun artık pencerelerin arkasında kaybolmuyor

<sub>1.30.2 · 9 Ekim 2026</sub>

Bir pencere onu kapatsa bile evcil dostun yaşamaya devam ediyor ve seçimi bıraktığında yere düşüyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Pencereler evcil dostunun yaşadığı şeridi tamamen kapattığında pikapik onu duraklatıyordu ve havada donup kalabiliyordu. Artık evcil dostun ve topu pencerenin arkasında da yaşamaya devam ediyor: yürüyor, düşüyor ve oynuyor. Yalnızca çizim mola veriyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Bir seçim kutusu evcil dostunu bir pencerenin arkasında yukarı kaldırırsa, bırakır bırakmaz aşağı düşüyor ve onu yeniden Dock’un yanında görüyorsun.

Ayrıca seçim kutusu evcil dostunu artık kendi şeridinden daha yükseğe kaldırmıyor.

**Deneyin:** Bir pencereyi tam boyuta getir, arkasında evcil dostunu bir seçim kutusuyla kaldır ve bırak. Evcil dostun düşüp Dock’un yanında beliriyor.

---

## <a id="v1.30.1"></a>Masaüstündeki seçimler yeniden çalışıyor

<sub>1.30.1 · 9 Ekim 2026</sub>

Evcil dostun ve topu yeniden seçim kutularına zıplıyor, uygulama listeleri de yalnızca uygulamalar için yanıyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Dock ya da bir uzak masaüstü uygulaması tüm ekranı kapladığında pikapik, masaüstünde çizdiğin seçim kutusunu fark etmiyordu. Artık yeniden fark ediyor; evcil dostun ve topu eskisi gibi kutunun üstüne zıplıyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Ayarlardaki uygulama listeleri yalnızca üzerlerine bir uygulama sürüklediğinde yanıyor. Diğer dosyalar yok sayılıyor: çerçeve görünmüyor ve fazladan hiçbir şey eklenmiyor. Bir uygulamayı başka dosyalarla birlikte sürüklersen yalnızca uygulama ekleniyor.

Uygulamayı bıraktığın ya da imleci uzaklaştırdığın anda çerçeve de sönüyor.

**Deneyin:** Masaüstünde bir seçim kutusu çiz ve evcil dostunun üstüne zıplamasını izle.

---

## <a id="v1.30.0"></a>Çık artık pikapik’i kapatmıyor

<sub>1.30.0 · 9 Ekim 2026</sub>

Alışkanlıkla Çık’a mı bastınız? Kısayollar, “Uyanık Tut” ve evcil dostunuz çalışmaya devam ediyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/keep-awake-dark.png"><img src="../media/keep-awake-light.png" width="340" alt=""></picture>

“Çık”ı seçtiğinizde, ⌘Q’ya bastığınızda ya da pikapik’ten Dock üzerinden çıktığınızda pencerelerini kapatır ve menü çubuğundaki simgesini gizler, ama arka planda sessizce çalışmaya devam eder: kısayollar, “Uyanık Tut” ve evcil dostunuz açık kalır. Simgeyi geri getirmek için pikapik’i yeniden açmanız yeterli.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Gerçekten çıkmak mı istiyorsunuz? Option (⌥) tuşunu basılı tutup “Çık”ı seçin ya da ⌥⌘Q’ya basın. pikapik ilk kez arka plana geçtiğinde ne olduğunu açıklar ve hemen oradan tamamen çıkmayı önerir.

Eskisi gibi mi olsun? Ayarlar › Genel’de “Çıktıktan sonra arka planda çalış”ı kapatın. Güncellemeler, dil değişikliği, oturumu kapatma, yeniden başlatma ve kapatma pikapik’ten her zaman tamamen çıkar, böylece hiçbiri onu beklemek zorunda kalmaz.

**Deneyin:** ⌘Q’ya basın, sonra simgesini geri getirmek için pikapik’i yeniden açın.

---

## <a id="v1.29.1"></a>Evcil dostun tüm ekranlarında geziyor

<sub>1.29.1 · 9 Ekim 2026</sub>

Birden fazla monitörün mü var? Evcil dostun ve topu artık nereye bakarsan oradalar ve hiç kaybolmuyorlar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Evcil dostun bir ekranın kenarına gelince yan ekrana geçiveriyor, top da arkasından yuvarlanıyor. Evcil dostu ya da topu fareyle tutup istediğin ekrana da taşıyabilirsin. Bir uygulama tam ekrana geçerse rahatsız etmemek için başka bir ekrana gidiyorlar, bir monitörü çıkarırsan ana ekrana dönüyorlar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Top artık köşede sıkışıp kalmıyor. Evcil dostun koşup topu başının üstünden geriye atıyor ve oynamaya devam ediyor.

Evcil dostun artık kaybolmuyor da. İki saniyede bir ekranda olup olmadığını kontrol ediyor; uyku, Mac’i kilitleme, masaüstü değiştirme ya da tam ekrandan sonra bir sorun olursa hemen kendiliğinden geri geliyor.

**Deneyin:** Evcil dostunu başka bir ekrana taşı ya da topu bir köşeye yuvarla.

**Düzeltilenler**

- Fırlatılan evcil dost artık zıplayamayacağı kadar yüksekteki bir seçim kutusuna konmuyor ve bu yüzden kaybolmuyor.

---

## <a id="v1.29.0"></a>Evcil dostunun artık bir topu var

<sub>1.29.0 · 9 Ekim 2026</sub>

Ekranın alt kenarında artık küçük bir futbol topu yuvarlanıyor. Evcil dostun onunla oynuyor, sen de oynayabilirsin.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Top gerçek bir top gibi yuvarlanıp sekiyor. Evcil dostun peşinden koşuyor, tekmeliyor ve yine kovalıyor. Topu kendin tekmelemek için imleci hızla topun üzerinden geçir ya da tıpkı evcil dost gibi topu tut, taşı ve fırlat.

Küçük bir püf noktası: masaüstünde boş bir yere tıklayıp sürükleyerek bir seçim kutusu çiz, Shift ile ya da Shift olmadan. Fare düğmesini basılı tuttuğun sürece kutu bir rafa dönüşür: evcil dostun üstüne zıplar, top da oraya düşebilir. Bırakınca raf kaybolur.

Masaüstün sakin kalsın mı istiyorsun? Evcil dost ayarlarında Top’u kapat, evcil dostun yine kendi başına gezinsin.

**Deneyin:** Ayarlar › Evcil Dost › Top

**Düzeltilenler**

- Dock’un yanında evcil dost yine istediği kadar yükseğe zıplıyor. Yalnızca tam Dock’un üstündeyken alçakta kalıyor, böylece hiçbir zaman Dock’un üstünden görünmüyor.

---

## <a id="v1.28.0"></a>Uygulamaları bir tıkla ya da sürükleyerek ekleyin

<sub>1.28.0 · 9 Ekim 2026</sub>

Ayarlar’daki her uygulama listesi artık Dock’unuzdakileri ve şu an açık olanları gösteriyor; Finder’dan uygulamaları listeye sürükleyebilirsiniz.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Bazı özellikler, kenara çekilecekleri uygulamaları seçmenize izin verir; yeşil düğme ya da Home ve End gibi. Eskiden “Uygulama Ekle…” her şeyin olduğu uzun bir klasörü açıyordu. Artık Dock’taki uygulamalarla şu an açık olanların durduğu bir raf çıkıyor. Bir uygulamaya tıklayınca eklenir, bir kez daha tıklayınca çıkar. Geri kalanı için “Diğer…” var.

Bir uygulamayı Finder’dan doğrudan listenin üzerine de sürükleyebilirsiniz. Liste parlayıp uygulamanın nereye gireceğini gösterir. Oyunlarınız da aynı rafla aynı şekilde çalışır.

Bir şeyler ters giderse, GitHub’daki hata bildirme formunda artık pikapik ve macOS sürümünüzü bir listeden seçebilirsiniz; bize anlatmak daha kısa sürer.

**Deneyin:** Ayarlar › Pencereler, sonra “Uygulama Ekle…”

**Düzeltilenler**

- İki Mac’te de klasik kaydırma yönü seçiliyken AnyDesk ya da başka bir uzak masaüstü uygulamasıyla kaydırma artık iki kez ters çevrilmiyor. pikapik artık yalnızca gerçek bir fareden ya da izleme dörtgeninden gelen kaydırmayı çeviriyor. Mos gibi kendi yumuşak kaydırmasını yapan bir uygulama kullanıyorsanız yönü o uygulamada ayarlayın.
- Dostunuz zıplarken de yürürken olduğu gibi Dock’un arkasında kalıyor ve tam ekran bir uygulamadan ya da oyundan çıkınca kendiliğinden geri geliyor.
- Ayarlar’daki küçük resimlerin etrafındaki ince çerçeveler, Retina olmayan sıradan ekranlarda artık kaybolmuyor.

---

## <a id="v1.27.3"></a>Dostunuz hep görünür, pencereler hazır açılır

<sub>1.27.3 · 9 Ekim 2026</sub>

Evcil dostunuz zıplarken artık pencerelerin arkasına saklanmıyor ve pikapik pencereleri hemen kullanıma hazır açılıyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Evcil dostunuz imlecin üzerinden atladığında ya da takla attığında, başka uygulamaların pencerelerinin arkasına kayıp havada kaybolabiliyordu. Artık zıplama boyunca önde kalıyor, yere inince yeniden pencerelerinizin arkasına geçiyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

pikapik oturum açılırken, bir güncellemeden sonra ya da bir pikapik:// bağlantısıyla arka planda sessizce başladığında, pencereleri gri açılıp siz tıklayana kadar diğerlerinin arkasında kalabiliyordu. Artık Ayarlar ve Yeni Dosya penceresi öne geliyor, hemen yazabilirsiniz.

Küçük Kopya Oluştur sonrasındaki ileti ve eklemek için uygulama seçtiğiniz liste için de aynısı geçerli. Hiçbir şey yapmanız gerekmiyor.

**Deneyin:** Ayarlar › Evcil Dost

---

## <a id="v1.27.2"></a>Yeni Dosya geri döndü, Ayarlar daha da hafifledi

<sub>1.27.2 · 9 Ekim 2026</sub>

Yeni Dosya herkes için Finder’ın sağ tık menüsüne geri döndü, Ayarlar da Mac’ini daha az yoruyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Son güncellemeden sonra Finder, Yeni Dosya’yı arka planda yeniden başlatıp hangi klasörlerde çalıştığını unutabiliyordu; bu yüzden öğe sağ tık menüsünden sessizce kayboluyordu. Artık Yeni Dosya her açılışta Finder’a klasörlerini yeniden hatırlatıyor, pikapik de açıldıktan kısa süre sonra Finder’ın bunu aldığını kontrol ediyor. Senin bir şey yapman gerekmiyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Ayarlar’daki hareketli resimler artık yalnızca resmin en az yarısı ekranda görünürken oynuyor. Oyun resimlerinde küçük kahraman yine saniyede 30 kez, arkasındaki tepeler ve zemin ise 15 kez hareket ediyor. Böylece Oyunlar sayfası Mac’ini çok daha az yoruyor. Her şey aynı görünüyor.

Güncellemeden sonra pikapik, uygulama gerçekten başka bir yere taşınmadıkça Finder öğelerini yeniden eklemiyor; Finder da onları her seferinde yeniden yüklemek zorunda kalmıyor.

**Deneyin:** Ayarlar › Oyunlar

---

## <a id="v1.27.1"></a>Daha sessiz, daha hafif, Finder hemen hazır

<sub>1.27.1 · 9 Ekim 2026</sub>

Ayarlar Mac’inizi neredeyse hiç yormuyor ve pikapik’e geçişin hemen ardından Finder’daki sağ tık öğeleri çalışıyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/wheel-lines-dark.png"><img src="../media/wheel-lines-light.png" width="340" alt=""></picture>

Ayarlar’daki küçük hareketli resimler eskiden tüm sayfayı saniyede defalarca yeniden çiziyordu, bu yüzden açık bir pencere Mac’inizi meşgul ediyordu. Artık her resim yalnızca kendini, saniyede en fazla 30 kez yeniden çiziyor ve kaydırıp geçtiğinizde ya da pencereyi gizlediğinizde dinleniyor. Görünüşleri tamamen aynı.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

pika-tools’tan pikapik’e geçtikten sonra Finder eski uygulamayı aramaya devam edebiliyordu ve “Yeni Dosya”, “Dönüştür” ile diğer sağ tık öğeleri hiçbir şey yapmıyordu. Artık pikapik bunu ilk açılışta fark ediyor ve açık Finder penceresi yoksa ve hiçbir şey kopyalanmıyorsa Finder’ı kendisi yeniden başlatıyor. Aksi hâlde Finder sayfasındaki kısa bir satır “Finder’ı yeniden başlat” düğmesini sunuyor.

Sistem Ayarları’nda, oturum açılınca açılan uygulamalar arasında uygulama artık yeni adıyla, pikapik olarak görünüyor ve açık kalıyor.

**Deneyin:** Ayarlar › Finder

---

## <a id="v1.27.0"></a>Masaüstündeki yeni dostunuzla tanışın

<sub>1.27.0 · 9 Ekim 2026</sub>

Ekranınızın altında artık küçük bir dost yaşıyor ve uygulamanın yeni bir adı var: pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Ayarlar › Evcil Dost bölümünden açın. Pencerelerinizin ve Dock’un arkasında geziniyor, imleç yoluna çıkarsa üstünden atlıyor, Boşluk tuşuna basınca zıplıyor. Onu tutup taşıyabilir, fırlatabilir ve zıplarken havada yakalayabilirsiniz.

Arada bir oturup kısa bir şey söylüyor. Gerçekten yeni bir sürüm çıktığında bunu bir kez söylüyor; üstüne tıklayınca güncellemenin beklediği Ayarlar açılıyor.

pika-tools artık pikapik adını taşıyor. İzinleriniz, ayarlarınız ve Kestirmeler bağlantılarınız olduğu gibi kalıyor. Homebrew ile kurduysanız bir kez `brew update && brew upgrade --cask pikapik` komutunu çalıştırın.

**Deneyin:** Ayarlar › Evcil Dost

**Düzeltilenler**

- Güncelleme denetimi, en yeni sürüm zaten yüklüyken bile yeni sürüm var diyordu.
- İzinler sayfası açıkken Mac’i meşgul ediyordu.

---

## <a id="v1.26.2"></a>Yenilikler artık sizin dilinizde

<sub>1.26.2 · 8 Ekim 2026</sub>

Ayarlardaki “Yenilikler” artık bu sayfayı, uygulamayla aynı dilde açıyor.

<img src="../media/icon.png" width="128" height="128" alt="">

Ayarlar › Hakkında’yı açıp “Yenilikler”e tıklayın. Doğrudan buraya, her güncellemenin bir resimle anlatıldığı sayfaya gelirsiniz; pikapik hangi dili konuşuyorsa o dilde.

Değişikliklerin tam listesi de daha düzenli. Her sürüm çıktığı günü gösteriyor, her sürüm numarası da kendi indirme sayfasını açıyor.

pikapik’in çalışma şeklinde hiçbir şey değişmiyor. Güncellemeler eskisi gibi kendiliğinden ya da Homebrew ile geliyor.

**Deneyin:** Ayarlar › Hakkında › Yenilikler

**Düzeltilenler**

- “Yenilikler” bu sayfa yerine İngilizce, uzun ve teknik bir liste açıyordu.
- Değişiklik listesinde hiçbir yere gitmeyen bağlantılar artık doğru sayfayı açıyor.

---

## <a id="v1.26.1"></a>Oyun resimleri canlandı

<sub>1.26.1 · 8 Ekim 2026</sub>

“Oyunlar” sayfasındaki resimler artık hareket ediyor; her anahtarın neyi durdurduğunu görüyorsunuz.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.26.1/game-previews-dark.png"><img src="../media/whats-new/1.26.1/game-previews-light.png" width="340" alt=""></picture>

“Oyunlar” sayfasındaki her anahtarın arkasında artık küçük bir oyun oynanıyor. Tuşlar belirip basılıyor ve Spotlight ya da Mission Control gibi oyununuzun üstüne neyin fırlayacağını görüyorsunuz; bu sırada oyun duruyor. Anahtar açıkken tuşlar yalnızca hafifçe parlıyor ve oyun sürüyor. Bir anahtarı değiştirin, resim farkı hemen gösterir.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Küçük oyun Mac’inizin görünümüne uyar: açık modda güneşli bir gün, koyu modda ay ve yıldızlarla sakin bir gece.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Uygulamadaki tüm resimlerde imleç artık bir el gibi hareket ediyor: uzak yerlere biraz daha uzun sürede gidiyor, duruyor ve ancak sonra tıklıyor. Bir resim baştan başladığında zıplamak yerine yumuşakça başa dönüyor. Pencere gizliyken resimler dinleniyor, “Hareketi azalt” açıkken de yerinde duruyor.

**Deneyin:** Ayarlar › Oyunlar

---

## <a id="v1.26.0"></a>Yeni bir simge ve eski izinlere temiz bir sayfa

<sub>1.26.0 · 8 Ekim 2026</sub>

pikapik’in yüzü yenilendi ve artık silinen uygulamaların geride bıraktığı izinleri temizliyor.

<img src="../media/icon.png" width="128" height="128" alt="">

Yeni simge, koyu bir karo üzerinde mavi, mor ve mercan renginde pikapik işareti. Menü çubuğunda da aynı şekil görünür ve açık ya da koyu menü çubuğuna uyar. Tüm araçlar kapalıyken şekil solar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>

Bir uygulamayı sildiğinizde macOS ona verdiğiniz izinleri saklar ve Sistem Ayarları’nda bunları kaldırmanın bir yolu yoktur. Artık “İzinler” sayfasında “Silinen uygulamalardan kalanlar” adlı bir liste var: her uygulama simgesiyle, neye izni olduğu ve ne zaman. “Kaldır” bir uygulamayı temizler, “Tümünü Kaldır” hepsini, yeniden yüklediğiniz bir uygulama ise yalnızca tekrar sorar. Listeyi görmek için pikapik’e Tam Disk Erişimi verin: “Kaldır”a basana kadar yalnızca bakar ve hiçbir şeyi değiştirmez.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

“Animasyonlar” ve “Oyunlar” sayfalarındaki resimler gerçek boyutlarına göre yeniden çizildi, bu yüzden net görünüyor. Bir pencere yuvarlak köşeleriyle Dock’a küçülür; imleç önce tıklar, menü ancak ondan sonra açılır. “Hakkında”nın altında da artık sessiz bir satır var: “Özenle yapıldı · Bana bir kahve ısmarlayın”. Hiçbir şey birden açılmaz, hiçbir şey hatırlatmaz.

**Deneyin:** Ayarlar › İzinler, ardından “Silinen uygulamalardan kalanlar”

**Düzeltilenler**

- Bir sistem kestirmesini tıklamak, yalnızca “Klavye”yi değil, Mission Control gibi doğrudan o kestirmenin bölümünü Sistem Ayarları’nda açar.
- Tuşların yanındaki ipucu, Sistem Ayarları açılır açılmaz artık kaybolmuyor.

---

## <a id="v1.25.2"></a>Kestirmeler, değiştirdiğiniz yerde açılır

<sub>1.25.2 · 8 Ekim 2026</sub>

Ayarlar’da bir kestirmeyi tıklayın, Sistem Ayarları doğru yerde açılsın.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Önceden Spotlight gibi bir kestirmeyi tıklamak hep “Niteleme Tuşları”na götürüyordu. Artık Spotlight tuşları doğrudan Spotlight’ı açıyor.

Diğer kestirmelerde Sistem Ayarları “Klavye”de açılır ve tuşların yanında nereyi tıklayacağınızı söyleyen kısa bir ipucu çıkar: önce “Klavye Kestirmeleri…”, sonra “Mission Control” ya da başka bir bölüm.

Oyunlar sayfasında ve “Finder’da dosyaları kes” özelliğinde de aynısı geçerli. Dosya keserken ipucu sizi “Uygulamalar” bölümüne götürür.

**Deneyin:** Ayarlar › Oyunlar, ardından “Arama ekrana gelmez” yanındaki tuşları tıklayın

**Düzeltilenler**

- Bir kestirmeyi tıklamak artık “Niteleme Tuşları”nı açmıyor.

---

## <a id="v1.25.1"></a>Büyük resimler ve doğrudan Dock’tan oyunlar

<sub>1.25.1 · 8 Ekim 2026</sub>

Her anahtarın artık büyük bir resmi var ve “Oyun Ekle…” Dock’unuzda ne varsa gösteriyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

Animasyonlar ve Oyunlar sayfalarındaki tüm resimler artık büyük, tıpkı sayfanın üstündeki gibi. Her anahtarın ne yaptığı hemen anlaşılıyor ve resimler hâlâ seçtiğiniz hızda hareket ediyor.

“Oyun Ekle…”ye basın, Dock’unuzu görün: orada tuttuğunuz uygulamalar ve şu an açık olanlar, aynı sırayla. Dock’taki bir oyun kapalıyken de görünür, Minecraft da. Tek tıklama onu ekler, bir onay işareti listede olduğunu gösterir. Çıkarmak için bir kez daha tıklayın.

Bir oyunu hâlâ Finder’dan buraya sürükleyebilirsiniz. Artık onu Dock’tan çekip çıkarmanız gerekmiyor, bu yüzden Dock da onu kaldırmayı önermiyor.

**Deneyin:** Ayarlar › Oyunlar, ardından “Oyun Ekle…”

**Düzeltilenler**

- Dock’ta duran ama kapalı olan bir oyun artık ekleme listesinde görünüyor.

---

## <a id="v1.25.0"></a>Tek tıkla oyun ekleyin, tuşları kendiniz seçin

<sub>1.25.0 · 8 Ekim 2026</sub>

Artık oyunu açık uygulamalar arasından seçebilir, çıkma ve kapatma tuşlarını kendiniz belirleyebilirsiniz.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

“Oyun Ekle…”ye basın; şu an açık olan uygulamalar Dock’taki gibi büyük simgelerle görünür. Tek tıklama bir oyunu ekler, ya da simgesini listeye sürükleyin. Bir oyunu doğrudan Finder’dan veya Dock’tan da bırakabilirsiniz. Artık her uygulama oyun olabilir, Java ile çalışan Minecraft bile; daha önce eklediğiniz oyunlar da yerinde kalır.

Oyun Modu anahtarları artık sade bir dille konuşuyor, örneğin “Oyun kapanmaz” ya da “Arama ekrana gelmez”, ve her birinin neyi durdurduğunu gösteren küçük bir resmi var. Spotlight gibi sistemdeki adı da yanında gri olarak durur.

Ayarlar › Pencereler’de “Uygulamadan çık” ya da “Pencereyi kapat”ın yanındaki tuşlara tıklayın ve yenilerine basın. ⌫ ⇧⌘Q ve ⇧⌘W’yi geri getirir; tuşlar zaten kullanılıyorsa pikapik önce size sorar. Oyun Modu da sizin tuşlarınızı kullanır. Ayrıca Ayarlar’daki her kestirme artık Mac’inizde gerçekte nasıl ayarlandığını gösteriyor: sizin tuşlarınız ya da Kapalı.

**Deneyin:** Ayarlar › Oyunlar, ardından “Oyun Ekle…”

**Düzeltilenler**

- Finder’da dosya kesme, Sistem Ayarları’nda Finder için ayarladığınız Kes kestirmesini izler.
- Listelerdeki uygulama adları “.app” olmadan görünür.

---

## <a id="v1.24.1"></a>Hemen göreceğiniz hız değişiklikleri

<sub>1.24.1 · 8 Ekim 2026</sub>

Animasyonlar sayfası artık bir değişikliğin nerede görüneceğini söylüyor ve kendi değerlerinizi koruyor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

Dock yalnızca gizlendiğinde daha hızlı kayabilir. Sizinki hep yerinde duruyorsa, “Dock’u otomatik olarak gizle” anahtarı artık hız sürgüsünün hemen altında.

Bir değişiklikten sonra sayfanın altındaki bir satır, uygulamaları yeniden açtığınızda değişikliğin geçerli olacağını söyler. Finder, Hızlı Bakış ve sütunların yeni hızını ancak yeniden başlatıldıktan sonra gösterir; bu yüzden satırda bir “Finder’ı yeniden başlat” düğmesi var.

Sürgü, örneğin Terminal komutlarıyla zaten hızlandırdığınız bir şeyi asla yavaşlatmaz. “Saptanmışlara Dön” ya da pikapik’i kaldırmak da değerlerinizi silmek yerine önceki hâllerine geri getirir.

**Deneyin:** Ayarlar › Animasyonlar

**Düzeltilenler**

- Dock gizlenmiyorken artık boş yere yeniden başlamıyor.

---

## <a id="v1.24.0"></a>Mac’inizin ne kadar hızlı hareket edeceğini seçin

<sub>1.24.0 · 8 Ekim 2026</sub>

Yeni Animasyonlar sayfası, Mac’inizde her şeyin ne kadar hızlı açılacağını, kayacağını ve belireceğini belirler.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Tek bir sürgü yeter. Onu kaydırdığınızda gizli Dock, yeni pencereler, Kaydet pencereleri, Hızlı Bakış ve Finder’daki sütunlar birlikte hızlanır; “macOS’teki gibi” ayarından “Anında” ayarına kadar.

Yalnızca bir şeyi mi ayarlamak istiyorsunuz? Her efektin kendi ayarı var; küçültme efekti, Dock’ta zıplayan simgeler ve Finder animasyonları için de öyle. Her ayarın yanında küçük bir resim tam seçtiğiniz hızda hareket eder.

“Saptanmışlara Dön” yalnızca pikapik’in değiştirdiklerini geri alır; uygulamayı kaldırmak da aynısını yapar. Bu değerlerden birini bir zamanlar Terminal’de kendiniz ayarladıysanız, pikapik onu olduğu gibi gösterir.

**Deneyin:** Ayarlar › Animasyonlar

---

## <a id="v1.23.2"></a>Oyun Modu’nda her kestirme için ayrı anahtar

<sub>1.23.2 · 8 Ekim 2026</sub>

Artık oynarken Oyun Modu’nun neyi susturacağına kestirme kestirme siz karar veriyorsunuz.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Q ve ⌘W’nin artık ayrı anahtarları var; Spotlight, Siri, ⌘Tab, Mission Control, kaydırmalar, imleç, ekran ve geri kalanı için de öyle. Önceki seçimleriniz korunur.

Her satır, durdurduğu tuşları tam olarak gösterir; böylece bir anahtarın ne yaptığını her zaman bilirsiniz.

Klavye dili ayarı Oyun Modu’ndan çıktı. ⌃Boşluk ve dili değiştirmenin diğer yolları her zaman, oyunda bile çalışır.

**Deneyin:** Ayarlar › Oyunlar

**Düzeltilenler**

- Aynı kestirmenin tuşları birbirine daha yakın, farklı kestirmeler arasında ise biraz daha fazla boşluk var; birinin nerede bitip diğerinin nerede başladığı kolayca görülüyor.

---

## <a id="v1.23.1"></a>İnternetiniz ne kadar hızlı, basit kelimelerle

<sub>1.23.1 · 8 Ekim 2026</sub>

Hız Testi bağlantınızı kontrol eder ve neye yettiğini size basitçe söyler.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

“Hızı Ölç”e basın; yarım dakika kadar sonra indirme, yükleme, ping ve tepki hızını görürsünüz. Rakamların altında, 4K filmler, görüntülü aramalar, çevrimiçi oyunlar ve büyük indirmeler için yeterli olup olmadığı basit kelimelerle yazar.

Ölçüm Apple’ın sunucularında yapılır ve son sonuç bir sonrakine kadar kalır. Hız Testi’nin Ayarlar’da kendi sayfası, menü çubuğu panelinde bir satırı ve Kestirmeler uygulaması için bir bağlantısı var: `pikapik://speed-test`.

Oyun Modu iki şey öğrendi. Control kestirmelerini engelleme artık onun bir parçası: oyunda ⌃-tıklama normal bir tıklama olarak kalır ve ⌃ kestirmeleri çalışmaz; başka her yerde ⌃ her zamanki gibi çalışır. Bir de Minecraft’ı tanıyor: Minecraft Launcher’ı ya da CurseForge’u oyunlarınıza ekleyin, Minecraft’ın kendisi öndeyken Oyun Modu açılır.

**Deneyin:** Ayarlar › Hız Testi, ardından “Hızı Ölç”

**Düzeltilenler**

- İnsanların kendi derlediği pikapik test sürümleri ayarlarını iCloud Drive’da ayrı tutar ve artık sizinkilere dokunmaz.

---

## <a id="v1.23.0"></a>Oyun Modu: kesintisiz oynayın

<sub>1.23.0 · 7 Ekim 2026</sub>

Oyunlarınızı ekleyin, Mac sizi onlardan koparmayı bıraksın.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Siz oynarken Spotlight, Siri, ⌘Tab, Mission Control ve masaüstleri arasında kaydırma oyunun üstünde açılmaz. ⌘Q ve ⌘W oyunu yanlışlıkla kapatmaz, imleç oyunun ekranında kalır ve ekran açık kalır.

Oyundan çıkmak için ⇧⌘Q’ya, penceresini kapatmak için ⇧⌘W’ye basın. ⌥⌘Esc her zaman çalışır. pikapik Mac’inizde bulduğu oyunları önerir. Oyun Modu siz açana kadar kapalıdır.

Uyanık Tut artık ekranın ne yapacağını seçmenize izin veriyor: ekran koruyucu ve kilit ekranı olmadan açık kalsın ya da Mac çalışmaya devam ederken her zamanki gibi kapansın. Yeni “Ekranı şimdi kapat” düğmesi ekranı hemen karartır; geri getirmek için fareyi oynatın ya da bir tuşa basın.

**Deneyin:** Ayarlar › Oyunlar, ardından “Oyun Ekle…”

**Düzeltilenler**

- Kapağı olmayan Mac’lerde Uyanık Tut artık kapak kapalıyken seçeneklerini göstermiyor.

---

<p align="center"><sub>Daha eski sürümler <a href="../../CHANGELOG.md">değişiklik günlüğünde</a> (İngilizce).</sub></p>
