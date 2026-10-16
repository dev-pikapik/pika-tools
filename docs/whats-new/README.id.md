<p align="center"><a href="../readme/README.id.md"><img src="../media/icon.png" width="96" height="96" alt="pikapik"></a></p>
<h1 align="center">Yang baru di pikapik</h1>
<p align="center">Setiap pembaruan dalam beberapa kata dan satu gambar, yang terbaru di atas.</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <b>Bahasa Indonesia</b> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.52.1"></a>Pemutar memainkan musik Anda, dan pengaturan Anda kembali setelah crash

<sub>1.52.1 · 16 Oktober 2026</sub>

Pemutar kini memainkan lagu dan punya panel kaca, dan pengaturan Anda kembali bahkan setelah crash.

- Pemutar (versi situs web): lagu diputar di jendela yang sama, dengan sampul, judul, dan artis, dan satu folder diputar lagu demi lagu.
- Pemutar (versi situs web): setiap format adalah tombol yang memberikannya ke pikapik Player dan mengembalikannya; **Buka Semua di pikapik** melakukannya untuk semua.
- Pemutar (versi situs web): panel kontrol dari kaca buram yang menghilang saat Anda menonton, dan gambar kecil video saat Anda menunjuk bilah waktu.

**Coba:** Pengaturan › Pemutar

**Diperbaiki**

- Pengaturan Anda, misalnya “Sembunyikan Dock Otomatis”, kembali meski pikapik berhenti tiba-tiba.
- Chrome, Slack, VS Code (versi situs web): setelah crash, app ini tidak lagi tertinggal di mode pikapik, dan jendela yang macet tidak lagi memperlambat pembukaan atau penutupan pikapik.
- Tombol samping: Pengaturan menampilkan panah mundur dan maju, bukan 4 dan 5, dan “Maju” tidak lagi meneruskan email di Mail atau Outlook.
- **Jadikan salinan ini yang utama** hanya bekerja sekali per klik, dan baris singkat di bawah beberapa sakelar lebih jelas menyebut fungsinya.
- Versi Mac App Store: halaman “Peliharaan” tidak lagi menjanjikan kabar soal pembaruan, karena App Store membawanya sendiri.

---

## <a id="v1.52.0"></a>Perbaikan kata dan tombol samping mouse kini berfungsi di hampir semua app

<sub>1.52.0 · 15 Oktober 2026</sub>

Kata yang salah bahasa kini diperbaiki juga di Chrome, Slack, dan VS Code, dan tombol samping mouse berfungsi sebagai kembali dan maju di hampir semua tempat.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/layout-fix-dark.png"><img src="../media/layout-fix-light.png" width="340" alt=""></picture>

Di versi situs web, kata yang diketik dengan bahasa yang salah kini diperbaiki juga di Chrome, Slack, VS Code, Discord, dan app serupa, sehingga “ghbdtn” di sana juga menjadi “привет”. Matikan fitur ini atau keluar dari pikapik, lalu app-app itu kembali seperti semula.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/side-buttons-dark.png"><img src="../media/side-buttons-light.png" width="340" alt=""></picture>

Tombol samping mouse kini berfungsi sebagai kembali dan maju di hampir semua app, dan berfungsi lagi di Pengaturan pikapik sendiri: pikapik menekan tombol Kembali atau Maju milik app itu. Di versi Mac App Store, ini berfungsi di pikapik dan di app Apple.

Jika dua salinan pikapik terbuka, misalnya dari situs web dan dari App Store, hanya yang dibuka paling akhir yang mengubah Mac, jadi Pengaturan selalu menunjukkan keadaan yang sebenarnya. Saat keluar, semua yang diubahnya dikembalikan.

**Juga baru**

- Klik tengah di trackpad: ketuk dengan tiga jari, di versi situs web.
- Keluar dari app dan Tutup jendela menampilkan lewat gambar apa yang dilakukan tombol-tombol itu.
- ⇧⌘. kini langsung ada di baris Tampilkan file tersembunyi.
- Bar samping Pengaturan kini punya nama grup.
- Pemutar, di versi situs web: tombol yang sama seperti di QuickTime Player, volume dengan roda gulir, kecepatan, dan lanjut dari tempat terakhir berhenti.

**Coba:** Pengaturan › Papan Ketik, Pengaturan › Tetikus

**Diperbaiki**

- Buka dengan menampilkan pikapik Player tepat setelah pembaruan, meski pemutar belum pernah dibuka.
- Volume App: saat penggeser sebuah app dikembalikan ke 100%, suara tidak lagi berakhir dengan bunyi klik kecil.
- Game (versi situs web): gerakan mouse yang cepat tidak lagi melompat ke layar lain, dan penunjuk tidak lagi melompat balik.

---

## <a id="v1.51.0"></a>Video yang tidak bisa dibuka QuickTime kini bisa diputar

<sub>1.51.0 · 15 Oktober 2026</sub>

Di versi situs web, MKV, WebM, AVI, WMV, FLV, dan video lain yang tidak bisa dibuka QuickTime kini diputar di pikapik Player.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/player-dark.png"><img src="../media/player-light.png" width="340" alt=""></picture>

Klik kanan sebuah video dan pilih Buka dengan › pikapik Player, atau klik Buka video… di Pengaturan › Pemutar. Video diputar di jendelanya sendiri: Spasi memutar dan menjeda, ← dan → melompat 5 detik, ↑ dan ↓ mengubah volume, dan F beralih ke layar penuh.

Pemutar adalah app kecil yang terpisah. Ia hanya melihat video yang Anda buka, tidak bisa terhubung ke internet, dan tidak meminta izin apa pun. App yang membuka video Anda secara default tetap sama. Subtitel belum didukung.

**Coba:** Pengaturan › Pemutar

---

## <a id="v1.50.3"></a>Menu sudut aktif dan layar utama kini berfungsi

<sub>1.50.3 · 15 Oktober 2026</sub>

Di versi situs web, menu Ubah… pada baris sudut aktif dan menu Layar utama kini melakukan apa yang dijanjikan.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-display-dark.png"><img src="../media/dock-display-light.png" width="340" alt=""></picture>

Di versi 1.50.2, setiap pilihan di kedua menu ini muncul tiga kali dan memilih salah satunya tidak mengubah apa pun. Sekarang setiap pilihan muncul sekali, pilihan saat ini diberi tanda centang, dan pilihan Anda langsung berlaku. Sudut aktif ada di Pengaturan › Game, dan Layar utama ada di bawah Pertahankan Dock di satu layar. Kembalikan, atau mematikan sakelar, tetap mengembalikan semuanya persis seperti semula.

---

## <a id="v1.50.2"></a>pikapik mengerjakannya sendiri, tanpa pergi ke Pengaturan Sistem

<sub>1.50.2 · 15 Oktober 2026</sub>

Di versi dari situs web, mematikan tugas latar belakang, menambah tata letak papan ketik, mengubah sudut aktif, dan memilih layar utama kini dilakukan langsung di pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/background-dark.png"><img src="../media/background-light.png" width="340" alt=""></picture>

Di Pengaturan › Tugas Latar Belakang, matikan sebuah tugas dan barisnya langsung berubah. Tidak perlu kata sandi, dan pilihan Anda tetap ada setelah restart. Nyalakan Lagi mengembalikan tugasnya. Tugas untuk seluruh Mac dan pembantu yang ditambahkan sebuah app sendiri tetap membuka Pengaturan Sistem, dan satu baris di bawahnya menjelaskan alasannya.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/layout-fix-dark.png"><img src="../media/layout-fix-light.png" width="340" alt=""></picture>

Memperbaiki teks yang diketik dengan tata letak yang salah berfungsi jika Anda punya dua tata letak papan ketik atau lebih. Jika hanya punya satu, catatan di Pengaturan › Papan Ketik kini menawarkan tata letak untuk bahasa Anda. Pilih satu di Tambah Tata Letak dan langsung siap, tanpa kata sandi. Jika tidak ada yang cocok, Pengaturan Papan Ketik… masih ada.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-display-dark.png"><img src="../media/dock-display-light.png" width="340" alt=""></picture>

Di Pengaturan › Game, menu Ubah… pada baris sudut aktif memilih aksi lain untuk sudut itu. Di Pertahankan Dock di satu layar, menu Layar utama menjadikan layar yang Anda pilih sebagai layar utama, dengan Dock di atasnya. pikapik mengingat keadaan sebelumnya: Kembalikan, atau mematikan sakelar, mengembalikan semuanya persis seperti semula.

**Coba:** Pengaturan › Tugas Latar Belakang

**Diperbaiki**

- Minimalkan atau sembunyikan dengan klik di Dock: jika Anda menyalakannya saat klik meminimalkan jendela, setelah restart ia tidak lagi berubah sendiri menjadi menyembunyikan app.
- Saat Anda membuka pikapik, kini ia memeriksa pengaturan yang berubah di Mac Anda yang lain, sehingga Mac yang melewatkan perubahan langsung menyusul.
- Tetap Terjaga kini menyebut bahwa ia tetap menyala sampai Anda mematikannya, dan Mode Game tidak lagi menyarankan game yang sudah Anda tambahkan.

---

## <a id="v1.50.0"></a>Lebih banyak pikapik di versi Mac App Store

<sub>1.50.0 · 15 Oktober 2026</sub>

Buka arsip, bersihkan desktop, pakai Home dan End, dan lainnya, kini juga di versi Mac App Store.

**Baru di versi Mac App Store**

- **Buka dan buat arsip di Finder.** Klik kanan arsip, lalu pilih “Ekstrak”. Untuk membuatnya, klik kanan file lalu pilih “Buat Arsip…”. Tekan Spasi pada arsip untuk melihat isinya. Di versi ini, hanya ZIP yang bisa diberi kata sandi.
- **Desktop yang bersih.** Nyalakan “Sembunyikan ikon desktop”, dan pikapik menutupi ikon dengan wallpaper Anda. Klik Anda tetap sampai ke desktop, dan tidak perlu izin apa pun.
- **Home dan End berfungsi lagi.** Keduanya menuju awal dan akhir baris di mana saja, kecuali di browser, Finder, Musik, dan TV.
- **Perbaiki teks yang salah tata letak dengan pintasan.** Pilih teksnya, lalu tekan ⌃⇧Spasi. Nyalakan “Perbaiki teks yang dipilih” di Pengaturan › Papan Ketik, tempat Anda juga bisa mengganti tombolnya.
- **Matikan layar dengan satu klik.** “Matikan layar sekarang” membuat layar langsung gelap, sementara Mac Anda tetap bekerja. Gerakkan tetikus untuk menyalakannya kembali.
- **Game tidak terganggu.** Di “Mode Game”, pintasan Mac seperti Spotlight dijeda selama game ada di depan. Penunjuk menjauh dari sudut layar, sehingga sudut aktif tidak terpicu.
- **Angka baterai kembali.** “Baterai” kembali menampilkan “Kapasitas Maksimum” di macOS 27, dan “Suhu” menampilkan suhu baterai.
- **Lihat app mana yang bisa meminta izin.** “Izin app lain” di Pengaturan › Izin menampilkannya beserta ikonnya.
- **Tahu ke mana harus mengklik.** Saat macOS tidak mengizinkan pikapik mengubah sebuah pengaturan, animasi singkat menunjukkan ke mana harus mengklik di Pengaturan Sistem.

**Di kedua versi**

- **Atur volume sebelum app dibuka.** App yang sudah Anda atur tetap ada di Pengaturan › Suara dengan penggesernya, bahkan saat tertutup, dan levelnya kembali saat app memutar suara lagi, juga setelah mulai ulang. Klik “Tambah App…” atau seret app dari Finder untuk mengaturnya lebih dulu, dan ✕ melupakannya serta mengembalikannya ke volume penuh.
- **Lihat apa yang ditambahkan pembaruan.** Setelah pembaruan, titik biru kecil menandai setiap tab Pengaturan yang punya hal baru, dan label “Baru” menandai bagiannya. Keduanya hilang setelah Anda melihatnya, dan hilang sendiri setelah 21 hari.
- **Peluncuran pertama yang tenang.** Versi dari situs web tidak lagi meminta izin saat pertama kali dibuka. Ia hanya bertanya saat Anda menyalakan alat yang membutuhkannya.
- **Salinan video yang lebih kecil.** “Buat Salinan Lebih Kecil” kini membuat video sekitar separuh ukurannya. Sebelumnya, sebagian besar video mendapat “Sudah ringkas”.
- **Dua salinan akur.** Jika Anda memakai versi App Store dan versi situs web bersamaan, keduanya tidak lagi saling membatalkan. ⇧⌘Q dan ⇧⌘W berfungsi lagi di game.
- **Game kembali setelah tidur.** “Mode Game” menyala lagi dengan sendirinya saat Mac Anda bangun.
- **“Port” berkata jujur.** Di macOS 27, port yang dipakai macOS atau pengguna lain tidak lagi disebut bebas.
- **Melaporkan masalah jadi lebih cepat.** “Laporkan Masalah” di Pengaturan › Tentang membuka formulir dengan versi Anda sudah terpilih.
- **Arsip yang lebih mulus.** Bilah kemajuan bergerak saat arsip diekstrak, kata sandi yang salah langsung dilaporkan, dan Mac tidak lagi tertidur di tengah mengekstrak atau membuat arsip.
- **Panel bilah menu yang lebih tenang.** Membuka satu baris di panel, misalnya opsi layar di bawah “Tetap Terjaga”, tidak lagi membuat bilah gulir berkedip. Panah di samping “Tetap Terjaga” kini bertuliskan “Pengaturan layar”.
- **Port menjelaskan dirinya sendiri.** Satu baris di bawah judul menjelaskan apa itu port, dan animasi kecil menunjukkan bahwa satu pintu hanya muat satu program. Program Anda sendiri dan program yang sebaiknya dibiarkan kini punya nama yang jelas.
- **Pengaturan bicara dengan jelas.** Setiap tab dimulai dengan satu baris tentang apa yang Anda dapat di sana, bilah samping punya jarak antar kelompok, dan “Tetap Terjaga”, “Izin” dan “Baterai” menyebutkan persis apa yang terjadi. Tombol “Perlu izin” hanya muncul saat alat yang Anda nyalakan kekurangan izin.

