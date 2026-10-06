# pika-tools

[English](../../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [Română](README.ro.md) · [Polski](README.pl.md) · [Türkçe](README.tr.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Čeština](README.cs.md) · [繁體中文](README.zh-Hant.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md) · **Bahasa Indonesia** · [Tiếng Việt](README.vi.md) · [ไทย](README.th.md)

[![Rilis terbaru](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![Lisensi: MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](../../LICENSE)
[![Unduhan](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

Aplikasi kecil untuk bar menu macOS yang membuat tombol, jendela, dan Dock lebih nyaman: memblokir pintasan Control, melindungi ⌘Q dan ⌘W, mengganti bahasa dengan Option+Shift seperti Alt+Shift di Windows, mengulang tombol yang ditahan seperti di Windows, mematikan akselerasi tetikus, menggulir roda tetikus per baris seperti di Windows, membuat tombol samping tetikus berfungsi untuk mundur dan maju, keluar dari app saat jendela terakhirnya ditutup, menyembunyikan app dengan satu klik di Dock, dan menjaga Mac Anda tetap terjaga.

## Instalasi

Dengan [Homebrew](https://brew.sh):

```bash
brew install --cask dev-pikapik/pika-tools/pika-tools && open -a pika-tools
```

Tanpa Homebrew, buka Terminal, tempel baris ini, lalu tekan Return:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

Atau unduh [pika-tools.dmg](https://github.com/dev-pikapik/pika-tools/releases/latest/download/pika-tools.dmg), buka, lalu seret app ke folder Aplikasi.

Homebrew maupun skrip sama-sama menaruh app di `/Applications`, membukanya, meminta izin, dan menyalakan “Buka saat Masuk”. Setelah itu, app memperbarui dirinya sendiri, lihat [Pembaruan](#pembaruan). Untuk menghapusnya, lihat [Hapus instalasi](#hapus-instalasi).

## Pembukaan pertama

pika-tools memerlukan dua izin. Saat pertama kali dibuka, app menampilkan pengaturan di halaman Izin yang memandu Anda langkah demi langkah, dan macOS menampilkan permintaannya sendiri. Buka **Pengaturan Sistem › Privasi & Keamanan** dan nyalakan pika-tools di:

- **Aksesibilitas**, agar app bisa mengubah tekanan tombol atau klik sebelum sampai ke app lain.
- **Pemantauan Input**, agar app bisa melihat tekanan tombol dan klik.

App mendeteksi perubahan dalam satu atau dua detik, tanpa perlu memulai ulang.

pika-tools tidak merekam, menyimpan, atau mengirim apa pun yang Anda ketik atau klik. Peristiwa diproses di memori dan langsung diteruskan. Satu-satunya permintaan jaringan adalah pemeriksaan pembaruan, yang menanyakan rilis terbaru ke GitHub.

## Fitur

**Blokir pintasan Control.** Control menjadi tombol biasa. App tetap tahu tombol itu ditekan, tetapi macOS tidak lagi mengubahnya menjadi pintasan: Control+Spasi tidak mengganti sumber input, Control+panah tidak berpindah desktop, dan Control-klik menjadi klik biasa, bukan menu pintasan. Klik kanan dan ketuk dua jari tetap bekerja seperti biasa. Berguna di game dan sesi desktop jarak jauh, tempat Control punya tugasnya sendiri.

**Lindungi ⌘Q dan ⌘W.** ⌘Q dan ⌘W saja tidak melakukan apa pun, jadi Anda tidak akan keluar dari app atau menutup jendela secara tidak sengaja. Tambahkan Shift untuk melakukannya dengan sengaja: ⇧⌘Q keluar, ⇧⌘W menutup. Berfungsi di semua app. Setiap tombol punya saklarnya sendiri. Mati secara default.

**Ganti bahasa dengan Option+Shift.** Tahan Option lalu ketuk Shift: macOS berpindah ke sumber input berikutnya. Tetap tahan Option dan ketuk Shift lagi untuk maju terus. Tahan Shift lalu ketuk Option untuk kembali. Jika di antaranya Anda menekan tombol lain, mengeklik, atau menambahkan Command, Control, atau Fn, bahasa tidak berganti, sehingga pintasan seperti Option+Shift+panah tetap bekerja seperti sebelumnya. Mati secara default.

**Ulangi tombol yang ditahan.** Tahan sebuah tombol dan hurufnya terketik berulang kali, seperti di Windows, bukan muncul menu aksen. Berguna saat bermain game dan mengetik. App yang sudah terbuka menerapkannya setelah dimulai ulang. Matikan, dan macOS kembali bekerja seperti biasa. Mati secara default.

**Matikan akselerasi penunjuk.** Penunjuk bergerak persis sejauh gerakan tetikus, secepat apa pun Anda menggerakkannya, seperti LinearMouse. Penggeser **Kecepatan melacak** mengatur seberapa cepat penunjuk bergerak. Hanya berlaku untuk tetikus, trackpad tetap seperti semula. Matikan fitur ini atau keluar dari pika-tools, dan macOS mendapatkan kembali pengaturannya sendiri. Mati secara default.

**Gulir per baris.** Setiap klik roda tetikus menggulir jumlah baris yang sama, secepat apa pun Anda memutarnya, seperti di Windows. Pilih 1 sampai 10 baris per klik, default-nya 3. Pengguliran alami tetap seperti yang Anda atur di Pengaturan Sistem. Hanya berlaku untuk tetikus, trackpad tidak berubah. Mati secara default.

Beberapa app dan game menghitung guliran dalam piksel yang tepat: untuk itu, ubah pengaturan yang sama ke piksel dan pilih 1 sampai 200 piksel per klik, bawaannya 40.

**Tombol samping untuk kembali dan maju.** Tombol tetikus 4 dan 5 berfungsi untuk mundur dan maju di Safari, Finder, dan app Apple lainnya, juga di Firefox, Opera, dan ForkLift, sama seperti usapan di trackpad. App lain, seperti IDE JetBrains, menerima tombolnya apa adanya dan menanganinya dengan cara sendiri. Jika posisi keduanya terbalik di tetikus Anda, nyalakan **Tukar tombol samping**. Mati secara default.

**Keluar saat jendela terakhir ditutup.** Tutup jendela terakhir sebuah app, dan app akan keluar, seperti di Windows. Finder tetap terbuka, begitu juga app yang punya jendela di desktop lain atau di Dock. Anda bisa membuat daftar app yang tidak boleh keluar dengan cara ini. Mati secara default.

**Sembunyikan dengan klik di Dock.** Klik ikon Dock dari app yang sedang Anda gunakan, dan app itu tersembunyi. Klik lagi untuk memunculkannya kembali. Mati secara default.

**File Baru di Finder.** Klik kanan di jendela Finder atau di desktop, pilih **File Baru**, ketik nama, dan file kosong langsung muncul, seperti New › Text Document di Windows. Bawaannya .txt. Mati secara bawaan.

Setiap alat punya saklarnya sendiri di menu dan di pengaturan. Perlu Control+C biasa lagi? Matikan alat itu.

Ikon di bar menu menunjukkan status sekilas: panah dengan klik saat alat bekerja, panah dicoret saat semuanya mati, dan segitiga peringatan saat sebuah alat menyala tetapi izinnya belum lengkap.

Anda bisa memilih baris apa saja yang tampil di panel bar menu: klik **Sesuaikan…**, hapus centang pada yang tidak Anda perlukan, lalu klik **Selesai**. Baris yang disembunyikan tetap berfungsi dan tetap ada di Pengaturan. Jika panel tidak muat di layar, panel bisa digulir.

App mengikuti bahasa sistem atau bahasa yang Anda pilih di pengaturan. Semua 23 bahasa dalam daftar di bagian atas halaman ini tersedia.

## Tetap Terjaga

Mencegah Mac masuk mode tidur saat Anda jauh dari papan ketik: untuk waktu berapa pun dari 1 menit hingga 12 bulan, atau sampai Anda mematikannya. Nyalakan dari menu, lalu atur durasinya di pengaturan dalam menit, jam, hari, minggu, atau bulan. Menu menampilkan sisa waktu dan kapan berakhir. **Biarkan layar menyala** juga mencegah layar meredup. Keluar dari pika-tools akan mengakhiri Tetap Terjaga.

Di MacBook, Anda juga bisa menyalakan **Bekerja dengan penutup tertutup**. macOS tidak punya saklar untuk ini, jadi pika-tools menjalankan `pmset -a disablesleep 1` dan meminta kata sandi administrator: hanya administrator yang bisa mengubah cara Mac tidur. Pengaturan ini kembali normal dengan sendirinya saat Tetap Terjaga berakhir, saat Anda keluar dari app, atau jika app mogok. Jika Anda tidak memasukkan kata sandi, tidak ada yang berubah. Pastikan Mac mendapat sirkulasi udara yang baik saat penutupnya tertutup. **Berhenti saat baterai di bawah 20%** mengakhiri sesi sebelum baterai habis.

Keep Awake, mode layar, dan mode layar tertutup bisa dipasang ke tombol di Pusat Kontrol, bilah menu, atau widget desktop lewat app Pintasan, dengan tautan yang kamu salin dari Pengaturan › Tetap Terjaga.

## Pengaturan

Buka pengaturan dari menu dengan **Pengaturan…** atau ⌘, atau buka lagi pika-tools dari Finder, Launchpad, atau Spotlight. Selama jendelanya terbuka, app muncul di Dock dan di ⌘Tab.

- **Umum**: buka saat masuk, tampilan (Sistem, Terang, atau Gelap), bahasa, pembaruan, dan pencadangan: ekspor dan impor pengaturan sebagai file, atau selaraskan lewat iCloud Drive.
- **Papan Ketik**: pintasan Control, ⌘Q dan ⌘W, penggantian bahasa.
- **Tetikus**: akselerasi penunjuk dan kecepatan melacak, gulir per baris, tombol samping.
- **Jendela & App**: keluar saat jendela terakhir ditutup, dengan daftar pengecualian, dan sembunyikan dengan klik di Dock.
- **Tetap Terjaga**: durasi, opsi layar dan penutup.
- **Izin**: status kedua izin, dan status iCloud Drive saat sinkronisasi menyala, dengan tombol yang membuka tempat yang tepat di Pengaturan Sistem.
- **Tentang**: versi, tautan ke catatan perubahan dan untuk melaporkan masalah.

Setiap halaman memiliki tombol **Pulihkan Default…** di bagian bawah. Tombol ini bertanya terlebih dahulu, lalu mematikan alat di halaman tersebut dan mengembalikan pilihannya, seolah pika-tools tidak pernah menyentuhnya.

**Selaraskan pengaturan dengan iCloud** menjaga pika-tools tetap sama di semua Mac Anda. Pengaturan disimpan di folder pika-tools di iCloud Drive, dan perubahan terbaru yang berlaku. Mati secara default dan memerlukan iCloud Drive yang menyala. Izin tidak ikut disinkronkan: setiap Mac memintanya sendiri.

## Pembaruan

pika-tools memeriksa versi baru saat dibuka dan setiap 6 jam. Anda bisa mematikannya di Pengaturan › Umum. Saat versi baru tersedia, tombol **Perbarui ke …** muncul di menu: satu klik, dan app mengunduh pembaruan, memasangnya, lalu memulai ulang. Anda juga bisa memeriksa sendiri dengan **Periksa Sekarang** di Pengaturan › Umum.

Dengan Homebrew, Anda juga bisa menjalankan `brew upgrade --cask pika-tools`.

Mulai versi 1.3, izin tetap ada setelah pembaruan.

## Hapus instalasi

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

Jika Anda memasang dengan Homebrew: `brew uninstall --cask --zap pika-tools`.

Keduanya keluar dari app, menghapusnya dari item masuk, dan menghapus app. Skrip juga mengatur ulang izinnya.

## Pertanyaan umum

**Mengapa perlu dua izin?**
macOS membagi akses ke papan ketik dan mouse menjadi dua. Pemantauan Input membuat app bisa melihat peristiwa, sedangkan Aksesibilitas membuatnya bisa mengubah peristiwa itu. Untuk memblokir pintasan, keduanya diperlukan.

**macOS mengatakan app berasal dari pengembang yang tidak dikenal.**
pika-tools sudah ditandatangani, tetapi tidak dinotarisasi oleh Apple. Homebrew dan skrip instalasi mengurus hal ini untuk Anda. Jika Anda memakai dmg, buka **Pengaturan Sistem › Privasi & Keamanan** dan klik **Tetap Buka**, atau jalankan:

```bash
xattr -dr com.apple.quarantine /Applications/pika-tools.app
```

**Apakah berjalan di Mac Intel?**
Ya. Ini adalah app universal untuk Apple silicon dan Intel, dengan macOS 14 Sonoma atau lebih baru.

**Izin sudah menyala, tetapi tidak ada yang bekerja.**
Di **Pengaturan Sistem › Privasi & Keamanan**, hapus pika-tools dari kedua daftar dengan tombol −, lalu tambahkan lagi. Halaman Izin di pengaturan pika-tools punya tombol yang membuka tempat yang tepat.

## Berkontribusi

Cara membangun dari kode sumber dan merilis dijelaskan di [CONTRIBUTING.md](../../CONTRIBUTING.md). Perubahan dicatat di [CHANGELOG.md](../../CHANGELOG.md).

## Lisensi

MIT, © 2026 pikapik. Lihat [LICENSE](../../LICENSE).