**Diperbaiki di versi Mac App Store**

- Setelah ⌘X, ⌘V di Finder kini memindahkan file Anda, seperti di versi situs web. Sebelumnya hanya menyalin.
- “File Baru di Finder”, “Salinan Lebih Kecil di Finder”, dan “Konversi di Finder” masing-masing menampilkan statusnya sendiri. Sebelumnya, menyalakan satu membuat ketiganya tampak menyala.
- Halaman “Port” yang kosong sudah hilang. macOS tidak menunjukkan kepada versi ini program mana yang memakai sebuah port, jadi Pengaturan › Port tidak punya apa-apa untuk ditampilkan.

---

## <a id="v1.49.0"></a>Kecerahan untuk setiap monitor

<sub>1.49.0 · 13 Oktober 2026</sub>

Redupkan atau terangkan monitor yang tidak bisa diatur macOS, langsung dari pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/brightness-dark.png"><img src="../media/brightness-light.png" width="340" alt=""></picture>

macOS mengatur layar bawaan dan monitor Apple, tetapi sebagian besar monitor lain hanya menurut pada tombolnya sendiri. Sekarang setiap monitor itu mendapat slider di Pengaturan › Kecerahan, dan Anda bisa menambahkan baris “Kecerahan” ke panel bar menu.

pikapik mengubah kecerahan monitor itu sendiri, sama seperti tombolnya. Jika monitor tidak merespons, aktifkan “Redupkan gambar sebagai gantinya”: gambar menjadi lebih gelap, tetapi tidak pernah hitam. pikapik mengingat level tiap monitor dan mengaturnya lagi setelah tidur.

Aktifkan “Tombol kecerahan”, maka tombol kecerahan di keyboard mengatur monitor tempat penunjuk berada, dengan indikator kecil di layar. Tahan ⌥⇧ untuk langkah yang lebih halus. Tombol ini memerlukan izin “Aksesibilitas”, yang Anda berikan di halaman “Izin”.

**Coba:** Pengaturan › Kecerahan

**Diperbaiki**

- Dengan VoiceOver, sakelar di Pengaturan kini bisa dinyalakan dan dimatikan. Sebelumnya VoiceOver membaca nama setiap sakelar dua kali, dan menekannya tidak berpengaruh apa-apa.

---

## <a id="v1.48.0"></a>Dock tetap di layarnya, secepat apa pun Anda menggerakkan mouse

<sub>1.48.0 · 13 Oktober 2026</sub>

“Pertahankan Dock di satu layar” kini memakai pengaturan milik Dock sendiri, jadi Dock tidak lagi mengikuti penunjuk ke layar lain, secepat apa pun gerakannya.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-display-dark.png"><img src="../media/dock-display-light.png" width="340" alt=""></picture>

Sebelumnya, pikapik mendorong penunjuk menjauh dari tepi bawah layar yang lain, tetapi dengan gerakan mouse yang cepat, Dock masih bisa melompat. Sekarang sakelar ini mematikan perpindahan itu di Dock sendiri, dan pikapik sama sekali tidak menyentuh penunjuk. Dock hanya membaca pengaturan ini saat mulai, jadi menyalakan atau mematikan sakelar akan memulai ulang Dock sekali. Jika sakelar sudah menyala sebelumnya, Dock juga dimulai ulang sekali setelah pembaruan.

Untuk memindahkan Dock dengan sengaja, jadikan layar lain sebagai layar utama. Klik “Layar utama” di bawah sakelar untuk membuka Pengaturan Sistem › Layar, klik layar yang Anda inginkan, lalu pilih “Layar utama” di “Gunakan sebagai”. Dock akan pindah ke layar itu.

Sakelar “Kembalikan Dock” sudah tidak ada: sakelar itu juga bekerja dengan mendorong penunjuk, dan kini Dock tidak lagi mengikuti penunjuk. “Pertahankan Dock di satu layar” tidak memerlukan izin apa pun dan mati secara default. Sakelar ini tidak ada di versi Mac App Store, karena app dari App Store tidak dapat mengubah pengaturan Dock.

**Coba:** Pengaturan › Dock

---

## <a id="v1.47.0"></a>Desktop rapi dengan sekali klik

<sub>1.47.0 · 13 Oktober 2026</sub>

Dua sakelar baru di pikapik menyembunyikan ikon di desktop dan menampilkan file yang disembunyikan macOS.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/desktop-icons-dark.png"><img src="../media/desktop-icons-light.png" width="340" alt=""></picture>

**Sembunyikan ikon desktop.** Nyalakan sebelum panggilan, rekaman layar, atau jepretan layar, dan file serta folder di desktop menghilang. Matikan, dan semuanya kembali ke tempat yang sama. Tidak ada yang dipindahkan: file tetap ada di folder Desktop di Finder. Ini adalah pengaturan **Tampilkan item › Di Desktop** di Pengaturan Sistem › Desktop & Dock, hanya lebih dekat di tangan, jadi keduanya selalu sama. Di versi Mac App Store, baris ini membuka halaman tersebut di Pengaturan Sistem.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/hidden-files-dark.png"><img src="../media/hidden-files-light.png" width="340" alt=""></picture>

**Tampilkan file tersembunyi.** File dan folder yang disembunyikan macOS, seperti Perpustakaan di folder pengguna Anda atau file yang namanya diawali titik, muncul redup di Finder dan di desktop. Sama seperti menekan ⇧⌘. di Finder, hanya saja Anda bisa melihat sekilas apakah sedang menyala. Untuk menerapkan perubahan, Finder dimulai ulang sebentar dan membuka lagi jendela serta tabnya. Jika Finder sedang menyalin atau memindahkan file, Finder baru dimulai ulang setelah selesai. Keduanya ada di Pengaturan › Finder. Agar keduanya ada di panel bar menu, klik tombol pensil di bagian bawah panel lalu centang. Di versi Mac App Store, Pengaturan › Finder menampilkan tombol ⇧⌘. sebagai gantinya.

---

## <a id="v1.46.1"></a>Halaman “Izin” kini memberi tahu apa adanya

<sub>1.46.1 · 13 Oktober 2026</sub>

Jika suatu alat masih memerlukan izin dari daftar di bawah, halaman ini kini memberitahukannya.

Sebelumnya, begitu kedua izin di atas aktif, halaman ini menjanjikan bahwa semua alat berfungsi, meskipun ada alat di “Untuk beberapa fitur” yang masih menunggu izinnya. Kini halaman ini menyebutkan bahwa beberapa alat juga memerlukan izin dari daftar di bawah, dan baru menjanjikan semuanya berfungsi jika memang benar begitu.

**Coba:** Pengaturan › Izin

**Diperbaiki**

- Di versi Mac App Store, “Ucapkan terima kasih” di halaman “Tentang” baru muncul saat tip siap dipilih. Sebelumnya ada roda berputar selama tip dimuat, dan bagian itu menghilang jika App Store tidak menjawab.
- Jika disk penuh saat arsip sedang dibuka, “Ruang tidak cukup” kini menampilkan ruang yang benar-benar kosong setelah file yang baru setengah dibuka dihapus. Sebelumnya pesan ini bisa menyebut hampir tidak ada ruang kosong.

---

## <a id="v1.46.0"></a>Sembunyikan app di depan dengan tombol tetikus

<sub>1.46.0 · 13 Oktober 2026</sub>

Tekan tombol tengah atau tombol samping, dan app yang sedang Anda pakai langsung menyingkir, sama seperti dengan ⌘H.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/hide-app-dark.png"><img src="../media/hide-app-light.png" width="340" alt=""></picture>

Buka Pengaturan › Tetikus, nyalakan “Sembunyikan app saat ini dengan tombol tetikus”, lalu tekan tombol yang ingin Anda pakai. Nanti Anda bisa memilih tombol lain lewat “Ubah…”. App tetap berjalan, dan klik ikonnya di Dock akan memunculkannya kembali. Saat Anda bermain dengan Mode Game aktif, tombol itu tetap bekerja seperti biasa di dalam game. Jika “Tombol samping untuk kembali dan maju” juga menyala, tombol samping yang Anda pilih justru menyembunyikan app. Fitur ini memerlukan izin “Aksesibilitas” dan mati secara default.

Di versi Mac App Store, ⌘X memotong file di Finder: pilih file, tekan ⌘X, buka folder lain, lalu pilih “Pindahkan Item Ke Sini” di menu pikapik atau tekan ⌥⌘V. “Animasi” dan “Matikan akselerasi penunjuk” kembali hadir, dan halaman “Izin” punya bagian baru, “Sisa dari app yang dihapus”. Versi ini tidak bisa mengubah pengaturan tersebut sendiri, jadi setiap baris menjelaskan apa yang perlu diubah dan membuka tempat yang tepat di Pengaturan Sistem. Peliharaan Anda kini berjalan di sepanjang lebar layar, di atas Dock.

**Coba:** Pengaturan › Tetikus › Sembunyikan app saat ini dengan tombol tetikus

**Diperbaiki**

- Gambar di halaman “Tetikus” kembali tajam.
- Fitur papan ketik dan tetikus hanya meminta izin yang benar-benar dipakai. Sebagian besar hanya perlu “Aksesibilitas”; sebelumnya fitur-fitur itu juga meminta “Pengawasan Input” dan tetap abu-abu tanpanya.
- “Ganti bahasa” memberi tahu saat memerlukan “Pengawasan Input”, dan klik padanya membuka halaman “Izin”. Sebelumnya fitur ini tetap menyala tetapi tidak berfungsi.
- “Keluar saat jendela terakhir ditutup” menunggu sampai Anda mengizinkan “Pengawasan Input”, alih-alih membuat macOS memintanya saat pikapik dibuka.
- Di macOS 27, “Aksesibilitas” muncul dengan nama barunya, “Kontrol Perangkat dan Akses Data”, sama seperti di Pengaturan Sistem.
- Dengan VoiceOver, kini Anda bisa memilih pakaian dan gaya peliharaan Anda di “Lemari pakaian” dan “Gaya”, serta membuka penghargaannya di “Penghargaan”. Sebelumnya, kotak-kotak itu tidak merespons.

---

## <a id="v1.45.0"></a>Setiap app punya volumenya sendiri

<sub>1.45.0 · 13 Oktober 2026</sub>

Kecilkan panggilan yang terlalu keras, bisukan game yang berisik, dan biarkan musik Anda apa adanya.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.45.0/app-volume-dark.png"><img src="../media/whats-new/1.45.0/app-volume-light.png" width="340" alt=""></picture>

Buka Pengaturan › Suara dan nyalakan “Volume App”. Setiap app yang memutar suara mendapat slider dan tombol bisu sendiri, di Pengaturan maupun di menu. Volume Mac Anda dan app lain tidak berubah, dan pikapik mengingat level tiap app. App yang Anda biarkan di volume penuh tidak pernah disentuh.

Untuk mengubah volume sebuah app, pikapik meneruskan suaranya melalui dirinya sendiri, jadi ia membutuhkan izin “Perekaman Audio Sistem”, yang Anda izinkan di halaman “Izin”. Suara hanya diteruskan: tidak direkam, disimpan, atau dikirim ke mana pun, dan mikrofon tidak digunakan. Memerlukan macOS 14.2 atau lebih baru (di macOS 14.0 dan 14.1 tetap tersembunyi) dan mati secara default.

**Coba:** Pengaturan › Suara › Volume App

---

## <a id="v1.44.3"></a>Kata yang diketik dengan tata letak yang salah diperbaiki otomatis

<sub>1.44.3 · 13 Oktober 2026</sub>

Ketik kata dengan tata letak papan ketik yang salah, tekan Spasi, lalu pikapik mengetik ulang kata itu dengan tata letak yang benar dan mengganti tata letaknya untuk Anda.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/layout-fix-dark.png"><img src="../media/layout-fix-light.png" width="340" alt=""></picture>

Nyalakan fitur ini di Pengaturan › Papan Ketik. Saat sebuah kata jadi huruf acak tanpa arti, seperti ghbdtn alih-alih привет, pikapik mengetik ulang kata itu begitu Anda menekan Spasi atau Return, lalu mengganti tata letak agar kata berikutnya langsung benar. Fitur ini berfungsi dengan semua tata letak papan ketik yang Anda tambahkan di Mac Anda, dalam bahasa apa pun yang Anda pakai.

Teks biasa tetap persis seperti yang Anda ketik. pikapik hanya mengubah kata jika kata itu tidak ada dalam satu pun bahasa Anda dan tombol yang sama di tata letak lain menghasilkan kata yang umum. Nama, salah ketik, dan kata yang jarang dipakai tetap apa adanya, begitu juga kolom kata sandi, Terminal, dan app yang Anda pilih.

Ada kata yang terlewat, atau ingin mengembalikan kata seperti semula? Tekan ⌃⇧Spasi untuk memperbaiki kata terakhir atau teks yang dipilih, lalu tekan lagi untuk mencoba tata letak lain. Tepat setelah perbaikan, tombol yang sama membatalkannya, dan pikapik tidak akan lagi memperbaiki kata itu secara otomatis. Di versi Mac App Store, pilih teksnya, lalu pilih “Perbaiki Tata Letak Papan Ketik” di menu Layanan.

**Coba:** Pengaturan › Papan Ketik › Perbaiki kata yang diketik dengan tata letak yang salah

---

## <a id="v1.44.2"></a>VoiceOver kembali bisa membuka menu pikapik

<sub>1.44.2 · 13 Oktober 2026</sub>

Di macOS 27, Anda kembali bisa membuka menu pikapik di bar menu dengan VoiceOver.

Sebelumnya, tidak terjadi apa-apa saat Anda mengaktifkan ikon pikapik dengan VoiceOver atau alat aksesibilitas lain. Sekarang menu terbuka, dan saat ikon diaktifkan lagi, menu tertutup, sama seperti klik.

---

## <a id="v1.44.0"></a>Lihat program mana yang memakai port

<sub>1.44.0 · 13 Oktober 2026</sub>

Halaman Port yang baru di Pengaturan menunjukkan program mana yang memakai setiap port di Mac Anda, dan membebaskan port saat Anda membutuhkannya.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/ports-dark.png"><img src="../media/ports-light.png" width="340" alt=""></picture>

Saat sebuah program bilang port-nya sudah dipakai, buka Pengaturan › Port. Setiap program yang memakai port ada di sana, lengkap dengan ikonnya, port yang dipakainya, dan apakah perangkat lain di jaringan Anda bisa terhubung. Ketik nomor port untuk mencari siapa yang memakainya, atau untuk melihat bahwa port itu bebas.

Klik sebuah baris untuk melihat alamat yang bisa dibuka di browser, file program, perintah yang menjalankannya, folder-nya, dan nomor prosesnya. “Bebaskan” meminta program keluar agar sempat menyimpan pekerjaannya. Jika program tidak tertutup, pikapik menawarkan untuk memaksanya keluar. Kedua langkah itu meminta persetujuan Anda dulu.

Bagian dari macOS dan program milik pengguna lain tidak disentuh. Untuk Penerima AirPlay, Berbagi File, Berbagi Layar, dan Masuk Jarak Jauh, pikapik memberi tahu saklar mana di Pengaturan Sistem yang membebaskan port. Di versi Mac App Store, “Bebaskan” menampilkan program, menyalin perintah untuk menutupnya di Terminal, atau membuka Monitor Aktivitas.

---

## <a id="v1.43.0"></a>Lihat apa yang berjalan di latar belakang

<sub>1.43.0 · 13 Oktober 2026</sub>

pikapik kini menampilkan semua yang mulai berjalan sendiri beserta app yang menambahkannya, dan mematikan tugas milik Anda tanpa menghapus apa pun.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.43.0/background-dark.png"><img src="../media/whats-new/1.43.0/background-light.png" width="340" alt=""></picture>

Halaman Tugas Latar Belakang yang baru di Pengaturan menampilkan app yang terbuka saat masuk, layanan latar belakang, pembantu di dalam app, dan sisa app yang sudah dihapus. Setiap tugas menunjukkan app mana yang menambahkannya, apakah sedang berjalan sekarang, dan di mana file-nya berada. Sekali klik, file-nya tampil di Finder.

Tugas milik Anda sendiri bisa dimatikan dan dinyalakan lagi dengan satu tombol. Tidak ada yang dihapus. Untuk tugas bagi semua pengguna dan untuk seluruh Mac, tombolnya membuka Item Login di Pengaturan Sistem.

Di versi Mac App Store, halaman ini menampilkan tugas, dan tombol-tombolnya membuka Item Login.

---

## <a id="v1.42.0"></a>Lihat seberapa hangat bagian dalam Mac Anda

<sub>1.42.0 · 13 Oktober 2026</sub>

Halaman Suhu yang baru di Pengaturan menunjukkan seberapa panas prosesor, grafis, memori, penyimpanan, baterai, dan Wi-Fi, serta memberi tahu dengan kata-kata sederhana apakah semuanya baik-baik saja.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/temperatures-dark.png"><img src="../media/temperatures-light.png" width="340" alt=""></picture>

Buka Pengaturan › Suhu. Di bagian atas, satu kata merangkum semuanya: “Normal”, “Hangat”, “Panas”, atau “Sangat panas”, dan satu baris pendek di bawahnya memberi tahu apakah Mac Anda berjalan dengan kecepatan penuh atau melambat agar dingin. Lebih ke bawah, setiap komponen yang bisa diukur Mac Anda punya baris sendiri berisi suhunya dan bilah berwarna: hijau berarti aman, kuning berarti hangat, dan oranye berarti panas, sesuai dengan suhu yang normal untuk komponen itu.

Ingin selalu memantau suhu? Klik pensil di bagian bawah menu pikapik dan centang “Suhu”. Setelah itu, menu menampilkan kata yang sama dan suhu prosesor, dan klik pada barisnya membuka halaman ini.

Suhu diperbarui setiap dua detik, tetapi hanya selama halaman atau menu terbuka, jadi tidak ada yang diperiksa di latar belakang. pikapik hanya membaca suhu: tidak perlu kata sandi dan tidak ada yang diubah.

**Diperbaiki**

- Jika Anda sudah memilih baris yang ditampilkan menu pikapik, baris “Pertahankan Dock di satu layar” tidak lagi muncul sendiri di sana. Untuk menampilkannya, klik pensil dan centang baris itu.
- Saat Anda menutup Pengaturan, pikapik kini langsung berhenti memeriksa kipas dan baterai, tidak lagi terus berjalan di latar belakang.

---

## <a id="v1.41.1"></a>Kontrol kipas tidak lagi meminta kata sandi

<sub>1.41.1 · 13 Oktober 2026</sub>

Pembantu yang mengatur kecepatan kipas kini diperbarui bersama pikapik, jadi versi baru tidak lagi meminta kata sandi administrator.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Pembaruan ini memintanya untuk terakhir kali. Jika Anda memakai kontrol kipas, buka Pengaturan › Izin, klik “Izinkan” di samping “Kontrol kipas”, lalu masukkan kata sandi. Setelah itu pikapik memperbarui pembantunya sendiri dan hanya menerima pembantu yang benar-benar berasal dari pikapik.

**Diperbaiki**

- Di Pengaturan Sistem › Umum › Item Login, pembantu kipas kini tampil sebagai pikapik, lengkap dengan ikon app.

---

## <a id="v1.41.0"></a>Lihat kondisi baterai Anda

<sub>1.41.0 · 13 Oktober 2026</sub>

Halaman Baterai yang baru di Pengaturan menunjukkan seberapa aus baterai, apa yang mengisinya, dan cara membuatnya lebih awet.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/battery-dark.png"><img src="../media/battery-light.png" width="340" alt=""></picture>

Buka Pengaturan › Baterai. Anda melihat tingkat pengisian dan apa yang sedang terjadi pada baterai saat ini, kondisinya, kapasitas maksimum dibandingkan saat masih baru, dan jumlah siklus yang sudah terpakai dari 1.000 siklus yang dirancang.

Saat Mac Anda tersambung ke listrik, halaman ini menampilkan adaptor daya dan wattnya, dan saat mengisi daya juga daya pengisian, yaitu seberapa banyak daya yang masuk ke baterai saat ini. Saat Mac Anda berjalan dengan baterai, halaman ini menampilkan berapa banyak daya yang sedang dipakainya.

Tips di bagian bawah membantu baterai bertahan lebih lama, dan “Pengaturan Baterai…” membuka Baterai di Pengaturan Sistem, tempat Anda memilih cara macOS mengisinya. Halaman ini tidak mengubah apa pun dan tidak memerlukan izin apa pun, termasuk di versi Mac App Store. Halaman ini hanya muncul di Mac yang memiliki baterai.

**Diperbaiki**

- Menghapus pikapik dengan Homebrew kini juga mematikan “Buka saat Login” dan mengembalikan pengaturan sistem yang diubah aplikasi, seperti animasi, pengulangan tombol, dan sudut aktif. Jika pikapik selama ini memperbarui dirinya sendiri, jalankan brew upgrade --cask pikapik sekali sebelum menghapusnya.

---

## <a id="v1.40.2"></a>Pembaruan lewat Homebrew tidak lagi memulai ulang Dock

<sub>1.40.2 · 13 Oktober 2026</sub>

Saat Anda memperbarui pikapik lewat Homebrew, Dock tidak lagi menghilang sesaat.

Pembaruan ke versi ini masih bisa memulai ulang Dock untuk terakhir kalinya, karena langkah itu masih dijalankan oleh versi yang Anda pakai sebelumnya. Pembaruan berikutnya tidak akan mengusik Dock lagi.

---

## <a id="v1.40.1"></a>Satu klik di Dock menyingkirkan jendela

<sub>1.40.1 · 13 Oktober 2026</sub>

Klik ikon Dock dari app yang sedang Anda pakai, dan semua jendelanya akan diminimalkan ke Dock. Klik lagi, dan semuanya kembali.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.40.1/dock-minimize-dark.png"><img src="../media/whats-new/1.40.1/dock-minimize-light.png" width="340" alt=""></picture>

Buka Pengaturan › Dock dan nyalakan “Minimalkan atau sembunyikan dengan klik di Dock”. Jendela kembali dengan urutan yang sama, dan jendela yang tadi Anda pakai ada di paling atas. Klik pada app lain, menahan ikon untuk membuka menunya, dan menyeret ikon tetap bekerja seperti biasa.

Lebih suka menyembunyikan seluruh app, seperti dengan ⌘H? Di bawah sakelar, ubah “Saat ikon diklik” menjadi “Menyembunyikan app”. Jika Anda sudah menyembunyikan app dengan klik di Dock, tidak ada yang berubah untuk Anda. Sakelar ini memerlukan izin “Aksesibilitas”, tidak ada di versi Mac App Store, dan mati secara default.

---

## <a id="v1.40.0"></a>Dock tetap di satu layar

<sub>1.40.0 · 13 Oktober 2026</sub>

Dock tidak lagi melompat ke layar lain saat penunjuk menekan tepi layar itu, dan tetap di tempat Anda meletakkannya.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-display-dark.png"><img src="../media/dock-display-light.png" width="340" alt=""></picture>

Buka Pengaturan › Dock dan nyalakan “Pertahankan Dock di satu layar”. Setelah itu Dock tetap di layarnya, di bawah atau di samping, dan sudut aktif tetap berfungsi. Tidak perlu izin apa pun, termasuk di versi Mac App Store.

Untuk memindahkan Dock dengan sengaja, tahan ⌥ dan dorong penunjuk ke tepi layar yang lain. Dock pindah ke layar itu dan tetap di sana sesudahnya.

Sakelar kedua, “Kembalikan Dock”, membawa Dock kembali ke layarnya secara otomatis setelah tidur atau saat layar berubah. Sakelar ini memerlukan izin “Aksesibilitas” dan tidak ada di versi Mac App Store. Kedua sakelar mati secara default.

---

## <a id="v1.39.4"></a>Tombol merah tidak lagi menghentikan arsip

<sub>1.39.4 · 13 Oktober 2026</sub>

Sebelumnya, jika jendela kata sandi ditutup dengan tombol merah, pikapik berhenti membuka dan membuat arsip sampai dimulai ulang. Masalah ini sudah diperbaiki.

Kini tombol merah di jendela kata sandi dan di jendela arsip baru bekerja persis seperti “Batalkan”, dan arsip berikutnya langsung terbuka. VoiceOver kini membacakan tombol pembaruan di Pengaturan › Tentang dengan namanya sendiri.

---

## <a id="v1.39.3"></a>Peliharaan mengikuti ritme Anda

<sub>1.39.3 · 13 Oktober 2026</sub>

Saat Anda mengetik, peliharaan jadi bersemangat dan berjalan riang dengan langkah ringan. Begitu Anda meninggalkan Mac, ia mulai mengantuk, duduk, lalu terkantuk-kantuk.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.3/pet-rhythm-dark.png"><img src="../media/whats-new/1.39.3/pet-rhythm-light.png" width="340" alt=""></picture>

Jika keyboard dan mouse tidak disentuh sekitar 40 detik, matanya mulai berat, dan setelah satu setengah menit ia sudah tidur nyenyak, dengan huruf-huruf z kecil yang melayang naik. Tekan tombol apa saja atau gerakkan mouse, dan ia akan bangun, berdiri, lalu berjalan lagi. Selama tidur, ia tetap diam dan lebih hemat energi.

pikapik tidak pernah melihat apa yang Anda ketik. Ia hanya memeriksa sudah berapa lama sejak tombol terakhir ditekan atau mouse terakhir digerakkan, sama seperti yang dilakukan macOS sebelum meredupkan layar, jadi tidak perlu izin apa pun. Lebih suka peliharaan Anda selalu lincah? Matikan “Mengikuti ritme Anda” di pengaturan peliharaan.

**Coba:** Pengaturan › Peliharaan › Mengikuti ritme Anda

---

## <a id="v1.39.2"></a>Pengaturan yang diselaraskan kini ada di folder pikapik

<sub>1.39.2 · 13 Oktober 2026</sub>

Jika Anda menyelaraskan pengaturan dengan iCloud, pengaturan kini disimpan di iCloud Drive dalam folder bernama pikapik, bukan pika-tools, dan pikapik memindahkannya ke sana sendiri.

<img src="../media/icon.png" width="128" height="128" alt="">

Anda tidak perlu melakukan apa pun: pengaturan Anda tetap sama, dan folder lama hilang setelah pengaturannya dipindahkan. Jika Anda menaruh file sendiri di dalamnya, folder itu tetap di tempatnya. Jika Anda menyelaraskan beberapa Mac, perbarui pikapik di setiap Mac agar tetap berbagi pengaturan.

**Diperbaiki**

- Menghapus pikapik sepenuhnya dengan Homebrew (brew uninstall --zap) kini juga menghapus daftar app yang baru dihapus.
- Postingan lama di halaman ini kini menyebut app ini pikapik.

---

## <a id="v1.39.1"></a>Bilah judul yang biasa di jendela arsip

<sub>1.39.1 · 13 Oktober 2026</sub>

Jendela arsip kembali memiliki bilah judul macOS yang biasa, dengan tiga tombol bulat di kiri.

Anda bisa menyeret jendela dari bagian atasnya, seperti di mana pun di Mac. Di jendela arsip baru dan jendela kata sandi, tombol merah menutup jendela tanpa membuat atau mengekstrak apa pun. Tombol yang tidak berguna di sebuah jendela berwarna abu-abu. Jendela yang menampilkan kemajuan saat membuat salinan lebih kecil atau mengonversi file kini juga punya tombol yang sama. Kini sakelar “Buka arsip dengan app ini” mengingat app yang sebelumnya membuka file ZIP dan 7Z, lalu mengembalikannya ke app itu saat Anda mematikannya.

---

## <a id="v1.39.0"></a>Jendela arsip baru, dan kata sandi diketik dua kali

<sub>1.39.0 · 13 Oktober 2026</sub>

Saat Anda melindungi arsip baru dengan kata sandi, kini Anda mengetiknya dua kali, agar salah ketik tidak membuat Anda terkunci dari file sendiri.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.0/archive-password-dark.png"><img src="../media/whats-new/1.39.0/archive-password-light.png" width="340" alt=""></picture>

Di bawah kolom muncul baris hijau saat kedua kata sandi cocok, atau baris merah saat tidak, dan “Buat” menunggu sampai keduanya sama.

Semua jendela arsip tampil baru: ikon besar, satu sakelar untuk kata sandi, dan satu baris pendek yang memberi tahu apakah nama file tetap terlihat, seperti di ZIP, atau ikut disembunyikan, seperti di 7Z. Di macOS 26, tombolnya terbuat dari Liquid Glass.

Memasang juga jadi lebih mudah: perintah di bagian atas halaman pikapik di GitHub tidak butuh apa pun lagi di Mac Anda. Perintah ini memasang pikapik hanya jika unduhannya ditandatangani pengembangnya dan lolos pemeriksaan malware Apple.

---

## <a id="v1.38.2"></a>Pembaruan lebih aman di samping versi App Store

<sub>1.38.2 · 12 Oktober 2026</sub>

Jika pikapik dari App Store juga ada di Mac Anda, versi GitHub kini diperbarui di tempatnya dan tidak menyentuh versi App Store.

Sebelumnya, jika versi GitHub masih memakai nama lamanya, pika-tools, dan tidak dipasang lewat Homebrew, pembaruan tidak terpasang, versi App Store terbuka sebagai gantinya, dan pembukaan pikapik saat login dimatikan.

---

## <a id="v1.38.1"></a>Menu Finder yang lebih andal

<sub>1.38.1 · 12 Oktober 2026</sub>

Item pikapik di menu klik kanan Finder kini tidak lagi hilang saat Anda menghubungkan disk, membuka image disk, membangunkan Mac, atau beralih ke Finder.

Dalam kasus yang jarang terjadi, program pembantu yang menampilkannya tertutup tepat pada saat itu.

---

## <a id="v1.38.0"></a>Buka dan buat arsip di Finder

<sub>1.38.0 · 12 Oktober 2026</sub>

Arsip di Finder yang baru membuka RAR dan arsip lain yang tidak bisa dibuka macOS, serta membuat ZIP dan 7Z dari menu klik kanan.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/archive-dark.png"><img src="../media/archive-light.png" width="340" alt=""></picture>

Buka Pengaturan › Finder dan nyalakan “Arsip di Finder”. Klik kanan sebuah arsip dan pilih “Ekstrak”, lalu file-nya muncul di sebelahnya. Klik kanan file atau folder lain dan pilih “Buat Arsip…” untuk membuat ZIP, 7Z, TAR.GZ, atau TAR.XZ. ZIP dan 7Z bisa diberi kata sandi, dan arsip apa pun bisa dipisah menjadi beberapa bagian, misalnya 15 MB per bagian untuk email. ZIP yang dibuat dengan cara ini tidak berisi file tersembunyi yang ditambahkan sistem dan menjaga nama dalam bahasa apa pun tetap terbaca.

pikapik juga membuka apa yang tidak bisa dibuka macOS: RAR, bahkan yang terpecah menjadi beberapa file, 7Z yang dikunci dengan kata sandi, ZIPX, CAB, LZH, ARJ, ZST, WIM, dan lainnya. Klik dua kali akan membukanya di pikapik. Nama file di ZIP lama, misalnya yang memakai aksara Sirilik, Jepang, atau Tionghoa, tampil terbaca. Sakelar “Buka arsip dengan app ini” juga menyerahkan ZIP dan 7Z ke pikapik, sementara TAR dan GZ tetap ditangani app arsip bawaan, yang memang sudah menanganinya dengan baik.

Sebuah jendela menanyakan kata sandi, “Berhenti” membatalkan pekerjaan apa pun, dan dari arsip yang rusak pikapik mengambil apa yang masih bisa dibaca. pikapik bertanya dulu sebelum mengekstrak arsip yang akan membengkak menjadi ukuran sangat besar, dan memblokir arsip yang mencoba menulis di luar foldernya sendiri. Tidak ada di versi Mac App Store. Pilih sebuah arsip lalu tekan Spasi untuk melihat isinya.

---

## <a id="v1.37.3"></a>Label FPS kini meminta izin di tempat yang tepat

<sub>1.37.3 · 12 Oktober 2026</sub>

Izin Perekaman Layar untuk label FPS kini diberikan di halaman Izin, bersama semua izin lainnya.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Untuk menghitung frame sebuah game, “Tampilkan FPS” bisa memerlukan Perekaman Layar. Dulu pikapik memintanya langsung di halaman Game. Kini izin itu berada bersama semua izin lainnya: saat “Tampilkan FPS” memerlukannya, baris “Perekaman Layar” muncul di Pengaturan › Izin, dan Anda klik “Izinkan” di sana.

Di halaman Game, Anda kini hanya melihat baris yang biasa di bawah sakelar: “Perlu izin. Klik untuk mengizinkan.” Tombol “Izinkan” di baris itu membawa Anda langsung ke baris “Perekaman Layar”. Menyalakan “Tampilkan FPS” tidak lagi memunculkan pertanyaan dengan sendirinya, dan pikapik tetap tidak pernah meminta apa pun saat Anda bermain.

---

## <a id="v1.37.2"></a>Diperiksa Apple

<sub>1.37.2 · 12 Oktober 2026</sub>

pikapik kini ditandatangani oleh pengembang Apple yang terverifikasi dan diperiksa oleh Apple. Jadi macOS tidak lagi memberi peringatan saat Anda membukanya pertama kali.

Setelah pembaruan ini, macOS mungkin meminta lagi izin yang pernah Anda berikan ke pikapik, seperti Aksesibilitas, Pemantauan Input, atau Akses Disk Penuh. Izinkan sekali lagi di Pengaturan Sistem › Privasi & Keamanan. Jika Anda memakai kontrol kipas, izinkan lagi di pengaturan pikapik, dan macOS akan menanyakan kata sandi satu kali.

---

## <a id="v1.37.1"></a>Label FPS kini mengikuti game Anda tanpa tertinggal

<sub>1.37.1 · 12 Oktober 2026</sub>

Geser jendela game, dan label FPS kini ikut bergerak bersamanya.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Dulu label hanya menyusul jendela yang bergerak sekitar sekali per detik, sehingga tertinggal di belakang. Sekarang label memeriksa jendela di setiap bingkai layar dan paling lambat hanya beberapa milidetik di belakangnya. Saat jendela diam, label lebih jarang memeriksanya, jadi hampir tidak membebani Mac Anda saat bermain. Label juga tidak lagi melompat ke tempat lain saat sebagian jendela melewati tepi layar.

Jika game yang tenang seperti catur menampilkan 0, itu wajar: game seperti itu hanya membuat gambar baru saat ada yang bergerak. Angkanya naik saat bidak bergeser dan kembali ke 0 saat papan diam.

---

## <a id="v1.37.0"></a>Lihat seberapa mulus game berjalan

<sub>1.37.0 · 12 Oktober 2026</sub>

Tampilkan FPS yang baru menaruh penghitung kecil di sudut game Anda, sehingga Anda langsung tahu seberapa mulus game berjalan.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Buka Pengaturan › Game dan nyalakan “Tampilkan FPS”. Selama Mode Game aktif, label kecil gelap berisi angka muncul di sudut game mana pun. FPS artinya frame per detik: berapa banyak gambar yang digambar game setiap detik, dan makin tinggi angkanya, makin mulus game berjalan. Klik sudut pada gambar di atas sakelar untuk memilih letak label.

Klik langsung menembus label, dan label mengikuti jendela game. Tanda hubung berarti frame pertama belum datang, dan angka 0 yang pudar berarti game berhenti menggambar. “Tampilkan FPS” mati sampai Anda menyalakannya.

Di macOS 27, sebagian besar game dihitung oleh macOS sendiri, jadi tidak perlu izin. Beberapa game, biasanya yang lama, hanya bisa dihitung lewat perekaman layar, dan saat itu angkanya tidak bisa melebihi kecepatan refresh layar. Di macOS 14–26 dan di versi Mac App Store, semua game dihitung dengan cara ini, jadi saat “Tampilkan FPS” dinyalakan, pikapik meminta “Perekaman Layar”. Tidak ada gambar yang disimpan atau dikirim.

---

## <a id="v1.36.0"></a>Hapus app tanpa khawatir

<sub>1.36.0 · 12 Oktober 2026</sub>

Hapus App yang baru menghapus sebuah app beserta semua filenya, dan mengembalikan semuanya jika Anda berubah pikiran.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/uninstaller-dark.png"><img src="../media/uninstaller-light.png" width="340" alt=""></picture>

Buka Pengaturan › Hapus App dan pilih sebuah app, atau seret app ke gambar. pikapik menampilkan semua yang disimpan app itu di Mac Anda, lengkap dengan alasan untuk setiap file. File yang jelas milik app diberi centang, sedangkan file yang hanya mungkin terkait tidak. Klik “Pindahkan ke Tong Sampah”, dan semuanya masuk ke Tong Sampah, jadi tidak ada yang dihapus permanen.

Berubah pikiran? Klik “Kembalikan”, dan semuanya kembali ke tempat semula. Sepuluh penghapusan terakhir menunggu di “Baru dihapus” selama file-nya masih ada di Tong Sampah. “Reset app” mempertahankan app dan hanya menghapus data tersimpan, pengaturan, dan file sementara miliknya, kalau app itu bermasalah.

Anda sendiri yang memindahkan app ke Tong Sampah? Halaman ini juga menampilkan app seperti itu beserta file yang ditinggalkannya, dan Anda bisa menyalakan sakelar yang menawarkan pembersihan setiap kali ada app masuk ke Tong Sampah. Tidak ada yang dihapus sebelum Anda memilih. Agar semuanya terlihat, halaman ini memerlukan Akses Disk Penuh.

---

## <a id="v1.35.0"></a>Dandani peliharaan Anda

<sub>1.35.0 · 12 Oktober 2026</sub>

Peliharaan Anda kini punya lemari pakaian, dan Anda meraih barang baru untuk dipakainya sambil bermain bersama.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.35.0/wardrobe-dark.png"><img src="../media/whats-new/1.35.0/wardrobe-light.png" width="340" alt=""></picture>

Buka Pengaturan › Peliharaan dan pilih apa yang dipakai peliharaan Anda: topi, kacamata, syal, kaus, sepatu, jubah, bahkan sayap. Dia langsung memakainya. Beberapa barang gratis, sisanya adalah penghargaan yang datang saat Anda bermain bersama: angkat peliharaan lalu lempar, tendang bolanya, lihat dia memanjat jendela dan mengobrol, atau sekadar temani dia hari demi hari. Saat Anda meraih penghargaan, peliharaan akan memberi tahu Anda.

Gaya siap pakai mendandani peliharaan dari kepala sampai kaki dengan sekali klik: penyihir, bajak laut, astronaut, pahlawan super, raja, dan masih banyak lagi. Setiap gaya siap dipakai setelah Anda meraih semua bagiannya.

Hanya angka sederhana yang disimpan, seperti langkah, lemparan, dan hari bersama. Angka itu tetap di Mac Anda, tidak ada yang dikirim ke mana pun, dan Anda bisa menghapusnya kapan saja di Pengaturan › Peliharaan.

---

## <a id="v1.34.0"></a>Mouse dan trackpad di dalam game

<sub>1.34.0 · 12 Oktober 2026</sub>

Gesekan, cubitan, dan sudut aktif kini tidak lagi mengeluarkan Anda dari game, seperti pintasan keyboard.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.34.0/pointer-shortcuts-dark.png"><img src="../media/whats-new/1.34.0/pointer-shortcuts-light.png" width="340" alt=""></picture>

Di Pengaturan › Game › Pengaturan game lainnya ada grup “Mouse dan trackpad”. Grup ini hanya menampilkan apa yang aktif di macOS pada Mac Anda, dengan nama dari Apple dan gambar kecil untuk setiap item: pintasan pada tombol mouse, geser antar desktop dan app layar penuh, Mission Control dan App Exposé, cubit untuk app dan rentangkan untuk Desktop, geser dari tepi kanan untuk Pusat Pemberitahuan, dan setiap sudut aktif beserta aksinya. Selama game berada di depan, semuanya dijeda, jadi geseran tak sengaja atau sentuhan di sudut layar tidak akan mengeluarkan Anda dari game. Gestur di dalam game tetap berfungsi. Setiap item bisa diatur agar bekerja seperti biasa.

---

## <a id="v1.33.2"></a>Grup pintasan terbuka seketika

<sub>1.33.2 · 11 Oktober 2026</sub>

Grup pintasan sistem yang paling panjang pun langsung terbuka, dan setiap baris punya nama yang jelas.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Dulu jendela pengaturan sempat macet sebentar saat grup berisi puluhan baris dibuka, karena semua baris beserta pratinjau animasinya dibuat sekaligus. Sekarang hanya baris yang terlihat dan beberapa di sekitarnya yang dibuat. Baris bernama “Tindakan sistem” dengan sebuah angka juga hilang: Dikte, Siri, serta tombol kecerahan dan zoom menampilkan nama aslinya, dan tindakan yang tidak diberi nama oleh macOS disembunyikan, tetapi tetap dijeda saat bermain game seperti sebelumnya.

---

## <a id="v1.33.1"></a>Grup pintasan terbuka tanpa macet

<sub>1.33.1 · 11 Oktober 2026</sub>

Halaman Game tetap lancar saat daftar panjang berisi pratinjau dibuka.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Sebelumnya, membuka grup pintasan keyboard sistem membuat jendela pengaturan macet hingga tiga detik, karena setiap baris beserta pratinjaunya dihitung berkali-kali. Kini setiap baris hanya dihitung sekali, sehingga grup terbuka hampir seketika.

---

## <a id="v1.33.0"></a>Semua izin di satu tempat

<sub>1.33.0 · 11 Oktober 2026</sub>

Pengaturan › Izin kini menampilkan semua yang dipakai pikapik dan memungkinkan Anda mencabut izin apa pun.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.33.0/permissions-dark.png"><img src="../media/whats-new/1.33.0/permissions-light.png" width="340" alt=""></picture>

Pengaturan › Izin kini menampilkan setiap izin yang dipakai pikapik, dari Aksesibilitas dan Pemantauan Input hingga Kontrol kipas, Ekstensi Finder, iCloud Drive, dan Akses Disk Penuh. Setiap baris menjelaskan dalam satu kalimat kegunaannya, dengan tanda centang hijau saat aktif dan tanda silang oranye saat belum ada.

Setiap baris punya satu tombol: Izinkan saat izin belum ada, Matikan saat sudah aktif. Jadi Anda bisa mencabut izin apa pun langsung di sana, tanpa mencari-cari di Pengaturan Sistem. Untuk Aksesibilitas dan Pemantauan Input, pikapik bertanya dulu lalu memulai ulang tanpa izin tersebut.

Alat yang membutuhkan izin yang belum Anda berikan tampak setengah abu-abu. Klik alat itu, lalu Izin terbuka dengan baris yang tepat disorot, siap untuk satu klik pada Izinkan.

**Coba:** Buka Pengaturan › Izin dan lihat setiap barisnya. Klik alat yang abu-abu untuk langsung menuju izin yang dibutuhkannya.

---

## <a id="v1.32.2"></a>Pemasangan lebih aman, dan pembaruan tidak pernah menghilangkan aplikasi

<sub>1.32.2 · 11 Oktober 2026</sub>

Serangkaian perbaikan agar memasang, memperbarui, dan menghapus lebih aman.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Pembantu kipas kini dipasang lebih hati-hati dan diperiksa sebelum dijalankan. Jika pembaruan tidak bisa disalin, pikapik Anda yang sekarang tetap di tempatnya. Saat dihapus, pembantu kipas ikut dibuang, dan pengaturan pengulangan tombol, sudut Dock, serta pintasan sistem Anda dikembalikan.

Tombol yang ditahan tidak lagi macet saat sebuah alat dimulai ulang, dan saat “Ulangi tombol yang ditahan” dimatikan, pengaturan menu aksen milik Anda kembali. Hewan peliharaan beristirahat saat layar tidur atau terkunci, dan salinan archive.tar.gz kini bernama archive 2.tar.gz.

---

## <a id="v1.32.1"></a>Kecepatan kipas manual langsung berlaku pada percobaan pertama

<sub>1.32.1 · 11 Oktober 2026</sub>

Memilih Manual di Kipas tidak lagi kembali ke Otomatis.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Kadang ketukan pertama pada Manual mengembalikan kipas ke Otomatis dengan peringatan keamanan, dan baru ketukan kedua yang berhasil. Sekarang Manual bertahan sejak percobaan pertama.

Jika sebuah kipas keluar dari mode Manual dengan sendirinya, pikapik kini benar-benar mengembalikannya ke Otomatis, sehingga yang Anda lihat selalu sama dengan yang dilakukan Mac Anda.

Anda tidak perlu mengizinkan apa pun lagi. Perbarui, lalu langsung berfungsi.

**Coba:** Buka Pengaturan › Kipas dan pilih Manual.

---

## <a id="v1.32.0"></a>Lihat seberapa cepat kipas Anda berputar

<sub>1.32.0 · 11 Oktober 2026</sub>

Tab Kipas yang baru menampilkan setiap kipas secara langsung dan memungkinkan Anda memilih kecepatannya.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Kipas kini punya tab sendiri di Pengaturan dan satu baris di menu. Anda melihat secara langsung seberapa cepat tiap kipas berputar saat ini, dengan kipas kecil yang ikut berputar di sebelahnya.

Biarkan di Otomatis, dan Mac Anda yang memutuskan seperti biasa. Atau pilih Manual dan geser satu penggeser untuk mengatur kecepatan yang Anda mau. Pertama kali, Anda mengizinkannya sekali dengan kata sandi administrator, dan selesai.

Dibuat agar aman. Kipas kembali ke Otomatis saat Anda keluar dari pikapik, saat Mac masuk mode tidur, jika pikapik berhenti karena error, atau saat Mac menjadi panas.

**Coba:** Buka Pengaturan › Kipas dan lihat kecepatannya. Pilih Manual untuk mencoba penggesernya.

---

## <a id="v1.31.4"></a>Detail saat dibutuhkan

<sub>1.31.4 · 11 Oktober 2026</sub>

Halaman game lebih tenang dan satu pencarian.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.4/game-choices-dark.png"><img src="../media/whats-new/1.31.4/game-choices-light.png" width="340" alt=""></picture>

Setiap mode menjelaskan fungsinya di dalam daftar tarik turun. Saat ditutup, hanya nama pilihan yang tersisa di halaman.

Deskripsi yang mengulang nama tindakan dihapus. Informasi tambahan yang berguna tetap ada.

Pencarian global menemukan tindakan sistem berdasarkan nama, makna, dan tombol. Memilih hasil membuka dan menyorot pengaturan yang tepat.

**Coba:** Temukan tindakan di pencarian global dan buka daftar modenya.

---

## <a id="v1.31.3"></a>Satu tampilan untuk pengaturan game

<sub>1.31.3 · 11 Oktober 2026</sub>

Pratinjau seragam dan pilihan pintasan yang lebih jelas.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.3/game-preview-dark.png"><img src="../media/whats-new/1.31.3/game-preview-light.png" width="340" alt=""></picture>

Setiap pintasan kini memiliki pratinjau lebar yang sama dengan perlindungan game dan halaman pengaturan lain. Deskripsi, kontrol, dan penjelasan pilihan berada di bawahnya.

«Ikuti aturan Mode Game». Pintasan singkat mengganti bahasa tanpa menu. Tombol game yang ditahan mencegah perubahan tidak sengaja.

«Nonaktifkan dalam game». Tindakan macOS ini dinonaktifkan saat game berada di depan. Setelah Anda meninggalkan game, tindakan berfungsi seperti semula. «Izinkan dalam game». macOS menjalankan tindakan secara normal, meski membuka jendela atau memindahkan fokus dari game.

**Coba:** Buka pengaturan game tambahan, perluas kontrol sistem, lalu pilih perilaku tindakan saat bermain.

---

## <a id="v1.31.2"></a>Pengaturan game yang lebih jelas

<sub>1.31.2 · 11 Oktober 2026</sub>

Sesuaikan perlindungan dan jelajahi pintasan Mac Anda.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.2/game-settings-dark.png"><img src="../media/whats-new/1.31.2/game-settings-light.png" width="340" alt=""></picture>

Delapan topik jelas menggantikan folder yang berulang. Setiap judul memiliki nama, penjelasan, ikon, dan jumlah. Klik di mana saja pada baris untuk membukanya.

Setiap tindakan menjelaskan fungsinya di samping pratinjau animasi. Tombol saat ini dan perilaku dalam game memiliki baris tersendiri. Pencarian juga menemukan deskripsi.

Tombol yang belum ditetapkan memiliki tautan jelas ke Pengaturan Sistem. Perlindungan game umum dikumpulkan terpisah, dan pilihan Anda tetap tersimpan.

**Coba:** Buka pengaturan game tambahan, perluas topik, lalu bandingkan deskripsi tindakan dengan pratinjaunya.

---

## <a id="v1.31.1"></a>Gestur bahasa dalam game

<sub>1.31.1 · 11 Oktober 2026</sub>

Sederhana secara bawaan, dengan katalog sistem lengkap saat diperlukan.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/input-switch-dark.png"><img src="../media/input-switch-light.png" width="340" alt=""></picture>

Gestur bahasa pikapik berfungsi dalam game meskipun pintasan bahasa macOS belum ditetapkan atau dinonaktifkan.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Otomatis menjeda tindakan yang membuka jendela atau memindahkan fokus. Pintasan bahasa singkat yang disengaja mengganti sumber tanpa jendela sistem. Tombol gerak yang ditahan punya prioritas, jadi berlari dan melompat tidak mengganti bahasa tanpa sengaja.

Setiap tindakan bisa diatur dalam katalog yang dapat dicari. Bahasa bisa berjalan di latar; tindakan lain bisa dijeda atau diizinkan seperti biasa. Pilihan disinkronkan. Aplikasi lain yang memantau tombol tampil terpisah. Paksa Keluar tetap tersedia.

**Coba:** Tahan ⌥ dan ketuk ⇧: bahasa berikutnya. Tahan ⇧ dan ketuk ⌥: sebelumnya

---

## <a id="v1.31.0"></a>Mode Game tahu pintasan Mac kamu

<sub>1.31.0 · 11 Oktober 2026</sub>

Sederhana secara bawaan, dengan katalog sistem lengkap saat diperlukan.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Nyalakan Mode Game dan bermain. Pengaturan game lainnya memuat katalog Mac, tombol saat ini dan pratinjau animasi untuk setiap tindakan.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Otomatis menjeda tindakan yang membuka jendela atau memindahkan fokus. Pintasan bahasa singkat yang disengaja mengganti sumber tanpa jendela sistem. Tombol gerak yang ditahan punya prioritas, jadi berlari dan melompat tidak mengganti bahasa tanpa sengaja.

Setiap tindakan bisa diatur dalam katalog yang dapat dicari. Bahasa bisa berjalan di latar; tindakan lain bisa dijeda atau diizinkan seperti biasa. Pilihan disinkronkan. Aplikasi lain yang memantau tombol tampil terpisah. Paksa Keluar tetap tersedia.

**Coba:** Buka pengaturan tambahan, cari pintasan tangkapan layar atau bahasa dan bandingkan pratinjau dengan dan tanpa perlindungan.

---

## <a id="v1.30.14"></a>Tautan pintasan terbuka tanpa crash

<sub>1.30.14 · 11 Oktober 2026</sub>

Mengeklik pintasan yang mati tidak lagi menutup pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Di halaman Game, kamu bisa mengeklik pintasan meski belum ada tombol yang ditetapkan. Pengaturan Sistem terbuka dengan aman.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Sebelumnya pikapik bisa membaca baris yang berubah dua kali saat jendela terbuka. Jika teks hilang di antara bacaan, aplikasi crash.

Setiap baris kini dibaca sekali. Teks yang hilang dilewati. Perbaikan juga mencakup tautan pintasan di halaman lain.

**Coba:** Klik pintasan yang mati di halaman Game.

---

## <a id="v1.30.13"></a>Tahan Control dan terus bermain

<sub>1.30.13 · 10 Oktober 2026</sub>

Control tidak lagi membiarkan pergantian bahasa mengambil Spasi dari game.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Tahan Control untuk berlari dan tekan Spasi untuk melompat. Dalam Mode Game, pergantian bahasa dengan Control+Spasi dan Control+Option+Spasi dijeda.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Pintasan macOS lain dengan Control, atau Shift dan Option tanpa Command, juga dijeda, termasuk pilihan sendiri. Tekanan, pelepasan dan tombol yang ditahan tetap mencapai game bersama.

Gestur bahasa pikapik dan pintasan keluar dengan pengubah game juga tidak mengganggu. Saat meninggalkan game, pintasan sistem kembali persis seperti sebelumnya.

**Coba:** Tahan Control, bergerak dan tekan Spasi beberapa kali. Lalu tinggalkan game dan ganti bahasa seperti biasa.

---

## <a id="v1.30.12"></a>Seret game dari Monitor Aktivitas

<sub>1.30.12 · 10 Oktober 2026</sub>

Mode Game menerima proses yang diseret dari Monitor Aktivitas.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Cari proses game lalu seret barisnya ke Game Anda di Pengaturan → Game.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Game Java juga bekerja tanpa ikon biasa di Dock. Sebelumnya baris ini diabaikan karena berisi nomor dan nama proses, bukan file.

Game tersimpan untuk peluncuran berikutnya. Minecraft tampil dengan namanya sendiri. Nomor dan nama harus cocok dengan proses yang berjalan.

**Coba:** Seret baris java Minecraft yang sedang terbuka ke Game Anda.

---

## <a id="v1.30.11"></a>Tambahkan game saat sedang berjalan

<sub>1.30.11 · 10 Oktober 2026</sub>

Game yang terbuka kini tampil pertama saat menambahkan game.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Buka Pengaturan → Game → Tambahkan Game dan klik game yang berjalan. Game melalui Java dan lingkungan lain juga tampil, meski tanpa file .app. Minecraft tampil sebagai Minecraft, bukan java.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Aplikasi di Dock kini punya daftar terpisah yang bisa dibuka, agar game yang berjalan langsung ditemukan.

Lainnya… dan seret dan lepas juga menerima file yang dapat dijalankan dari game, selain aplikasi. Setelah ditambahkan, Mode Game menyala saat beralih ke game.

**Coba:** Biarkan game terbuka, pilih Tambahkan Game, lalu klik ikonnya. Tidak perlu mencari folder.

---

## <a id="v1.30.10"></a>Peliharaanmu tetap terlihat saat melompat

<sub>1.30.10 · 10 Oktober 2026</sub>

Peliharaanmu tak lagi menghilang di balik jendela saat melompat di layar tanpa Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Dulu, kalau Dock ada di layar lain atau disembunyikan, peliharaanmu melompat ke balik jendela dan menghilang sampai mendarat. Sekarang, begitu lepas dari tanah, ia tampil di depan jendela di layar mana pun, ada Dock atau tidak. Bolanya juga begitu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Jendela yang hanya menyentuh tepi peliharaanmu tak lagi menyembunyikannya saat melompat. Peliharaanmu tetap di balik jendela hanya kalau jendela itu benar-benar menutupinya, seperti video yang sedang kamu tonton.

Di tanah, peliharaanmu dan bolanya berjalan-jalan di balik jendelamu seperti biasa.

**Coba:** Biarkan Dock bersembunyi otomatis atau pindahkan ke layar lain, lalu tekan Spasi di samping jendela. Peliharaanmu melompat di depannya.

---

## <a id="v1.30.9"></a>Layar penuh milikmu, dan bolanya main jujur

<sub>1.30.9 · 10 Oktober 2026</sub>

Peliharaanmu tak lagi muncul di video layar penuh, dan bolanya tak lagi menabrak hal yang tidak ada.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Dulu, saat kamu menonton video layar penuh, peliharaanmu kadang muncul. Sekarang pikapik bertanya langsung ke macOS apakah sebuah layar sedang dalam mode layar penuh, lalu memeriksa sekali lagi setelah peralihannya selesai. Peliharaanmu dan bolanya tetap bersembunyi sampai kamu keluar dari layar penuh.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Bola tak lagi memantul dari udara kosong. Ia terbang melewati Dock alih-alih menabrak dinding tak terlihat di atasnya. Mouse sekarang mengenai bola hanya saat penunjuk benar-benar menyentuhnya. Sentuhan ringan membuatnya menggelinding, ayunan cepat membuatnya terbang. Dan kalau peliharaanmu atau bolanya bersembunyi di balik jendela, mouse di atas jendela itu tidak mengganggu mereka.

Menyeret file di desktop tak lagi membuat pijakan untuk peliharaanmu. Hanya bingkai pilihan yang melakukannya.

**Coba:** Tonton video dalam layar penuh dan jeda beberapa kali dengan Spasi. Peliharaanmu tidak muncul. Lalu sentil bola dengan mouse.

---

## <a id="v1.30.8"></a>Sudut layar tetap tenang saat kamu bermain

<sub>1.30.8 · 10 Oktober 2026</sub>

Di Mode Game, mouse di tepi dan sudut layar tidak lagi memicu sudut aktif atau menarik keluar Dock yang tersembunyi.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Dulu, di tengah permainan, mouse di sudut atau tepi layar bisa memicu sudut aktif atau menarik keluar Dock yang tersembunyi.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Sekarang Mode Game mematikan sudut aktif dan Dock tersembunyi selama kamu bermain. Beberapa detik setelah kamu keluar dari game, atau saat menutup pikapik, semuanya kembali persis seperti semula.

Dan penunjuk tidak lagi tersendat di tepi layar tempat game berjalan.

**Coba:** Nyalakan Mode Game, mulai game, lalu gerakkan mouse ke sudut layar. Tidak ada yang muncul.

---

## <a id="v1.30.7"></a>Peliharaanmu tidak lagi menerobos videomu

<sub>1.30.7 · 10 Oktober 2026</sub>

Saat peliharaanmu atau bolanya ada di balik jendela, mereka tetap di sana meski melompat atau terbang.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Dulu, kalau peliharaanmu atau bolanya bersembunyi di balik video atau game, satu lompatan atau terbang bisa memunculkannya tepat di atas yang sedang kamu tonton. Menekan Spasi untuk menjeda video juga memancing peliharaanmu keluar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Sekarang mereka tetap di balik jendela yang menutupinya, apa pun yang mereka lakukan. Dan video layar penuh di Firefox langsung menyembunyikan mereka.

Di balik jendela biasa, mereka tetap bersembunyi seperti dulu.

**Coba:** Putar video di jendela besar yang menutupi bagian bawah layar dan tekan Spasi untuk menjedanya. Peliharaanmu tetap di balik video.

---

## <a id="v1.30.6"></a>Saat layar penuh, peliharaanmu istirahat di semua layar

<sub>1.30.6 · 10 Oktober 2026</sub>

Selama ada aplikasi dalam layar penuh, peliharaanmu dan bolanya kini bersembunyi di semua layar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Dulu, saat kamu membuka video atau game dalam layar penuh, peliharaanmu dan bolanya kadang kabur ke layar lain dan terus bermain di sana.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Sekarang, selama ada aplikasi dalam layar penuh, mereka bersembunyi di semua layarmu. Keluar dari layar penuh, dan mereka langsung kembali.

Di balik jendela biasa, mereka tetap bersembunyi seperti dulu.

**Coba:** Kalau kamu punya dua layar, putar video dalam layar penuh di salah satunya. Peliharaanmu dan bolanya hilang dari keduanya dan kembali saat kamu keluar dari layar penuh.

---

## <a id="v1.30.5"></a>Peliharaanmu minggir saat kamu menonton atau bermain

<sub>1.30.5 · 10 Oktober 2026</sub>

Peliharaanmu dan bolanya kini bersembunyi saat aplikasi dalam layar penuh, juga di Mac dengan notch.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Dulu, di Mac dengan notch, peliharaanmu bisa tetap di atas video atau game layar penuh, dan bolanya kadang muncul di atas aplikasi layar penuh di layar lain.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Sekarang, selama aplikasi memenuhi seluruh layar, peliharaanmu dan bolanya menunggu di luar pandangan. Keluar dari layar penuh, dan mereka langsung kembali.

Di balik jendela biasa, mereka tetap bersembunyi seperti dulu.

**Coba:** Putar video dalam layar penuh atau mulai game. Peliharaanmu dan bolanya tidak mengganggu sampai kamu selesai.

---

## <a id="v1.30.4"></a>Peliharaanmu tetap terlihat saat melompat atau menumpang kotak pilihan

<sub>1.30.4 · 10 Oktober 2026</sub>

Peliharaanmu dan bolanya tidak lagi hilang di balik jendela saat sedang di udara.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Dulu, saat peliharaanmu melompati penunjuk atau naik menumpang kotak pilihan, jendela yang diperbesar penuh menutupinya, dan peliharaanmu seolah hilang.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Sekarang, selama peliharaanmu atau bolanya lebih tinggi dari Dock, mereka tampil di depan jendelamu. Begitu kembali ke tanah, mereka masuk lagi ke balik jendela.

Dan peliharaanmu bisa berjalan di balik Dock lagi, sama seperti dulu.

**Coba:** Perbesar jendela hingga penuh, mulai kotak pilihan di desktop di samping Dock supaya peliharaanmu naik ke atasnya, lalu seret pelan-pelan ke atas. Peliharaanmu ikut naik di depan jendela.

---

## <a id="v1.30.3"></a>Peliharaanmu dan bolanya tak lagi masuk ke bawah Dock

<sub>1.30.3 · 9 Oktober 2026</sub>

Peliharaanmu tidak lagi berjalan atau tidur di bawah Dock, jadi kamu selalu bisa melihatnya.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Dulu peliharaanmu dan bolanya sering berjalan dan beristirahat tepat di bawah Dock, tempat tak ada yang bisa melihat mereka. Dengan jendela yang diperbesar penuh, peliharaanmu seolah hilang selamanya.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Sekarang Dock seperti dinding bagi mereka. Peliharaanmu berbalik di tepinya, dan bola memantul darinya.

Jadi peliharaanmu selalu terlihat di samping Dock, bahkan saat jendela memenuhi seluruh layar.

**Coba:** Perbesar jendela hingga penuh dan amati beberapa menit. Peliharaanmu selalu terlihat di kiri atau kanan Dock.

---

## <a id="v1.30.2"></a>Peliharaanmu tidak lagi hilang di balik jendela

<sub>1.30.2 · 9 Oktober 2026</sub>

Meski tertutup jendela, peliharaanmu tetap hidup dan jatuh ke tanah saat kamu melepas pilihan.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Saat jendela menutupi seluruh jalur tempat peliharaanmu tinggal, pikapik menjedanya, dan ia bisa membeku di udara. Sekarang peliharaan dan bolanya tetap hidup di balik jendela: berjalan, jatuh, dan bermain. Hanya gambarnya yang beristirahat.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Jika kotak pilihan mengangkat peliharaanmu di balik jendela, ia langsung jatuh begitu kamu melepasnya, dan kamu melihatnya lagi di dekat Dock.

Dan kotak pilihan tidak lagi mengangkat peliharaanmu lebih tinggi dari jalurnya.

**Coba:** Perbesar jendela hingga penuh, angkat peliharaanmu dengan kotak pilihan di baliknya, lalu lepaskan. Peliharaanmu jatuh dan muncul di dekat Dock.

---

## <a id="v1.30.1"></a>Pilihan di desktop berfungsi lagi

<sub>1.30.1 · 9 Oktober 2026</sub>

Peliharaanmu dan bolanya kembali melompat ke kotak pilihan, dan daftar app hanya menyala untuk app.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Saat Dock atau app desktop jarak jauh menutupi seluruh layar, pikapik tidak menyadari kotak pilihan yang kamu gambar di desktop. Sekarang ia menyadarinya lagi, dan peliharaanmu serta bolanya melompat ke atasnya seperti dulu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Daftar app di pengaturan hanya menyala saat kamu menyeret app ke atasnya. File lain diabaikan: bingkai tidak muncul dan tidak ada yang ikut ditambahkan. Kalau kamu menyeret app bersama file lain, hanya app yang ditambahkan.

Dan bingkainya padam begitu kamu melepas app atau menjauhkan penunjuk.

**Coba:** Gambar kotak pilihan di desktop dan lihat peliharaanmu melompat ke atasnya.

---

## <a id="v1.30.0"></a>Keluar tidak lagi mematikan pikapik

<sub>1.30.0 · 9 Oktober 2026</sub>

Menekan Keluar karena kebiasaan? Pintasan, “Tetap Terjaga”, dan peliharaan Anda tetap berjalan.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/keep-awake-dark.png"><img src="../media/keep-awake-light.png" width="340" alt=""></picture>

Saat Anda memilih “Keluar”, menekan ⌘Q, atau keluar dari pikapik lewat Dock, pikapik menutup jendelanya dan menyembunyikan ikonnya dari bar menu, tetapi tetap bekerja diam-diam di latar: pintasan, “Tetap Terjaga”, dan peliharaan Anda tetap menyala. Untuk mengembalikan ikonnya, cukup buka pikapik lagi.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Ingin benar-benar keluar? Tahan Option (⌥) lalu pilih “Keluar”, atau tekan ⌥⌘Q. Saat pertama kali pikapik masuk ke latar, ia menjelaskan apa yang terjadi dan menawarkan untuk keluar sepenuhnya saat itu juga.

Lebih suka cara lama? Matikan “Tetap berjalan di latar setelah Keluar” di Pengaturan › Umum. Pembaruan, mengganti bahasa, keluar akun, memulai ulang, dan mematikan Mac selalu menutup pikapik sepenuhnya, jadi tidak pernah perlu menunggunya.

**Coba:** Tekan ⌘Q, lalu buka pikapik lagi untuk mengembalikan ikonnya.

---

## <a id="v1.29.1"></a>Peliharaanmu jalan-jalan di semua layar

<sub>1.29.1 · 9 Oktober 2026</sub>

Punya lebih dari satu monitor? Peliharaanmu dan bolanya kini ikut ke mana pun kamu melihat, dan tak pernah hilang.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Saat sampai di tepi satu layar, peliharaanmu langsung pindah ke layar berikutnya, dan bolanya menggelinding mengikuti. Kamu juga bisa mengangkat peliharaan atau bola dengan mouse dan membawanya ke layar mana pun. Kalau sebuah app masuk layar penuh, mereka pindah ke layar lain supaya tidak mengganggu, dan kalau monitor dicabut, mereka kembali ke layar utama.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Bola tak lagi tersangkut di sudut. Peliharaanmu berlari ke sana, mencungkilnya ke belakang lewat atas kepala, lalu terus bermain.

Dan peliharaanmu tak lagi menghilang. Setiap dua detik ia memeriksa apakah masih di layar, dan kalau ada yang salah, setelah tidur, Mac dikunci, ganti desktop, atau layar penuh, ia langsung kembali sendiri.

**Coba:** Bawa peliharaanmu ke layar lain, atau gelindingkan bola ke sudut.

**Diperbaiki**

- Peliharaan yang dilempar tak lagi mendarat di kotak pilihan yang lebih tinggi dari lompatannya, dan tak lagi menghilang karenanya.

---

## <a id="v1.29.0"></a>Peliharaanmu punya bola

<sub>1.29.0 · 9 Oktober 2026</sub>

Sekarang ada bola sepak kecil yang bergulir di tepi bawah layar. Peliharaanmu bermain dengannya, dan kamu juga bisa ikut.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Bolanya bergulir dan memantul seperti bola sungguhan. Peliharaan berlari mengejarnya, menendangnya, lalu mengejarnya lagi. Gerakkan penunjuk cepat ke arah bola untuk menendangnya sendiri, atau ambil bolanya, bawa, dan lempar, sama seperti peliharaan.

Ada trik kecil: klik tempat kosong di desktop lalu seret untuk menggambar kotak pilihan, dengan atau tanpa Shift. Selama tombol mouse ditahan, kotak itu jadi rak: peliharaan melompat ke atasnya, dan bola juga bisa mendarat di sana. Lepaskan, dan raknya hilang.

Lebih suka desktop yang tenang? Matikan Bola di pengaturan peliharaan, dan ia kembali berjalan-jalan sendiri.

**Coba:** Pengaturan › Peliharaan › Bola

**Diperbaiki**

- Di samping Dock, peliharaan kembali melompat setinggi yang ia mau. Ia tetap rendah hanya saat tepat berada di atas Dock, jadi tidak pernah menyembul di atasnya.

---

## <a id="v1.28.0"></a>Tambahkan app dengan sekali klik atau seret

<sub>1.28.0 · 9 Oktober 2026</sub>

Setiap daftar app di Pengaturan kini menampilkan isi Dock Anda dan app yang sedang terbuka, dan Anda bisa menyeret app ke sana dari Finder.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Beberapa fitur membiarkan Anda memilih app tempat fitur itu menyingkir, seperti tombol hijau atau Home dan End. Dulu, “Tambah App…” hanya membuka folder panjang berisi semuanya. Sekarang muncul rak berisi app di Dock dan app yang sedang terbuka. Klik app untuk menambahkannya, klik lagi untuk melepasnya. Untuk yang lain, ada “Lainnya…”.

Anda juga bisa menyeret app dari Finder langsung ke daftar. Daftar akan menyala untuk menunjukkan tempat app itu masuk. Game Anda bekerja dengan cara yang sama, dengan rak yang sama.

Kalau ada yang tidak beres, formulir laporan bug di GitHub kini memungkinkan Anda memilih versi pikapik dan macOS dari daftar, jadi memberi tahu kami lebih cepat.

**Coba:** Pengaturan › Jendela, lalu “Tambah App…”

**Diperbaiki**

- Gulir lewat AnyDesk atau app desktop jarak jauh lain tidak lagi dibalik dua kali saat kedua Mac memakai arah klasik. Kini pikapik hanya membalik gulir dari mouse atau trackpad sungguhan. Jika sebuah app membuat gulir halusnya sendiri, seperti Mos, atur arahnya di app itu.
- Peliharaan tetap di belakang Dock saat melompat, sama seperti saat berjalan, dan kembali sendiri setelah Anda keluar dari app layar penuh atau game.
- Bingkai tipis di sekitar gambar kecil di Pengaturan tidak lagi hilang di layar biasa tanpa Retina.

---

## <a id="v1.27.3"></a>Peliharaan selalu terlihat, dan jendela terbuka siap pakai

<sub>1.27.3 · 9 Oktober 2026</sub>

Peliharaan tidak lagi bersembunyi di balik jendela di tengah lompatan, dan jendela pikapik terbuka langsung siap dipakai.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Saat peliharaan melompati penunjuk atau berguling, ia bisa menyelinap ke balik jendela app lain dan menghilang di udara. Sekarang ia tetap di depan selama melompat dan kembali ke balik jendela Anda begitu mendarat.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Saat pikapik mulai diam-diam di latar belakang, ketika masuk, setelah pembaruan, atau dari tautan pikapik://, jendelanya bisa terbuka abu-abu dan tertinggal di balik jendela lain sampai Anda mengekliknya. Sekarang Pengaturan dan jendela File Baru maju ke depan, siap untuk mengetik.

Hal yang sama berlaku untuk pesan setelah Buat Salinan Lebih Kecil dan daftar tempat Anda memilih app untuk ditambahkan. Anda tidak perlu melakukan apa pun.

**Coba:** Pengaturan › Peliharaan

---

## <a id="v1.27.2"></a>File Baru kembali, dan Pengaturan makin ringan

<sub>1.27.2 · 9 Oktober 2026</sub>

File Baru kembali ada di menu klik kanan Finder untuk semua orang, dan Pengaturan makin sedikit membebani Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Setelah pembaruan terakhir, Finder bisa memulai ulang File Baru di latar belakang dan lupa di folder mana ia bekerja, sehingga pilihan itu diam-diam hilang dari menu klik kanan. Sekarang File Baru mengingatkan Finder tentang foldernya setiap kali dimulai, dan pikapik memeriksa sesaat setelah dibuka bahwa Finder sudah mengingatnya. Kamu tidak perlu melakukan apa pun.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Gambar bergerak di Pengaturan sekarang hanya bergerak saat setidaknya separuh gambar terlihat di layar. Di gambar game, pahlawan kecil tetap bergerak 30 kali per detik, sedangkan bukit dan tanah di belakangnya 15 kali. Jadi halaman Game jauh lebih sedikit membebani Mac. Tampilannya tetap sama.

Setelah pembaruan, pikapik tidak lagi menambahkan ulang pilihan Finder-nya kecuali app benar-benar pindah tempat, jadi Finder tidak perlu memuatnya ulang setiap kali.

**Coba:** Pengaturan › Game

---

## <a id="v1.27.1"></a>Lebih tenang, lebih ringan, dan Finder langsung siap

<sub>1.27.1 · 9 Oktober 2026</sub>

Pengaturan kini hampir tidak membebani Mac, dan item klik kanan di Finder langsung berfungsi setelah pindah ke pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/wheel-lines-dark.png"><img src="../media/wheel-lines-light.png" width="340" alt=""></picture>

Gambar bergerak kecil di Pengaturan dulu menggambar ulang seluruh halaman berkali-kali per detik, jadi jendela yang terbuka membuat Mac sibuk. Sekarang setiap gambar hanya menggambar ulang dirinya sendiri, paling banyak 30 kali per detik, dan beristirahat saat Anda menggulir melewatinya atau menyembunyikan jendela. Tampilannya tetap sama persis.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Setelah pindah dari pika-tools ke pikapik, Finder bisa terus mencari app lama, sehingga “File Baru”, “Konversi ke”, dan item klik kanan lainnya tidak berbuat apa-apa. Sekarang pikapik menyadarinya saat pertama dibuka dan memulai ulang Finder sendiri jika tidak ada jendela Finder yang terbuka dan tidak ada yang sedang disalin. Jika tidak, satu baris singkat di halaman Finder menawarkan tombol “Mulai Ulang Finder”.

Di Pengaturan Sistem, di antara app yang terbuka saat masuk, app kini tampil dengan nama barunya, pikapik, dan tetap menyala.

**Coba:** Pengaturan › Finder

---

## <a id="v1.27.0"></a>Kenalan dengan peliharaan di desktop Anda

<sub>1.27.0 · 9 Oktober 2026</sub>

Kini ada teman kecil yang tinggal di bagian bawah layar Anda, dan app ini punya nama baru: pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Nyalakan di Pengaturan › Peliharaan. Ia berjalan-jalan di belakang jendela dan Dock, melompati penunjuk kalau menghalangi jalannya, dan melompat saat Anda menekan Spasi. Anda bisa mengangkatnya, membawanya, melemparnya, dan menangkapnya lagi di tengah lompatan.

Sesekali ia duduk dan mengucapkan sesuatu yang singkat. Kalau versi baru benar-benar keluar, ia memberi tahu sekali, dan mengekliknya membuka Pengaturan, tempat pembaruan menunggu.

pika-tools sekarang bernama pikapik. Izin, pengaturan, dan tautan di Pintasan tetap seperti semula. Kalau Anda memasangnya lewat Homebrew, jalankan sekali `brew update && brew upgrade --cask pikapik`.

**Coba:** Pengaturan › Peliharaan

**Diperbaiki**

- Pemeriksaan pembaruan mengatakan ada versi baru padahal Anda sudah memakai yang terbaru.
- Halaman Izin membuat Mac sibuk selama terbuka.

---

## <a id="v1.26.2"></a>Yang Baru, dalam bahasa Anda

<sub>1.26.2 · 8 Oktober 2026</sub>

“Yang Baru” di pengaturan kini membuka halaman ini, dalam bahasa yang sama dengan aplikasi.

<img src="../media/icon.png" width="128" height="128" alt="">

Buka Pengaturan › Tentang lalu klik “Yang Baru”. Anda langsung tiba di sini, di halaman dengan gambar untuk setiap pembaruan, dalam bahasa yang digunakan pikapik.

Daftar lengkap perubahan juga lebih rapi. Setiap versi menampilkan hari rilisnya, dan setiap nomor versi membuka halaman unduhannya.

Tidak ada yang berubah dalam cara kerja pikapik. Pembaruan datang seperti biasa, dengan sendirinya atau lewat Homebrew.

**Coba:** Pengaturan › Tentang › Yang Baru

**Diperbaiki**

- “Yang Baru” dulu membuka daftar teknis panjang dalam bahasa Inggris, bukan halaman ini.
- Tautan di daftar perubahan yang tidak mengarah ke mana pun kini membuka halaman yang benar.

---

## <a id="v1.26.1"></a>Gambar game kini hidup

<sub>1.26.1 · 8 Oktober 2026</sub>

Gambar di halaman “Game” kini bergerak, jadi Anda bisa melihat apa yang dihentikan setiap sakelar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.26.1/game-previews-dark.png"><img src="../media/whats-new/1.26.1/game-previews-light.png" width="340" alt=""></picture>

Di balik setiap sakelar di halaman “Game”, kini berjalan sebuah game kecil. Beberapa tombol muncul lalu ditekan, dan Anda melihat apa yang akan muncul di atas game, seperti Spotlight atau Mission Control, sementara game berhenti. Saat sakelar menyala, tombol hanya berpendar lembut dan game terus berjalan. Ubah sebuah sakelar, dan gambar langsung menunjukkan bedanya.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Game kecil itu mengikuti tampilan Mac Anda: siang yang cerah di mode terang, dan malam yang tenang dengan bulan dan bintang di mode gelap.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Di semua gambar dalam app, penunjuk kini bergerak seperti tangan: untuk jarak jauh ia butuh sedikit lebih lama, berhenti dulu, baru kemudian mengeklik. Saat gambar mulai lagi, ia kembali ke awal dengan lembut, bukan melompat. Gambar beristirahat saat jendela tersembunyi, dan dengan “Kurangi gerakan” menyala, gambar diam.

**Coba:** Pengaturan › Game

---

## <a id="v1.26.0"></a>Ikon baru, dan bersih-bersih izin lama

<sub>1.26.0 · 8 Oktober 2026</sub>

pikapik punya wajah baru, dan kini bisa menghapus izin yang ditinggalkan app yang sudah dihapus.

<img src="../media/icon.png" width="128" height="128" alt="">

Ikon barunya adalah tanda pikapik berwarna biru, ungu, dan koral di atas ubin gelap. Bar menu menampilkan bentuk yang sama, yang menyesuaikan diri dengan bar menu terang atau gelap. Saat semua alat mati, bentuknya memudar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>

Saat Anda menghapus app, macOS tetap menyimpan izin yang pernah Anda berikan, dan Pengaturan Sistem tidak punya cara untuk menghapusnya. Kini halaman “Izin” punya daftar bernama “Sisa dari app yang dihapus”: setiap app dengan ikonnya, apa yang dulu diizinkan, dan kapan. “Hapus” membersihkan satu app, “Hapus Semua” membersihkan semuanya, dan app yang Anda pasang lagi hanya akan meminta izin lagi. Untuk melihat daftarnya, beri pikapik Akses Disk Penuh: ia hanya melihat dan tidak mengubah apa pun sampai Anda menekan “Hapus”.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Gambar di halaman “Animasi” dan “Game” digambar ulang sesuai ukuran aslinya, jadi tampak tajam. Jendela mengecil ke Dock dengan sudut membulat, dan penunjuk mengeklik dulu, baru kemudian menu terbuka. Dan di bagian bawah “Tentang” kini ada satu baris yang tenang: “Dibuat dengan sepenuh hati · Traktir saya kopi”. Tidak ada yang tiba-tiba muncul atau mengingatkan Anda.

**Coba:** Pengaturan › Izin, lalu “Sisa dari app yang dihapus”

**Diperbaiki**

- Mengeklik pintasan sistem kini langsung membuka bagiannya sendiri di Pengaturan Sistem, seperti Mission Control, bukan hanya “Papan Ketik”.
- Tip di samping tombol tidak lagi hilang begitu Pengaturan Sistem terbuka.

---

## <a id="v1.25.2"></a>Pintasan terbuka di tempat Anda mengubahnya

<sub>1.25.2 · 8 Oktober 2026</sub>

Klik pintasan di Pengaturan, dan Pengaturan Sistem terbuka di tempat yang tepat.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Dulu, mengeklik pintasan, misalnya untuk Spotlight, selalu membawa Anda ke “Tombol Pengubah”. Sekarang tombol Spotlight langsung membuka Spotlight.

Untuk pintasan lainnya, Pengaturan Sistem terbuka di “Papan Ketik”, dan tip singkat di samping tombol memberi tahu tempat yang perlu diklik: “Pintasan Papan Ketik…”, lalu “Mission Control” atau bagian lain.

Begitu juga di halaman Game dan untuk “Potong file di Finder”. Untuk memotong file, tipnya membawa Anda ke “Pintasan App”.

**Coba:** Pengaturan › Game, lalu klik tombol di samping “Pencarian tidak muncul”

**Diperbaiki**

- Mengeklik pintasan tidak lagi membuka “Tombol Pengubah”.

---

## <a id="v1.25.1"></a>Gambar besar, dan game langsung dari Dock

<sub>1.25.1 · 8 Oktober 2026</sub>

Setiap sakelar kini punya gambar besar, dan “Tambah Game…” menampilkan isi Dock Anda.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

Di halaman Animasi dan Game, semua gambar kini besar, sama seperti gambar di bagian atas halaman. Langsung terlihat apa yang dilakukan tiap sakelar, dan gambarnya tetap bergerak dengan kecepatan yang Anda pilih.

Tekan “Tambah Game…” dan Anda melihat Dock Anda: app yang Anda simpan di sana dan app yang sedang terbuka, dengan urutan yang sama. Game di Dock tetap muncul meski tertutup, Minecraft juga. Satu klik menambahkannya, dan tanda centang menunjukkan game itu sudah ada di daftar. Klik sekali lagi untuk melepasnya.

Anda masih bisa menyeret game ke sini dari Finder. Tidak perlu lagi menariknya keluar dari Dock, jadi Dock tidak akan menawarkan untuk menghapusnya.

**Coba:** Pengaturan › Game, lalu “Tambah Game…”

**Diperbaiki**

- Game yang ada di Dock tetapi tertutup kini muncul di daftar untuk ditambahkan.

---

## <a id="v1.25.0"></a>Tambah game dengan satu klik, dan pilih tombol sendiri

<sub>1.25.0 · 8 Oktober 2026</sub>

Kini Anda memilih game dari app yang sedang terbuka, dan menentukan sendiri tombol untuk keluar dan menutup.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

Tekan “Tambah Game…”, dan app yang sedang terbuka muncul dengan ikon besar, seperti di Dock. Satu klik menambahkan game, atau seret ikonnya ke daftar. Anda juga bisa menjatuhkan game langsung dari Finder atau Dock. Kini app apa pun bisa menjadi game, bahkan Minecraft yang berjalan di Java, dan game yang Anda tambahkan sebelumnya tetap ada.

Saklar Mode Game kini memakai kata-kata sederhana, seperti “Game tidak tertutup” atau “Pencarian tidak muncul”, dan masing-masing punya gambar kecil tentang apa yang dihentikannya. Nama di sistem, seperti Spotlight, ada di sampingnya dengan warna abu-abu.

Di Pengaturan › Jendela, klik tombol di samping “Keluar dari app” atau “Tutup jendela” lalu tekan yang baru. ⌫ mengembalikan ⇧⌘Q dan ⇧⌘W, dan jika tombolnya sudah dipakai, pikapik bertanya dulu. Mode Game juga memakai tombol Anda. Dan setiap pintasan di Pengaturan kini menunjukkan bagaimana pintasan itu benar-benar diatur di Mac Anda: tombol Anda, atau Mati.

**Coba:** Pengaturan › Game, lalu “Tambah Game…”

**Diperbaiki**

- Memotong file di Finder mengikuti pintasan Potong yang Anda atur untuk Finder di Pengaturan Sistem.
- Nama app di daftar tampil tanpa “.app”.

---

## <a id="v1.24.1"></a>Perubahan kecepatan yang langsung terlihat

<sub>1.24.1 · 8 Oktober 2026</sub>

Halaman Animasi kini memberi tahu di mana perubahan terlihat, dan menjaga nilai Anda sendiri.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

Dock hanya bisa meluncur lebih cepat jika ia bersembunyi. Jika Dock Anda selalu tampil, saklar “Sembunyikan Dock secara otomatis” kini ada tepat di bawah penggeser kecepatan.

Setelah ada perubahan, satu baris di bagian bawah halaman memberi tahu bahwa app menerapkannya setelah Anda membukanya lagi. Finder baru menampilkan kecepatan baru Lihat Cepat dan kolom setelah dimulai ulang, jadi baris itu punya tombol “Mulai Ulang Finder”.

Penggeser tidak pernah memperlambat apa yang sudah Anda percepat, misalnya dengan perintah di Terminal. Dan “Pulihkan Default” atau menghapus pikapik mengembalikan nilai yang Anda punya sebelumnya, bukan menghapusnya.

**Coba:** Pengaturan › Animasi

**Diperbaiki**

- Dock tidak lagi dimulai ulang tanpa alasan saat tidak bersembunyi.

---

## <a id="v1.24.0"></a>Pilih seberapa cepat Mac Anda bergerak

<sub>1.24.0 · 8 Oktober 2026</sub>

Halaman Animasi yang baru mengatur seberapa cepat segala sesuatu terbuka, meluncur, dan muncul di Mac Anda.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Satu penggeser sudah cukup. Geser, maka Dock yang tersembunyi, jendela baru, dialog simpan, Lihat Cepat, dan kolom di Finder menjadi lebih cepat bersama-sama, dari “Seperti di macOS” sampai “Instan”.

Ingin menyetel satu hal saja? Setiap efek punya pengaturannya sendiri, begitu juga efek minimalkan, ikon memantul di Dock, dan animasi Finder. Di samping setiap pengaturan, gambar kecil bergerak tepat dengan kecepatan yang Anda pilih.

“Pulihkan Default” hanya mengembalikan apa yang diubah pikapik, dan menghapus app ini juga begitu. Jika Anda pernah mengatur salah satu nilai ini sendiri di Terminal, pikapik menampilkannya apa adanya.

**Coba:** Pengaturan › Animasi

---

## <a id="v1.23.2"></a>Saklar untuk setiap pintasan di Mode Game

<sub>1.23.2 · 8 Oktober 2026</sub>

Kini Anda yang menentukan, satu pintasan demi satu, apa yang dibungkam Mode Game saat Anda bermain.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Q dan ⌘W kini punya saklar terpisah, begitu juga Spotlight, Siri, ⌘Tab, Mission Control, gesekan, penunjuk, layar, dan sisanya. Pilihan Anda sebelumnya tetap terbawa.

Setiap baris menunjukkan persis tombol mana yang dihentikannya, jadi Anda selalu tahu apa yang dilakukan sebuah saklar.

Pengaturan bahasa papan ketik sudah keluar dari Mode Game. ⌃Spasi dan cara lain untuk mengganti bahasa selalu berfungsi, bahkan di dalam game.

**Coba:** Pengaturan › Game

**Diperbaiki**

- Tombol dalam satu pintasan kini lebih rapat, dan ada sedikit lebih banyak ruang di antara pintasan yang berbeda, sehingga mudah melihat di mana satu berakhir dan berikutnya dimulai.

---

## <a id="v1.23.1"></a>Seberapa cepat internet Anda, dengan kata-kata sederhana

<sub>1.23.1 · 8 Oktober 2026</sub>

Tes Kecepatan memeriksa koneksi Anda dan memberi tahu dengan sederhana untuk apa koneksi itu cukup.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

Tekan “Cek Kecepatan”, dan dalam sekitar setengah menit Anda akan melihat unduh, unggah, ping, dan responsivitas. Di bawah angka-angka itu, kata-kata sederhana menjelaskan apakah cukup untuk film 4K, panggilan video, game online, dan unduhan besar.

Pemeriksaan berjalan di server Apple, dan hasil terakhir tetap ada sampai pemeriksaan berikutnya. Tes Kecepatan punya halaman sendiri di Pengaturan, satu baris di panel bar menu, dan tautan untuk app Pintasan: `pikapik://speed-test`.

Mode Game belajar dua hal. Memblokir pintasan Control kini menjadi bagiannya: di dalam game, ⌃-klik tetap klik biasa dan pintasan dengan ⌃ tidak berjalan; di tempat lain, ⌃ berfungsi seperti biasa. Dan ia mengenali Minecraft: tambahkan Minecraft Launcher atau CurseForge ke game Anda, dan Mode Game menyala saat Minecraft sendiri ada di depan.

**Coba:** Pengaturan › Tes Kecepatan, lalu “Cek Kecepatan”

**Diperbaiki**

- Versi uji pikapik yang dibuat sendiri oleh orang-orang kini menyimpan pengaturannya terpisah di iCloud Drive dan tidak lagi menyentuh pengaturan Anda.

---

## <a id="v1.23.0"></a>Mode Game: bermain tanpa gangguan

<sub>1.23.0 · 7 Oktober 2026</sub>

Tambahkan game Anda, dan Mac berhenti menarik Anda keluar darinya.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Selama Anda bermain, Spotlight, Siri, ⌘Tab, Mission Control, dan gesekan antar-desktop tidak terbuka di atas game. ⌘Q dan ⌘W tidak menutupnya tanpa sengaja, penunjuk tetap di layar game, dan layar tetap menyala.

Untuk keluar dari game, tekan ⇧⌘Q; untuk menutup jendelanya, tekan ⇧⌘W. ⌥⌘Esc selalu berfungsi. pikapik menyarankan game yang ditemukannya di Mac Anda. Mode Game mati sampai Anda menyalakannya.

Tetap Terjaga kini membiarkan Anda memilih apa yang dilakukan layar: tetap menyala, tanpa penghemat layar atau layar kunci, atau mati seperti biasa sementara Mac tetap bekerja. Tombol baru “Matikan layar sekarang” langsung menggelapkannya; gerakkan mouse atau tekan tombol untuk menyalakannya lagi.

**Coba:** Pengaturan › Game, lalu “Tambah Game…”

**Diperbaiki**

- Di Mac tanpa penutup, Tetap Terjaga tidak lagi menampilkan pilihan untuk penutup yang tertutup.

---

<p align="center"><sub>Versi sebelumnya ada di <a href="../../CHANGELOG.md">catatan perubahan</a> (dalam bahasa Inggris).</sub></p>
